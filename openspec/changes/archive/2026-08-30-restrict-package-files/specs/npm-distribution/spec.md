# npm-distribution Specification (change delta)

## MODIFIED Requirements

### Requirement: Package configuration

The repository SHALL contain a `package.json` declaring the package name `@gabrielzavando/specboot`, an initial version `0.1.1`, the `publishConfig.registry` pointing to `https://npm.pkg.github.com`, a `bin.specboot` entry pointing to `./specboot.sh`, `scripts` (`check`, `validate`, `ci`), and a `files` allowlist that includes ONLY the following intocable framework assets:
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

## ADDED Requirements

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
