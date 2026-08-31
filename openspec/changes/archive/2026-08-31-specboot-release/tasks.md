# Tasks: Workflow de release que publica a npm tras merge a main

## Task 1: Create `.github/workflows/release.yml`
**Status**: [x]
**Domain**: Tooling / CI
**Layer**: N/A (framework infrastructure)
**Priority**: High
**Estimate**: M
**Suggested Path**: .github/workflows/release.yml
**Test Path**: `python -c "import yaml; yaml.safe_load(open('.github/workflows/release.yml'))"` + `grep -nE '^\s*if:.*hashFiles' .github/workflows/release.yml` (debe ser 0)

**Steps**:
1. Create `.github/workflows/release.yml` with `name: Release`, triggers `push: branches: [main]` and `release: types: [published]`.
2. Set `permissions: contents: read, packages: write`.
3. Job `validate` (runs-on: ubuntu-latest): checkout@v4, setup-node@v4 (node 20, registry-url: https://npm.pkg.github.com), npm install, then steps:
   - `bash check-refs.sh`
   - `bash specboot.sh --ci`
   - `make ci`
   - Conditional step: `if: ${{ hashFiles('tests/*-test.sh') != '' }}` running all `tests/*-test.sh` scripts in a loop
4. Job `publish` (runs-on: ubuntu-latest, `needs: validate`): same checkout/setup-node, npm install, `npm pack --dry-run`, then `npm publish` with `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}`.
5. Publish job gated with `if: ${{ (github.event_name == 'push' && github.ref == 'refs/heads/main') || github.event_name == 'release' }}` (paréntesis explícitos para precedencia clara).
6. No `update.sh --bump` invocation in the workflow.

**Acceptance Criteria**:
- YAML parsea con `yaml.safe_load` sin error (REQ-005).
- 0 matches de `hashFiles` en job-level `if` (REQ-005).
- Publica a `https://npm.pkg.github.com` con `secrets.GITHUB_TOKEN` + `packages: write` (REQ-004).
- No invoca `update.sh --bump` (REQ-007).

---

## Task 2: Add "Release automático" section to `docs/versioning-standard.md`
**Status**: [x]
**Domain**: Documentation
**Layer**: N/A
**Priority**: Medium
**Estimate**: S
**Suggested Path**: docs/versioning-standard.md
**Test Path**: check-refs.sh / specboot.sh --ci

**Steps**:
1. Add a new "## Release automático" section after section 6 (Formato de CHANGELOG / Release notes) in `docs/versioning-standard.md`.
2. Document:
   - El workflow `release.yml` dispara en push a `main` (o en Release published).
   - Antes de publicar, valida: `check-refs.sh` + `specboot.sh --ci` + `make ci` + `tests/*.sh`.
   - Si alguna validación falla, no se publica.
   - Publica a GitHub Packages (`https://npm.pkg.github.com`) con `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}`.
   - El mantenedor incrementa `version` en `package.json` (SemVer) antes del merge.
   - El release workflow NO hace bump automático.
3. Use relative markdown links (not `{file:...}`) to avoid breaking `check-refs.sh`.

**Acceptance Criteria**:
- Section present with triggers, validation gate, and version-bump policy (REQ-006).
- `check-refs.sh` → 0 (uses relative markdown links) (REQ-008).

---

## Task 3: Add "Publicación" section to `README.md`
**Status**: [x]
**Domain**: Documentation
**Layer**: N/A
**Priority**: Medium
**Estimate**: S
**Suggested Path**: README.md
**Test Path**: check-refs.sh

**Steps**:
1. Add "## Publicación (release automático)" section after the "Workflows del framework" section in `README.md`.
2. Include YAML snippet showing triggers (`push: branches: [main]` + `release: types: [published]`).
3. Update line 121 (`update.sh --bump` description): clarify that `update.sh --bump` is maintainer convenience for the version bump only; the publish trigger is push-to-`main` / Release-published, NOT a direct tag push. The `publish.yml`-on-tag model from TICKET-1.1 is superseded by `release.yml`.
4. Document that `release.yml` is intocable (reemplazado por `specboot update`).

**Acceptance Criteria**:
- Section present with correct trigger model and updated `update.sh --bump` description (REQ-006).
- `check-refs.sh` → 0 (REQ-008).

---

## Task 4: Validate YAML + framework self-check (no regression)
**Status**: [x]
**Domain**: QA
**Layer**: N/A
**Priority**: High
**Estimate**: S
**Suggested Path**: repo root
**Test Path**: `python -c "import yaml; yaml.safe_load(...)"` + `bash check-refs.sh` + `bash specboot.sh --ci` + `make ci` + `bash tests/*-test.sh`

**Steps**:
1. Validate `release.yml` YAML via `python -c "import yaml; yaml.safe_load(open('.github/workflows/release.yml'))"`.
2. Grep for job-level `hashFiles`: `grep -nE '^\s*if:.*hashFiles' .github/workflows/release.yml` → must be 0.
3. Run `bash check-refs.sh` → 0 errors.
4. Run `bash specboot.sh --ci` → 0 errors.
5. Run `make ci` → exit 0 (stack "framework" → solid-lint skips cleanly).
6. Run all `tests/*-test.sh` → all pass.
7. Edge-case reasoning: confirm that if a `tests/*-test.sh` fails, `validate` job fails → `publish` skipped (Scenario 9) via `needs: validate`.

**Acceptance Criteria**:
- YAML valid, 0 job-level `hashFiles`, all framework validations green (REQ-005, REQ-008).

---

## Traceability to Requirements
| Task | Requirements |
|------|-------------|
| T1 | REQ-001, REQ-003, REQ-004, REQ-005, REQ-007 |
| T2 | REQ-006, REQ-008 |
| T3 | REQ-006, REQ-008 |
| T4 | REQ-005, REQ-008 |
