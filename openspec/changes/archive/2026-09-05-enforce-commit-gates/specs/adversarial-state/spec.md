# adversarial-state Specification

## REMOVED Requirements

### Requirement: commit skill MUST use the adversarial verdict as informed evidence
**Reason**: Superseded by the hard evidence gate (M-901). The soft-gate behavior (warn on NO-SHIP, optional audit when evidence is absent) is replaced by blocking semantics specified in `commit-gates`.

## ADDED Requirements

### Requirement: commit skill MUST enforce the adversarial verdict as a hard gate
The `commit` skill SHALL read `openspec/state/adversarial-result.json` as a hard gate: with `verdict: SHIP` for the reference change (the active change; when committing after `/archive`, the change just archived by its derived name) it SHALL skip the manual audit confirmation and report the evidence; with `NO-SHIP` it SHALL block, offering to re-run `/adversarial-review`, abort, or use `--force`; if the file is missing, invalid, or its `change` field does not match the reference change it SHALL block, offering to run `/adversarial-review`, abort, or use `--force` — the absence of an adversarial audit is no longer tolerated as optional. A staleness check (timestamp older than the last commit touching code) SHALL remain warn-only. The unified gate matrix, the `--force` registration and the `Gate-Bypass` trailer are specified in `commit-gates`.

#### Scenario: Commit skips the audit confirmation with a fresh matching SHIP
- **GIVEN** `adversarial-result.json` with `verdict: SHIP` and a matching `change` field
- **WHEN** commit executes its adversarial gateway
- **THEN** it skips the manual audit confirmation and reports the found evidence (verdict and timestamp)

#### Scenario: Commit blocks on NO-SHIP
- **GIVEN** `adversarial-result.json` with `verdict: NO-SHIP` for the reference change
- **WHEN** commit executes its adversarial gateway
- **THEN** it blocks and offers to re-run `/adversarial-review`, abort, or use `--force`
- **AND** it does not continue without an explicit user decision

#### Scenario: Commit blocks when the verdict is absent, invalid or foreign
- **GIVEN** a missing or invalid `adversarial-result.json`, or one whose `change` field differs from the reference change
- **WHEN** commit executes its adversarial gateway
- **THEN** it blocks and offers to run `/adversarial-review`, abort, or use `--force`
- **AND** the absence of an adversarial audit no longer keeps the previous optional flow: it blocks

#### Scenario: Staleness check is warn-only
- **GIVEN** a present, matching `adversarial-result.json` whose timestamp predates the last commit touching code
- **WHEN** commit executes its adversarial gateway
- **THEN** it prints a warning about possibly stale evidence
- **AND** it does not block on staleness alone
