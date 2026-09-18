# Tasks: cycle-hygiene

## Mandatory Steps

> Inyectado desde `docs/openspec-tasks-mandatory-steps.md` (fuente única de
> verdad, leído en el momento de generación). **Regla vigente (M-909):** el
> agente build marca cada checkbox `[x]` vía edit tool en cuanto satisface el
> paso — el tick ocurre en `/apply`, no en `/archive`.

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

- **Subtarea 1.1**: extender `tests/mandatory-steps-test.sh` con asserts para
  REQ-001 (build-agent.md documenta el tick vía edit tool al satisfacer cada
  paso), REQ-002 (archive skill declara a `/apply` como dueño canónico del
  tick), REQ-003 (PLAN_MEJORAS: `## [x] M-701`, `## [x] M-908`, fila de
  historial). Ejecutar y confirmar **RED**.
- **Subtarea 1.2**: crear `tests/plan-proposal-test.sh` (guard nuevo) que
  aserte que el skill `plan-change` declara las secciones `## Why` y
  `## What Changes` en su template de proposal y las valida en su Step 6.
  Ejecutar y confirmar **RED**.
- Suggested Path: tests/mandatory-steps-test.sh
- Test Path: tests/mandatory-steps-test.sh + tests/plan-proposal-test.sh

## Task 2 — Tick canónico en /apply — Prioridad: Alta — Capa: framework tooling — Estimación: S

- **Subtarea 2.1**: en `ai-specs/agents/build-agent.md` añadir el paso de
  marcar cada checkbox del Mandatory Steps vía edit tool en el momento en que
  se satisface (pre/durante/post), dejando `tasks.md` sin checkboxes abiertas
  al cerrar `/apply`. Ejecutar guards hasta GREEN.
- Suggested Path: ai-specs/agents/build-agent.md
- Test Path: tests/mandatory-steps-test.sh

## Task 3 — Archive defensivo — Prioridad: Media — Capa: framework tooling — Estimación: XS

- **Subtarea 3.1**: en `ai-specs/skills/archive/SKILL.md` reescribir la regla de
  checkboxes del Step 2: `/apply` es el dueño canónico del tick; archive solo
  cubre restos satisfechos vía edit tool (nunca `sed -i`) y aborta ante tareas
  genuinas pendientes. Mantener el token "edit tool" (lo aserte el guard de
  agent-permissions). El resto de asserts existentes deben seguir en verde.
- Suggested Path: ai-specs/skills/archive/SKILL.md
- Test Path: tests/mandatory-steps-test.sh + tests/agent-permissions-test.sh

## Task 4 — Registro del roadmap — Prioridad: Media — Capa: framework tooling — Estimación: S

- **Subtarea 4.1**: en `PLAN_MEJORAS_SPECBOOT.md`: marcar `## [x] M-701`
  (Fase 7), añadir sección `## [x] M-908` (patrón M-403: SemVer `minor`,
  dependencias M-701, resultado resumido) y fila de historial del ciclo
  (M-701 + M-908 + M-909). Nota explícita del toil del pin resuelto (ítem 2 del
  backlog Fase 11 ya cubierto por asserts dinámicos).
- Suggested Path: PLAN_MEJORAS_SPECBOOT.md
- Test Path: tests/mandatory-steps-test.sh

## Task 5 — Template de proposal — Prioridad: Media — Capa: framework tooling — Estimación: S

- **Subtarea 5.1**: en `ai-specs/skills/plan-change/SKILL.md` añadir `## Why` y
  `## What Changes` al template de `proposal.md` (Step 5, artefacto 1) y la
  validación de su presencia al checklist del Step 6. Ejecutar
  `bash tests/plan-proposal-test.sh` hasta GREEN.
- Suggested Path: ai-specs/skills/plan-change/SKILL.md
- Test Path: tests/plan-proposal-test.sh

## Task 6 — Verificación integral read-only — Prioridad: Alta — Capa: framework tooling — Estimación: XS

- **Subtarea 6.1**: ejecutar `bash check-refs.sh`, `bash specboot.sh --ci`,
  `bash validate-specboot.sh` y todos los `tests/*-test.sh` — en verde. Si
  alguno falla, diagnosticar y corregir antes de dar el change por implementado.
- Suggested Path: no aplica (verificación read-only)
- Test Path: no aplica
