# specboot-release Specification Delta

## MODIFIED Requirements

### Requirement: `validate` job runs full framework self-check

The `validate` job SHALL run `bash check-refs.sh`, `bash specboot.sh --ci`, `make
ci`, and all `tests/*-test.sh` scripts. If any step fails, the job exits non-zero
and the `publish` job is skipped. The `actions/checkout` step of the `validate`
job SHALL set `fetch-depth: 0` so the self-check and the historical-provenance
tests (`tests/specboot-update-test.sh`, which query historical `release.yml`
variants via `git show`/`git log`) have the full git history and do not fail on a
push to `main`. The `publish` job's `actions/checkout` SHALL remain unchanged
(no `fetch-depth: 0`) and the `publish` job SHALL keep `needs: validate`.

#### Scenario: validate checkout enables full history

- **GIVEN** a push to `main` that triggers `.github/workflows/release.yml`
- **WHEN** the `validate` job runs
- **THEN** its `actions/checkout` step sets `fetch-depth: 0`
- **AND** `tests/specboot-update-test.sh` passes with the full git history
  available

#### Scenario: validate failure blocks publish

- **GIVEN** the `release.yml` workflow has `validate` and `publish` jobs with
  `needs: validate`
- **WHEN** the `validate` job fails (e.g. a `tests/*-test.sh` script exits
  non-zero)
- **THEN** the `publish` job does not run
- **AND** the package is not published to GitHub Packages

#### Scenario: publish checkout stays unchanged and dependent

- **GIVEN** `fetch-depth: 0` on the `validate` job's checkout
- **WHEN** the `publish` job is inspected
- **THEN** the `publish` job's `actions/checkout` does NOT set `fetch-depth: 0`
- **AND** the `publish` job keeps `needs: validate`

## ADDED Requirements

### Requirement: `release-workflow-test.sh` enforces fetch-depth exclusively on validate (REQ-003)

`tests/release-workflow-test.sh` SHALL verify that `fetch-depth: 0` is declared
exclusively inside the `validate` job of `.github/workflows/release.yml` and is
NOT present in the `publish` job. If `fetch-depth: 0` disappears from `validate`
or is added to `publish`, the test SHALL fail (exit non-zero).

#### Scenario: contract passes with fetch-depth only on validate

- **GIVEN** `.github/workflows/release.yml` with `fetch-depth: 0` on the
  `validate` job's checkout only
- **WHEN** `bash tests/release-workflow-test.sh` runs
- **THEN** it passes (exit 0)

#### Scenario: contract fails if fetch-depth leaves validate or enters publish

- **GIVEN** `fetch-depth: 0` removed from the `validate` job or added to the
  `publish` job of `.github/workflows/release.yml`
- **WHEN** `bash tests/release-workflow-test.sh` runs
- **THEN** it fails (exit non-zero)

### Requirement: The legacy-repair regression fixture MUST derive from git history (REQ-004)

The legacy-repair regression fixture MUST derive the exact/matched variant from
the immutable git history (pre-isolation v3 commit) instead of copying the live
internal `release.yml`, because REQ-001 evolves that file and its content
fingerprint stops matching the distributed legacy variants. The
`KNOWN_RELEASE_FINGERPRINTS` allowlist MUST NOT be altered, and the HARDEN-02
repair contract (exact legacy removed + backed up; modified legacy preserved with
explicit-resolution warning) MUST keep passing.

#### Scenario: legacy-repair fixture uses a git-derived legacy variant

- **GIVEN** the framework repo after REQ-001 evolved the internal `release.yml`
- **WHEN** `tests/specboot-update-test.sh` runs its legacy-repair tests
- **THEN** the exact-match fixture is derived from git history (v3 pre-isolation
  commit), not copied from the live internal `release.yml`
- **AND** the exact legacy variant is removed and backed up, and a modified one
  is preserved with a warning — without touching the fingerprints allowlist

#### Scenario: framework self-check stays green

- **GIVEN** the change applied to the framework repo
- **WHEN** `bash tests/release-workflow-test.sh`, `bash tests/specboot-update-test.sh`,
  `bash tests/run-all.sh`, `bash specboot.sh --ci` and `bash check-refs.sh` run
- **THEN** all pass and `specboot.sh --ci` / `check-refs.sh` report 0 errors