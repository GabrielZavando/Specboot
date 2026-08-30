# versioning-standard Specification

## Purpose
TBD - created by archiving change versioning-standard. Update Purpose after archive.
## Requirements
### Requirement: SemVer standard defined

The framework SHALL use `MAJOR.MINOR.PATCH` versioning. The version SHALL live in `package.json` of the framework and be reflected in `frameworkVersion` of each project's `.specboot.json`. During `0.x` it SHALL be treated as unstable (a minor may break) but still recorded per the matrix; at `1.0.0` strict SemVer applies.

#### Scenario: Version follows MAJOR.MINOR.PATCH and maps to frameworkVersion

- **Given** the `@gabrielzavando/specboot` package
- **When** a release is cut
- **Then** the version matches `MAJOR.MINOR.PATCH` (e.g. `0.1.1`)
- **And** after `specboot update`, the project's `.specboot.json` `frameworkVersion` matches the installed package version

### Requirement: Breaking-change matrix is canonical

`docs/versioning-standard.md` SHALL contain a table classifying each framework change type and the level it triggers (patch/minor/major), including the changes from tickets 0.1–0.3: `.openspec/`→`openspec/` path fixes = patch; `base-standards.md` placeholder fix = patch; optional `layers` field (0.3) = minor; `docs/` tree restructure (0.2) = major.

#### Scenario: Framework change is classified by the matrix

- **Given** the canonical breaking-change matrix in `docs/versioning-standard.md`
- **When** a concrete framework change is evaluated
- **Then** it receives a patch/minor/major level per the table
- **And** the 0.1–0.3 examples are classified correctly (path fixes = patch, `layers` optional = minor, `docs/` restructure = major)

### Requirement: Consumer meaning per level documented

The document SHALL define, per level, what the consuming project must do: patch = internal change, no action; minor = added capability, no break, may adopt; major = alters interface/injected files, must read release notes and possibly migrate `.specboot.json` / `docs/`.

#### Scenario: Project understands each level

- **Given** a consuming project with `.specboot.json`
- **When** it receives a framework update of a given level
- **Then** patch requires no action, minor requires no migration, major requires reviewing release notes and possibly migrating config/context

### Requirement: specboot update behavior defined

The document SHALL define (for Fase 4) that `specboot update`, on a major jump (project `frameworkVersion` < installed), prints `⚠️ Breaking change. Lee CHANGELOG/release notes de vX.Y.Z` and replaces injected files (option A) but warns; on minor/patch it replaces silently; it never touches project `docs/` or code.

#### Scenario: specboot update warns on major

- **Given** a project whose `frameworkVersion` is below the installed major
- **When** the developer runs `specboot update`
- **Then** the warning is printed and injected files are replaced (option A)
- **And** project `docs/` and code are untouched

#### Scenario: specboot update is silent on minor/patch

- **Given** a project whose `frameworkVersion` is only behind by minor/patch
- **When** the developer runs `specboot update`
- **Then** injected files are replaced without a breaking-change warning

### Requirement: CHANGELOG format and breaking-changes template

The `CHANGELOG.md` SHALL follow Keep a Changelog + Semantic Versioning. Each major release SHALL include a `### Breaking changes` section and (if applicable) a migration section. The `0.1.1` entry SHALL exemplify the format with `### Breaking changes: None` and leave an empty `## [Unreleased]` for future versions.

#### Scenario: CHANGELOG keeps standard format and template

- **Given** the repo `CHANGELOG.md`
- **When** the `0.1.1` entry is added
- **Then** it follows Keep a Changelog + SemVer with a `### Breaking changes` subsection
- **And** an empty `## [Unreleased]` remains for future entries

### Requirement: versioning-standard.md created and linked from contract

The document `docs/versioning-standard.md` SHALL exist and `docs/framework-contract.md` SHALL link to it via a relative markdown link.

#### Scenario: Document is created and linked

- **Given** `docs/versioning-standard.md` written
- **When** a developer reads `docs/framework-contract.md`
- **Then** they find a relative link to `versioning-standard.md`

### Requirement: versioning-standard.md marked untouchable

`docs/versioning-standard.md` SHALL appear in the Intocable column of the framework frontier (in `framework-contract.md`) and be noted as a framework doc in `docs/docs-standard.md`.

#### Scenario: Document is marked intouchable

- **Given** the frontier table in `docs/framework-contract.md`
- **When** a developer reviews the Intocable column
- **Then** `docs/versioning-standard.md` is listed there
- **And** `docs/docs-standard.md` notes it as a framework doc

### Requirement: Passes automated validation

The change SHALL pass the framework's own reference and CI validation: `check-refs.sh` with 0 errors (link uses relative markdown, not `{file:...}`) and `specboot.sh --ci` with no new errors/warnings vs the 0.3 baseline.

#### Scenario: Change passes framework validation

- **Given** the new and modified files of this change
- **When** `check-refs.sh` and `specboot.sh --ci` are executed
- **Then** no broken `{file:...}` references exist and CI exits 0 with no new errors/warnings

