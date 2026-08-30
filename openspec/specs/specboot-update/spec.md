# specboot-update Specification

## Purpose
TBD - created by archiving change specboot-update. Update Purpose after archive.
## Requirements
### Requirement: specboot update subcommand exists
`specboot.sh` MUST expose an `update` subcommand (distinct from `--init`/`--ci`) that refreshes a
project's intocable files from the installed framework version.

#### Scenario: update subcommand refreshes a project
- **WHEN** `specboot update` runs in a project with `.specboot.json`
- **THEN** the framework intocable files are replaced and `frameworkVersion` is updated

### Requirement: Guard against missing .specboot.json
`update` MUST abort with exit 1 and the message `❌ No existe .specboot.json. Usa 'specboot init' para crearlo.` if `.specboot.json` is absent.

#### Scenario: update refuses without config
- **WHEN** `specboot update` runs in a directory without `.specboot.json`
- **THEN** it prints the init suggestion and exits 1 without modifying anything

### Requirement: Version read and resolution
`update` MUST read `frameworkVersion` from `.specboot.json` and resolve the installed framework version, in order, from `specboot.sh --version`, `node_modules/@gabrielzavando/specboot/package.json`, or the repo's own `package.json`.

#### Scenario: Resolves installed version
- **WHEN** `specboot update` runs
- **THEN** it knows both the declared `frameworkVersion` and the installed version

### Requirement: Version jump classification
`update` MUST classify the jump as `major|minor|patch|eq|older|bad`, comparing SemVer after stripping pre-release/build metadata.

#### Scenario: Classifies the jump
- **WHEN** `specboot update` compares `0.2.0` (declared) to `1.0.0` (installed)
- **THEN** it classifies the jump as `major`

### Requirement: Breaking-change warning on major
On a `major` jump, `update` MUST print `⚠️ Breaking change. Lee CHANGELOG/release notes de vX.Y.Z` and ask for confirmation; it proceeds on `y`/`--yes` and cancels (exit 0, no changes) on `N`. On minor/patch no warning is printed.

#### Scenario: update warns then replaces on major
- **WHEN** a project is behind by a major version and `specboot update` runs with `--yes`
- **THEN** the warning prints and injected files are replaced

#### Scenario: update is silent on minor/patch
- **WHEN** a project is behind only by minor/patch
- **THEN** injected files are replaced without a breaking-change warning

### Requirement: Framework source resolution
`update` MUST resolve the framework source directory, preferring `--template <dir>` and defaulting to the script's own directory.

#### Scenario: --template overrides resolution
- **WHEN** `specboot update --template /custom/path` runs
- **THEN** framework files are replaced from `/custom/path`

### Requirement: Backup before replacement
`update` MUST back up replaced intocable files to `.specboot-backup-<timestamp>/` unless `--no-backup` is given. If a `.gitignore` exists, it MUST append the `.specboot-backup-*` pattern.

#### Scenario: Backup created
- **WHEN** `specboot update` replaces files
- **THEN** a `.specboot-backup-<timestamp>/` directory holds the previous versions

### Requirement: Replaces intocable files without mercy (with exclusions)
`update` MUST overwrite the `UPDATE_ITEMS[]` set: `.opencode/commands`, `.opencode/agents`, `ai-specs`, `check-refs.sh`, `specboot.sh`, `validate-specboot.sh`, `templates/ci`, the 5 framework docs, `opencode.json`, `AGENTS.md`, `Makefile`, and the framework's `.github/workflows/*` (file-by-file). `README.md` and `LICENSE` MUST NOT be in `UPDATE_ITEMS[]`; `.github/` as a whole MUST NOT be deleted.

#### Scenario: Intocable set replaced
- **WHEN** `specboot update` runs
- **THEN** the listed intocable items are overwritten even if hand-edited

#### Scenario: README and LICENSE excluded
- **WHEN** `specboot update` runs
- **THEN** the project's `README.md` and `LICENSE` are left intact

### Requirement: Never touches project docs or code
`update` MUST NOT modify any `docs/` file other than the 5 framework docs, nor any project code (`backend/`, `frontend/`, …), nor a project-authored `.github/workflows/*`.

#### Scenario: Project docs and code preserved
- **WHEN** `specboot update` runs
- **THEN** `docs/backend-standards.md`, `docs/project/*`, `docs/api/api-spec.yml`, `docs/data-model/*`, `backend/`, `frontend/`, and project workflows remain unchanged

### Requirement: Rewrites .specboot.json version
If the installed version differs, `update` MUST rewrite `frameworkVersion` in `.specboot.json`, preserving all other fields and 2-space formatting. On `eq`, the file MUST stay byte-identical.

#### Scenario: Version rewritten
- **WHEN** `specboot update` upgrades the framework
- **THEN** `.specboot.json` `frameworkVersion` matches the installed version

#### Scenario: Equal version keeps file intact
- **WHEN** declared and installed versions are equal
- **THEN** `.specboot.json` is unchanged

### Requirement: Post-validation split strictness
After replacement, `update` MUST run `bash check-refs.sh` and `bash specboot.sh --ci` in the target dir. `check-refs.sh` failure MUST cause exit 1 (with the backup path for rollback). `specboot.sh --ci` failure/warning MUST be reported but MUST NOT block (exit 0).

#### Scenario: check-refs failure blocks
- **WHEN** replacement leaves a broken `{file:...}` reference
- **THEN** `specboot update` exits 1 pointing to the backup

#### Scenario: --ci warnings do not block
- **WHEN** the project's `docs/` is incomplete so `--ci` warns
- **THEN** `specboot update` exits 0 after reporting

### Requirement: Documentation and update.sh deprecation
`docs/framework-contract.md` MUST contain an "Actualización con `specboot update`" section and `README.md` MUST show a `specboot update` example. The sync mode of `update.sh` MUST print a deprecation notice pointing to `specboot update`.

#### Scenario: Contract and README document update
- **WHEN** the change is applied
- **THEN** `framework-contract.md` has the section and `README.md` shows the example

#### Scenario: update.sh sync is deprecated
- **WHEN** a developer runs `update.sh` in sync mode
- **THEN** it advises `specboot update` as the canonical path

