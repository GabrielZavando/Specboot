# specboot-init Specification

## Purpose
TBD - created by archiving change specboot-init. Update Purpose after archive.
## Requirements
### Requirement: specboot init subcommand exists
`specboot.sh` MUST expose an `init` subcommand (distinct from the existing `--init` verification flag) that bootstraps a new project by injecting framework files, creating `.specboot.json`, and scaffolding `docs/`.

#### Scenario: Init subcommand bootstraps a new project
- **WHEN** `specboot init` runs in an empty target directory
- **THEN** `.specboot.json` is created with defaults and the framework intocable files plus a `docs/` skeleton are copied into the directory

#### Scenario: Existing --init verification stays intact
- **WHEN** `specboot.sh --init` runs after the change is applied
- **THEN** it still verifies project structure and exits 0

### Requirement: Guard against existing .specboot.json
`init` MUST abort with a warning and exit 0 if `.specboot.json` already exists in the target directory, advising `specboot update` instead.

#### Scenario: Init refuses to overwrite an existing config
- **WHEN** `specboot init` runs in a directory that already has `.specboot.json`
- **THEN** it prints a warning advising `specboot update` and exits 0 without modifying anything

### Requirement: Framework source resolution
`init` MUST resolve the framework source directory, preferring `node_modules/@gabrielzavando/specboot` when present and falling back to the script's own directory. A `--template <dir>` flag MUST override the resolution.

#### Scenario: Resolves source from node_modules when installed
- **WHEN** the target project has `node_modules/@gabrielzavando/specboot` and `specboot init` runs without `--template`
- **THEN** framework files are copied from that package directory

#### Scenario: Resolves source from script directory by default
- **WHEN** `specboot init` runs from the framework repo itself (no node_modules package)
- **THEN** framework files are copied from the script's own directory

#### Scenario: --template overrides resolution
- **WHEN** `specboot init --template /custom/path` runs
- **THEN** framework files are copied from `/custom/path`

### Requirement: Copies framework intocable files
`init` MUST copy the framework's intocable files (the `package.json` `files` allowlist: `.opencode/`, `ai-specs/`, `check-refs.sh`, `specboot.sh`, `validate-specboot.sh`, `templates/ci/`, the 5 framework docs, `opencode.json`, `AGENTS.md`, `Makefile`, `.github/`, `LICENSE`, `README.md`) from the resolved source into the target directory.

#### Scenario: Intocable files are copied
- **WHEN** `specboot init` runs in a fresh directory
- **THEN** the framework files listed above are present in the target directory after the run

### Requirement: Creates .specboot.json
`init` MUST create `.specboot.json` in the target directory with default values (`frameworkVersion` from the framework, `services: ["."]`, `stack: "framework"`) or, when `--interactive` is passed, with values collected from the user (name, stack, services).

#### Scenario: Default .specboot.json created
- **WHEN** `specboot init` runs without `--interactive`
- **THEN** `.specboot.json` contains `frameworkVersion`, `services: ["."]` and `stack: "framework"`

#### Scenario: Interactive .specboot.json created
- **WHEN** `specboot init --interactive` runs and the user supplies name/stack/services
- **THEN** `.specboot.json` reflects the entered values

### Requirement: Creates docs skeleton
`init` MUST create the project-owned `docs/` skeleton with placeholder templates (backend-standards.md, frontend-standards.md, ci-standards.md, deploy-standards.md, documentation-standards.md, project/{domain,stack,client}.md, api/api-spec.yml, data-model/data-model.md) when `docs/` is missing.

#### Scenario: Docs skeleton scaffolded
- **WHEN** `specboot init` runs in a directory without `docs/`
- **THEN** the project-owned `docs/` files are created with placeholder content

### Requirement: Never overwrites existing project files
`init` MUST NOT overwrite files already present in the target directory; existing files are skipped with a warning.

#### Scenario: Existing files are preserved
- **WHEN** `specboot init` runs in a directory that already has a project-owned file (e.g. `AGENTS.md`)
- **THEN** that file is preserved and a warning is printed

### Requirement: Documentation updated
`docs/framework-contract.md` MUST contain a section documenting "Inicialización con `specboot init`" and `README.md` MUST include a usage example.

#### Scenario: Contract and README document init
- **WHEN** the change is applied
- **THEN** `docs/framework-contract.md` has the init section and `README.md` shows a `specboot init` example

### Requirement: Validation stays green
After the change, `bash check-refs.sh` and `bash specboot.sh --ci` MUST both exit 0 and `openspec validate specboot-init` MUST pass.

#### Scenario: Framework checks pass
- **WHEN** the change artifacts are written and the CLI runs
- **THEN** `check-refs.sh` exits 0, `specboot.sh --ci` exits 0, and `openspec validate specboot-init` passes

