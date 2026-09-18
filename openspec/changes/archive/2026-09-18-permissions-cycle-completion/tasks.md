# Tasks: permissions-cycle-completion

## Mandatory Steps

> Inyectado desde `docs/openspec-tasks-mandatory-steps.md` (fuente única de
> verdad, leída en el momento de generación). **Regla vigente (M-909):** el
> agente build marca cada checkbox `[x]` vía edit tool en cuanto satisface el
> paso.

### Pre-implementación

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

## Task 1 — Guard TDD (RED) — Prioridad: Alta — Capa: framework tooling — Estimación: S

- **Subtarea 1.1**: extender `tests/agent-permissions-test.sh` con asserts:
  `archive.md` con `"mkdir -p openspec/*": allow`; `tests/run-all.sh` existe y
  es ejecutable (loop de todos los tests); `opencode.json` con
  `"bash check-refs.sh *"`; `framework-contract.md` con el trust model
  (tokens `node *`/`python3 *` + "trust model"). Ejecutar y confirmar **RED**.
- **Subtarea 1.2**: extender `tests/commit-gate-test.sh` con asserts del
  staleness configurable (skill `commit` con token `stalenessPaths`, fallback
  documentado, comando canónico git) + fixture actualizado en
  `ai-specs/examples/commit-gate-fixtures/`. Ejecutar y confirmar **RED**.
- Suggested Path: tests/agent-permissions-test.sh
- Test Path: tests/agent-permissions-test.sh + tests/commit-gate-test.sh

## Task 2 — Permisos archive + opencode.json — Prioridad: Alta — Capa: framework tooling — Estimación: XS

- **Subtarea 2.1**: en `.opencode/agents/archive.md` añadir
  `"mkdir -p openspec/*": allow`.
- **Subtarea 2.2**: en `opencode.json` añadir `"bash check-refs.sh *": "allow"`.
  Ejecutar guard hasta GREEN en los asserts de permisos.
- Suggested Path: .opencode/agents/archive.md
- Test Path: tests/agent-permissions-test.sh

## Task 3 — Runner canónico — Prioridad: Alta — Capa: framework tooling — Estimación: S

- **Subtarea 3.1**: crear `tests/run-all.sh` (loop de todos los
  `tests/*-test.sh`, exit 1 si alguno falla, resumen final). Ejecutar
  `bash tests/run-all.sh` hasta GREEN.
- Suggested Path: tests/run-all.sh
- Test Path: tests/run-all.sh + tests/agent-permissions-test.sh

## Task 4 — W5: stalenessPaths configurable — Prioridad: Alta — Capa: framework tooling — Estimación: M

- **Subtarea 4.1**: en `.specboot.json` (y su standard `docs/specboot-json-standard.md`)
  añadir el campo opcional `"stalenessPaths"`; `validate-specboot.sh` lo valida
  (array de strings cuando presente).
- **Subtarea 4.2**: en `ai-specs/skills/commit/SKILL.md` (Step 2, regla 2)
  reescribir el staleness: lectura token-light de `stalenessPaths` vía
  `node -e` con fallback al default + comando canónico git documentado.
- **Subtarea 4.3**: fixture del commit-gate actualizado
  (`ai-specs/examples/commit-gate-fixtures/` con caso configurable). Guard
  `tests/commit-gate-test.sh` hasta GREEN.
- Suggested Path: ai-specs/skills/commit/SKILL.md
- Test Path: tests/commit-gate-test.sh + tests/agent-permissions-test.sh

## Task 5 — Trust model documentado — Prioridad: Media — Capa: framework tooling — Estimación: XS

- **Subtarea 5.1**: en `docs/framework-contract.md` documentar el trust model
  bash del primario (`node *`/`python3 *` = ejecución arbitraria, consistente
  con `npm *`/`npx *`; decisión aceptada y documentada).
- Suggested Path: docs/framework-contract.md
- Test Path: tests/agent-permissions-test.sh

## Task 6 — Verificación integral read-only — Prioridad: Alta — Capa: framework tooling — Estimación: XS

- **Subtarea 6.1**: ejecutar `bash check-refs.sh`, `bash specboot.sh --ci`,
  `bash validate-specboot.sh` y `bash tests/run-all.sh` — todos en verde. Si
  alguno falla, diagnosticar y corregir antes de dar el change por implementado.
- Suggested Path: no aplica (verificación read-only)
- Test Path: no aplica
