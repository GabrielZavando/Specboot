# adversarial-state Specification

## Purpose
TBD - created by archiving change persist-adversarial-verdict. Update Purpose after archive.
## Requirements
### Requirement: code-auditing skill MUST persist the adversarial verdict after every audit
The `code-auditing` skill SHALL write `openspec/state/adversarial-result.json` at the end of every `/adversarial-review` run (including NO-SHIP verdicts), containing `schema_version`, `change`, `ticket_id`, `verdict`, `confidence`, `timestamp` (ISO-8601) and the `findings` object (`total`, `critical`, `warnings`, `info`, `discarded`). The file SHALL be tracked in git (not ignored) and the latest run wins.

#### Scenario: Adversarial-review persists the verdict after every run
- **GIVEN** an active change audited by `/adversarial-review`
- **WHEN** the audit finishes (with any verdict: SHIP or NO-SHIP)
- **THEN** `openspec/state/adversarial-result.json` is written with `schema_version`, `change`, `ticket_id`, `verdict`, `confidence`, `timestamp` and the `findings` counters
- **AND** the file is tracked in git and the latest run wins

### Requirement: Adversarial results schema is versioned and self-tested
The results file SHALL declare `schema_version: 1` with required keys, `verdict` enum `SHIP|NO-SHIP`, numeric `confidence` in 0.0–1.0, an ISO-8601 timestamp, non-negative integer counters in `findings` with the invariants `critical ≤ total` and `total = critical + warnings + info`. A self-test script `tests/adversarial-state-test.sh` SHALL validate the schema against a canonical fixture, including negative tests.

#### Scenario: Schema validated by self-test
- **GIVEN** the canonical `adversarial-result.json` schema (`schema_version: 1`)
- **WHEN** `tests/adversarial-state-test.sh` runs
- **THEN** it validates required keys, enums, confidence range, timestamp format and findings counters against `ai-specs/examples/adversarial-results-example.json`
- **AND** the self-test fails if the schema deviates from the contract (negative tests included)

### Requirement: Every CRITICAL finding MUST pass the structured self-refutation protocol
The `code-auditing` skill SHALL formalize auto-refutation as a 4-step protocol (finding → could it be a false positive? → search for contradicting evidence in code/tests → final decision keep/discard with reason), replacing the current one-line heuristic. Every CRITICAL finding SHALL pass the protocol before appearing in the final verdict.

#### Scenario: CRITICAL finding goes through the refutation protocol
- **GIVEN** a CRITICAL-severity finding during the audit
- **WHEN** the reviewer applies the 4-step protocol
- **THEN** it asks whether the finding may be a false positive, searches for contradicting evidence in code/tests, and records a final keep/discard decision with its reason
- **AND** only findings that survive appear in the verdict

### Requirement: Discarded findings MUST be auditable in a "Descartados" annex
The audit report SHALL include a "Descartados" annex listing, for each refuted CRITICAL finding, the original finding, the refutation and the discard reason. Discarded findings SHALL NOT appear in the verdict. The `findings.discarded` counter SHALL reflect the discarded amount.

#### Scenario: Discarded findings land in the annex with a reason
- **GIVEN** CRITICAL findings discarded during self-refutation
- **WHEN** the final report is produced
- **THEN** discarded findings appear in the "Descartados" annex with their refutation and reason, not in the verdict
- **AND** `findings.discarded` in the persisted JSON counts them

### Requirement: archive MUST reference the adversarial verdict in the manifest as an informed soft gate
The `archive` skill SHALL add an optional `adversarial: {verdict, timestamp, source}` field to the manifest entry when `adversarial-result.json` exists with a matching `change` field, and SHALL omit it without blocking when the file is absent or foreign (warning and suggesting `/adversarial-review` instead). Archive SHALL read only the summary (token-light, never the findings detail). The hard gate remains M-901 (out of scope).

#### Scenario: Archive references the verdict in the manifest
- **GIVEN** an archived change with an existing `adversarial-result.json` whose `change` field matches
- **WHEN** archive generates the manifest entry
- **THEN** the entry includes `adversarial: {verdict, timestamp, source: "openspec/state/adversarial-result.json"}`
- **AND** archive does not read the findings detail of the JSON (token-light)

#### Scenario: Archive warns without blocking when evidence is absent or foreign
- **GIVEN** an archived change without `adversarial-result.json`, or one whose `change` field differs from the active change
- **WHEN** archive generates the manifest entry
- **THEN** the `adversarial` field is omitted, a warning is printed and running `/adversarial-review` is suggested
- **AND** the archive completes without error or block (the hard gate is M-901)

### Requirement: Reviewer agent permissions and descriptions MUST match the persistence capability
The permission block of `.opencode/agents/reviewer.md` SHALL include the scoped evidence-writing exception (`mkdir -p openspec/*` allowed and `cat` redirection for writing, mirroring the verify agent) while keeping `edit: deny` and all other bash denied. Descriptions in `AGENTS.md` (§5.3), `.opencode/commands/adversarial-review.md` and `ai-specs/README.md` SHALL declare: read-only over code, persists evidence under `openspec/state/`. Every command documented in the role SHALL have an allow pattern in the permission block, and vice versa (M-403 lesson).

#### Scenario: Reviewer permissions match its documented role
- **GIVEN** the reviewer agent needs to write the evidence file while remaining read-only over code
- **WHEN** the change is applied
- **THEN** the permission block allows exactly the scoped evidence-writing commands and `edit` stays deny
- **AND** no description claims absolute read-only: they state read-only over code with evidence persisted under `openspec/state/`
- **AND** every documented bash command has a matching allow pattern in the permission block (and vice versa)

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

