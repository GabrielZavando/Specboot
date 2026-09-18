# Tasks: fix-agent-permissions

## Mandatory Steps

> Inyectado desde `docs/openspec-tasks-mandatory-steps.md` (fuente única de
> verdad, leído en el momento de generación).

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

- **Subtarea 1.1**: extender `tests/agent-permissions-test.sh` con asserts
  `[SC-001]`..`[SC-005]` para los nuevos requisitos (allowlist del primario en
  `opencode.json`: `bash tests/*`, `bash scripts/*`, `bash check-refs.sh`,
  `bash specboot.sh *`, `bash validate-specboot.sh`, `node *`, `mkdir *`,
  `date *`, `gh *`, `python3 *`; `rm -rf *`/`find`/`sed` en ask; agente
  `sync-specs` con `agent:` en el comando y permission block acotado; verify con
  `bash tests/*`/`bash scripts/*`/`node -e *`/`date *`; archive con
  `rm -f openspec/tickets/*`). Ejecutar y confirmar que **falla** (RED).
- Suggested Path: tests/agent-permissions-test.sh
- Test Path: tests/agent-permissions-test.sh (el test ES el código; dogfooding)

## Task 2 — Allowlist del agente primario — Prioridad: Alta — Capa: framework tooling — Estimación: S

- **Subtarea 2.1**: en `opencode.json`, añadir al permission block bash los
  patrones allow de rutina: `"bash tests/*"`, `"bash scripts/*"`,
  `"bash check-refs.sh"`, `"bash specboot.sh *"`, `"bash validate-specboot.sh"`,
  `"node *"`, `"mkdir *"`, `"date *"`, `"gh *"`, `"python3 *"` — manteniendo
  `"rm -rf *": "ask"` y el fallback `"*": "ask"`. Ejecutar el guard hasta GREEN.
- Suggested Path: opencode.json
- Test Path: tests/agent-permissions-test.sh

## Task 3 — Agente dedicado sync-specs — Prioridad: Alta — Capa: framework tooling — Estimación: S

- **Subtarea 3.1**: crear `.opencode/agents/sync-specs.md` (mode: primary,
  permissions: edit `openspec/**` allow + `"*": deny`; bash: `openspec *`,
  `git status`/`git diff` con variantes, `ls *`, `cat *`, `"*": deny`) con rol
  mínimo y referencia `{file:ai-specs/skills/sync-specs/SKILL.md}` (patrón
  reviewer.md → skill).
- **Subtarea 3.2**: añadir `agent: sync-specs` al frontmatter de
  `.opencode/commands/sync-specs.md`.
- Suggested Path: .opencode/agents/sync-specs.md
- Test Path: tests/agent-permissions-test.sh

## Task 4 — Sync rol↔permisos verify y archive — Prioridad: Alta — Capa: framework tooling — Estimación: S

- **Subtarea 4.1**: en `.opencode/agents/verify.md` añadir `"bash tests/*"`,
  `"bash scripts/*"`, `"node -e *"`, `"date *"` como allow; sincronizar
  `ai-specs/agents/verify-agent.md` (sección "Bash permitido" documenta tests
  bash del framework — dogfooding — y `node -e`/`date`).
- **Subtarea 4.2**: en `.opencode/agents/archive.md` añadir
  `"rm -f openspec/tickets/*"` como allow; en
  `ai-specs/skills/archive/SKILL.md` mandar tick de checkboxes del Mandatory
  Steps vía edit tool (acotada a `openspec/**`) en vez de `sed -i`.
- Suggested Path: .opencode/agents/verify.md
- Test Path: tests/agent-permissions-test.sh

## Task 5 — Verificación integral read-only — Prioridad: Alta — Capa: framework tooling — Estimación: XS

- **Subtarea 5.1**: ejecutar `bash check-refs.sh`, `bash specboot.sh --ci`,
  `bash validate-specboot.sh` y `for t in tests/*-test.sh; do bash "$t"; done`
  — todos en verde. Si alguno falla, diagnosticar y corregir antes de dar el
  change por implementado.
- Suggested Path: no aplica (verificación read-only)
- Test Path: no aplica
