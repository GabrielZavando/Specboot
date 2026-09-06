# Change: sync-agent-permissions

## Header

- **Ticket ID:** M-403
- **Original title:** [docs] Sincronizar permisos bash del subagente verify con su documentación
- **Tag:** docs (explícito)
- **Change type:** framework (dogfooding — sin specs de aplicación)
- **SemVer level:** `patch` (sincroniza permisos y documentación de agentes; no agrega capacidad nueva ni rompe contratos existentes)
- **Source ticket:** `PLAN_MEJORAS_SPECBOOT.md` — FASE 4, M-403 (descubierto durante el change `persist-verify-results`, tarea 1.6)

## Summary

Sincronizar los permission blocks de `.opencode/agents/*.md` con los roles
documentados en `ai-specs/agents/*.md` y los pasos reales de cada SKILL:
todo comando documentado en la lista "Bash permitido" del rol debe existir
como patrón allow en el permission block del agente, y viceversa.

Fix central (M-403): añadir `"pytest *": allow` al permission block de
`.opencode/agents/verify.md` — su rol documenta `pytest`, pero el block cae
en `"*": deny` y el subagente `verify` no puede ejecutar tests Python
(Step 5b del skill `verify`) en proyectos Python.

## Motivation

La documentación del rol es contrato para el usuario; el permission block es
contrato para el runtime. Cuando divergen, ninguna de las dos partes cumple:
el rol promete capacidades que los permisos niegan (comandos documentados que
fallan en runtime) y el block otorga patrones que nadie documentó (superficie
de permisos invisible para auditoría).

La auditoría de planificación de este change amplió el inventario del ticket y
encontró la misma desincronía en el agente `archive`:

- El skill `archive` (Steps 2, 3 y 5) usa `git status --porcelain`,
  `git diff --stat` y lecturas token-light `node -e` — el block no tiene
  patrones allow para ninguno → caen en deny en runtime.
- El block permite `rm -rf openspec/changes/*` (más amplio que el comportamiento
  documentado; el Step 7 del skill solo elimina `openspec/tickets/{TICKET-ID}-enriched.md`)
  y **no** permite el `rm openspec/tickets/...` sí documentado.
- El rol lista `git commit` en "Bash permitido", contradiciendo la regla
  "Commit ownership" del propio rol y el Step 6 del skill ("No ejecutar
  git commit") — el block lo niega correctamente; la documentación es la que
  miente.

`reviewer` y `plan` están sincronizados; `backend`, `frontend` y `build` usan
`bash: allow` y no tienen superficie de desincronía.

## Scope

**In scope:**

- `verify`: añadir `"pytest *": allow` al block; documentar `npm run test` en
  el rol (viceversa).
- `archive`: añadir patrones allow para `git status *`, `git diff`, `git diff *`,
  `git log`, `git log *` y `node -e *`; reemplazar `rm -rf openspec/changes/*`
  por `rm openspec/tickets/*`; corregir el rol (quitar `git commit` de "Bash
  permitido", documentar `node -e`).
- Auditoría bidireccional reviewer/plan fijada en guard ejecutable
  `tests/agent-permissions-test.sh` (asserts con prefijo `[SC-NNN]`).
- Delta de spec nueva `agent-permissions` (contrato de sincronía rol↔block).
- Cierre: `[x]` M-403 + fila v3.7 en `PLAN_MEJORAS_SPECBOOT.md`; bump `0.6.1`.

**Out of scope:**

- Agentes con `bash: allow` (backend, frontend, build) — no hay bloque
  restrictivo que sincronizar.
- Cambios de comportamiento de los skills (`verify`, `archive`,
  `code-auditing`, `plan-change`): este change solo alinea permisos y
  documentación con lo que los skills ya definen.
- Nuevas capacidades de permisos no respaldadas por documentación existente.

## Design Validation

- **Entities checked against data-model:** none (change de framework; no aplica
  data model de dominio).
- **API endpoints checked against api-spec.yml:** none.
- **Conflicts:**
  - Critical: none.
  - Minor: la spec archivada `agents-bridge` gobierna la estructura del puente
    `AGENTS.md`, no los permission blocks de los agentes → no hay colisión;
    este change crea la spec nueva `agent-permissions`. Criterio de resolución
    de desacuerdos fijado en la spec: **el SKILL.md de cada skill es la fuente
    de verdad del comportamiento**; el rol y el block deben coincidir con él
    (comando que el skill ejecuta → patrón allow + mención en el rol; comando
    que el skill no ejecuta y el block niega → se elimina del rol).
