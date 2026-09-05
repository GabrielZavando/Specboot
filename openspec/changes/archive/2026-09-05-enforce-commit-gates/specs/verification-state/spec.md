# verification-state Specification

## REMOVED Requirements

### Requirement: commit skill MUST use verify results as an informed soft gate
**Reason**: Superseded by the hard evidence gate (M-901). The soft-gate behavior (warn + question on PARTIAL/FAIL, blind question on missing evidence) is replaced by blocking semantics specified in `commit-gates`.

## ADDED Requirements

### Requirement: commit skill MUST enforce verify results as a hard gate
The `commit` skill SHALL read `openspec/state/verify-results.json` as a hard gate: with `status: PASS` for the reference change (the active change; when committing after `/archive`, the change just archived by its derived name) it SHALL skip the verify question and report the evidence; with `PARTIAL` or `FAIL` it SHALL block, offering to re-run `/verify`, abort, or use `--force`; if the file is missing, invalid, or its `change` field does not match the reference change it SHALL block, offering to run `/verify`, abort, or use `--force` — never a blind question. A staleness check (timestamp older than the last commit touching code) SHALL remain warn-only. The unified gate matrix, the `--force` registration and the `Gate-Bypass` trailer are specified in `commit-gates`.

#### Scenario: Commit skips the verify question with a fresh matching PASS
- **GIVEN** `verify-results.json` with `status: PASS` and a matching `change` field
- **WHEN** commit executes its verify gateway
- **THEN** it skips the "did you run /verify?" question and reports the found evidence (status and timestamp)

#### Scenario: Commit blocks on PARTIAL or FAIL
- **GIVEN** `verify-results.json` with `status: PARTIAL` or `FAIL` for the reference change
- **WHEN** commit executes its verify gateway
- **THEN** it blocks and offers to re-run `/verify`, abort, or use `--force`
- **AND** it does not continue without an explicit user decision

#### Scenario: Commit blocks when evidence is absent, invalid or foreign
- **GIVEN** a missing or invalid `verify-results.json`, or one whose `change` field differs from the reference change
- **WHEN** commit executes its verify gateway
- **THEN** it blocks and offers to run `/verify`, abort, or use `--force`
- **AND** it does not fall back to the pre-M-401 question flow

#### Scenario: Staleness check is warn-only
- **GIVEN** a present, matching `verify-results.json` whose timestamp predates the last commit touching code
- **WHEN** commit executes its verify gateway
- **THEN** it prints a warning about possibly stale evidence
- **AND** it does not block on staleness alone
