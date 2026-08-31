# Proposal: `Makefile` del framework parametrizado por `.specboot.json`

## Change created from ticket

**Ticket ID**: TICKET-4.1
**Original title**: Makefile del framework que lee `.specboot.json` (servicios, stack)
**Tag (source)**: [docs] (confirmed — el cambio edita `docs/framework-contract.md` + `README.md` y tooling del framework; carga `docs/documentation-standards.md`)
**Derived change name**: specboot-makefile
**Change folder**: openspec/changes/specboot-makefile/
**Enriched artifact used**: no (el ticket TICKET-4.1 ya trae pseudocódigo y decisiones explícitas; no requiere `/enrich-us`)

### Naming rationale
- `specboot-makefile`: nombre del artefacto del framework, consistente con la pista del ticket §7 (`openspec/changes/.../specboot-makefile/`) y con los specs de capacidad existentes (`specboot-update`, `specboot-init`, `specboot-json-standard`).

### Context loaded
- `docs/base-standards.md` (siempre vía `instructions[]`)
- `docs/documentation-standards.md` (tag `[docs]`)
- `docs/framework-contract.md` (Makefile es intocable; §9, §184 — "Makefile y workflows los provee el framework (intocables)")
- `docs/specboot-json-standard.md` (TICKET-0.3: `.specboot.json` `services`/`stack` son la entrada)
- `Makefile` actual (ya itera `services`/`stack` en `solid-lint`; el resto de targets no)
- `.specboot.json` del repo (services: `["."]`, stack: `"framework"`)
- `.github/workflows/ci.yml` (invoca `make install/lint/test/build/audit/solid-lint/commitlint` como jobs separados)

## Why

Hoy el `Makefile` del framework sólo lee `services`/`stack` en el target `solid-lint`. Los demás targets (`install`, `lint`, `test`, `build`, `audit`) operan sobre el stack de la **raíz** y no hay target `ci`. El ticket TICKET-4.1 exige que el Makefile sea **intocable pero parametrizable**: el proyecto declara `services` y `stack` en `.specboot.json` y el Makefile aplica linting/validaciones **por servicio**, sin que el proyecto edite el Makefile.

El pseudocódigo original del ticket tenía errores de sintaxis Make y dependía de `jq`. Durante la fase de plan se corrigió a `node -e` (convención del framework) y se decidió implementar con **bucle shell `for d in $(SERVICES)` + guardas de stack y de script**, evitando pattern rules generadas (que rompían rutas anidadas y producían targets vacíos). También se separó `lint` (lint **propio del proyecto**) de `solid-lint` (SOLID **del framework**), y se definió `ci` como gate del proyecto consumidor (`refs solid-lint lint test audit`), dejando `specboot.sh --ci` como framework self-check aparte.

## What Changes

- **`Makefile`**:
  - Calcular `SERVICES` (default `["."]`) y `STACK`/`FINAL_STACK` (auto si vacío o `"auto"`) vía `node -e` (sin `jq`).
  - Cada target (`install`, `lint`, `test`, `build`, `audit`, `solid-lint`) itera `for d in $(SERVICES)` con guarda de stack (`HAS_NODE`/`HAS_PYTHON`) y de script (salto *graceful* si el script/manifest no existe).
  - `lint` = lint propio del proyecto (`npm run lint` / `ruff check .`); `solid-lint` = SOLID del framework (eslint@8 + dependency-cruiser + ruff + import-linter), respetando la guarda de stack ya existente.
  - Nuevos targets: `ci` (`refs solid-lint lint test audit`), `validate-specboot` (si existe `validate-specboot.sh`), y `help` mejorado que muestra servicios/stack detectados.
- **`docs/framework-contract.md`**: sección "Makefile del framework" (intocable, parametrizable, distinción CI del proyecto vs framework self-check).
- **`README.md`**: ejemplo `.specboot.json` con `services`/`stack` + comandos Makefile.
- **`openspec/specs/specboot-makefile/spec.md`**: nuevo spec de capacidad (creado en `/archive`).

## Goals
- El Makefile lee `services`/`stack` de `.specboot.json` con `node -e` (sin `jq`).
- Por cada servicio declarado, aplica lint/test/build/audit/install según stack, con salto sin error si no aplica.
- `stack: "framework"` (repo del framework) → todos los targets de app saltan limpio; `make ci` queda verde.
- `ci` = gate del proyecto; `specboot.sh --ci` queda fuera del Makefile.
- Sin regresión de los 6 jobs de CI existentes.

## Non-Goals
- Editar el `Makefile` por parte del proyecto (sigue intocable).
- Cambiar `update.sh` (no toca el Makefile; mantiene solo `--bump`).
- Cambiar `specboot.sh` ni `validate-specboot.sh` (la validación `--ci` es dogfooding del framework).
- Migrar las configs `eslintrc.*.js` a flat config.
- Cambiar los umbrales SOLID de `docs/backend-standards.md` / `docs/frontend-standards.md`.

## Enriched User Story
**As a** framework maintainer / project consumer
**I want** the framework `Makefile` to adapt to my `services`/`stack` declared in `.specboot.json`
**So that** I get per-service lint/test/build/audit/install without editing the (intocable) Makefile.

### Context
`make solid-lint` ya itera `services` y respeta `stack` desde TICKET-0.5. TICKET-4.1 extiende ese mismo patrón al resto de targets y añade `ci` como gate del proyecto. El repo del framework usa `services: ["."]` y `stack: "framework"`, por lo que cualquier refactor debe mantener su CI verde (sin correr linters de app).

## Dependencies
- TICKET-0.3 (`.specboot.json` con `services`/`stack`).
- TICKET-3.2 (`specboot update` reemplaza el Makefile como intocable).
- TICKET-1.1 (`files` de `package.json` define qué se publica; el Makefile se publica).
- TICKET-0.5 (base de `solid-lint` por servicio/stack ya implementada).
