# Proposal: sync-specs

**Ticket ID**: M-701
**Título original**: [docs] Implementar /sync-specs
**Tag**: docs
**Origen**: PLAN_MEJORAS_SPECBOOT.md, Fase 7 (ticket pendiente del roadmap)

## Resumen

Comando `/sync-specs` que sincroniza los deltas de specs del change activo
(`openspec/changes/<change>/specs/`) con las specs principales
(`openspec/specs/`) **sin archivar el change**, manteniendo la fuente de verdad
actualizada durante changes largos.

## Motivación

Hoy `openspec/specs/` solo se actualiza al ejecutar `/archive`. En changes
largos, las specs principales quedan desactualizadas mientras el
work-in-progress avanza, y agentes/humanos que consultan las specs ven una foto
vieja que puede contradecir lo ya implementado.

## Alcance

- Nuevo skill `ai-specs/skills/sync-specs/SKILL.md` (token-light, patrón de
  `/archive`).
- Nuevo comando `.opencode/commands/sync-specs.md` (autodescubierto;
  `opencode.json` no tiene sección `command`).
- Actualización de `AGENTS.md` §5.3 (herramientas opcionales).
- Guard `tests/sync-specs-test.sh` con asserts `[SC-NNN]`.
- La eliminación de `PLAN_IMPLEMENTACION.md` (documento de auditoría cumplido)
  viaja en el commit de este change.

## Decisiones del mantenedor (del enriquecido)

- Delta `## MODIFIED` sobre spec inexistente en `openspec/specs/` → se trata
  como `## ADDED`.
- Premisa de entorno: existe como máximo un change activo; no hay argumento
  `TICKET-ID` ni manejo de múltiples changes.

## Fuera de alcance

- No toca `openspec/state/manifest.json` (eso es de `/archive`).
- No modifica el formato de deltas OpenSpec ni el comportamiento de `/archive`.

## Artefacto enriquecido

`openspec/tickets/M-701-enriched.md` (fuente primaria de este change).

## Change type

specs + tooling (los deltas de specs de este change se documentan en `specs/`
como spec nueva `sync-specs` si el flujo lo requiere; en este change el
comportamiento se valida vía guard de tests, siguiendo el patrón de
`agent-permissions`).
