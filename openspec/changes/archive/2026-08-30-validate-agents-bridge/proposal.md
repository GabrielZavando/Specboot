# Validate Agents Bridge — Validación del puente AGENTS.md ↔ docs/

## Why

El puente `AGENTS.md` implementado en TICKET-2.1 declara, en su sección
"Carga dinámica", una **matriz de carga tag-based** y una **regla de carga
condicional de `docs/project/*` con fallback a placeholder** (ya
documentada en `docs/docs-standard.md` §3.1). Hasta ahora, esa regla no
se ha validado contra escenarios concretos: hace falta cerrar la Fase 2
con evidencia de que el puente **no rompe el flujo SDD** cuando la
estructura de `docs/` es parcial o asimétrica, y de que las
verificaciones de integridad (`check-refs.sh`, `specboot.sh --ci`)
permanecen en `0` errores en todos los casos.

## What Changes

- Añade una nueva sección "Validación del puente AGENTS.md" en
  `docs/docs-standard.md`, a continuación de §3.1, con los 3 escenarios
  Gherkin del ticket TICKET-2.2a §3.1, sus resultados esperados y
  4 edge cases documentados (A–D).
- Codifica en `openspec/specs/agents-bridge/spec.md` los nuevos
  requisitos de comportamiento del puente que la validación evidencia
  (carga obligatoria de `base-standards.md`, carga tag-based selectiva,
  carga condicional de `docs/project/*` como prosa, fallback a
  placeholder, no-ruptura del flujo SDD).
- Cierra la Fase 2 con `check-refs.sh` y `specboot.sh --ci` en `0`
  errores, sin modificar archivos intocables del framework
  (`AGENTS.md`, `docs/base-standards.md`, `docs/framework-contract.md`,
  `docs/versioning-standard.md`, `specboot.sh`,
  `validate-specboot.sh`).

**No breaking changes.** La modificación a `docs/docs-standard.md` es una
**inserción** de sección nueva, no un reemplazo del contrato. La
modificación a `openspec/specs/agents-bridge/spec.md` añade
`## ADDED Requirements` (no modifica ni elimina requisitos existentes).

## Capabilities

### New Capabilities

_Ninguna._ Este change no introduce una capability nueva; la validación
se materializa como evidencia documental en `docs/docs-standard.md` y
como requisitos adicionales en la capability existente.

### Modified Capabilities

- `agents-bridge`: se añaden nuevos requisitos que codifican el
  comportamiento del puente validado por los 3 escenarios Gherkin del
  ticket (carga obligatoria, carga tag-based, carga condicional de
  `docs/project/*` como prosa, fallback a placeholder, no-ruptura del
  flujo SDD, verificación continua con `check-refs.sh` y
  `specboot.sh --ci`).

## Impact

- **Code:** no se modifica código de aplicación. El puente es prosa
  declarada en `AGENTS.md` (intocable) y los scripts de validación son
  del framework (intocables, TICKET-1.x).
- **Specs:** se añade una sección `## ADDED Requirements` a
  `openspec/specs/agents-bridge/spec.md` con los requisitos REQ-VAB-1 a
  REQ-VAB-8.
- **Docs:** se añade una sección nueva en `docs/docs-standard.md` a
  continuación de §3.1. El contrato de §3.1 no se altera.
- **CI:** `check-refs.sh` y `specboot.sh --ci` deben seguir
  reportando `0` errores. Este change los preserva (verificado
  durante la implementación).

## Origin

- **Ticket ID:** TICKET-2.2a
- **Title:** Prueba de fluidez del puente AGENTS.md ↔ docs/
- **Phase:** 2 (Puente docs ↔ AGENTS.md)
- **Type:** docs + validation
- **Priority:** P0
- **Depends on:** TICKET-2.1 (puente AGENTS.md implementado)
- **Tag:** `[docs]`
