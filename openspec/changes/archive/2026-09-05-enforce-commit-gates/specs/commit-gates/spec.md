# commit-gates Specification

## ADDED Requirements

### Requirement: commit skill MUST enforce hard evidence gates before committing
The `commit` skill SHALL treat `openspec/state/verify-results.json` and `openspec/state/adversarial-result.json` as hard gates and SHALL proceed only when verify reports `status: PASS` and adversarial reports `verdict: SHIP`, both with a `change` field matching the reference change — the active change, or, when committing after `/archive`, the change just archived (matched by its derived name, tolerating the `YYYY-MM-DD-` date prefix the CLI adds to the archive folder). With `PARTIAL`, `FAIL`, `NO-SHIP`, missing, invalid or foreign evidence it SHALL block and offer to run the missing tool, abort, or use `--force`; it SHALL NOT continue without an explicit user decision and SHALL NOT fall back to blind questions. Reading SHALL be token-light (summary fields only; `node -e`, never `jq`). A staleness check SHALL remain warn-only.

#### Scenario: Commit proceeds with fresh matching evidence
- **GIVEN** `verify-results.json` with `status: PASS` and `adversarial-result.json` with `verdict: SHIP`, both matching the active change
- **WHEN** `/commit` runs its evidence gateway
- **THEN** it skips both gate questions, reports both evidences (status/verdict + timestamp) and continues to branch validation

#### Scenario: Commit blocks on negative verify evidence
- **GIVEN** `verify-results.json` with `status: PARTIAL` or `FAIL` matching the active change
- **WHEN** `/commit` runs its evidence gateway
- **THEN** it blocks and offers (a) re-running `/verify`, (b) aborting, or (c) `--force`
- **AND** it does not continue without an explicit user decision

#### Scenario: Commit blocks when verify evidence is absent, invalid or foreign
- **GIVEN** `verify-results.json` missing, invalid JSON, or with a `change` field not matching the reference change
- **WHEN** `/commit` runs its evidence gateway
- **THEN** it blocks and offers (a) running `/verify`, (b) aborting, or (c) `--force`
- **AND** it does not fall back to asking whether verify was run

#### Scenario: Commit blocks on a NO-SHIP verdict
- **GIVEN** `adversarial-result.json` with `verdict: NO-SHIP` matching the active change
- **WHEN** `/commit` runs its evidence gateway
- **THEN** it blocks and offers (a) re-running `/adversarial-review`, (b) aborting, or (c) `--force`
- **AND** it does not continue without an explicit user decision

#### Scenario: Commit blocks when the adversarial verdict is absent or foreign
- **GIVEN** `adversarial-result.json` missing, invalid, or with a `change` field not matching the reference change
- **WHEN** `/commit` runs its evidence gateway
- **THEN** it blocks and offers (a) running `/adversarial-review`, (b) aborting, or (c) `--force`
- **AND** the absence of an adversarial audit is no longer tolerated as optional

#### Scenario: Staleness remains warn-only
- **GIVEN** matching evidence whose timestamp predates the last commit touching code
- **WHEN** `/commit` runs its evidence gateway
- **THEN** it prints a staleness warning and continues
- **AND** staleness alone never blocks the commit

#### Scenario: Post-archive commit uses the just-archived change as reference
- **GIVEN** `/commit` running after `/archive`, with no active change under `openspec/changes/` and the change just archived (e.g. archive folder `2026-09-05-enforce-commit-gates`)
- **WHEN** the evidence gateway resolves the reference change
- **THEN** it uses the just-archived change's derived name (`enforce-commit-gates`), tolerating the `YYYY-MM-DD-` date prefix
- **AND** evidence whose `change` field equals that derived name passes the change-match, so the cycle-closing commit proceeds without `--force`

### Requirement: commit skill MUST support --force as a registered emergency escape
The `commit` skill SHALL support the `--force` flag as the only way to bypass a blocked gate. When used, the commit message SHALL include the git trailer `Gate-Bypass: --force (verify=<PASS|PARTIAL|FAIL|missing>; adversarial=<SHIP|NO-SHIP|missing>)` recording the real state of both gates. Without a bypass, the trailer SHALL NOT be emitted.

#### Scenario: Force bypass is registered in the commit message
- **GIVEN** `/commit --force` invoked with blocked or missing gates
- **WHEN** the commits are created
- **THEN** each commit message ends with the `Gate-Bypass` trailer reflecting the actual state of both gates
- **AND** normal commits with passing gates carry no `Gate-Bypass` trailer

### Requirement: Commit gate descriptions MUST stay synchronized with the contract
Descriptions of `/commit` in `AGENTS.md` (§5.2), `.opencode/commands/commit.md`, the consumer note in `ai-specs/skills/verify/SKILL.md` and the hard-gate references in `ai-specs/skills/archive/SKILL.md` and `ai-specs/skills/code-auditing/SKILL.md` SHALL declare the hard gate contract (verify `PASS` + adversarial `SHIP`, `--force` registered) and SHALL NOT describe the hard gate as future work (M-403 lesson: documented role and actual contract never diverge).

#### Scenario: No stale "future gate" wording remains
- **GIVEN** the framework documentation after this change
- **WHEN** the `/commit` descriptions are reviewed (including by the self-test)
- **THEN** `AGENTS.md` §5.2 declares the hard evidence gates and the `--force` escape hatch
- **AND** no file describes the commit hard gate as "M-901, futuro"
