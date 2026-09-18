# Proposal: docs-followups

**Ticket ID**: M-801 + M-910
**Título original**: [docs] Resoluciós de follow-ups: estrategia Git para consumidores (M-801), tick-post (M-910) y registro F-harness
**Tag**: docs (framework tooling, sin código de producto)
**Origen**: Backlog Fase 11/12 del roadmap + hallazgo F1 del adversarial-review de M-909 (patrón M-403)

## Why

Al cerrar el ciclo M-701/M-908/M-909 quedaron tres pendientes registrados:

1. **M-801 (Fase 8 del roadmap, pendiente desde su creación)**: `docs/git-workflow-standards.md` gobierna el desarrollo interno del framework (rama por ticket, local-first) pero no dice nada sobre qué estrategia Git recomendar a un **proyecto consumidor**. Falta `docs/consumer-git-workflow.md` (GitHub Flow, explícitamente opcional) con referencias desde `framework-contract.md` y `README.md`, sin tocar el estándar interno (intocable).
2. **M-910 (nuevo, del adversarial-review de M-909 — hallazgo F1)**: el invariante "0 checkboxes abiertas al cerrar `/apply`" es inalcanzable para los 2 pasos post (verify/adversarial corren después de `/apply`) porque los skills `verify` y `code-auditing` no documentan el handoff del tick. Corrección: documentar que el agente orquestador (build/primario) marca la checkbox al validar la evidencia, y que el subagente no la marca (read-only). Sin cambios de permisos.
3. **F-harness (investigación del entorno)**: durante M-908/M-909 el entorno OpenCode degradó tool calls (write rechazado por schema, subagente reviewer cancelado, bucles de read). Investigación: son defectos del entorno/harness, no de la configuración del repo (los permission blocks de M-908 ya eliminaron la fricción repo-side). Se registra como **evaluado — sin acción en el repo**, con mitigación operativa (sesiones cortas, reintentos tras mensaje del usuario).

## What Changes

- Nuevo `docs/consumer-git-workflow.md` (GitHub Flow para proyectos consumidores: ramas `feature/*`/`fix/*`/`chore/*`/`docs/*`, PR con CI, semver, hotfixes, nota de que es recomendación opcional).
- Referencias desde `docs/framework-contract.md` y `README.md`, distinguiéndolo de `docs/git-workflow-standards.md` (que **no se toca**).
- `ai-specs/skills/verify/SKILL.md` (Step 8) y `ai-specs/skills/code-auditing/SKILL.md` (Paso 7): documentar el handoff del tick del Mandatory Steps al agente orquestador.
- `PLAN_MEJORAS_SPECBOOT.md`: marcar M-801 `[x]`, registrar M-910 `[x]` (patrón M-403) y F-harness como evaluado-sin-acción; fila de historial.
- Guard `tests/mandatory-steps-test.sh` extendido + `docs/git-workflow-standards.md` verificado sin modificaciones.

## Fuera de alcance

- W5 (allowlist de staleness configurable vía `.specboot.json`): change propio (código, `minor`).
- Bump de versión: `release-bump` del mantenedor antes del merge.
- Tags retroactivos v0.6.4+ y política de tagging (decisión aparte del mantenedor, propuesta pendiente).

## Nivel SemVer

`minor` (documentación nueva de comportamiento para consumidores + handoff documentado; sin breaking changes).

**Change type**: docs (los cambios viven en `docs/`, `ai-specs/` y `PLAN_MEJORAS_SPECBOOT.md`).
