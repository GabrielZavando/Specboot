# npm-distribution Specification

## Purpose
TBD - created by archiving change specboot-npm-publish. Update Purpose after archive.
## Requirements
### Requirement: Package configuration

The repository SHALL contain a `package.json` declaring the package name `@gabrielzavando/specboot`, an initial version `0.1.2`, the `publishConfig.registry` pointing to `https://npm.pkg.github.com`, a `bin.specboot` entry pointing to `specboot.sh` (pre-normalized path, no `./` prefix), `scripts` (`check`, `validate`, `ci`), and a `files` allowlist that includes ONLY the following intocable framework assets:
- `.opencode/commands`
- `.opencode/agents`
- `ai-specs`
- `check-refs.sh`
- `specboot.sh`
- `validate-specboot.sh`
- `templates/ci`
- `docs/base-standards.md`
- `docs/framework-contract.md`
- `docs/docs-standard.md`
- `docs/specboot-json-standard.md`
- `docs/versioning-standard.md`
- `opencode.json`
- `AGENTS.md`
- `Makefile`
- `.github/workflows`
- `LICENSE`
- `README.md`

while EXCLUDING internal repository state (`.git/`, `.github/` other than `workflows`, `openspec/`, `tests/`, `node_modules/`, the project `docs/` tree, the standalone `update.sh`, `CHANGELOG.md`). The `description` MUST NOT contain the word "template" and `keywords` MUST reflect a framework (e.g. `sdd`, `openspec`, `opencode`, `framework`, `spec-driven-development`, `agents`).

#### Scenario: Package content validation
- **Given** the `package.json` is configured with the `files` allowlist
- **When** running `npm pack --dry-run`
- **Then** only the allowlisted framework files are included in the package
- **And** internal repository files (`.git/`, `openspec/`, `tests/`, `node_modules/`, project `docs/`, `update.sh`) are excluded

#### Scenario: bin entry survives publish normalization without warnings
- **Given** the `package.json` declares `"bin": { "specboot": "specboot.sh" }`
- **When** running `npm publish --dry-run`
- **Then** no bin normalization warning is emitted
- **And** the `bin.specboot` entry still points to the shipped `specboot.sh` script

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

The repository SHALL contain a `.npmignore` that does NOT block any path in the `files` allowlist (i.e. it MUST NOT contain blanket `.github/` or `.opencode/` exclusions) while still excluding internal repository state (`.git/`, `openspec/`, `tests/`, `node_modules/`, `.env*`, `CHANGELOG.md`, `*.log`, `.DS_Store`, and the legacy `.openspec/`).

#### Scenario: .npmignore does not shadow the allowlist
- **Given** `files` allowlists `.opencode/commands`, `.opencode/agents`, `.github/workflows`
- **When** running `npm pack --dry-run`
- **Then** those three paths are present in the tarball
- **And** `openspec/`, `tests/`, `node_modules/`, `.git/` remain excluded

### Requirement: Self-consistent shipped CLI

`specboot.sh` SHALL NOT list `update.sh` in its `REQUIRED_FILES` array, because `update.sh` is no longer shipped in the package.

#### Scenario: Shipped CLI validation passes
- **Given** `update.sh` is absent from the installed package
- **When** a consumer runs `bash specboot.sh --ci`
- **Then** the validation exits 0 (no missing-required-file failure)

### Requirement: Distribution boundary documentation

`README.md` and `docs/framework-contract.md` SHALL explicitly document the npm distribution boundary: what the package includes (the `files` allowlist of intocable framework assets) and what stays in the project (application code, project `docs/` except the 5 standards, `.specboot.json`, project MCP, env/GitHub vars), including a note that the Specboot development repository's own `docs/` are not published because they are filtered out by `files`.

#### Scenario: README documents the boundary
- **Given** `package.json` declares a `files` allowlist shipping only intocable framework assets
- **When** a reader opens `README.md`
- **Then** a "Qué incluye el paquete" section lists the allowlisted assets
- **And** a "Qué es del proyecto" section lists the NOT-shipped assets (app code, project `docs/` minus 5 standards, `.specboot.json`, project MCP, env/GitHub vars)

#### Scenario: framework-contract reaffirms intocable-only
- **Given** `docs/framework-contract.md` describes the distribution architecture
- **When** a reader opens the document
- **Then** a "Distribución vía npm" subsection states `files` is the source of truth and project `docs/` is filtered out by the allowlist

