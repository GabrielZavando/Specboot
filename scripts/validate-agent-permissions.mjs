#!/usr/bin/env node
// validate-agent-permissions.mjs — SPECBOOT-PERM-01 + SPECBOOT-HARDEN-02 (REQ-006)
//
// Validador de contratos de permisos de agentes OpenCode.
//
// Uso:
//   node scripts/validate-agent-permissions.mjs --root <proyecto> [--manifest <manifiesto.yml>]
//
// Semántica (SPECBOOT-HARDEN-02, REQ-006 — fiel a OpenCode):
//   - Descubre <root>/.opencode/agents/*.md y exige una entrada en el manifiesto
//     por cada archivo descubierto (y viceversa).
//   - Parsea el front matter YAML con js-yaml (nunca con búsquedas de texto).
//   - Calcula los permisos EFECTIVOS combinando defaults → globales de
//     <root>/opencode.json → bloque del agente, respetando last-match-wins dentro
//     de cada bloque (la ÚLTIMA regla que calza gana). El bloque del agente se
//     evalúa DESPUÉS del global, por lo que sobrescribe en caso de conflicto.
//   - Implementa los wildcards `*` (multi-carácter) y `?` (un carácter) conforme a
//     OpenCode; `?` NO se trata como literal.
//   - Compara el `mode` real del front matter con el manifiesto (si el manifiesto
//     lo declara).
//   - Valida `permission.task` contra el contrato de subagentes (si el manifiesto
//     declara `task`): los agentes con can_spawn_subagents=false resuelven deny
//     para cualquier subagente; build solo permite backend/frontend.
//   - Fiscaliza INDEPENDIENTEMENTE can_commit, can_push, can_manage_prs,
//     can_run_arbitrary_code y can_spawn_subagents (sin derivar push/PR de commit).
//   - Detecta bypasses: comandos compuestos que embeben un comando git de
//     escritura prohibido en un segmento no inicial. Separadores auditados,
//     con y sin espacios: `;`, `&&`, `||`, `|` y newline. NO se promete
//     cobertura pattern-based para wrappers de código arbitrario (`bash -c`,
//     `node -e`, subshells, backticks): esa capacidad queda gobernada por
//     can_run_arbitrary_code y la nota de defensa en profundidad del manifiesto.
//   - Exit 0 sin violaciones; exit 1 ante cualquier violación.
//
// Nota de distribución: vive DENTRO del paquete Specboot; js-yaml se resuelve
// desde el directorio de ESTE archivo, nunca del node_modules hoisted del
// consumidor. El manifiesto por defecto se lee desde el paquete.

import { parseArgs } from 'node:util';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { load as yamlLoad } from 'js-yaml';

const HERE = path.dirname(fileURLToPath(import.meta.url));

const PROBE_PATH = 'src/__probe__.ts';
// Nombres de subagente representativos para evaluar permission.task.
const SUBAGENT_PROBES = ['backend', 'frontend', 'verify', 'reviewer', 'commit', 'archive', 'sdd-plan', 'sync-specs'];
// Comandos git de escritura cuyo ownership NO puede escaparse por bypass compuesto.
const GIT_WRITE_OPS = ['git push', 'git commit', 'git add'];

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
// `*` comodín multi-carácter, `?` comodín de un solo carácter (nunca literal).
// El flag `s` (DOTALL) hace que `*`/`?` crucen newlines: un comando puede
// contener saltos de línea y un comodín debe matchearlos (multi-carácter).
function patternToRegex(pattern) {
  const escaped = pattern
    .replace(/[.+^${}()|[\]\\]/g, '\\$&') // escapa metacharacters (NO `*` ni `?`)
    .replace(/\*/g, '.*')
    .replace(/\?/g, '.');
  return new RegExp(`^${escaped}$`, 's');
}

// Efecto last-match-wins de un bloque (string escalar u objeto {pattern: action}).
function evaluateBlock(block, probe) {
  if (block === undefined || block === null) {
    return { action: 'default', rule: '(permiso no declarado: default OpenCode)' };
  }
  if (typeof block === 'string') {
    return { action: block, rule: `(bloque escalar: ${block})` };
  }
  if (typeof block !== 'object') {
    return { action: 'default', rule: '(bloque inválido)' };
  }
  const candidate = probe.replace(/\*/g, 'x');
  let result = null;
  for (const [pat, action] of Object.entries(block)) {
    if (patternToRegex(pat).test(candidate)) result = { action, rule: `${pat}: ${action}` };
  }
  return result ?? { action: 'default', rule: `(sin regla que calce: default, probe=${candidate})` };
}

// Combina permisos con el orden defaults → global → agente (last-match-wins).
// Devuelve un bloque estructurado {pairs: [[pat, action]...], scalar} que se
// evalúa con las entradas globales primero y del agente después.
function mergedBlock(globalBlock, agentBlock) {
  const pairs = [];
  let scalar = null;
  const addScalar = b => { if (typeof b === 'string') scalar = b; };
  const addMap = b => { if (b && typeof b === 'object') Object.entries(b).forEach(([p, a]) => pairs.push([p, a])); };
  addScalar(globalBlock); addMap(globalBlock);
  addScalar(agentBlock); addMap(agentBlock);
  if (pairs.length === 0 && scalar !== null) {
    return { kind: 'scalar', action: scalar };
  }
  return { kind: 'map', pairs, scalar };
}

// Evalúa un bloque combinado (merged) contra un probe.
function evaluateEffective(merged, probe) {
  if (merged.kind === 'scalar') return { action: merged.action, rule: '(bloque combinado escalar)' };
  const candidate = probe.replace(/\*/g, 'x');
  let result = null;
  for (const [pat, action] of merged.pairs) {
    if (patternToRegex(pat).test(candidate)) result = { action, rule: `${pat}: ${action}` };
  }
  if (result) return result;
  if (merged.scalar !== null) return { action: merged.scalar, rule: '(default del bloque combinado)' };
  return { action: 'default', rule: '(sin regla que calce: default OpenCode)' };
}

// --- Carga del front matter de un agente (YAML real, no texto) -------------
function loadAgentFrontMatter(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const m = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!m) return null;
  return yamlLoad(m[1]) ?? {};
}

// --- Permisos globales de <root>/opencode.json ------------------------------
function loadGlobalPermission() {
  const p = path.join(ROOT, 'opencode.json');
  if (!fs.existsSync(p)) return { edit: null, bash: null, task: null };
  try {
    const cfg = JSON.parse(fs.readFileSync(p, 'utf8'));
    const perm = cfg.permission || {};
    return { edit: perm.edit ?? null, bash: perm.bash ?? null, task: perm.task ?? null };
  } catch {
    return { edit: null, bash: null, task: null };
  }
}

const GLOBAL = loadGlobalPermission();

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
  const taskBlock = front.permission.task;

  // mode: comparar el mode real del front matter con el manifiesto (si se declara).
  if (contract.mode !== undefined && front.mode !== contract.mode) {
    violation(name, 'mode', `front matter mode='${front.mode}' != manifiesto mode='${contract.mode}'`);
  }

  // Permisos efectivos (defaults → global → agente).
  const effEdit = mergedBlock(GLOBAL.edit, editBlock);
  const effBash = mergedBlock(GLOBAL.bash, bashBlock);

  // edit: objetivos declarados (evaluados sobre el bloque efectivo).
  for (const target of contract.edit.allow) {
    const eff = evaluateEffective(effEdit, target);
    if (eff.action !== 'allow') violation(name, `edit.allow:${target}`, `efectivo=${eff.action} (regla: ${eff.rule})`);
  }
  for (const target of contract.edit.forbidden) {
    const eff = evaluateEffective(effEdit, target);
    if (eff.action !== 'deny') violation(name, `edit.forbidden:${target}`, `efectivo=${eff.action} (regla: ${eff.rule})`);
  }
  // edit: alcance
  const probe = evaluateEffective(effEdit, PROBE_PATH);
  if (contract.edit.mode === 'restricted' && probe.action === 'allow') {
    violation(name, `edit.scope:${PROBE_PATH}`, `ruta no declarada resulta allow (regla: ${probe.rule}) — alcance excedido`);
  }
  if (contract.edit.mode === 'implementer' && probe.action !== 'allow') {
    violation(name, `edit.scope:${PROBE_PATH}`, `agente implementador sin edición general (efectivo=${probe.action}, regla: ${probe.rule})`);
  }
  if (contract.edit.mode === 'restricted' && editBlock && typeof editBlock === 'object') {
    for (const [pat, action] of Object.entries(editBlock)) {
      if (action === 'allow' && !contract.edit.allow.includes(pat)) {
        violation(name, `edit.scope:${pat}`, `patrón allow no declarado en el manifiesto — alcance excedido`);
      }
    }
  }
  for (const ev of contract.evidence.must_write) {
    const eff = evaluateEffective(effEdit, ev);
    if (eff.action !== 'allow') violation(name, `evidence.must_write:${ev}`, `evidencia sin allow (efectivo=${eff.action}, regla: ${eff.rule})`);
  }

  // permission.task (si el manifiesto declara el contrato `task`).
  if (contract.task && Array.isArray(contract.task.allow) && Array.isArray(contract.task.forbidden)) {
    if (contract.can_spawn_subagents === true) {
      for (const sub of contract.task.allow || []) {
        const eff = evaluateEffective(mergedBlock(GLOBAL.task, taskBlock), sub);
        if (eff.action !== 'allow') violation(name, `task.allow:${sub}`, `efectivo=${eff.action} (regla: ${eff.rule})`);
      }
    }
    if (contract.can_spawn_subagents === false) {
      for (const sub of SUBAGENT_PROBES) {
        const eff = evaluateEffective(mergedBlock(GLOBAL.task, taskBlock), sub);
        if (eff.action !== 'deny') violation(name, `task.deny:${sub}`, `agente sin subagentes resuelve efectivo=${eff.action} (regla: ${eff.rule})`);
      }
    }
  }

  // bash: requeridos y prohibidos, con fiscalización independiente de flags.
  for (const entry of contract.bash.required) {
    const eff = evaluateEffective(effBash, entry);
    if (eff.action !== 'allow') violation(name, `bash.required:${entry}`, `efectivo=${eff.action} (regla: ${eff.rule})`);
  }

  const forbidden = new Set(contract.bash.forbidden || []);
  // can_commit → ownership de staging + commit.
  if (contract.can_commit === false) {
    ['git add', 'git add *', 'git commit', 'git commit *'].forEach(e => forbidden.add(e));
  }
  // can_push → push en todas sus variantes (independiente de commit).
  if (contract.can_push === false) {
    ['git push', 'git push *', 'git push --force*', 'git push --force-with-lease*', 'git push -f*', 'git push *-f*']
      .forEach(e => forbidden.add(e));
  }
  // can_manage_prs → gestión de PRs vía gh (independiente de commit).
  if (contract.can_manage_prs === false) {
    ['gh pr create *', 'gh pr edit *', 'gh pr view *', 'gh pr *'].forEach(e => forbidden.add(e));
  }
  // can_run_arbitrary_code → ejecución de código arbitrario.
  if (contract.can_run_arbitrary_code === false) {
    ['node -e *', 'python -c *', 'python3 -c *'].forEach(e => forbidden.add(e));
  }

  for (const entry of forbidden) {
    const eff = evaluateEffective(effBash, entry);
    if (eff.action !== 'deny') violation(name, `bash.forbidden:${entry}`, `efectivo=${eff.action} (regla: ${eff.rule})`);
  }

  // Bypass por comando compuesto: un git de escritura prohibido NO puede
  // escaparse embebido en un comando compuesto. Separadores auditados, con y
  // sin espacios: `;`, `&&`, `||`, `|` y newline (cobertura EXACTA — sin
  // prometer más de lo que aquí se sondea). Solo los agentes con
  // can_commit/can_push=false se fiscalizan aquí; los wrappers de código
  // arbitrario (`bash -c`, `node -e`, subshells, backticks) NO son cobertura
  // pattern-based: los gobierna can_run_arbitrary_code (ver manifiesto).
  if (contract.can_commit === false || contract.can_push === false) {
    const separators = [';', '; ', '&&', ' && ', '||', ' || ', '|', '| ', '\n', '\n '];
    for (const op of GIT_WRITE_OPS) {
      const needed = (op === 'git commit' || op === 'git add') ? contract.can_commit === false : contract.can_push === false;
      if (!needed) continue;
      for (const sep of separators) {
        const compound = `echo x${sep}${op} --force`;
        const eff = evaluateEffective(effBash, compound);
        if (eff.action !== 'deny') {
          violation(name, `bash.bypass:${op}`, `comando compuesto '${compound}' resuelve efectivo=${eff.action} (regla: ${eff.rule}) — bypass de ownership`);
        }
      }
    }
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