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

The `validate` job SHALL run `bash check-refs.sh`, `bash specboot.sh --ci`, `make ci`, and all `tests/*-test.sh` scripts. If any step fails, the job exits non-zero and the `publish` job is skipped.

#### Scenario: validate runs check-refs, specboot --ci, make ci, and framework self-tests

- **GIVEN** the Specboot framework repo (has `tests/*-test.sh`, `check-refs.sh`, `specboot.sh`, `Makefile`, `.specboot.json` with `stack: "framework"`)
- **WHEN** the `validate` job runs
- **THEN** it executes `bash check-refs.sh`, `bash specboot.sh --ci`, `make ci`, and the `tests/*-test.sh` scripts

#### Scenario: validate failure blocks publish

- **GIVEN** the `release.yml` workflow has `validate` and `publish` jobs with `needs: validate`
- **WHEN** the `validate` job fails (e.g. a `tests/*-test.sh` script exits non-zero)
- **THEN** the `publish` job does not run
- **AND** the package is not published to GitHub Packages

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

