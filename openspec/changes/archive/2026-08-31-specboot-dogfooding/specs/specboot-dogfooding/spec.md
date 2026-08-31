## ADDED Requirements

### Requirement: README documents the framework dogfooding flow
The framework SHALL include a README section titled "Desarrollar Specboot con Specboot (Dogfooding)" that documents the SDD workflow (branch per ticket, `/plan-change` → `/apply` → `/verify` → `/archive` → `/commit`), the `bash scripts/dogfood-check.sh` validation, and the one-PR-per-phase rule.

#### Scenario: README documents the dogfooding flow
- **WHEN** the README is rendered
- **THEN** it contains the "Desarrollar Specboot con Specboot (Dogfooding)" section listing the SDD steps, the `bash scripts/dogfood-check.sh` validation, and the one-PR-per-phase rule

#### Scenario: No broken references introduced
- **WHEN** `check-refs.sh` runs after the README change
- **THEN** it reports 0 errors

### Requirement: dogfood-check script exists and is executable
The repository SHALL include `scripts/dogfood-check.sh` with a bash shebang and `set -euo pipefail`, marked executable.

#### Scenario: Script is present and executable
- **WHEN** `test -x scripts/dogfood-check.sh` runs
- **THEN** it succeeds

### Requirement: dogfood-check runs both validations and propagates failures
The `scripts/dogfood-check.sh` SHALL run `check-refs.sh` then `specboot.sh --ci` and SHALL abort (non-zero exit) if either fails.

#### Scenario: Clean repo passes
- **WHEN** `bash scripts/dogfood-check.sh` runs on a clean repo
- **THEN** it exits 0 after running both validations

#### Scenario: Aborts if check-refs fails
- **WHEN** `check-refs.sh` fails and `bash scripts/dogfood-check.sh` runs
- **THEN** the script aborts with non-zero exit and does not continue to `specboot.sh --ci`

#### Scenario: Aborts if specboot --ci fails
- **WHEN** `check-refs.sh` passes but `specboot.sh --ci` fails and `bash scripts/dogfood-check.sh` runs
- **THEN** the script aborts with non-zero exit

### Requirement: No regression in framework validations
After the change, `check-refs.sh`, `specboot.sh --ci`, and `make ci` SHALL remain green in the framework repo.

#### Scenario: All framework validations pass
- **WHEN** `check-refs.sh`, `specboot.sh --ci`, and `make ci` run after the change
- **THEN** all three report 0 errors

### Requirement: TDD test for dogfood-check script
The repository SHALL include `tests/dogfood-check-test.sh` asserting the script exists, is executable, and runs clean.

#### Scenario: Test fails before script exists (RED)
- **WHEN** the test runs before `scripts/dogfood-check.sh` exists
- **THEN** it fails

#### Scenario: Test passes after script exists (GREEN)
- **WHEN** the test runs after the script exists and is executable
- **THEN** it passes
