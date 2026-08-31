# npm-distribution Specification

The framework SHALL be packaged and distributed as a private npm package `@gabrielzavando/specboot` via GitHub Packages, with a clean `files` allowlist, automated release via `release.yml`, and documentation for consumers.

## MODIFIED Requirements

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
