# Tasks: phase10-cleanup (M-906-M-907)

## Task 1 — Guard anti-regresión (RED primero) [SC-004]

- **Prioridad**: Alta
- **Capa**: framework / tests
- **Estimación**: 15 min
- **Suggested Path**: `tests/commit-gate-test.sh`
- **Test Path**: `tests/commit-gate-test.sh` (self-test; se ejecuta directamente)

Subtasks:
1. Añadir sección al final de `tests/commit-gate-test.sh` (antes del Summary):
   asserts `lacks_all` sobre `openspec/specs/adversarial-state/spec.md` para
   `the hard gate remains M-901` y `the hard gate is M-901`, etiquetados
   `[SC-004]`, categoría M-907.
2. Ejecutar `bash tests/commit-gate-test.sh` y verificar que **falla** (RED).

## Task 2 — Reescritura del wording en la spec viva [SC-003]

- **Prioridad**: Alta
- **Capa**: framework / specs
- **Estimación**: 15 min
- **Suggested Path**: `openspec/specs/adversarial-state/spec.md`
- **Test Path**: `tests/commit-gate-test.sh`

Subtasks:
1. Reescribir la requirement "archive MUST reference the adversarial verdict…"
   (línea 43) y el escenario "Archive warns without blocking…" (línea 55) con
   el texto del delta `## MODIFIED` de este change.
2. Ejecutar `bash tests/commit-gate-test.sh` → verde (GREEN).

## Task 3 — Reconciliación SemVer M-906 [SC-001, SC-002]

- **Prioridad**: Media
- **Capa**: framework / docs
- **Estimación**: 20 min
- **Suggested Path**: `docs/versioning-standard.md`
- **Test Path**: no aplica (documentación canónica; validada por
  `bash specboot.sh --ci` y revisión humana)

Subtasks:
1. Añadir a `docs/versioning-standard.md` §2 la regla "majors durante 0.x":
   roadmap `major` → release `minor` con `### Breaking changes` (y
   `### Migration` si aplica, §6.1); `major` estricto solo desde 1.0.0.
   Ejemplo: M-901 → `0.5.0`.
2. Añadir nota de reconciliación en la sección `[x] M-901` de
   `PLAN_MEJORAS_SPECBOOT.md` (referencia a `0.5.0` y a §2).

## Task 4 — Cierre administrativo y release 0.6.3 [SC-005]

- **Prioridad**: Media
- **Capa**: framework / docs + release
- **Estimación**: 25 min
- **Suggested Path**: `PLAN_MEJORAS_SPECBOOT.md`, `CHANGELOG.md`,
  `package.json`, `tests/mandatory-steps-test.sh`
- **Test Path**: `tests/mandatory-steps-test.sh` (pin de versión)

Subtasks:
1. Marcar `[x]` M-906 y M-907 con referencia a `phase10-cleanup`.
2. Corregir la frase residual de la fila v3.4 (`el gate duro sigue siendo
   M-901` → nota coherente con M-901 ya implementado).
3. Añadir fila de historial v3.9 y registrar el backlog "Fase 11" (W5
   allowlist configurable, pin dinámico de versión, `## Why` del template de
   plan-change, cómputo git canónico del staleness) — sin implementarlo.
4. Bump `package.json` → `0.6.3`; `CHANGELOG.md` `## [0.6.3]` con ambos
   tickets; pin de `tests/mandatory-steps-test.sh` 0.6.2 → 0.6.3.
5. Ejecutar suite completa: `bash check-refs.sh`, `bash specboot.sh --ci`,
   todos los `tests/*-test.sh` relevantes.

## Mandatory Steps

> **Rol de este documento**: es la **fuente única de verdad** del checklist
> obligatorio de implementación del ciclo SDD. El skill `plan-change` **inyecta
> su contenido** como sección `## Mandatory Steps` en todo `tasks.md` generado,
> leyéndolo en el momento de generación, de modo que la checklist viaja dentro
> del artefacto que el agente `build` ejecuta. Editar aquí actualiza todo
> `tasks.md` generado después; no duplicar esta lista dentro de skills ni
> agentes.

Esta checklist es **obligatoria, no sugerida**. Aplica a toda tarea de
implementación ejecutada vía `/apply`, tanto en el propio framework Specboot
(dogfooding) como en cualquier proyecto consumidor.

## Pre-implementación

Antes de escribir la primera línea de la tarea actual:

- [x] La **rama activa** sigue la convención vigente del proyecto (ej.
  `feature/*`, `fix/*`); trabajar sobre ella, nunca directamente sobre la rama
  principal.
- [x] Estado **git limpio**: sin cambios sin commitear (ni staged) antes de
  empezar; si hay trabajo en curso, resolverlo primero.

## Durante la implementación

- [x] **Test nuevo que falla antes de implementar (RED)**: escribir el test del
  escenario (`SC-NNN`) y verificar que falla antes de escribir código de
  producción.
- [x] Ejecutar los **tests unitarios del módulo** tocado mientras se itera
  (ciclo RED-GREEN-REFACTOR), no solo al final.

## Post-implementación

Antes de dar la tarea por cerrada:

- [x] **Ejecutar `verify`**: la verificación del change corre y produce
  evidencia persistente (`openspec/state/verify-results.json`).
- [x] **Ejecutar `adversarial-review`**: la auditoría adversarial corre y
  produce veredicto persistente (`openspec/state/adversarial-result.json`).

> Ambos pasos post alimentan los gates duros de `/commit` (M-901): sin
> `PASS` + `SHIP` vigentes para el change activo, el commit bloquea.
