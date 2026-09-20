#!/usr/bin/env node
// validate-agent-permissions.mjs — SPECBOOT-PERM-01 (change agent-permission-contracts)
//
// Validador de contratos de permisos de agentes OpenCode.
//
// Uso:
//   node scripts/validate-agent-permissions.mjs --root <proyecto> [--manifest <manifiesto.yml>]
//
// Semántica:
//   - Descubre <root>/.opencode/agents/*.md y exige una entrada en el
//     manifiesto por cada archivo descubierto (y viceversa).
//   - Parsea el front matter YAML con js-yaml (nunca con búsquedas de texto).
//   - Calcula los permisos efectivos respetando la semántica last-match-wins
//     de OpenCode: la ÚLTIMA regla que calza el comando/ruta gana.
//   - Compara contra el manifiesto y reporta cada descalce con agente +
//     capacidad + regla causante.
//   - Exit 0 sin violaciones; exit 1 ante cualquier violación.
//
// Nota de distribución: este script vive DENTRO del paquete Specboot. El
// import de 'js-yaml' se resuelve desde el directorio de ESTE archivo (su
// node_modules), nunca desde el node_modules hoisted del proyecto consumidor.
// El manifiesto por defecto se lee desde el propio paquete
// (<dir del validador>/../docs/agent-permission-contracts.yml).

import { parseArgs } from 'node:util';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { load as yamlLoad } from 'js-yaml';

const HERE = path.dirname(fileURLToPath(import.meta.url));

const FORBIDDEN_WHEN_NO_COMMIT = ['git commit', 'git commit *', 'git push', 'git push *', 'gh pr create *'];
const FORBIDDEN_WHEN_NO_ARBITRARY = ['node -e *', 'python -c *', 'python3 -c *'];
const PROBE_PATH = 'src/__probe__.ts';

function failUsage(msg) {
  console.error(`error: ${msg}`);
  console.error('uso: node validate-agent-permissions.mjs --root <proyecto> [--manifest <archivo.yml>]');
  process.exit(2);
}

const { values } = parseArgs({
  options: { root: { type: 'string' }, manifest: { type: 'string' } },
});
if (!values.root) failUsage('falta --root <proyecto>');

const ROOT = path.resolve(values.root);
const MANIFEST_PATH = values.manifest
  ? path.resolve(values.manifest)
  : path.join(HERE, '..', 'docs', 'agent-permission-contracts.yml');

if (!fs.existsSync(MANIFEST_PATH)) failUsage(`manifiesto no encontrado: ${MANIFEST_PATH}`);

let manifest;
try {
  manifest = yamlLoad(fs.readFileSync(MANIFEST_PATH, 'utf8'));
} catch (e) {
  console.error(`error: no se pudo parsear el manifiesto (${e.message})`);
  process.exit(2);
}
if (!manifest || typeof manifest !== 'object' || typeof manifest.agents !== 'object' || manifest.agents === null) {
  failUsage('manifiesto inválido: falta la clave agents');
}

// --- Semántica de patrones OpenCode ----------------------------------------
// Convierte un patrón de permiso en RegExp anclado: '*' actúa como comodín.
function patternToRegex(pattern) {
  const escaped = pattern.replace(/[.+?^${}()|[\]\\]/g, '\\$&').replace(/\*/g, '.*');
  return new RegExp(`^${escaped}$`);
}

// Calcula el efecto last-match-wins de un bloque de permiso sobre un caso.
// block puede ser: string ('allow'|'deny'|'ask') u objeto {pattern: action}.
// candidate se genera sustituyendo '*' por 'x' (comando/ruta representativa).
function evaluateBlock(block, probe) {
  if (block === undefined || block === null) {
    return { action: 'deny', rule: '(permiso ausente: deny implícito)' };
  }
  if (typeof block === 'string') {
    return { action: block, rule: `(bloque escalar: ${block})` };
  }
  if (typeof block !== 'object') {
    return { action: 'deny', rule: '(bloque inválido)' };
  }
  const candidate = probe.replace(/\*/g, 'x');
  let result = null;
  for (const [pat, action] of Object.entries(block)) {
    if (patternToRegex(pat).test(candidate)) result = { action, rule: `${pat}: ${action}` };
  }
  return result ?? { action: 'default', rule: '(sin regla que calce: deny por defecto)' };
}

// --- Carga del front matter de un agente (YAML real, no texto) -------------
function loadAgentFrontMatter(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const m = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!m) return null;
  return yamlLoad(m[1]) ?? {};
}

const violations = [];
function violation(agent, capability, detail) {
  violations.push({ agent, capability, detail });
}

// --- Descubrimiento de agentes y cobertura del manifiesto ------------------
const agentsDir = path.join(ROOT, '.opencode', 'agents');
const discovered = fs.existsSync(agentsDir)
  ? fs.readdirSync(agentsDir).filter(f => f.endsWith('.md')).map(f => f.slice(0, -3)).sort()
  : [];

for (const name of discovered) {
  if (!manifest.agents[name]) {
    violation(name, 'manifest.coverage', `agente descubierto sin entrada en el manifiesto (${MANIFEST_PATH})`);
  }
}
for (const name of Object.keys(manifest.agents)) {
  if (!discovered.includes(name)) {
    violation(name, 'manifest.coverage', 'entrada del manifiesto sin archivo en .opencode/agents/');
  }
}

// --- Validación por agente --------------------------------------------------
for (const name of discovered) {
  const contract = manifest.agents[name];
  if (!contract) continue;

  const front = loadAgentFrontMatter(path.join(agentsDir, `${name}.md`));
  if (!front || typeof front.permission === 'undefined') {
    violation(name, 'front-matter', 'front matter ausente o sin clave permission');
    continue;
  }
  const editBlock = front.permission.edit;
  const bashBlock = front.permission.bash;

  // edit: objetivos declarados
  for (const target of contract.edit.allow) {
    const eff = evaluateBlock(editBlock, target);
    if (eff.action !== 'allow') violation(name, `edit.allow:${target}`, `efectivo=${eff.action} (regla: ${eff.rule})`);
  }
  for (const target of contract.edit.forbidden) {
    const eff = evaluateBlock(editBlock, target);
    if (eff.action !== 'deny') violation(name, `edit.forbidden:${target}`, `efectivo=${eff.action} (regla: ${eff.rule})`);
  }
  // edit: alcance
  const probe = evaluateBlock(editBlock, PROBE_PATH);
  if (contract.edit.mode === 'restricted' && probe.action === 'allow') {
    violation(name, `edit.scope:${PROBE_PATH}`, `ruta no declarada resulta allow (regla: ${probe.rule}) — alcance excedido`);
  }
  if (contract.edit.mode === 'implementer' && probe.action !== 'allow') {
    violation(name, `edit.scope:${PROBE_PATH}`, `agente implementador sin edición general (efectivo=${probe.action}, regla: ${probe.rule})`);
  }
  if (contract.edit.mode === 'restricted' && editBlock && typeof editBlock === 'object') {
    // CA-009: ningún allow explícito puede quedar fuera del alcance del manifiesto.
    for (const [pat, action] of Object.entries(editBlock)) {
      if (action === 'allow' && !contract.edit.allow.includes(pat)) {
        violation(name, `edit.scope:${pat}`, `patrón allow no declarado en el manifiesto — alcance excedido`);
      }
    }
  }
  for (const ev of contract.evidence.must_write) {
    const eff = evaluateBlock(editBlock, ev);
    if (eff.action !== 'allow') violation(name, `evidence.must_write:${ev}`, `evidencia sin allow (efectivo=${eff.action}, regla: ${eff.rule})`);
  }

  // bash: requeridos y prohibidos declarados
  for (const entry of contract.bash.required) {
    const eff = evaluateBlock(bashBlock, entry);
    if (eff.action !== 'allow') violation(name, `bash.required:${entry}`, `efectivo=${eff.action} (regla: ${eff.rule})`);
  }
  const forbidden = new Set(contract.bash.forbidden);
  if (contract.can_commit === false) FORBIDDEN_WHEN_NO_COMMIT.forEach(e => forbidden.add(e));
  if (contract.can_run_arbitrary_code === false) FORBIDDEN_WHEN_NO_ARBITRARY.forEach(e => forbidden.add(e));
  for (const entry of forbidden) {
    const eff = evaluateBlock(bashBlock, entry);
    if (eff.action !== 'deny') violation(name, `bash.forbidden:${entry}`, `efectivo=${eff.action} (regla: ${eff.rule})`);
  }
}

// --- Reporte ----------------------------------------------------------------
if (violations.length > 0) {
  console.error(`\nContratos de permisos: ${violations.length} violación(es)`);
  for (const v of violations) {
    console.error(`  ✗ agent=${v.agent} capability=${v.capability}`);
    console.error(`    rule: ${v.detail}`);
  }
  process.exit(1);
}
console.log(`Contratos de permisos OK (${discovered.length} agentes validados contra el manifiesto)`);
process.exit(0);
