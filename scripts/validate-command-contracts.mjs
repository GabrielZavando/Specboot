#!/usr/bin/env node
// validate-command-contracts.mjs — SPECBOOT-HARDEN-02 (REQ-007, SC-015).
//
// Valida los contratos de `.opencode/commands/*.md` desde el front matter (la
// etiqueta visual del TUI NO es prueba del agente efectivo):
//   - Todo comando DEBE declarar `agent`.
//   - Mapeos: apply->build, plan-change->sdd-plan, verify->verify, archive->archive,
//     commit->commit, adversarial-review->reviewer + subtask: true.
//
// Uso: node scripts/validate-command-contracts.mjs --root <proyecto>
// Exit 0 sin violaciones; exit 1 ante cualquier descalce.

import { parseArgs } from 'node:util';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { load as yamlLoad } from 'js-yaml';

const HERE = path.dirname(fileURLToPath(import.meta.url));

const { values } = parseArgs({ options: { root: { type: 'string' } } });
if (!values.root) { console.error('falta --root <proyecto>'); process.exit(2); }

const ROOT = path.resolve(values.root);
const commandsDir = path.join(ROOT, '.opencode', 'commands');
if (!fs.existsSync(commandsDir)) {
  console.log('Contratos de comandos OK (sin .opencode/commands)');
  process.exit(0);
}

const MAP = {
  'apply.md': 'build',
  'plan-change.md': 'sdd-plan',
  'verify.md': 'verify',
  'archive.md': 'archive',
  'commit.md': 'commit',
  'adversarial-review.md': 'reviewer',
};

const violations = [];
const files = fs.readdirSync(commandsDir).filter(f => f.endsWith('.md')).sort();
for (const f of files) {
  const content = fs.readFileSync(path.join(commandsDir, f), 'utf8');
  const m = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!m) { violations.push(`${f}: sin front matter`); continue; }
  let front;
  try { front = yamlLoad(m[1]) ?? {}; } catch { violations.push(`${f}: front matter YAML inválido`); continue; }
  if (!front.agent) { violations.push(`${f}: falta 'agent'`); continue; }
  const expected = MAP[f];
  if (expected && front.agent !== expected) {
    violations.push(`${f}: agent='${front.agent}', esperado '${expected}'`);
  }
  if (f === 'adversarial-review.md' && front.subtask !== true) {
    violations.push(`${f}: falta 'subtask: true'`);
  }
}

if (violations.length > 0) {
  console.error(`\nContratos de comandos: ${violations.length} violación(es)`);
  for (const v of violations) console.error(`  ✗ ${v}`);
  process.exit(1);
}
console.log(`Contratos de comandos OK (${files.length} comandos validados desde el front matter)`);
process.exit(0);