# Scenarios: Cierre de Fase 6 — cleanup publish.yml, bump node 24, limpiar clutter, reconciliar docs

## Acceptance Criteria

### Scenario 1: publish.yml no existe tras el change
- **Given** el repo con `.github/workflows/publish.yml` + `.github/workflows/release.yml` coexistiendo
- **When** se aplica el change
- **Then** `.github/workflows/publish.yml` NO existe
- **And** `release.yml` es el único workflow de publicación
- **And** `release.yml` dispara en `push: branches: [main]` y `release: types: [published]`

### Scenario 2: release.yml y ci.yml usan actions v5 y node 24
- **Given** el repo con `release.yml` y `ci.yml` usando `actions/checkout@v4`, `actions/setup-node@v4`, `node-version: 20`
- **When** se aplica el change
- **Then** `release.yml` usa `actions/checkout@v5` y `actions/setup-node@v5` con `node-version: '24'`
- **And** `ci.yml` usa `actions/checkout@v5` y `actions/setup-node@v5` con `node-version: '24'`
- **And** no hay warnings de deprecation en los logs de los workflows

### Scenario 3: Digital/ y .openspec/ no existen en el árbol
- **Given** el repo con `Digital/` y `.openspec/` como directorios no trackeados en disco
- **When** se aplica el change
- **Then** el directorio `Digital/` NO existe
- **And** el directorio `.openspec/` NO existe
- **And** `git ls-files Digital/ .openspec/` retorna vacío
- **And** `.npmignore` conserva la línea `.openspec/` (safety net, no se toca)

### Scenario 4: npm-distribution y workflow-node-upgrade apuntan a release.yml
- **Given** las specs activas `openspec/specs/npm-distribution/spec.md` y `openspec/specs/workflow-node-upgrade/spec.md` coexisten con `openspec/specs/specboot-release/spec.md`
- **When** se aplica el change
- **Then** `npm-distribution/spec.md` exige `release.yml` (no `publish.yml`)
- **And** `workflow-node-upgrade/spec.md` exige `release.yml` y `ci.yml` con `@v5` + node 24
- **And** `specboot-release/spec.md` añade el requisito de node 24 consolidando `workflow-node-upgrade`
- **And** las tres specs son mutuamente consistentes (sin contradicciones)

### Scenario 5: README lead con npm install + specboot init, no git clone
- **Given** `README.md` Quick Start recomienda `git clone` a consumidores
- **When** se aplica el change
- **Then** README lead con `npm install --save-dev @gabrielzavando/specboot` + `specboot init`
- **And** el `git clone` se mueve a una nota secundaria "Desarrollo del framework (maintainers)"
- **And** `update.sh` se documenta como `--bump` maintainer-only (no se publica al consumidor)
- **And** `specboot update` es el flujo de actualización documentado para consumidores

### Scenario 6: framework-contract lista los tres workflows
- **Given** `docs/framework-contract.md` §"Workflows del framework" lista solo `ci.yml` + `deploy.yml`
- **When** se aplica el change
- **Then** la sección lista `ci.yml` + `deploy.yml` + `release.yml`
- **And** describe los triggers de `release.yml` (`push: branches: [main]` + `release: types: [published]`)
- **And** describe que `release.yml` **no invoca** `update.sh --bump` (maintainer-only)
- **And** describe el gate `needs: validate` y `permissions: packages: write`

### Scenario 7: ci.yml corre los mismos 9 tests que release.yml
- **Given** `ci.yml` solo corre 3 self-tests (`check-refs-test`, `solid-templates-test`, `update-test`)
- **And** `release.yml` corre los 9 tests (`tests/*-test.sh`)
- **When** se aplica el change
- **Then** `ci.yml` corre los mismos 9 tests que `release.yml`
- **And** ambos workflows son consistentes en su validación de self-tests

### Scenario 8: update-test.sh prueba el modo --bump (no el deprecado)
- **Given** `tests/update-test.sh` prueba el modo sincronización de `update.sh` (deprecado)
- **When** se aplica el change
- **Then** el test prueba el modo `--bump` (modo vigente)
- **And** mantiene una aserción de que el modo sincronización imprime el aviso de deprecation

### Scenario 9: specs activas reconciliadas — sin publish.yml en ninguna spec
- **Given** las tres specs activas han sido actualizadas
- **When** `grep -rn "publish\.yml" openspec/specs/` se ejecuta
- **Then** `npm-distribution/spec.md` no contiene `publish.yml` como modelo vigente
- **And** `workflow-node-upgrade/spec.md` no contiene `publish.yml` como modelo vigente
- **And** cualquier mención de `publish.yml` es solo en contexto histórico (superseded)

### Scenario 10: no regression — todas las validaciones del framework pasan
- **Given** el change ha sido aplicado al repositorio Specboot
- **When** se ejecutan `check-refs.sh`, `specboot.sh --ci`, `validate-specboot.sh`, `make ci`, `bash scripts/dogfood-check.sh` y todos los `tests/*-test.sh`
- **Then** todas las validaciones reportan 0 errores
- **And** todos los tests pasan
