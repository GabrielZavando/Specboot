# specboot-workflows Specification Delta

## ADDED Requirements

### Requirement: The internal release workflow stays repo-internal

`.github/workflows/release.yml` MUST exist only in the Specboot development
repository. It MUST NOT be included in the npm `files` allowlist, MUST NOT be
copied by `specboot init` or `specboot update`, and MUST NOT exist in any
template directory distributed to consumers. A consumer project MUST NOT receive
any workflow that executes `npm publish` of the Specboot package.

#### Scenario: Fresh init does not install the release workflow

- **GIVEN** the Specboot framework with `templates/github/workflows/`
- **WHEN** a new project runs `specboot init`
- **THEN** `.github/workflows/release.yml` does not exist in the project
- **AND** no installed file publishes the Specboot package

#### Scenario: update never copies the release workflow

- **GIVEN** a consumer project running `specboot update`
- **WHEN** the update copies framework workflow files
- **THEN** `release.yml` is never among them

### Requirement: Consumer workflow templates live in an explicit template location

The framework MUST ship consumer workflow artifacts under
`templates/github/`: `templates/github/workflows/consumer-ci.yml` (the only CI
workflow installed by default), `templates/github/workflows/deploy.example.yml`
(optional deploy template, never installed automatically) and
`templates/github/pull_request_template.md` (source of the PR template that
`init` installs into `.github/pull_request_template.md`).

#### Scenario: Templates exist and deploy template is not installed

- **GIVEN** the Specboot framework repository
- **WHEN** the template directory is inspected after a `specboot init` in a
  fresh project
- **THEN** `templates/github/workflows/consumer-ci.yml`,
  `templates/github/workflows/deploy.example.yml` and
  `templates/github/pull_request_template.md` exist
- **AND** the fresh project received `.github/workflows/ci.yml` (from the
  consumer template) and `.github/pull_request_template.md`
- **AND** `deploy.example.yml` was not installed as an active workflow

### Requirement: `specboot update` repairs a contaminated consumer safely

`specboot update` MUST detect a legacy framework-owned `release.yml` in the
consumer's `.github/workflows/`, back it up (`.specboot-backup-*/`) before
removing it when it matches the known framework-owned signature, warn and
require explicit resolution when the file was modified (never removing it
automatically), and MUST never delete or overwrite custom workflows unrelated
to the framework.

#### Scenario: Intact legacy release is backed up and removed

- **GIVEN** a consumer with the legacy framework-owned `release.yml` unmodified
- **WHEN** `specboot update` runs
- **THEN** the file is copied to the backup directory and then removed
- **AND** the removal and backup path are reported

#### Scenario: Modified legacy release requires explicit resolution

- **GIVEN** a consumer whose `release.yml` no longer matches the framework
  signature
- **WHEN** `specboot update` runs
- **THEN** the update warns and requires explicit resolution without deleting
  the file automatically

#### Scenario: Custom workflows survive the update

- **GIVEN** a consumer with a custom workflow unrelated to the framework
- **WHEN** `specboot update` runs
- **THEN** the custom workflow remains intact

### Requirement: init/update distribute workflows via explicit file lists

`specboot init` and `specboot update` MUST use explicit file lists for
GitHub-related artifacts and MUST NOT copy the `.github` tree as a whole. Only
the consumer CI workflow (from `templates/github/workflows/consumer-ci.yml`)
and the PR template are installed by default; the framework's internal
`release.yml` and `deploy.yml` are never copied.

#### Scenario: init installs CI and PR template only

- **GIVEN** a fresh project
- **WHEN** `specboot init` runs
- **THEN** the project receives `.github/workflows/ci.yml` and
  `.github/pull_request_template.md`
- **AND** no other `.github/workflows/*` file is created and the `.github` tree
  was never copied as a whole

## MODIFIED Requirements

### Requirement: Documentation describes intocable + parametrizable workflows

`docs/framework-contract.md` and `README.md` SHALL document the workflows
distinguishing the Specboot repository's internal workflows (`release.yml`,
repo-only) from the consumer templates (`templates/github/`), stating that only
the consumer CI workflow is installed by default and that `init`/`update` use
explicit file lists. No edit introduces a broken `{file:...}` reference.

#### Scenario: docs distinguish internal workflows from consumer templates

- **GIVEN** the change applied
- **WHEN** `README.md` and `docs/framework-contract.md` are inspected
- **THEN** they distinguish internal workflows from consumer templates and
  state the default install set (consumer CI + PR template)

#### Scenario: docs reflect behavior without broken refs

- **GIVEN** the change applied
- **WHEN** `bash check-refs.sh` runs
- **THEN** it reports 0 errors
