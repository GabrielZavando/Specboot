# Tasks: docs-followups

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

- **Subtarea 1.1**: extender `tests/mandatory-steps-test.sh` con asserts
  `[SC-001]`..`[SC-005]` de M-801/M-910/F-harness: `docs/consumer-git-workflow.md`
  existe con GitHub Flow + nota opcional; `framework-contract.md` y `README.md`
  lo referencian; `verify`/`code-auditing` skills documentan el handoff del
  tick; PLAN_MEJORAS con `## [x] M-801`, `## [x] M-910`, fila de historial y
  nota F-harness. Ejecutar y confirmar **RED**.
- Suggested Path: tests/mandatory-steps-test.sh
- Test Path: tests/mandatory-steps-test.sh (el test ES el código; dogfooding)

## Task 2 — docs/consumer-git-workflow.md (M-801) — Prioridad: Alta — Capa: framework tooling — Estimación: S

- **Subtarea 2.1**: crear `docs/consumer-git-workflow.md` con el contenido
  GitHub Flow de M-801 (ramas, PRs, semver, hotfix, nota opcional) **sin tocar**
  `docs/git-workflow-standards.md`. Ejecutar guards hasta GREEN.
- Suggested Path: docs/consumer-git-workflow.md
- Test Path: tests/mandatory-steps-test.sh

## Task 3 — Referencias + handoff del tick (M-910) — Prioridad: Alta — Capa: framework tooling — Estimación: S

- **Subtarea 3.1**: referenciar `docs/consumer-git-workflow.md` desde
  `docs/framework-contract.md` (sección de docs/workflows) y `README.md`
  (personalización).
- **Subtarea 3.2**: en `ai-specs/skills/verify/SKILL.md` (Step 8) y
  `ai-specs/skills/code-auditing/SKILL.md` (Paso 7) añadir el handoff del tick
  (orquestador marca; subagente read-only no).
- Suggested Path: ai-specs/skills/verify/SKILL.md
- Test Path: tests/mandatory-steps-test.sh

## Task 4 — Roadmap + F-harness — Prioridad: Media — Capa: framework tooling — Estimación: S

- **Subtarea 4.1**: en `PLAN_MEJORAS_SPECBOOT.md`: marcar `## [x] M-801`,
  añadir `## [x] M-910` (SemVer `patch`, dependencias M-909/F1-reviewer,
  resultado) y nota F-harness evaluada (síntomas → fuera del repo → sin acción,
  mitigaciones: sesiones cortas + reintentos). Fila de historial.
- Suggested Path: PLAN_MEJORAS_SPECBOOT.md
- Test Path: tests/mandatory-steps-test.sh

## Task 5 — Verificación integral read-only — Prioridad: Alta — Capa: framework tooling — Estimación: XS

- **Subtarea 5.1**: ejecutar `bash check-refs.sh`, `bash specboot.sh --ci`,
  `bash validate-specboot.sh` y todos los `tests/*-test.sh`; confirmar
  `git diff origin/main -- docs/git-workflow-standards.md` vacío. Corregir
  desvíos antes de dar el change por implementado.
- Suggested Path: no aplica (verificación read-only)
- Test Path: no aplica
