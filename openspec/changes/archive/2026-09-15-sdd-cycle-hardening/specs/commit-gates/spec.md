# commit-gates Delta

## ADDED Requirements

### Requirement: Canonical TDD Failure Protocol document

The normative TDD Failure Protocol MUST live in `docs/tdd-failure-protocol.md`
(3-attempt limit, TDD Failure Report fields, stop rule, retry reset).
`.opencode/commands/apply.md`, `ai-specs/agents/build-agent.md` and
`ai-specs/examples/tasks.md` MUST reference that document without duplicating
the protocol steps or the report template.

#### Scenario: Protocol content is referenced, not duplicated

- **WHEN** the protocol text is searched across `apply.md`,
  `build-agent.md` and `examples/tasks.md`
- **THEN** those files contain a reference to
  `docs/tdd-failure-protocol.md` and no duplicated step list

### Requirement: plan-change creates the ticket branch

The `plan-change` skill MUST contain an explicit step, between ticket
parsing (Step 1) and context loading (Step 2), verifying a clean git
state and creating the branch `feature/ticket-X-short-name` from HEAD per
`docs/git-workflow-standards.md`, confirming the branch name with the
user and asking before reusing an existing branch.

#### Scenario: Branch created before artifacts

- **WHEN** `/plan-change` runs on a clean tree
- **THEN** the ticket branch exists before any artifact under
  `openspec/changes/` is written

## MODIFIED Requirements

### Requirement: Commit gate descriptions MUST stay synchronized with the contract

The `/commit` command MUST run under a dedicated `commit` agent
(`.opencode/agents/commit.md`; see agent-permissions delta), and the
descriptions in `AGENTS.md`, the command frontmatter and the commit skill
MUST reflect that wiring. The hard-gate contract itself is unchanged:
verify `PASS` + adversarial `SHIP` evidence in `openspec/state/` for the
reference change, staleness warn-only, and the `--force` escape hatch
registered as the `Gate-Bypass` trailer.

#### Scenario: Gates unchanged by rewiring

- **WHEN** the command frontmatter is updated to `agent: commit`
- **THEN** the gate behavior (PASS + SHIP requirements, `--force`
  trailer, push/PR confirmations) remains identical and
  `tests/commit-gate-test.sh` passes
