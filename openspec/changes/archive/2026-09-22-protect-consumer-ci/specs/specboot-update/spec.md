# specboot-update Specification Delta

## ADDED Requirements

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
