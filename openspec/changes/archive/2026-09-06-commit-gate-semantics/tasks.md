# Tasks: commit-gate-semantics (M-904-M-905)

## 1. Semántica de staleness y gramática del trailer (TDD primero)

- [x] 1.1 Extender `tests/commit-gate-test.sh` con los asserts nuevos (RED): asertar en `ai-specs/skills/commit/SKILL.md` los marcadores de la semántica de staleness — evidencia stale solo por commits posteriores que tocan rutas de código (`src/`, `app/`, `tests/`, `ai-specs/`, `.opencode/`), commits solo de docs/`openspec/` no ensucian, warn-only con mensaje preciso `[SC-001][SC-002]`; la gramática EBNF del trailer (orden fijo `verify`/`adversarial`, enums cerrados) y la regex canónica documentadas `[SC-004]`; la nota last-write-wins en `commit`, `verify` y `code-auditing` `[SC-003]`; y la validación de la regex: matchea el ejemplo canónico y rechaza counter-examples (orden invertido, valor fuera del enum) `[SC-005]`. Debe fallar (RED) antes de 1.2. Prioridad: alta. Layer: tests. Estimación: S.
  - **Suggested Path**: `tests/commit-gate-test.sh`
  - **Test Path**: `tests/commit-gate-test.sh` (es el propio guard)

- [x] 1.2 Reescribir el bloque de staleness del Step 2 de `ai-specs/skills/commit/SKILL.md` (GREEN): reemplazar la comparación genérica contra `git log -1 --format=%cI` por la regla formal — stale si existe commit posterior al `timestamp` de la evidencia tocando rutas de código (`src/`, `app/`, `tests/`, `ai-specs/`, `.opencode/`); commits solo de `docs/`/`openspec/` no ensucian; warn-only con mensaje preciso que declara la regla y sugiere re-ejecutar la herramienta; nunca bloquea. Añadir la nota last-write-wins (cada ejecución sobrescribe su archivo de estado; el gate lee la corrida más reciente). Prioridad: alta. Layer: docs (skill). Estimación: S.
  - **Suggested Path**: `ai-specs/skills/commit/SKILL.md`
  - **Test Path**: `tests/commit-gate-test.sh`

- [x] 1.3 Documentar la gramática del trailer `Gate-Bypass` en el Step 6 de `ai-specs/skills/commit/SKILL.md` (GREEN): EBNF con orden fijo `verify=` antes de `adversarial=`, separador exacto `; `, enums cerrados (`PASS|PARTIAL|FAIL|missing` / `SHIP|NO-SHIP|missing`) y regex canónica `^Gate-Bypass: --force \(verify=(PASS|PARTIAL|FAIL|missing); adversarial=(SHIP|NO-SHIP|missing)\)$` para tooling externo. Prioridad: alta. Layer: docs (skill). Estimación: S.
  - **Suggested Path**: `ai-specs/skills/commit/SKILL.md`
  - **Test Path**: `tests/commit-gate-test.sh`

- [x] 1.4 Añadir la nota last-write-wins en `ai-specs/skills/verify/SKILL.md` (Step 8) y `ai-specs/skills/code-auditing/SKILL.md` (Paso 7): cada ejecución sobrescribe su archivo de estado; prevalece la corrida más reciente. Prioridad: media. Layer: docs (skill). Estimación: XS.
  - **Suggested Path**: `ai-specs/skills/verify/SKILL.md`, `ai-specs/skills/code-auditing/SKILL.md`
  - **Test Path**: `tests/commit-gate-test.sh`

- [x] 1.5 Ejecutar `bash tests/commit-gate-test.sh` hasta verde completo (sin debilitar asserts previos de M-901) y `bash check-refs.sh`. Prioridad: alta. Layer: tests. Estimación: XS.
  - **Suggested Path**: `tests/commit-gate-test.sh`
  - **Test Path**: `tests/commit-gate-test.sh`

## 2. Delta de spec consolidada + cierre del roadmap

- [x] 2.1 Verificar que el delta `specs/commit-gates/spec.md` de este change refleja exactamente lo implementado (MODIFIED: staleness git-based warn-only + gramática EBNF/regex; ADDED: prevalencia last-write-wins) — lo materializa `/archive`. Prioridad: media. Layer: docs. Estimación: XS.
  - **Suggested Path**: `openspec/changes/commit-gate-semantics/specs/commit-gates/spec.md`
  - **Test Path**: no aplica (lo valida `openspec validate`)

- [x] 2.2 Cerrar el roadmap en `PLAN_MEJORAS_SPECBOOT.md`: marcar `[x]` M-904 y M-905 y añadir fila de historial **v3.8** con lo entregado (semántica de staleness git-based warn-only, gramática EBNF + regex canónica del trailer, last-write-wins documentado, guard extendido) — v3.7 ya la ocupó M-403 (`sync-agent-permissions`). M-906/M-907 permanecen pendientes. Bump `0.6.1` → `0.6.2` (`package.json`, `.specboot.json`) + entrada `## [0.6.2]` en `CHANGELOG.md` (patch, sin `### Breaking changes`). Prioridad: media. Layer: docs. Estimación: S.
  - **Suggested Path**: `PLAN_MEJORAS_SPECBOOT.md`, `package.json`, `.specboot.json`, `CHANGELOG.md`
  - **Test Path**: no aplica (lo valida `specboot.sh --ci`)

- [x] 2.3 Ejecutar `openspec validate commit-gate-semantics` y `bash specboot.sh --ci` hasta 0 errores antes de `/verify`. Prioridad: alta. Layer: docs. Estimación: XS.
  - **Suggested Path**: no aplica (validación)
  - **Test Path**: no aplica (validación)

## Mandatory Steps

> **Rol de esta sección**: checklist obligatoria del ciclo SDD, inyectada por
> `plan-change` desde `docs/openspec-tasks-mandatory-steps.md` (fuente única
> de verdad). Es **obligatoria, no sugerida** y aplica a toda tarea de
> implementación ejecutada vía `/apply`.

### Pre-implementación

Antes de escribir la primera línea de la tarea actual:

- [x] La **rama activa** sigue la convención vigente del proyecto (ej.
  `feature/*`, `fix/*`); trabajar sobre ella, nunca directamente sobre la rama
  principal.
- [x] Estado **git limpio**: sin cambios sin commitear (ni staged) antes de
  empezar; si hay trabajo en curso, resolverlo primero.

### Durante la implementación

- [x] **Test nuevo que falla antes de implementar (RED)**: escribir el test del
  escenario (`SC-NNN`) y verificar que falla antes de escribir código de
  producción.
- [x] Ejecutar los **tests unitarios del módulo** tocado mientras se itera
  (ciclo RED-GREEN-REFACTOR), no solo al final.

### Post-implementación

Antes de dar la tarea por cerrada:

- [x] **Ejecutar `verify`**: la verificación del change corre y produce
  evidencia persistente (`openspec/state/verify-results.json`).
- [x] **Ejecutar `adversarial-review`**: la auditoría adversarial corre y
  produce veredicto persistente (`openspec/state/adversarial-result.json`).
