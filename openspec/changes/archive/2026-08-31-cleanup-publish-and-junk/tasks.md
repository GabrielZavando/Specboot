# Tasks: Cierre de Fase 6 — cleanup publish.yml, bump node 24, limpiar clutter, reconciliar docs

## Task B1: Reconciliar npm-distribution/spec.md con el modelo release.yml
**Status**: [x]
**Domain**: Framework specs
**Layer**: N/A (documentation/contracts)
**Priority**: High
**Estimate**: S
**Suggested Path**: openspec/specs/npm-distribution/spec.md
**Test Path**: `grep -n "publish\.yml" openspec/specs/npm-distribution/spec.md` (0 en contexto vigente); `grep -n "release\.yml" openspec/specs/npm-distribution/spec.md` (≥1)

**Steps**:
1. Editar `openspec/specs/npm-distribution/spec.md` — Sección "Automated publication" (Requirement existente en línea 36–46).
2. Reemplazar toda referencia a `publish.yml` por `release.yml`.
3. Documentar los triggers correctos: `push: branches: [main]` + `release: types: [published]`.
4. Documentar `permissions: packages: write`, `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}`.
5. Documentar gate `needs: validate`.
6. Añadir escenario Gherkin: "publish.yml is superseded by release.yml".

**Acceptance Criteria**:
- `grep -n "publish\.yml" openspec/specs/npm-distribution/spec.md` retorna 0 resultados en contexto vigente.
- `grep -n "release\.yml" openspec/specs/npm-distribution/spec.md` retorna ≥1.
- Spec pasa `check-refs.sh` (0 errores de referencias).

---

## Task B2: Reconciliar workflow-node-upgrade/spec.md con release.yml + ci.yml
**Status**: [x]
**Domain**: Framework specs
**Layer**: N/A (documentation/contracts)
**Priority**: High
**Estimate**: S
**Suggested Path**: openspec/specs/workflow-node-upgrade/spec.md
**Test Path**: `grep -n "release\.yml" openspec/specs/workflow-node-upgrade/spec.md` (≥1); `grep -n "node-version.*24" openspec/specs/workflow-node-upgrade/spec.md` (≥1)

**Steps**:
1. Editar `openspec/specs/workflow-node-upgrade/spec.md`.
2. Reemplazar requisito de `publish.yml` con `release.yml` y `ci.yml`.
3. Actualizar actions: `actions/checkout@v5`, `actions/setup-node@v5`.
4. Actualizar node-version: `'24'`.
5. Actualizar escenario Gherkin para reflejar `release.yml` + `ci.yml`.

**Acceptance Criteria**:
- Spec menciona `release.yml` y `ci.yml` con `@v5` y `node-version: '24'`.
- `grep -n "publish\.yml" openspec/specs/workflow-node-upgrade/spec.md` retorna 0.
- Spec pasa `check-refs.sh`.

---

## Task B3: Añadir requisito de node 24 a specboot-release/spec.md
**Status**: [x]
**Domain**: Framework specs
**Layer**: N/A (documentation/contracts)
**Priority**: High
**Estimate**: S
**Suggested Path**: openspec/specs/specboot-release/spec.md
**Test Path**: `grep -n "node-version.*24" openspec/specs/specboot-release/spec.md` (≥1)

**Steps**:
1. Editar `openspec/specs/specboot-release/spec.md`.
2. Añadir Requirement consolidando `workflow-node-upgrade`: "`release.yml` SHALL use `actions/checkout@v5`, `actions/setup-node@v5`, `node-version: '24'`".
3. Añadir Scenario Gherkin correspondiente.

**Acceptance Criteria**:
- Spec contiene requisito de node 24 para `release.yml`.
- Scenario Gherkin cubre happy path y error path.

---

## Task C1: Eliminar Digital/ del árbol de trabajo
**Status**: [x]
**Domain**: Hygiene
**Layer**: N/A
**Priority**: Critical (P0)
**Estimate**: XS
**Suggested Path**: N/A (directorio a eliminar)
**Test Path**: `test ! -e Digital/`; `git ls-files Digital/` (vacío)

**Steps**:
1. Verificar: `git ls-files Digital/` → vacío.
2. Ejecutar: `rm -rf Digital/`.
3. Verificar: `test ! -e Digital/`.

**Acceptance Criteria**:
- `Digital/` no existe en el árbol de trabajo.
- `.npmignore` conserva la línea `.openspec/` (no se toca).

---

## Task C2: Eliminar .openspec/ del árbol de trabajo
**Status**: [x]
**Domain**: Hygiene
**Layer**: N/A
**Priority**: Critical (P0)
**Estimate**: XS
**Suggested Path**: N/A (directorio a eliminar)
**Test Path**: `test ! -e .openspec/`; `git ls-files .openspec/` (vacío)

**Steps**:
1. Verificar: `git ls-files .openspec/` → vacío.
2. Ejecutar: `rm -rf .openspec/`.
3. Verificar: `test ! -e .openspec/`.

**Acceptance Criteria**:
- `.openspec/` no existe en el árbol de trabajo.
- `.npmignore` conserva la línea `.openspec/` (safety net intacta).

---

## Task D1: Eliminar publish.yml (conflicto de publicación)
**Status**: [x]
**Domain**: Tooling / CI
**Layer**: N/A (workflow infrastructure)
**Priority**: Critical (P1)
**Estimate**: XS
**Suggested Path**: .github/workflows/publish.yml (archivo a eliminar)
**Test Path**: `test ! -f .github/workflows/publish.yml`; `ls .github/workflows/` (3 archivos: ci.yml, deploy.yml, release.yml)

**Steps**:
1. Ejecutar: `git rm .github/workflows/publish.yml`.
2. Verificar que `release.yml` sigue presente y funcional.
3. Confirmar que `package.json` `files` incluye `.github/workflows` (ya lo tiene).

**Acceptance Criteria**:
- `publish.yml` no existe.
- `release.yml` existe y es el único workflow de publicación.
- `release.yml` pasa `python -c "import yaml; yaml.safe_load(open('.github/workflows/release.yml'))"`.
- `release.yml` no invoca `update.sh` ni `--bump`.

---

## Task E1: Bump release.yml a actions v5 + node 24
**Status**: [x]
**Domain**: Tooling / CI
**Layer**: N/A (workflow infrastructure)
**Priority**: High (P2)
**Estimate**: S
**Suggested Path**: .github/workflows/release.yml
**Test Path**: `grep -n "checkout@v5\|setup-node@v5\|node-version: '24'" .github/workflows/release.yml`

**Steps**:
1. Editar `.github/workflows/release.yml` — jobs `validate` y `publish`.
2. Reemplazar `actions/checkout@v4` → `actions/checkout@v5`.
3. Reemplazar `actions/setup-node@v4` → `actions/setup-node@v5`.
4. Reemplazar `node-version: 20` → `node-version: '24'`.
5. Verificar YAML: `python -c "import yaml; yaml.safe_load(open('.github/workflows/release.yml'))"`.
6. Verificar que no hay `update.sh` ni `--bump`: `grep -n "update\.sh\|--bump" .github/workflows/release.yml` → 0.

**Acceptance Criteria**:
- YAML válido y parsea sin errores.
- `release.yml` usa `@v5` y `node-version: '24'` en ambos jobs.
- No se invoca `update.sh` ni `--bump`.

---

## Task E2: Bump ci.yml a actions v5 + node 24
**Status**: [x]
**Domain**: Tooling / CI
**Layer**: N/A (workflow infrastructure)
**Priority**: High (P2)
**Estimate**: S
**Suggested Path**: .github/workflows/ci.yml
**Test Path**: `grep -n "checkout@v5\|setup-node@v5\|node-version: '24'" .github/workflows/ci.yml`

**Steps**:
1. Editar `.github/workflows/ci.yml` — jobs `validate` y `project-ci`.
2. Reemplazar `actions/checkout@v4` → `actions/checkout@v5`.
3. Reemplazar `actions/setup-node@v4` → `actions/setup-node@v5`.
4. Reemplazar `node-version: 20` → `node-version: '24'`.
5. Verificar YAML: `python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"`.

**Acceptance Criteria**:
- YAML válido y parsea sin errores.
- `ci.yml` usa `@v5` y `node-version: '24'` en ambos jobs.
- `deploy.yml` NO se ha tocado (verificar que sigue usando `@v4` y `node-version: 20` si aplica).

---

## Task E3: Actualizar tests/release-workflow-test.sh para verificar node 24 y v5
**Status**: [x]
**Domain**: Testing
**Layer**: N/A
**Priority**: Medium
**Estimate**: S
**Suggested Path**: tests/release-workflow-test.sh
**Test Path**: `bash tests/release-workflow-test.sh` (debe pasar)

**Steps**:
1. Editar `tests/release-workflow-test.sh`.
2. Añadir aserciones que verifiquen `checkout@v5` y `setup-node@v5` y `node-version: '24'` en `release.yml`.
3. Verificar que el test sigue pasando: `bash tests/release-workflow-test.sh`.

**Acceptance Criteria**:
- Test pasa (exit 0).
- Test cubre las nuevas aserciones de version y node.

---

## Task F1: Reconciliar README.md — Quick Start y modelo npm
**Status**: [x]
**Domain**: Documentation
**Layer**: N/A
**Priority**: High (P3)
**Estimate**: M
**Suggested Path**: README.md
**Test Path**: `grep -n "Template boilerplate" README.md` (0); `grep -n "git clone" README.md | head -1` (solo en nota maintainers); `grep -n "specboot update" README.md` (≥1)

**Steps**:
1. Editar `README.md` línea 8: `Template boilerplate for Spec-Driven Development` → `SDD framework for Spec-Driven Development`.
2. Reescribir Quick Start (líneas 23–55) — lead con:
   ```bash
   npm install --save-dev @gabrielzavando/specboot
   bash node_modules/@gabrielzavando/specboot/specboot.sh init
   ```
3. Mover `git clone` a nota secundaria "Desarrollo del framework (maintainers)".
4. Editar sección "Versionado y actualización" (líneas 504–521): eliminar `bash update.sh --template`; reemplazar por `bash specboot.sh update`; aclarar que `update.sh --bump` es maintainer-only no publicado.
5. Verificar que `check-refs.sh` pasa (0 errores de referencias).

**Acceptance Criteria**:
- `grep "Template boilerplate" README.md` → 0.
- `git clone` solo aparece en nota de maintainers.
- `specboot update` aparece como flujo de actualización para consumidores.
- `update.sh --template` no aparece.
- `check-refs.sh` → 0.

---

## Task F2: Añadir release.yml a framework-contract.md §Workflows
**Status**: [x]
**Domain**: Documentation
**Layer**: N/A
**Priority**: High (P3)
**Estimate**: S
**Suggested Path**: docs/framework-contract.md
**Test Path**: `grep -n "release\.yml" docs/framework-contract.md` (≥1 en §Workflows)

**Steps**:
1. Editar `docs/framework-contract.md` §"Workflows del framework" (líneas 260–287).
2. Añadir `release.yml` a la lista de workflows intocables (junto a `ci.yml` y `deploy.yml`).
3. Describir triggers: `push: branches: [main]` + `release: types: [published]`.
4. Describir gate `needs: validate`, `permissions: packages: write`, `NODE_AUTH_TOKEN`.
5. Aclarar que `release.yml` **no invoca** `update.sh --bump` (maintainer-only convenience).
6. Verificar que `check-refs.sh` pasa.

**Acceptance Criteria**:
- `grep -n "release\.yml" docs/framework-contract.md` → ≥1 en §Workflows.
- Sección lista los tres workflows (`ci.yml`, `deploy.yml`, `release.yml`).
- `check-refs.sh` → 0.

---

## Task F3: Revisar versioning-standard.md por residuos de publish.yml
**Status**: [x]
**Domain**: Documentation
**Layer**: N/A
**Priority**: Low (P3)
**Estimate**: XS
**Suggested Path**: docs/versioning-standard.md
**Test Path**: `grep -n "publish\.yml" docs/versioning-standard.md` (0 en contexto vigente, solo histórico superseded)

**Steps**:
1. Revisar `docs/versioning-standard.md` §"Release automático" (líneas 104–137).
2. Verificar que no queda referencia residual a `publish.yml` como modelo vigente.
3. Cualquier mención de `publish.yml` solo como histórico superseded (si aplica).

**Acceptance Criteria**:
- No hay residuos de `publish.yml` como modelo vigente.
- `check-refs.sh` → 0.

---

## Task G1: Alinear self-tests de ci.yml con release.yml (9 tests, no 3)
**Status**: [x]
**Domain**: Tooling / CI
**Layer**: N/A (workflow infrastructure)
**Priority**: Medium (P4)
**Estimate**: S
**Suggested Path**: .github/workflows/ci.yml
**Test Path**: `diff <(grep -A4 "tests/\*-test.sh" .github/workflows/ci.yml) <(grep -A4 "tests/\*-test.sh" .github/workflows/release.yml)` (idéntico)

**Steps**:
1. Editar `.github/workflows/ci.yml` — job `validate`.
2. Reemplazar el bloque de 3 tests:
   ```yaml
   if: ${{ hashFiles('tests/check-refs-test.sh', 'tests/solid-templates-test.sh', 'tests/update-test.sh') != '' }}
   run: |
     bash tests/check-refs-test.sh
     bash tests/solid-templates-test.sh
     bash tests/update-test.sh
   ```
   Por el bloque completo de 9 tests (igual que `release.yml`):
   ```yaml
   if: ${{ hashFiles('tests/*-test.sh') != '' }}
   run: |
     for t in tests/*-test.sh; do
       echo "→ running $t"
       bash "$t"
     done
   ```
3. Verificar que el diff entre bloques es 0.

**Acceptance Criteria**:
- `ci.yml` corre los mismos 9 tests que `release.yml`.
- YAML parsea sin errores.

---

## Task G2: Repuntar tests/update-test.sh a modo --bump
**Status**: [x]
**Domain**: Testing
**Layer**: N/A
**Priority**: Medium (P4)
**Estimate**: S
**Suggested Path**: tests/update-test.sh
**Test Path**: `bash tests/update-test.sh` (debe pasar)

**Steps**:
1. Editar `tests/update-test.sh`.
2. Identificar la sección de "Sync test" (modo deprecado) — mantener aserción de que imprime aviso de deprecation.
3. Asegurar que la sección "Bump test" usa `--bump` y pasa (modo vigente).
4. Verificar: `bash tests/update-test.sh` → exit 0.

**Acceptance Criteria**:
- Test pasa (exit 0).
- Modo `--bump` es el principal.
- Aviso de deprecation del modo sincronización se mantiene verificado.

---

## Task H1: Verificación integral — check-refs.sh
**Status**: [x]
**Domain**: QA
**Layer**: N/A
**Priority**: Critical
**Estimate**: XS
**Suggested Path**: repo root
**Test Path**: `bash check-refs.sh` (exit 0)

**Steps**:
1. Ejecutar `bash check-refs.sh` desde la raíz del repo.

**Acceptance Criteria**:
- `check-refs.sh` reporta 0 errores.

---

## Task H2: Verificación integral — specboot.sh --ci
**Status**: [x]
**Domain**: QA
**Layer**: N/A
**Priority**: Critical
**Estimate**: XS
**Suggested Path**: repo root
**Test Path**: `bash specboot.sh --ci` (exit 0)

**Steps**:
1. Ejecutar `bash specboot.sh --ci` desde la raíz del repo.

**Acceptance Criteria**:
- `specboot.sh --ci` reporta 0 errores.

---

## Task H3: Verificación integral — validate-specboot.sh
**Status**: [x]
**Domain**: QA
**Layer**: N/A
**Priority**: Critical
**Estimate**: XS
**Suggested Path**: repo root
**Test Path**: `bash validate-specboot.sh` (exit 0)

**Steps**:
1. Ejecutar `bash validate-specboot.sh` desde la raíz del repo.

**Acceptance Criteria**:
- `validate-specboot.sh` reporta 0 errores.

---

## Task H4: Verificación integral — make ci
**Status**: [x]
**Domain**: QA
**Layer**: N/A
**Priority**: Critical
**Estimate**: XS
**Suggested Path**: repo root
**Test Path**: `make ci` (exit 0)

**Steps**:
1. Ejecutar `make ci` desde la raíz del repo.

**Acceptance Criteria**:
- `make ci` sale con exit 0.

---

## Task H5: Verificación integral — dogfood-check.sh
**Status**: [x]
**Domain**: QA
**Layer**: N/A
**Priority**: Critical
**Estimate**: XS
**Suggested Path**: repo root
**Test Path**: `bash scripts/dogfood-check.sh` (exit 0)

**Steps**:
1. Ejecutar `bash scripts/dogfood-check.sh` desde la raíz del repo.

**Acceptance Criteria**:
- `dogfood-check.sh` reporta 0 errores.

---

## Task H6: Verificación integral — migración .openspec/ completa
**Status**: [x]
**Domain**: QA
**Layer**: N/A
**Priority**: High
**Estimate**: XS
**Suggested Path**: repo root
**Test Path**: `grep -R ".openspec/" .opencode/ ai-specs/` (0 coincidencias)

**Steps**:
1. Ejecutar `grep -R ".openspec/" .opencode/ ai-specs/`.
2. Verificar que retorna 0 coincidencias.

**Acceptance Criteria**:
- `.openspec/` no aparece en `.opencode/` ni `ai-specs/`.

---

## Task H7: Verificación integral — clutter eliminado
**Status**: [x]
**Domain**: QA
**Layer**: N/A
**Priority**: High
**Estimate**: XS
**Suggested Path**: repo root
**Test Path**: `git ls-files .openspec/ Digital/` (vacío); `test ! -e Digital/ && test ! -e .openspec/` (exit 0)

**Steps**:
1. Ejecutar `git ls-files .openspec/ Digital/`.
2. Ejecutar `test ! -e Digital/ && test ! -e .openspec/ && echo "clutter gone"`.

**Acceptance Criteria**:
- Ambos directorios eliminados y no trackeados.

---

## Task H8: Verificación integral — YAML de workflows válido
**Status**: [x]
**Domain**: QA
**Layer**: N/A
**Priority**: High
**Estimate**: XS
**Suggested Path**: repo root
**Test Path**: `python -c "import yaml; yaml.safe_load(open('.github/workflows/release.yml'))"` + ci.yml + deploy.yml

**Steps**:
1. Ejecutar `python -c "import yaml; yaml.safe_load(open('.github/workflows/release.yml'))"`.
2. Ejecutar `python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"`.
3. Ejecutar `python -c "import yaml; yaml.safe_load(open('.github/workflows/deploy.yml'))"`.

**Acceptance Criteria**:
- Los tres workflows parsean como YAML válido.

---

## Task H9: Verificación integral — todos los tests pasan
**Status**: [x]
**Domain**: QA
**Layer**: N/A
**Priority**: Critical
**Estimate**: S
**Suggested Path**: repo root
**Test Path**: `for t in tests/*-test.sh; do bash "$t"; done` (todos exit 0)

**Steps**:
1. Ejecutar `for t in tests/*-test.sh; do bash "$t"; done`.

**Acceptance Criteria**:
- Los 9 tests pasan (exit 0 para cada uno).

---

## Traceability to Requirements

| Task | Requirements |
|------|-------------|
| B1 | REQ-004 (npm-distribution reconciliada) |
| B2 | REQ-004 (workflow-node-upgrade reconciliada) |
| B3 | REQ-004 (specboot-release consolida node 24) |
| C1 | REQ-003 (Digital/ eliminado) |
| C2 | REQ-003 (.openspec/ eliminado) |
| D1 | REQ-001 (publish.yml eliminado) |
| E1 | REQ-002 (release.yml bump v5 + node 24) |
| E2 | REQ-002 (ci.yml bump v5 + node 24) |
| E3 | REQ-007 (release-workflow-test.sh cubre node 24) |
| F1 | REQ-005 (README.md reconciliado) |
| F2 | REQ-006 (framework-contract.md lista release.yml) |
| F3 | REQ-004 (versioning-standard.md sin residuos publish.yml) |
| G1 | REQ-007 (ci.yml alineado: 9 tests) |
| G2 | REQ-007 (update-test.sh prueba --bump) |
| H1–H9 | REQ-007 (no regression — todas las validaciones pasan) |
