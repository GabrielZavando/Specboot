# cycle-baseline Specification

## Purpose
TBD - created by archiving change permission-baseline. Update Purpose after archive.
## Requirements
### Requirement: Reproducible baseline with strict location separation

The framework MUST register a reproducible baseline identified by the SHA of
`main` at feature start, recording the Specboot version, the OpenCode/OpenSpec
version and configuration, the model used and the test commands, without
credentials. The human-readable report (methodology, how to reproduce it,
baseline conclusions) MUST live in `docs/`; the raw data (JSONs with metrics,
durations, bytes and validator results) MUST live in `openspec/state/` for
future framework consumption. (REQ-001)

#### Scenario: Baseline reproducible registered

- **WHEN** the feature branch is created from the latest `main` and the environment is recorded
- **THEN** a baseline exists identified by the `main` SHA with the Specboot version, OpenCode/OpenSpec configuration, model used and test commands, without credentials, with the report in `docs/` and raw data in `openspec/state/`

### Requirement: Real validator results preserved

The framework MUST execute the existing validators
(`scripts/validate-agent-permissions.mjs`, `scripts/validate-command-contracts.mjs`)
and the mandatory repository controls (`bash specboot.sh --ci`,
`bash tests/run-all.sh`), preserving their real results; no success MAY be
attributed to tests that did not run, and a failing validator MUST be recorded
as-is. (REQ-002)

#### Scenario: Validators executed with real results

- **WHEN** the validators and mandatory controls are executed during the baseline
- **THEN** the real results are preserved in `openspec/state/`
- **AND** no success is attributed to tests that did not run

