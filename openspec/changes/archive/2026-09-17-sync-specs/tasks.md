# Tasks: sync-specs

## Mandatory Steps

> Inyectado desde `docs/openspec-tasks-mandatory-steps.md` (fuente única de
> verdad, leído en el momento de generación).

### Pre-implementación

- [ ] La rama activa sigue la convención vigente (`feature/m-701-sync-specs`); trabajar sobre ella, nunca sobre main.
- [ ] Estado git limpio: resolver primero los cambios en curso (`PLAN_IMPLEMENTACION.md` borrado — confirmado por el mantenedor, viaja en el commit de este change — y `openspec/tickets/M-701-enriched.md` nuevo, artefacto del ciclo). Ambos pertenecen a este change; no es trabajo ajeno en curso.

### Durante la implementación

- [ ] Test nuevo que falla antes de implementar (RED): escribir el assert del escenario (`SC-NNN`) en `tests/sync-specs-test.sh` y verificar que falla antes de escribir el skill/comando.
- [ ] Ejecutar los tests del guard mientras se itera (`bash tests/sync-specs-test.sh`), no solo al final.

### Post-implementación

- [ ] Ejecutar `verify`: evidencia persistente en `openspec/state/verify-results.json`.
- [ ] Ejecutar `adversarial-review`: veredicto persistente en `openspec/state/adversarial-result.json`.

## Task 1 — Guard TDD (RED) — Prioridad: Alta — Capa: framework tooling — Estimación: S

- **Subtarea 1.1**: crear `tests/sync-specs-test.sh` con asserts `[SC-001]`..`[SC-005]` que verifiquen: existencia de `ai-specs/skills/sync-specs/SKILL.md` y `.opencode/commands/sync-specs.md`; presencia de `sync-specs` en `AGENTS.md`; reglas documentales del skill (token-light, idempotencia, MODIFIED→ADDED, único change activo, sin tocar manifest); fixtures en `ai-specs/examples/sync-specs-fixtures/` si aplica. Ejecutar y confirmar que **falla** (RED).
- Suggested Path: tests/sync-specs-test.sh
- Test Path: tests/sync-specs-test.sh (el test ES el código; dogfooding del framework)

## Task 2 — Skill sync-specs — Prioridad: Alta — Capa: framework tooling — Estimación: S

- **Subtarea 2.1**: crear `ai-specs/skills/sync-specs/SKILL.md` con el flujo: (1) detectar el change activo (listar `openspec/changes/`, premisa de uno solo); si no hay → SC-003; (2) localizar deltas en `specs/` (solo nombres de archivo, patrón token-light de `/archive`); (3) aplicar deltas a `openspec/specs/` con operaciones determinísticas de archivo (Added/Modified/Removed/Renamed; MODIFIED sobre spec inexistente = ADDED); abortar ante headers no reconocidos sin aplicación parcial; (4) idempotencia (re-sync = "sin diferencias"); (5) reporte cuantitativo resumido, nunca contenido completo; (6) nunca tocar `openspec/state/manifest.json`. Ejecutar guard hasta GREEN.
- Suggested Path: ai-specs/skills/sync-specs/SKILL.md
- Test Path: tests/sync-specs-test.sh

## Task 3 — Comando OpenCode — Prioridad: Alta — Capa: framework tooling — Estimación: XS

- **Subtarea 3.1**: crear `.opencode/commands/sync-specs.md` siguiendo el patrón de los comandos existentes (frontmatter `description` + `{file:ai-specs/skills/sync-specs/SKILL.md}` + una línea de propósito). Los comandos se autodescubren: NO añadir sección `command` a `opencode.json`.
- Suggested Path: .opencode/commands/sync-specs.md
- Test Path: tests/sync-specs-test.sh

## Task 4 — Registro en AGENTS.md — Prioridad: Media — Capa: framework tooling — Estimación: XS

- **Subtarea 4.1**: añadir `sync-specs` a la tabla §5.3 (herramientas opcionales) de `AGENTS.md`: trigger "specs principales desactualizadas durante un change largo", uso "sincroniza deltas sin archivar; token-light". Ejecutar `bash check-refs.sh` (debe pasar con 0 errores — valida que el skill aparece en AGENTS.md).
- Suggested Path: AGENTS.md
- Test Path: tests/check-refs-test.sh (guard existente) + tests/sync-specs-test.sh

## Task 5 — Verificación integral read-only — Prioridad: Alta — Capa: framework tooling — Estimación: XS

- **Subtarea 5.1**: ejecutar `bash check-refs.sh`, `bash specboot.sh --ci`, `bash validate-specboot.sh`, y `for t in tests/*-test.sh; do bash "$t"; done` — todos en verde. Si alguno falla, diagnosticar y corregir antes de dar el change por implementado.
- Suggested Path: no aplica (verificación read-only)
- Test Path: no aplica
