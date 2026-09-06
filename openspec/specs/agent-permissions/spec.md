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

The permission block of `.opencode/agents/archive.md` MUST allow the commands
that the `archive` skill and its role document: `git status *`,
`git diff`, `git diff *`, `git log`, `git log *`, and `node -e *` (token-light
evidence reads of Step 5). The `rm` allow pattern MUST be scoped to
`rm openspec/tickets/*` (Step 7 cleanup), and the pattern
`rm -rf openspec/changes/*` MUST NOT exist. The role
`ai-specs/agents/archive-agent.md` MUST NOT list `git commit` in its "Bash
permitido" list (Commit ownership rule) and MUST document `node -e`.

#### Scenario: Token-light evidence reads are allowed

- **WHEN** the archive agent executes the Step 5 `node -e` evidence reads
- **THEN** the command matches an allow pattern in the permission block

#### Scenario: rm is scoped to the documented cleanup

- **WHEN** the archive agent runs the Step 7 cleanup
- **THEN** only `rm openspec/tickets/*` is allowed
- **AND** no rm pattern reaches `openspec/changes/` or `openspec/archive/`

#### Scenario: git commit is neither promised nor allowed

- **WHEN** the archive role list and permission block are audited
- **THEN** `git commit` is absent from the role's "Bash permitido" list
- **AND** the permission block contains no allow pattern for `git commit`

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

