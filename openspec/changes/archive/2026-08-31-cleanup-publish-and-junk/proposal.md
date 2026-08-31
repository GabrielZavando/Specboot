# Proposal: Cierre de Fase 6 — cleanup publish.yml, bump node 24, limpiar clutter, reconciliar docs

## Change created from ticket

**Ticket ID**: TICKET-CLEANUP
**Original title**: Cierre de Fase 6: eliminar publish.yml, bump a node 24, limpiar clutter de paths, reconciliar documentación
**Tag (source)**: none (inferred — multi-issue framework cleanup)
**Derived change name**: cleanup-publish-and-junk
**Change folder**: openspec/changes/cleanup-publish-and-junk/
**Enriched artifact used**: no (ticket is the PLAN_IMPLEMENTACION.md itself; acceptance criteria defined in this document)

### Naming rationale
- **Verb**: `cleanup` — removing obsolete files, reconciling specs, bumping versions
- **Noun/entity**: `publish-and-junk` — `publish.yml` is the core target, `junk` covers `Digital/` and `.openspec/` clutter
- **Domain prefix**: none needed — this is framework-internal hygiene

### Context loaded
- `PLAN_IMPLEMENTACION.md` (fuente primaria del ticket — auditoría estructural completa del repo)
- `openspec/specs/npm-distribution/spec.md` (spec activa que contradice el estado real)
- `openspec/specs/workflow-node-upgrade/spec.md` (spec activa que contradice)
- `openspec/specs/specboot-release/spec.md` (spec activa que define el modelo correcto)
- `.github/workflows/publish.yml` (archivo a eliminar — coexiste con release.yml)
- `.github/workflows/release.yml` (archivo correcto — a retener y actualizar)
- `.github/workflows/ci.yml` (a bump a node 24 + actions v5)
- `README.md` (Quick Start y "Versionado y actualización" inconsistentes)
- `docs/framework-contract.md` §"Workflows del framework" (omite release.yml)
- `tests/release-workflow-test.sh`, `tests/update-test.sh` (tests a actualizar)

## Why

Phase 0–6 del plan de Specboot está sustancialmente cumplido y el dogfooding funciona, pero la **Fase 6 quedó a medio ejecutar**: `release.yml` se añadió sin eliminar el `publish.yml` que la propia spec `specboot-release` marca como superseded. Dos specs activas (`npm-distribution`, `workflow-node-upgrade`) siguen apuntando al modelo obsoleto. Sumado al clutter `Digital/` + `.openspec/` y a inconsistencias de README/contrato, el repo necesita **una pasada de reconciliación**.

Sin este cambio:
1. `publish.yml` + `release.yml` colisionan en cada push de tag → doble publish / race condition.
2. Un consumidor que corra `openspec validate` obtiene specs mutuamente contradictorias.
3. Los workflows corren con Node 20 + actions@v4, emitiendo warnings de deprecation.
4. README contradice el modelo npm (`git clone` vs `npm install --save-dev`).
5. `framework-contract.md` omite `release.yml` de la lista de workflows intocables.

## What Changes

### Eliminación (P0 – clutter y conflicto de publicación)
- **Elimina** `.github/workflows/publish.yml` — obsoleto, reemplazado por `release.yml`.
- **Elimina** `Digital/` — directorio basura (fragmento de ruta absoluta mal creado).
- **Elimina** `.openspec/` — directorio leftover de la migración a `openspec/` (sin punto).

### Reconciliación de specs activas (P1)
- **Actualiza** `openspec/specs/npm-distribution/spec.md` — requisito `publish.yml` → `release.yml`.
- **Actualiza** `openspec/specs/workflow-node-upgrade/spec.md` — repointera a `release.yml` + `ci.yml` con `@v5` + node 24.
- **Actualiza** `openspec/specs/specboot-release/spec.md` — añade requisito de node 24 consolidando `workflow-node-upgrade`.

### Bump de workflows (P2)
- **Actualiza** `.github/workflows/release.yml` — `@v4` → `@v5`, `node-version: 20` → `node-version: '24'`.
- **Actualiza** `.github/workflows/ci.yml` — `@v4` → `@v5`, `node-version: 20` → `node-version: '24'`.
- **No toca** `.github/workflows/deploy.yml` (ya usa `@v4`, fuera del decision).

### Reconciliación de documentación (P3)
- **Actualiza** `README.md` — Quick Start con `npm install --save-dev @gabrielzavando/specboot` + `specboot init`; `git clone` movido a nota "Desarrollo del framework"; `update.sh` documentado como `--bump` maintainer-only.
- **Actualiza** `docs/framework-contract.md` §"Workflows del framework" — añade `release.yml` con sus triggers y descripción de que no invoca `update.sh --bump`.
- **Revisa** `docs/versioning-standard.md` §"Release automático" — sin residuos de `publish.yml` como modelo vigente.

### Hygiene menor (P4)
- **Actualiza** `.github/workflows/ci.yml` — alignment de self-tests con `release.yml` (9 tests, no solo 3).
- **Actualiza** `tests/update-test.sh` — repointera de modo sincronización (deprecado) a `--bump`.

## Goals

- Eliminar el conflicto `publish.yml` + `release.yml` dejando `release.yml` como único workflow de publicación.
- Bump `release.yml` y `ci.yml` a `actions/checkout@v5` + `setup-node@v5` + `node-version: '24'`.
- Limpiar `Digital/` y `.openspec/` del árbol de trabajo.
- Reconciliar las specs activas (`npm-distribution`, `workflow-node-upgrade`, `specboot-release`) con el modelo `release.yml`.
- Hacer que `README.md` y `framework-contract.md` reflejen el estado real del framework.
- No regresión: todos los tests y validaciones del framework siguen en verde.

## Non-Goals

- **No** se rediseña el framework — es una pasada de cierre.
- **No** se toca `deploy.yml` (fuera del decision de bump).
- **No** se elimina `update.sh` (se mantiene `--bump` como convenience de maintainer).
- **No** se elimina la línea `.openspec/` de `.npmignore` (safety net).
- **No** se cambia `package.json` `version` (es un `fix`, no un release).
- **No** se modifican los 5 documentos intocables de `docs/` salvo `framework-contract.md` §Workflows y revisión menor de `versioning-standard.md`.
