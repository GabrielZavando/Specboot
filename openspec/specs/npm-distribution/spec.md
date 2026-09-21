# npm-distribution Specification

## Purpose
TBD - created by archiving change specboot-npm-publish. Update Purpose after archive.
## Requirements
### Requirement: Package configuration

The package `files` allowlist MUST include the framework assets, the 7
intocable framework docs (including `docs/tdd-failure-protocol.md`), the root
script `release-bump.sh`, and the consumer workflow templates under
`templates/github/` (including the PR template source). The allowlist MUST NOT
include `.github/workflows/**`.

#### Scenario: Allowlist includes templates and excludes workflows

- **WHEN** `package.json#files` is inspected
- **THEN** `templates/github/` (consumer templates + PR template source) is
  included and `.github/workflows` is absent

#### Scenario: release-bump.sh is published

- **WHEN** `npm pack` runs on the framework repository
- **THEN** the tarball contains `release-bump.sh`

### Requirement: Automated publication

The repository SHALL contain a GitHub Actions workflow (`release.yml`) that publishes the package to GitHub Packages when a commit is pushed to `main` or when a GitHub Release is published, using the runner-provided `GITHUB_TOKEN` with `packages: write` permissions, gated by a full framework validation (`validate` job with `check-refs.sh` + `specboot.sh --ci` + `make ci` + `tests/*-test.sh`).

`publish.yml` is **superseded** by `release.yml` and SHALL NOT exist.

#### Scenario: Publication triggered by push to main

- **Given** a commit is pushed to the `main` branch
- **When** the `release.yml` workflow is triggered
- **Then** the `validate` job runs (check-refs.sh + specboot.sh --ci + make ci + tests/*.sh)
- **And** if validation passes, the `publish` job publishes the package to GitHub Packages
- **And** the published package is visible in the GitHub Packages section of the repository owner

#### Scenario: Publication triggered by GitHub Release published

- **Given** a GitHub Release is published on the repository
- **When** the `release.yml` workflow is triggered by `release: types: [published]`
- **Then** the `validate` job runs
- **And** if validation passes, the `publish` job publishes the package to GitHub Packages
- **And** the published package is visible in the GitHub Packages section of the repository owner

#### Scenario: publish.yml is superseded and does not exist

- **Given** the `.github/workflows/publish.yml` file existed in a previous version of the framework
- **When** this change is applied
- **Then** `.github/workflows/publish.yml` does NOT exist
- **And** `release.yml` is the only publication workflow
- **And** `release.yml` uses `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}` with `permissions: packages: write`

### Requirement: Consumption documentation

`README.md` SHALL document how consumers authenticate against GitHub Packages — both for
local installs (`npm login` with a PAT holding `read:packages`, or an `.npmrc` entry) and
for **CI installs** — and how to install the package with standard NPM commands.

For CI installs, `README.md` SHALL include a section **"Autenticación para consumidores
(CI)"** covering two scenarios:

1. **Same owner/org with granted access**: a consumer repository with access granted in
   Package settings → Manage Actions access can use the runner-provided `secrets.GITHUB_TOKEN`
   with `permissions: packages: read` and `registry-url: https://npm.pkg.github.com`.
2. **Different owner / no granted access**: requires a PAT with scope `read:packages`
   saved as a repository secret (e.g. `NPM_TOKEN`), equivalent to the local `.npmrc` /
   `npm login` mechanism.

Additionally, the section SHALL include troubleshooting for common `401` (missing
`NODE_AUTH_TOKEN`, or PAT without `read:packages`) and `403` (repository without access
granted in Package settings) errors.

#### Scenario: Consumer installs the package locally

- **Given** a consumer project configured with a valid GitHub PAT (`read:packages`) in `.npmrc` for the `@gabrielzavando` scope
- **When** running `npm install --save-dev @gabrielzavando/specboot`
- **Then** the package is installed in `node_modules/@gabrielzavando/specboot`
- **And** the consumer can execute `bash node_modules/@gabrielzavando/specboot/specboot.sh --init`

#### Scenario: Consumer installs the package in CI (same owner with granted access)

- **Given** a consumer repository with access granted to the package in Package settings
- **When** the CI workflow uses a step with `registry-url: https://npm.pkg.github.com`,
  `permissions: packages: read`, and `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}`
- **Then** `npm install` runs without a `401`/`403` error

#### Scenario: Consumer installs the package in CI (different owner / no granted access)

- **Given** a consumer repository without granted access to the package
- **When** the CI workflow is configured with a secret holding a PAT scoped with `read:packages`
- **Then** `npm install` authenticates using that secret instead of `GITHUB_TOKEN`

#### Scenario: Troubleshooting 401/403 in CI

- **Given** a consumer CI install fails
- **When** the failure is a `401`
- **Then** `README.md` explains the likely causes: missing `NODE_AUTH_TOKEN`, or a PAT without `read:packages` scope
- **And** when the failure is a `403`, `README.md` explains the repository lacks access granted in Package settings → Manage Actions access

### Requirement: Reconciled .npmignore

The repository SHALL contain a `.npmignore` that does NOT block any path in the
`files` allowlist (i.e. it MUST NOT contain blanket `.github/`, `.opencode/` or
`templates/` exclusions) while still excluding internal repository state
(`.git/`, `openspec/`, `tests/`, `node_modules/`, `.env*`, `CHANGELOG.md`,
`*.log`, `.DS_Store`, and the legacy `.openspec/`).

#### Scenario: .npmignore does not shadow the allowlist

- **GIVEN** `files` allowlists `.opencode/commands`, `.opencode/agents` and
  `templates/github/**` (and no longer `.github/workflows`)
- **WHEN** running `npm pack --dry-run`
- **THEN** the allowlisted paths are present in the tarball and no internal
  workflow ships
- **AND** `openspec/`, `tests/`, `node_modules/`, `.git/` remain excluded

### Requirement: Self-consistent shipped CLI

`specboot.sh` SHALL NOT list `update.sh` in its `REQUIRED_FILES` array, because `update.sh` is no longer shipped in the package.

#### Scenario: Shipped CLI validation passes
- **Given** `update.sh` is absent from the installed package
- **When** a consumer runs `bash specboot.sh --ci`
- **Then** the validation exits 0 (no missing-required-file failure)

### Requirement: Distribution boundary documentation

`README.md` and `docs/framework-contract.md` SHALL explicitly document the npm
distribution boundary: what the package includes (the `files` allowlist of
intocable framework assets, now with the consumer templates under
`templates/github/` and without `.github/workflows/**`), what stays in the
project, and the distinction between the Specboot repository's internal
workflows (`release.yml`, repo-only) and the consumer templates installed by
`init`/`update` via explicit file lists.

#### Scenario: README documents the boundary and the workflow split

- **GIVEN** `package.json` declares a `files` allowlist with consumer templates
  and without internal workflows
- **WHEN** a reader opens `README.md`
- **THEN** internal workflows and consumer templates are distinguished
  explicitly, and the default install set (consumer CI + PR template) is stated

#### Scenario: framework-contract reaffirms intocable-only

- **GIVEN** `docs/framework-contract.md` describes the distribution architecture
- **WHEN** a reader opens the document
- **THEN** `init`/`update` distribute GitHub artifacts via explicit file lists
  (never the `.github` tree as a whole)

### Requirement: Internal workflows are never packaged

The npm package MUST NOT include any file under `.github/workflows/**`
(including `release.yml`). The consumer workflow templates
(`templates/github/workflows/consumer-ci.yml`,
`templates/github/workflows/deploy.example.yml`) and the PR template source
(`templates/github/pull_request_template.md`) MUST be included so consumers
receive the artifacts `init` installs. `npm pack --dry-run` MUST reflect both
rules.

#### Scenario: npm pack excludes internal workflows and includes templates

- **WHEN** `npm pack --dry-run` runs on the framework repository
- **THEN** no `.github/workflows/**` path appears in the tarball
- **AND** `templates/github/workflows/consumer-ci.yml`,
  `templates/github/workflows/deploy.example.yml` and
  `templates/github/pull_request_template.md` appear in the tarball

