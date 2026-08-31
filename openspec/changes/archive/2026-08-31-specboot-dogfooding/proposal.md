# Proposal: Dogfooding — desarrollar Specboot con Specboot

## Change created from ticket

**Ticket ID**: TICKET-5.1
**Original title**: Dogfooding: cambio real de framework con flujo SDD
**Tag (source)**: [docs] (explicit in ticket §2)
**Derived change name**: specboot-dogfooding
**Change folder**: openspec/changes/specboot-dogfooding/
**Enriched artifact used**: no (el ticket TICKET-5.1 ya trae pseudocódigo y decisiones explícitas; no requiere `/enrich-us`)

### Naming rationale
- `specboot-dogfooding`: consistente con los specs de capacidad existentes (`specboot-makefile`, `specboot-update`, `specboot-init`, `specboot-json-standard`) y con la pista del ticket §8 (`openspec/specs/specboot-dogfooding/spec.md`).

### Context loaded
- `docs/base-standards.md` (siempre vía `instructions[]`)
- `docs/documentation-standards.md` (tag `[docs]`)
- `docs/docs-standard.md` (carga dinámica implícita del framework)
- `docs/framework-contract.md`, `docs/versioning-standard.md` (referenciados por el ticket §2)
- `README.md` actual (punto de inserción de la sección)
- `package.json` (`files` allowlist), `check-refs.sh`, `specboot.sh` (comportamiento observado)

## Capabilities

- `specboot-dogfooding` — el framework documenta y auto-valida su propio flujo SDD (README + scripts/dogfood-check.sh + tests/dogfood-check-test.sh).

## Why

El framework debe demostrar que se desarrolla a sí mismo (dogfooding) usando su propio flujo SDD completo (`/plan-change` → `/apply` → `/verify` → `/archive` → `/commit`) dentro del repo local. El ticket elige un cambio pequeño y útil: documentar el flujo de trabajo del propio framework en el `README.md` y añadir un script `scripts/dogfood-check.sh` que ejecute las dos validaciones de dogfooding del framework (`check-refs.sh` + `specboot.sh --ci`). Esto ejercita el puente `AGENTS.md`, los agentes, `check-refs.sh`, `specboot.sh --ci`, el `Makefile` de Fase 4 y la validación de `.specboot.json`, sin riesgo.

`specboot update` es no-op en el repo del framework (target==source), por lo que el dogfooding usa el flujo de comandos, no `specboot update`.

## What Changes

- **`README.md`**: nueva sección "Desarrollar Specboot con Specboot (Dogfooding)" (docs).
- **`scripts/dogfood-check.sh`**: nuevo script del framework (corre `check-refs.sh` + `specboot.sh --ci`).
- **`tests/dogfood-check-test.sh`**: nuevo test TDD del script (existencia, ejecutabilidad, ejecución limpia).
- **`openspec/specs/specboot-dogfooding/spec.md`**: creado en `/archive`.

## Goals

- El README documenta el flujo SDD del framework (rama por ticket + un PR por fase, `/plan-change` → `/apply` → `/verify` → `/archive` → `/commit`, validaciones).
- `scripts/dogfood-check.sh` existe, es ejecutable y falla si cualquiera de las dos validaciones falla.
- `check-refs.sh`, `specboot.sh --ci`, `make ci` en verde tras el cambio.

## Non-Goals

- No editar `AGENTS.md`, `Makefile`, `.github/workflows/`, `specboot.sh`, `update.sh`.
- No añadir target `dogfood` al `Makefile` (ya existe `make ci` y `specboot.sh --ci`).
- No publicar el script vía `package.json` `files` ni añadir un npm script (fuera de alcance según la decisión de planificación).

## Enriched User Story

**As a** framework maintainer
**I want** the framework to document and self-validate its own SDD flow
**So that** dogfooding is demonstrable and the framework proves it can develop itself.

### Context

Las piezas ya construidas (puente `AGENTS.md`, agentes, `check-refs.sh`, `specboot.sh --ci`, `Makefile` Fase 4, validación `.specboot.json`) deben ser ejercitadas por un cambio real. El ticket elige docs + script para minimizar riesgo mientras cubre todo el flujo.

## Dependencies

- TICKET-4.2 (workflows parametrizados), TICKET-4.1 (Makefile), TICKET-3.2 (`specboot update`), TICKET-2.1 (`AGENTS.md` puente), TICKET-0.1–0.4 (fundamento).
