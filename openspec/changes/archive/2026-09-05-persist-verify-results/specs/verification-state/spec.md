# verification-state Specification

## ADDED Requirements

### Requirement: verify skill MUST persist verification results after every run
The `verify` skill SHALL write `openspec/state/verify-results.json` after every execution (including failed runs), containing `schema_version`, `change`, `ticket_id`, `status`, `evidence_mode`, `timestamp`, task totals and the scenario mapping. The file SHALL be tracked in git (not ignored) and the latest run wins.

#### Scenario: Verify persists results after every run
- **GIVEN** an active change verified by `/verify`
- **WHEN** the verify execution finishes (with any result: PASS, PARTIAL or FAIL)
- **THEN** `openspec/state/verify-results.json` is written with `change`, `ticket_id`, `status`, `evidence_mode`, `timestamp`, task totals and the scenario mapping
- **AND** the file is tracked in git

### Requirement: Verify results schema is versioned and self-tested
The results file SHALL declare `schema_version: 1` with required keys and status enums (`PASS|PARTIAL|FAIL` for the global status; `PASS|FAIL|UNTESTED` per scenario). A self-test script `tests/verify-state-test.sh` SHALL validate the schema against a canonical fixture.

#### Scenario: Schema validated by self-test
- **GIVEN** the canonical `verify-results.json` schema (`schema_version: 1`)
- **WHEN** `tests/verify-state-test.sh` runs
- **THEN** it validates required keys, status enums and `schema_version` against `ai-specs/examples/verify-results-example.json`
- **AND** the self-test fails if the schema deviates from the contract

### Requirement: Static evidence MUST never produce a PASS status
The results file SHALL declare `evidence_mode: executable|static`. When verification runs through the static fallback (Step 5e), the global status SHALL be `PARTIAL` and no scenario SHALL be marked `PASS` in the JSON.

#### Scenario: Static evidence yields PARTIAL
- **GIVEN** a change without executable tests (static fallback)
- **WHEN** verify completes the verification
- **THEN** the global status is `PARTIAL` and `evidence_mode` is `static`
- **AND** no scenario is marked `PASS` in the JSON

### Requirement: commit skill MUST use verify results as an informed soft gate
The `commit` skill SHALL read `openspec/state/verify-results.json` as an informed soft gate: with `status: PASS` for the active change it SHALL skip the verify question; with `PARTIAL` or `FAIL` it SHALL warn and offer to re-run or abort; if the file is missing or its `change` field does not match the active change it SHALL fall back to the current question flow. A staleness check (timestamp older than the last commit touching code) SHALL be warn-only. The hard gate remains M-901 (out of scope).

#### Scenario: Commit skips the verify question with a fresh PASS
- **GIVEN** `/commit` on the active change with `verify-results.json` reporting `status: PASS` and a matching `change` field
- **WHEN** commit executes its verify gateway
- **THEN** it skips the "did you run /verify?" question and reports the found evidence (status and timestamp)

#### Scenario: Commit warns on PARTIAL or FAIL
- **GIVEN** `verify-results.json` with `status: PARTIAL` or `FAIL` for the active change
- **WHEN** commit executes its verify gateway
- **THEN** it warns about the recorded status and offers to re-run `/verify` or abort
- **AND** it does not continue without an explicit user decision

#### Scenario: Commit falls back to the question when evidence is absent or foreign
- **GIVEN** a missing `verify-results.json`, or one whose `change` field differs from the active change
- **WHEN** commit executes its verify gateway
- **THEN** it applies the current flow: asks the user whether `/verify` was executed
- **AND** it does not continue without confirmation

#### Scenario: Staleness check is warn-only
- **GIVEN** a present `verify-results.json` whose timestamp predates the last commit touching code
- **WHEN** commit executes its verify gateway
- **THEN** it prints a warning about possibly stale evidence
- **AND** it does not block on its own (the hard gate is M-901)

### Requirement: archive MUST reference verification in the manifest
The `archive` skill SHALL add an optional `verification: {status, timestamp, source}` field to the manifest entry when `verify-results.json` exists, and SHALL omit it without blocking when the file is absent. Archive SHALL read only the summary (token-light, never the scenarios array).

#### Scenario: Archive references verification in the manifest
- **GIVEN** an archived change with an existing `verify-results.json`
- **WHEN** archive generates the manifest entry
- **THEN** the entry includes `verification: {status, timestamp, source: "openspec/state/verify-results.json"}`
- **AND** archive does not read the scenarios array of the JSON

#### Scenario: Archive does not block without a results file
- **GIVEN** an archived change without `verify-results.json`
- **WHEN** archive generates the manifest entry
- **THEN** the `verification` field is omitted
- **AND** the archive completes without error or block