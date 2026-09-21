# npm-distribution Specification Delta

## ADDED Requirements

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

## MODIFIED Requirements

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
