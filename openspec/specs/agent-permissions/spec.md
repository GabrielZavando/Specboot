# agent-permissions Specification

## Purpose
TBD - created by archiving change sync-agent-permissions. Update Purpose after archive.
## Requirements
### Requirement: Permission blocks match documented role capabilities bidirectionally

The restrictive bash permission blocks in `.opencode/agents/{agent}.md` MUST
coincide bidirectionally with the commands documented in the agent's role file
(`ai-specs/agents/*.md`) or backing skill (`ai-specs/skills/*/SKILL.md`).
This applies to every block built from explicit allow patterns plus a
`"*": deny` fallback:

- Every command documented in the role's "Bash permitido" list MUST have a
  matching allow pattern in the permission block.
- Every allow pattern in the permission block MUST be documented in the role
  list.

The resolution rule for disagreements is the backing SKILL.md: a command the
skill actually executes MUST be allowed and documented; a command the skill
never executes and the block denies MUST be removed from the role list.
Agents declaring `bash: allow` (backend, frontend, build) are out of scope of
this contract.

#### Scenario: Documented command has an allow pattern

- **WHEN** an agent's role list documents a bash command
- **THEN** the agent's permission block contains an allow pattern matching it
- **AND** the command does not fall through to the `"*": deny` fallback

#### Scenario: Allow pattern is documented

- **WHEN** an agent's permission block contains an allow pattern
- **THEN** the agent's role list documents that command
- **AND** no undocumented allow surface exists

### Requirement: Verify agent can run pytest

The permission block of `.opencode/agents/verify.md` MUST include
`"pytest *": allow`, matching the `pytest` entry documented in the "Bash
permitido" list of `ai-specs/agents/verify-agent.md`, so the verify subagent
can execute Python tests (Step 5b of the `verify` skill) in Python projects.
The verify role MUST also document `npm run test`, matching the existing
`"npm run test *"` allow pattern.

#### Scenario: pytest allowed in verify block

- **WHEN** the verify subagent runs `pytest` in a Python project
- **THEN** the command matches the `"pytest *": allow` pattern
- **AND** it is not denied by the `"*": deny` fallback

#### Scenario: npm run test documented in verify role

- **WHEN** the verify permission block is audited against the role list
- **THEN** `npm run test` appears in the role's "Bash permitido" list
- **AND** both directions of the sync hold for the verify agent

### Requirement: Archive agent permission block matches its skill steps

The permission block of `.opencode/agents/archive.md` MUST mirror exactly
the commands and paths its skill and role document. `CHANGELOG.md` MUST NOT
appear in the `edit` allow map while no archive skill step documents writing
it; if a future skill step documents that write, the permission MUST be
re-added in the same change that adds the step.

#### Scenario: No orphaned edit permission

- **WHEN** the archive agent's `edit` map is compared against the archive
  skill steps
- **THEN** every allowed path corresponds to a documented write

### Requirement: Deny fallback preserved in restrictive blocks

Every agent with a restrictive permission block MUST keep the `"*": deny`
fallback in its bash permission map (agents: `verify`, `reviewer`, `archive`,
`plan`; and in its edit permission map where applicable). No permission sync
change may remove or weaken the fallback.

#### Scenario: Wildcard deny intact

- **WHEN** the frontmatter of each restrictive agent is inspected
- **THEN** the bash permission map ends with `"*": deny`
- **AND** the edit permission map (where restrictive) also ends with `"*": deny`

### Requirement: Sync is guarded by an executable test

A guard script `tests/agent-permissions-test.sh` MUST validate the sync
contract (including the pytest fix, the archive block fixes, the reviewer and
plan sync pairs, the deny fallbacks, and the roadmap completion marker for
M-403) using asserts prefixed with `[SC-NNN]`, failing on any regression.

#### Scenario: Guard passes and detects regressions

- **WHEN** `tests/agent-permissions-test.sh` is executed after the change
- **THEN** all asserts pass
- **AND** removing a required allow pattern, reintroducing
  `rm -rf openspec/changes/*`, or unmarking M-403 in
  `PLAN_MEJORAS_SPECBOOT.md` makes the guard fail

### Requirement: Plan agent can create the ticket branch via git

The renamed `.opencode/agents/sdd-plan.md` MUST keep bash allow patterns for
the branch-create/read git operations (`plan.md` was renamed because `plan`
is a reserved OpenCode built-in agent name that forces the editor's read-only
plan mode); the commands `plan-change.md`, `enrich-us.md` and `explain.md`
MUST declare `agent: sdd-plan`, and no command may declare `agent: plan`.

#### Scenario: Reserved name no longer used

- **WHEN** the frontmatter of every file under `.opencode/commands/` is inspected
- **THEN** none declares `agent: plan` and at least the three planning commands declare `agent: sdd-plan`

#### Scenario: Renamed agent keeps its contract

- **WHEN** `.opencode/agents/sdd-plan.md` is inspected
- **THEN** it keeps `mode: primary`, edit restricted to `openspec/**`,
  branch-creating git allowances, and `git commit`/`git push` deny

### Requirement: Sync guard covers the plan git capability

The guard `tests/agent-permissions-test.sh` SC-007 MUST assert that `plan` allows the
branch-create git operations (`git checkout *`, `git switch *`, `git branch *`,
`git status`), that the role documents the git contract, and that `plan` has no allow
pattern for `git commit` or `git push`; the guard MUST fail if the capability is
reverted or an unexpected commit/push allow is introduced.

#### Scenario: Guard passes and detects regressions

- **WHEN** `tests/agent-permissions-test.sh` is executed after the change
- **THEN** all SC-007 asserts pass
- **AND** removing a branch-create allow pattern or adding an allow for `git commit`
  makes the guard fail

### Requirement: Dedicated commit agent with minimal permissions

The step `/commit` MUST run under a dedicated agent defined in
`.opencode/agents/commit.md` with `mode: primary`. The agent MUST NOT load
the build-agent role and MUST deny editing:

- `edit: deny` for all paths.
- Bash allow patterns limited to the commands the commit skill executes:
  git read commands (`status`, `diff`, `log`, `fetch`, `merge-base`,
  `branch`, `show-current`), `git add *`, `git commit *`, `git push *`,
  `gh *`, `node -e *`, `ls *`, `cat *`, `mkdir -p openspec/*`.
- `"git push --force*": deny` MUST precede the wildcard deny.
- `"*": deny` as final fallback.

The command `.opencode/commands/commit.md` MUST declare `agent: commit`
in its frontmatter.

#### Scenario: Commit command runs under the dedicated agent

- **WHEN** the frontmatter of `.opencode/commands/commit.md` is inspected
- **THEN** it declares `agent: commit`

#### Scenario: Force push is structurally denied

- **WHEN** any invocation under the commit agent attempts `git push --force`
- **THEN** the permission block denies it before the wildcard fallback

#### Scenario: No build role loaded in commit sessions

- **WHEN** `.opencode/agents/commit.md` is inspected
- **THEN** it does not reference `ai-specs/agents/build-agent.md`

### Requirement: Verify agent allows bare npm test

The permission block of `.opencode/agents/verify.md` MUST include
`"npm test": allow` in addition to the existing `"npm test *": allow`,
giving symmetric coverage for invocations with and without arguments.

#### Scenario: Bare npm test is allowed

- **WHEN** the verify agent runs `npm test` without arguments
- **THEN** the permission block allows it instead of falling into `"*": deny`

### Requirement: Apply verifies preconditions before dispatch

The `.opencode/commands/apply.md` command MUST include a precondition
section that, before dispatching any task, verifies the active branch
matches the project convention (e.g. `feature/*`) and that git has no
uncommitted or staged changes; on failure it MUST abort with an explicit
message suggesting `/plan-change` when the branch is missing.

#### Scenario: Dirty git state aborts apply

- **WHEN** `/apply` starts with uncommitted changes
- **THEN** it aborts listing the dirty files and dispatches no task

