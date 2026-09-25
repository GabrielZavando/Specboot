# specboot-workflows Specification Delta

## ADDED Requirements

### Requirement: The consumer CI template MUST be valid YAML for GitHub Actions (REQ-001)

`templates/github/workflows/consumer-ci.yml` SHALL parse as valid YAML for
GitHub Actions: no step `name` value SHALL contain ambiguous YAML syntax
(`: ` inside an unquoted plain scalar, which the Actions YAML parser rejects
with "Invalid workflow file"). The fix SHALL be limited to quoting or
rephrasing the offending `name` value — the job `ci`, its steps and the
standing consumer wiring (GitHub Packages auth, `node-version: '24'`, actions
v5, step-level `hashFiles`) MUST be preserved (REQ-005).

#### Scenario: GitHub Actions processes the template without a syntax error

- **GIVEN** the corrected `templates/github/workflows/consumer-ci.yml`
- **WHEN** a YAML parser (`python3 -c "import yaml; yaml.safe_load(...)"`)
  processes it and GitHub Actions loads it as a workflow
- **THEN** the YAML parses cleanly and the job `ci` is created without syntax
  errors

### Requirement: A regression test guards the consumer CI template YAML validity (REQ-003)

`tests/consumer-ci-yaml-test.sh` SHALL validate that
`templates/github/workflows/consumer-ci.yml` parses as valid YAML, and SHALL
fail (exit non-zero) if a step `name` value again contains an unquoted `: `.
The test SHALL follow the house test pattern (`tests/consumer-ci-auth-test.sh`)
and SHALL be auto-discovered by `tests/run-all.sh` (glob `tests/*-test.sh`).

#### Scenario: regression test fails on an ambiguous unquoted name

- **GIVEN** the template with an unquoted `name` value containing `: ` (e.g.
  the 0.11.0 line 42: `Project gate (make ci: refs + solid-lint + lint + test
  + audit)`)
- **WHEN** `bash tests/consumer-ci-yaml-test.sh` runs
- **THEN** it fails (exit non-zero) reporting the ambiguous `name` and its line

#### Scenario: regression test passes on the corrected template

- **GIVEN** the corrected `templates/github/workflows/consumer-ci.yml`
- **WHEN** `bash tests/consumer-ci-yaml-test.sh` and `bash tests/run-all.sh` run
- **THEN** the regression test passes (exit 0) and the full suite stays green

#### Scenario: consumer gets a valid ci.yml after updating to 0.11.1

- **GIVEN** a consumer project with Specboot 0.11.0 (broken ci.yml) and
  version 0.11.1 published
- **WHEN** the consumer runs `specboot update`
- **THEN** the standing tri-state policy (SPECBOOT-HARDEN-04,
  `docs/versioning-standard.md` §5.1) backs up the known historical variant
  and installs the corrected 0.11.1 template as `.github/workflows/ci.yml`,
  which is valid YAML for GitHub Actions
