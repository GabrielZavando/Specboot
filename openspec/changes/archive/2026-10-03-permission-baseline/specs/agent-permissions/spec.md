# agent-permissions Specification Delta

## ADDED Requirements

### Requirement: Baseline regression test over effective capabilities

The framework MUST ship a regression test (`tests/baseline-capabilities-test.sh`)
that compares the effective capabilities of every OpenCode agent (edit targets,
allowed/forbidden commands, `task` delegation, evidence ownership and Git)
against the registered baseline, reusing the validator semantics of
`scripts/validate-agent-permissions.mjs` instead of re-implementing pattern
parsing. It MUST fail on any delta. (REQ-003)

#### Scenario: Permission matrix has no differences

- **WHEN** the regression test compares the effective capabilities of the 9 agents against the reference
- **THEN** the result is 0 deltas across edit, commands, delegation, evidence ownership and Git

### Requirement: Deliberate regressions are detected in fixtures

The regression test MUST fail when a deliberate regression is introduced in a
fixture (one regression per fixture, derived from the `good/` fixture):
build allowed to write foreign evidence, verify/reviewer granted general edit,
archive allowed to stage, commit allowed to spawn subagents, and any covered
force-push variant relaxed. Existing fixtures MUST be reused when their
semantics already cover a case; only missing fixtures are added. (REQ-004, REQ-005)

#### Scenario: Build writes foreign evidence

- **WHEN** the regression test runs against a fixture where build is allowed to write `openspec/state/verify-results.json`
- **THEN** the test fails reporting the evidence-ownership violation (agent + capability + rule)

#### Scenario: Verify or reviewer edits code

- **WHEN** the regression test runs against a fixture where verify or reviewer obtains general edit permission
- **THEN** the test fails reporting the exceeded edit scope

#### Scenario: Archive stages

- **WHEN** the regression test runs against a fixture where archive obtains `git add`/`git commit`
- **THEN** the test fails reporting the staging-ownership violation (reusing `bad-ownership` when its semantics already cover it)

#### Scenario: Commit spawns subagents

- **WHEN** the regression test runs against a fixture where the commit agent declares a non-empty `task.allow`
- **THEN** the test fails because an agent with `can_spawn_subagents=false` resolves allow for a subagent

#### Scenario: Covered force-push variants stay forbidden

- **WHEN** any covered force-push variant (`--force*`, `--force-with-lease*`, `-f*`, `*-f*`, compound separators `;`, `&&`, `||`, `|`, newline) is evaluated
- **THEN** all variants resolve to `deny`, and a fixture relaxing them makes the regression test fail (reusing `bad-force-push` when already covered)

### Requirement: No indirect capability amplification

No agent MUST gain capabilities indirectly through the baseline or benchmark
scripts: the harness MUST NOT add allows, MUST NOT touch permission blocks
(`.opencode/agents/*.md`) and MUST NOT relax the manifest
(`docs/agent-permission-contracts.yml`) to make a test pass. (REQ-008)

#### Scenario: Harness does not amplify capabilities

- **WHEN** the baseline and benchmark scripts (allowed by `opencode.json`) are audited for their effects
- **THEN** no agent gains capabilities indirectly: no allows added, no permission blocks touched, no manifest relaxed
