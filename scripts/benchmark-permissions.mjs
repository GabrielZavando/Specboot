#!/usr/bin/env node
// benchmark-permissions.mjs — SPECBOOT-PREC-01 (REQ-007, change permission-baseline)
//
// Auxiliar SEMIMANUAL del benchmark de línea base. Ejecuta los validadores de
// permisos existentes, mide su duración real y reporta el resultado. NO es un
// orquestador de benchmarks automatizado: eso corresponde al ticket final
// SPECBOOT-REL-01. Las métricas del ciclo (/adversarial-review, /archive) se
// asientan manualmente en la plantilla de registro
// (openspec/state/benchmark/registro-inicial.md).
//
// Política de métricas (REQ-006): solo `aproximación_de_volumen`
// (bytes/caracteres de prompts y respuestas). NUNCA calcular ni estimar tokens
// matemáticamente: los agentes no tienen permisos para consultar APIs de
// billing/usage del proveedor externo.
//
// Uso: node scripts/benchmark-permissions.mjs [--root <proyecto>]
// Exit 0 si todos los validadores pasan; exit 1 ante cualquier fallo.

import { parseArgs } from 'node:util';
import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));

const { values } = parseArgs({ options: { root: { type: 'string' } } });
const ROOT = path.resolve(values.root ?? path.join(HERE, '..'));

// Validadores de permisos existentes (reutilización — SPECBOOT-PREC-01).
const VALIDATORS = [
  {
    name: 'validate-agent-permissions',
    script: 'scripts/validate-agent-permissions.mjs',
    args: ['--root', ROOT],
  },
  {
    name: 'validate-command-contracts',
    script: 'scripts/validate-command-contracts.mjs',
    args: ['--root', ROOT],
  },
];

let failures = 0;
for (const v of VALIDATORS) {
  const startedAt = process.hrtime.bigint();
  const result = spawnSync(process.execPath, [path.join(HERE, '..', v.script), ...v.args], {
    encoding: 'utf8',
  });
  const durationMs = Number(process.hrtime.bigint() - startedAt) / 1e6;
  const passed = result.status === 0;
  if (!passed) failures += 1;
  console.log(`${passed ? 'PASS' : 'FAIL'} ${v.name} — duración ${durationMs.toFixed(1)} ms (exit ${result.status})`);
  if (result.stdout && result.stdout.trim()) console.log(result.stdout.trim());
  if (result.stderr && result.stderr.trim()) console.error(result.stderr.trim());
}

console.log('');
console.log('Benchmark semimanual (SPECBOOT-PREC-01): los tiempos del ciclo (/adversarial-review, /archive)');
console.log('se asientan manualmente en openspec/state/benchmark/registro-inicial.md, etiquetados como');
console.log('aproximación_de_volumen. Nunca calcular o estimar tokens matemáticamente.');
console.log('El orquestador automatizado corresponde a SPECBOOT-REL-01.');

process.exit(failures > 0 ? 1 : 0);
