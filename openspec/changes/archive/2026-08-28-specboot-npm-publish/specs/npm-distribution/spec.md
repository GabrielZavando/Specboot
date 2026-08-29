# Capability: npm-distribution

Specboot is distributed as a private NPM package (`@gabrielzavando/specboot`) hosted on GitHub Packages, so consumer applications can install and update it via standard NPM commands.

## ADDED Requirements

### Requirement: Package configuration

The repository SHALL contain a `package.json` declaring the package name `@gabrielzavando/specboot`, an initial version `0.1.0`, the `publishConfig.registry` pointing to `https://npm.pkg.github.com`, and a `files` allowlist that includes framework assets (`docs/`, `ai-specs/`, `templates/`, `specboot.sh`, `update.sh`, `check-refs.sh`, `Makefile`, `AGENTS.md`, `opencode.json`, `README.md`, `LICENSE`) while excluding internal repository state (`.git/`, `.github/`, `tests/`, `openspec/`, `.opencode/`, `CHANGELOG.md`).

#### Scenario: Package content validation

- **Given** the `package.json` is configured with the `files` allowlist
- **When** running `npm pack --dry-run`
- **Then** only the allowlisted framework files are included in the package
- **And** internal repository files (`.git/`, `.github/`, `tests/`, `openspec/`) are excluded

### Requirement: Automated publication

The repository SHALL contain a GitHub Actions workflow (`publish.yml`) that publishes the package to GitHub Packages when a git tag matching `v*.*.*` is pushed, using the runner-provided `GITHUB_TOKEN` with `packages: write` permissions.

#### Scenario: Publication triggered by version tag

- **Given** a git tag `v0.1.0` matching the version in `package.json` is pushed to the repository
- **When** the `publish.yml` workflow is triggered
- **Then** the package is published successfully to GitHub Packages
- **And** the published package is visible in the GitHub Packages section of the repository owner

### Requirement: Consumption documentation

The `README.md` SHALL document how consumers authenticate against GitHub Packages (via `npm login` with a PAT holding `read:packages`, or an `.npmrc` entry) and how to install the package with standard NPM commands.

#### Scenario: Consumer installs the package

- **Given** a consumer project configured with a valid GitHub PAT (`read:packages`) in `.npmrc` for the `@gabrielzavando` scope
- **When** running `npm install --save-dev @gabrielzavando/specboot`
- **Then** the package is installed in `node_modules/@gabrielzavando/specboot`
- **And** the consumer can execute `bash node_modules/@gabrielzavando/specboot/specboot.sh --init`
