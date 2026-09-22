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

`update` MUST overwrite the `UPDATE_ITEMS[]` set, which now includes
`release-bump.sh` (root script, same criterion as `check-refs.sh`) alongside
the 7 intocable framework docs. Because `.opencode/agents` is replaced
whole-tree, a consumer's stale `plan.md` MUST disappear after updating to the
framework version that renamed the agent to `sdd-plan`.

#### Scenario: update propagates release-bump.sh

- **WHEN** a consumer project runs `specboot update`
- **THEN** `release-bump.sh` exists in the project root

#### Scenario: stale plan.md agent is wiped on update

- **WHEN** a consumer project containing a legacy `.opencode/agents/plan.md` runs `specboot update`
- **THEN** the file no longer exists and `.opencode/agents/sdd-plan.md` is present

### Requirement: Never touches project docs or code
`update` MUST NOT modify any `docs/` file other than the 6 framework docs, nor any project code (`backend/`, `frontend/`, …), nor a project-authored `.github/workflows/*`.

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

### Requirement: Legacy release.yml workflows are detected and repaired safely (REQ-002)

`specboot update` MUST detect a legacy Specboot-owned `release.yml` in the
consumer's `.github/workflows/` using an allowlist of known framework-owned
signatures: the exact content fingerprints of EVERY `release.yml` variant
Specboot distributed before artifact isolation, derived from the framework's
git history and documented as immutable legacy content. The allowlist MUST
NOT be derived from the current internal `.github/workflows/release.yml`
(which may evolve and is no longer distributed). When the file matches ANY
allowlisted fingerprint exactly, update MUST back it up (`.specboot-backup-*/`)
before removing it. When the file does NOT match any allowlisted fingerprint
exactly (it was modified, or it is not the framework's file — e.g. a
consumer-authored `release.yml`), update MUST warn and require explicit
resolution — it MUST NEVER delete a non-matching `release.yml` automatically.
Custom workflows unrelated to the framework MUST always be preserved, and the
framework's internal `release.yml`/`deploy.yml` are never installed by `init`
or `update`.

#### Scenario: Intact legacy release is backed up and removed

- **GIVEN** a consumer whose `.github/workflows/release.yml` matches any
  allowlisted framework-owned fingerprint exactly
- **WHEN** `specboot update` runs
- **THEN** the file is backed up to `.specboot-backup-*/` before removal
- **AND** the file is then removed and the removal and backup path are reported

#### Scenario: Every distributed legacy variant is repaired

- **GIVEN** a consumer contaminated with any `release.yml` variant Specboot
  distributed before artifact isolation (each historical version of the
  framework's `release.yml`, identified by its immutable content fingerprint)
- **WHEN** `specboot update` runs
- **THEN** every matching variant is backed up and removed exactly like the
  latest variant

#### Scenario: The fingerprint allowlist covers the distributed history

- **GIVEN** the framework repo with git history for its internal `release.yml`
- **WHEN** the regression tests derive the content fingerprints of every
  pre-isolation `release.yml` variant from the git history
- **THEN** each derived fingerprint is present in the update allowlist
- **AND** no allowlist entry exists outside that historical set (no invented
  hashes), and the allowlist is documented as immutable legacy content, never
  derived from the current internal `release.yml`

#### Scenario: Modified legacy release requires explicit resolution

- **GIVEN** a consumer whose `release.yml` was modified (no longer matches the
  known signature exactly)
- **WHEN** `specboot update` runs
- **THEN** update warns and requires explicit resolution without deleting the
  file automatically

#### Scenario: Custom workflows survive the update

- **GIVEN** a consumer with custom workflows unrelated to the framework
- **WHEN** `specboot update` runs
- **THEN** every custom workflow remains intact
- **AND** no update step deletes or overwrites workflows outside the
  framework-owned set

### Requirement: init/update and validation modes operate on the target project (REQ-008)

`specboot init`, `specboot update` and the `--ci`/`--init` validation modes MUST
operate on the directory from which `specboot.sh` was invoked (the target
project), even when the script executes from
`node_modules/@gabrielzavando/specboot`. The framework source resolution for
project `init`/`update` is unchanged (the script's own directory or
`--template`); only the validation target changes: `--ci` and `--init` MUST
validate the invocation directory, never the package's own content.

#### Scenario: --ci from node_modules validates the consumer

- **GIVEN** a consumer project with the framework installed in
  `node_modules/@gabrielzavando/specboot` and an invalid configuration in the
  consumer
- **WHEN** the consumer runs `bash node_modules/@gabrielzavando/specboot/specboot.sh --ci`
- **THEN** the validation runs against the invocation directory (the consumer)
- **AND** the invalid configuration is detected and reported

#### Scenario: --init from node_modules targets the invocation directory

- **GIVEN** the framework executed from `node_modules/@gabrielzavando/specboot`
- **WHEN** `bash node_modules/@gabrielzavando/specboot/specboot.sh --init` runs
- **THEN** the structural validation targets the invocation directory, not the
  package content

#### Scenario: Direct invocation validates its own directory

- **GIVEN** the Specboot framework repo
- **WHEN** `bash specboot.sh --ci` and `bash specboot.sh --init` run from the
  repo root
- **THEN** the validation targets the repo root and passes with conforming
  configuration

#### Scenario: update keeps targeting the project

- **GIVEN** a consumer project
- **WHEN** `specboot update` runs
- **THEN** the replacement targets the invocation directory (the consumer
  project), never the package content

### Requirement: Consumer CI workflow is updated safely (REQ-001, REQ-002)

`specboot update` MUST apply a safe policy to the consumer's
`.github/workflows/ci.yml` instead of overwriting it unconditionally. The
policy is tri-state over the current file: (1) when the file is missing, the
current consumer CI template (`templates/github/workflows/consumer-ci.yml`)
is installed and the installation is reported; (2) when the file exactly
matches (content fingerprint) any known consumer CI variant Specboot
distributed since 0.10.0 — an explicit, immutable allowlist of historical
fingerprints, each with verifiable git provenance, never derived from the
mutable internal `.github/workflows/ci.yml` — update MUST back the file up
(`.specboot-backup-*/`) BEFORE modifying it, replace it with the current
template, and report the repair; (3) when the file was modified or does not
match any known variant (foreign content), update MUST preserve it
byte-for-byte, emit a clear warning requiring explicit user resolution, and
MUST NEVER overwrite it automatically (no silent overwrite). An exact match
with the current template is an idempotent no-op (no backup, no rewrite, no
warning). All other consumer-authored workflows MUST always remain untouched,
`.github/workflows/ci.yml` and `.github/workflows/release.yml` of the
Specboot repo remain internal, `templates/github/workflows/consumer-ci.yml`
remains the only distributable consumer CI source, and no operation copies
the whole `.github` directory. The policy applies identically when update
runs from a `node_modules` installation (consumer mode).

#### Scenario: Missing consumer CI is installed

- **GIVEN** a consumer project without `.github/workflows/ci.yml`
- **WHEN** `specboot update` runs
- **THEN** the current consumer CI template is installed and reported

#### Scenario: Exact historical variant is backed up and updated

- **GIVEN** a consumer whose `.github/workflows/ci.yml` exactly matches a
  known distributed variant (each variant in the allowlist)
- **WHEN** `specboot update` runs
- **THEN** the file is backed up to `.specboot-backup-*/` before modification
- **AND** it is replaced with the current template and the repair is reported

#### Scenario: Modified consumer CI requires explicit resolution

- **GIVEN** a consumer whose `ci.yml` was modified (no longer matches any
  allowlisted fingerprint)
- **WHEN** `specboot update` runs
- **THEN** the file stays byte-for-byte intact
- **AND** a clear warning requires explicit resolution; the file is never
  overwritten automatically

#### Scenario: Foreign consumer CI requires explicit resolution

- **GIVEN** a consumer-authored `ci.yml` never distributed by Specboot
- **WHEN** `specboot update` runs
- **THEN** the file stays byte-for-byte intact with a clear warning (no
  silent overwrite)

#### Scenario: Exact current template is an idempotent no-op

- **GIVEN** a consumer whose `ci.yml` matches the current template exactly
- **WHEN** `specboot update` runs again (and again)
- **THEN** the file remains byte-for-byte identical with no backup, no
  rewrite, and no spurious warnings

#### Scenario: Custom workflows survive init and update

- **GIVEN** a consumer with additional own workflows in `.github/workflows/`
- **WHEN** `init` or `update` runs
- **THEN** none of them is deleted or overwritten

#### Scenario: Policy holds from a node_modules installation

- **GIVEN** a consumer running `specboot update` from the package installed
  in `node_modules/@gabrielzavando/specboot`
- **WHEN** the update evaluates `.github/workflows/ci.yml`
- **THEN** the same tri-state policy applies using the installed package's
  template and allowlist

#### Scenario: The consumer CI allowlist has verifiable provenance

- **GIVEN** the framework git history containing every consumer CI variant
  distributed since 0.10.0
- **WHEN** the regression suite re-derives each variant's content fingerprint
  from pinned commits
- **THEN** every derived fingerprint is present in the `specboot.sh` allowlist
- **AND** no allowlist entry exists outside that historical set (no invented
  hashes), and the allowlist is documented as immutable historical content,
  never derived from the current internal `.github/workflows/ci.yml`

