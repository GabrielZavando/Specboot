# specboot-release Specification

## Purpose
TBD - created by archiving change specboot-release. Updated by cleanup-publish-and-junk to add node 24 requirement (consolidating workflow-node-upgrade).
## Requirements
### Requirement: `release.yml` uses actions v5 and node 24

`release.yml` SHALL use `actions/checkout@v5`, `actions/setup-node@v5`, and `node-version: '24'` in all its jobs (both `validate` and `publish`). This consolidates the requirement from `workflow-node-upgrade` and ensures no Node.js 20 deprecation warnings in the release workflow.

#### Scenario: release.yml uses checkout@v5, setup-node@v5, and node 24

- **Given** the Specboot framework repo with `.github/workflows/release.yml`
- **WHEN** the workflow is inspected
- **THEN** it uses `actions/checkout@v5` (not @v4)
- **AND** it uses `actions/setup-node@v5` (not @v4)
- **AND** it uses `node-version: '24'` (not 20)
- **AND** no Node.js deprecation warnings appear in the workflow logs

### Requirement: `release.yml` triggers on push to `main` and on Release published

`release.yml` SHALL be triggered on `push: branches: [main]` AND on `release: types: [published]`.

#### Scenario: release.yml triggers on push to main

- **GIVEN** the Specboot framework repo with `.github/workflows/release.yml`
- **WHEN** a commit is pushed to the `main` branch
- **THEN** the `release` workflow is triggered
- **AND** the `validate` job runs

#### Scenario: release.yml triggers on GitHub Release published

- **GIVEN** the Specboot framework repo with `.github/workflows/release.yml`
- **WHEN** a GitHub Release is published (release event, `types: [published]`)
- **THEN** the `release` workflow is triggered
- **AND** the `validate` job runs

### Requirement: `validate` job runs full framework self-check

The `validate` job SHALL run `bash check-refs.sh`, `bash specboot.sh --ci`, `make
ci`, and all `tests/*-test.sh` scripts. If any step fails, the job exits non-zero
and the `publish` job is skipped. The `actions/checkout` step of the `validate`
job SHALL set `fetch-depth: 0` so the self-check and the historical-provenance
tests (`tests/specboot-update-test.sh`, which query historical `release.yml`
variants via `git show`/`git log`) have the full git history and do not fail on a
push to `main`. The `publish` job's `actions/checkout` SHALL remain unchanged
(no `fetch-depth: 0`) and the `publish` job SHALL keep `needs: validate`.

#### Scenario: validate checkout enables full history

- **GIVEN** a push to `main` that triggers `.github/workflows/release.yml`
- **WHEN** the `validate` job runs
- **THEN** its `actions/checkout` step sets `fetch-depth: 0`
- **AND** `tests/specboot-update-test.sh` passes with the full git history
  available

#### Scenario: validate failure blocks publish

- **GIVEN** the `release.yml` workflow has `validate` and `publish` jobs with
  `needs: validate`
- **WHEN** the `validate` job fails (e.g. a `tests/*-test.sh` script exits
  non-zero)
- **THEN** the `publish` job does not run
- **AND** the package is not published to GitHub Packages

#### Scenario: publish checkout stays unchanged and dependent

- **GIVEN** `fetch-depth: 0` on the `validate` job's checkout
- **WHEN** the `publish` job is inspected
- **THEN** the `publish` job's `actions/checkout` does NOT set `fetch-depth: 0`
- **AND** the `publish` job keeps `needs: validate`

### Requirement: `publish` job publishes to GitHub Packages with GITHUB_TOKEN

The `publish` job SHALL run `npm pack --dry-run` then `npm publish` to `https://npm.pkg.github.com` (from `publishConfig` in `package.json`), using `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}` with `permissions: packages: write`.

#### Scenario: publish succeeds on validation pass

- **GIVEN** the `publish` job runs after `validate` passes
- **WHEN** `npm pack --dry-run` succeeds and `npm publish` executes
- **THEN** the package is published to `https://npm.pkg.github.com`
- **AND** it uses `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}` with `permissions: packages: write`

### Requirement: `release.yml` is valid YAML with no job-level `hashFiles()`

The `release.yml` SHALL parse with `yaml.safe_load` without error and SHALL NOT use `hashFiles()` in any job-level `if` (only in `steps[*].if`, if at all).

#### Scenario: release.yml YAML is valid

- **GIVEN** the `release.yml` file exists
- **WHEN** `python -c "import yaml; yaml.safe_load(open('.github/workflows/release.yml'))"` runs
- **THEN** it parses without error

#### Scenario: no job-level hashFiles in release.yml

- **GIVEN** the change applied
- **WHEN** `grep -nE '^\s*if:.*hashFiles' .github/workflows/release.yml` runs
- **THEN** it matches zero job-level lines (any `hashFiles` appears only inside a `steps:` block)

### Requirement: Documentation documents the automatic release

`docs/versioning-standard.md` SHALL have a "Release automático" section documenting workflow triggers (push to `main` / Release published), the validation gate (`check-refs.sh` + `specboot.sh --ci` + `make ci` + `tests/*.sh`), and that the maintainer bumps `version` in `package.json` (SemVer) before merge, with the workflow NOT doing automatic bump. `README.md` SHALL have a "Publicación (release automático)" section with a YAML snippet of triggers and an updated `update.sh --bump` description (maintainer convenience, not direct workflow trigger).

#### Scenario: versioning-standard.md has release automatico section

- **GIVEN** the change applied
- **WHEN** `docs/versioning-standard.md` is inspected
- **THEN** it has a "Release automático" section documenting triggers, validation gate, and manual version-bump policy

#### Scenario: README.md has publicacion section with updated bump description

- **GIVEN** the change applied
- **WHEN** `README.md` is inspected
- **THEN** it has a "Publicación (release automático)" section with YAML snippet of triggers
- **AND** the `update.sh --bump` description reflects that the publish trigger is push-to-`main` / Release-published, NOT a direct tag push

### Requirement: No regression in framework validations

After the change, the YAML SHALL parse, `check-refs.sh` SHALL report 0 errors, `specboot.sh --ci` SHALL report 0 errors, `make ci` SHALL exit 0, and all `tests/*-test.sh` SHALL pass.

#### Scenario: framework self-check stays green after release.yml

- **GIVEN** the change applied to the framework repo (branch based on Fase 4: 4.1 + 4.2)
- **WHEN** `python -c "import yaml; yaml.safe_load(open('.github/workflows/release.yml'))"`, `bash check-refs.sh`, `bash specboot.sh --ci`, `make ci`, and all `tests/*-test.sh` run
- **THEN** the YAML parses, `check-refs.sh` reports 0 errors, `specboot.sh --ci` reports 0 errors, `make ci` exits 0, and all tests pass

### Requirement: `release.yml` is intocable and does not invoke `update.sh --bump`

The workflow `release.yml` SHALL be an intocable framework file (replaced by `specboot update`, not editable by consumer projects). It SHALL NOT invoke `update.sh --bump` (which is a maintainer-only local convenience tool for the version bump).

#### Scenario: release.yml does not invoke update.sh --bump

- **GIVEN** the change applied
- **WHEN** `release.yml` is inspected
- **THEN** it does not contain `update.sh` or `--bump`

### Requirement: `release-workflow-test.sh` enforces fetch-depth exclusively on validate (REQ-003)

`tests/release-workflow-test.sh` SHALL verify that `fetch-depth: 0` is declared
exclusively inside the `validate` job of `.github/workflows/release.yml` and is
NOT present in the `publish` job. If `fetch-depth: 0` disappears from `validate`
or is added to `publish`, the test SHALL fail (exit non-zero).

#### Scenario: contract passes with fetch-depth only on validate

- **GIVEN** `.github/workflows/release.yml` with `fetch-depth: 0` on the
  `validate` job's checkout only
- **WHEN** `bash tests/release-workflow-test.sh` runs
- **THEN** it passes (exit 0)

#### Scenario: contract fails if fetch-depth leaves validate or enters publish

- **GIVEN** `fetch-depth: 0` removed from the `validate` job or added to the
  `publish` job of `.github/workflows/release.yml`
- **WHEN** `bash tests/release-workflow-test.sh` runs
- **THEN** it fails (exit non-zero)

### Requirement: The legacy-repair regression fixture MUST derive from git history (REQ-004)

The legacy-repair regression fixture MUST derive the exact/matched variant from
the immutable git history (pre-isolation v3 commit) instead of copying the live
internal `release.yml`, because REQ-001 evolves that file and its content
fingerprint stops matching the distributed legacy variants. The
`KNOWN_RELEASE_FINGERPRINTS` allowlist MUST NOT be altered, and the HARDEN-02
repair contract (exact legacy removed + backed up; modified legacy preserved with
explicit-resolution warning) MUST keep passing.

#### Scenario: legacy-repair fixture uses a git-derived legacy variant

- **GIVEN** the framework repo after REQ-001 evolved the internal `release.yml`
- **WHEN** `tests/specboot-update-test.sh` runs its legacy-repair tests
- **THEN** the exact-match fixture is derived from git history (v3 pre-isolation
  commit), not copied from the live internal `release.yml`
- **AND** the exact legacy variant is removed and backed up, and a modified one
  is preserved with a warning — without touching the fingerprints allowlist

#### Scenario: framework self-check stays green

- **GIVEN** the change applied to the framework repo
- **WHEN** `bash tests/release-workflow-test.sh`, `bash tests/specboot-update-test.sh`,
  `bash tests/run-all.sh`, `bash specboot.sh --ci` and `bash check-refs.sh` run
- **THEN** all pass and `specboot.sh --ci` / `check-refs.sh` report 0 errors

