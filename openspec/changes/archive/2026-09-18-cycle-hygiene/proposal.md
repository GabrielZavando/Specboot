# Proposal: cycle-hygiene

**Ticket ID**: M-909
**Título original**: [docs] Higiene del ciclo SDD
**Tag**: docs (framework tooling)
**Origen**: Residuos identificados al cerrar el ciclo de M-908 (mantenedor: "resolviendo el desastre que dejaste")

## Why

Tras ejecutar los cambios `sync-specs` (M-701) y `fix-agent-permissions` (M-908) quedaron tres deudas de higiene:

1. **El tick del Mandatory Steps ocurre en el lugar equivocado**: `/apply` satisface los pasos (rama, RED, tests, verify, adversarial) pero nunca marca las checkboxes de `tasks.md`; el `/archive` terminó dependiendo de `--yes` (o de ticks de emergencia) para no abortar. La responsabilidad canónica del tick debe ser de `/apply`, con `/archive` solo como defensiva.
2. **El roadmap quedó atrás respecto a la realidad**: `PLAN_MEJORAS_SPECBOOT.md` no registra M-701 ni M-908 como completados (sin `[x]`, sin fila de historial). El plan es la memoria del roadmap; su desactualización siembra contradicciones (el patrón que M-906 corrigió).
3. **El template de proposal genera un warning evitable**: `openspec archive` advierte `## Why`/`## What Changes` ausentes porque el skill `plan-change` no los incluye en su template (backlog Fase 11, ítem 3).

## What Changes

- `ai-specs/agents/build-agent.md`: nuevo paso — marcar vía edit tool cada checkbox del Mandatory Steps en cuanto se satisface (pre/durante/post).
- `ai-specs/skills/archive/SKILL.md`: el tick canónico pasa a ser de `/apply`; archive solo cubre restos satisfechos sin marcar (edit tool) y aborta ante tareas genuinas pendientes.
- `PLAN_MEJORAS_SPECBOOT.md`: marcar M-701 `[x]`, registrar M-908 como ticket completado, añadir fila de historial.
- `ai-specs/skills/plan-change/SKILL.md`: template de `proposal.md` incluye `## Why` y `## What Changes` (elimina el warning de `openspec archive` para changes futuros).
- Guards: asserts nuevos en `tests/mandatory-steps-test.sh` + nuevo guard `tests/plan-proposal-test.sh`.

## Fuera de alcance

- F-harness (degradación de tool calls del entorno): investigación aparte, no es código del repo.
- El texto residual `gh *` en el `tasks.md` archivado de M-908: histórico, no se toca (`openspec/changes/archive/` es intocable).
- Bump de versión: lo hace el mantenedor con `release-bump` antes del merge (precedente TICKET-AUDIT-*).
- Toil del pin de versión en `mandatory-steps-test.sh`: ya resuelto (asserts dinámicos desde `package.json` en SC-007); verificado en la auditoría de este change.

## Nivel SemVer

`minor` (cambia el flujo del ciclo: el tick de Mandatory Steps migra de archive a apply; sin breaking changes).
