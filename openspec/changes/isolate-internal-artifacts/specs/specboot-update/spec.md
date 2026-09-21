# specboot-update Specification Delta

## ADDED Requirements

### Requirement: Legacy release.yml workflows are detected and repaired safely (REQ-002)

`specboot update` MUST detect a legacy Specboot-owned `release.yml` in the
consumer's `.github/workflows/` using the known framework-owned signature
(stable markers of the framework's own file or an exact content fingerprint).
When the file matches the known signature exactly, update MUST back it up
(`.specboot-backup-*/`) before removing it. When the file does NOT match the
known signature exactly (it was modified, or it is not the framework's file —
e.g. a consumer-authored `release.yml`), update MUST warn and require
explicit resolution — it MUST NEVER delete a non-matching `release.yml`
automatically. Custom workflows unrelated to the framework MUST always be
preserved, and the framework's internal `release.yml`/`deploy.yml` are never
installed by `init` or `update`.

#### Scenario: Intact legacy release is backed up and removed

- **GIVEN** a consumer whose `.github/workflows/release.yml` matches the
  framework-owned signature exactly
- **WHEN** `specboot update` runs
- **THEN** the file is backed up to `.specboot-backup-*/` before removal
- **AND** the file is then removed and the removal and backup path are reported

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
