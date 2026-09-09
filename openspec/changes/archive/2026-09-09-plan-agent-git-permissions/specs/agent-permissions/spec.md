# agent-permissions Delta

## ADDED Requirements

### Requirement: Plan agent can create the ticket branch via git

The permission block of `.opencode/agents/plan.md` MUST include bash allow
patterns for the branch-create/read git operations the `/plan-change` flow
needs to create `feature/ticket-X.Y-nombre-corto` from HEAD per
`docs/git-workflow-standards.md` §6.1: `git checkout`, `git switch`,
`git branch`, `git status`, `git log`, and `git merge-base`. It MUST NOT
include allow patterns for `git commit` or `git push` (commit ownership lives
in `/commit`; push happens only when closing a ticket group per §6.3). The
role `ai-specs/agents/plan-agent.md` MUST document these operations and the
commit/push prohibition, keeping the `"*": deny` fallback in both bash and
edit.

#### Scenario: Plan creates the ticket branch

- **WHEN** the plan agent runs `/plan-change` and needs to create the ticket branch
- **THEN** the permission block of `.opencode/agents/plan.md` contains the branch-create
  allow patterns (`git checkout *`, `git switch *`, `git branch *`)
- **AND** the branch creation does not fall through to the `"*": deny` fallback

#### Scenario: Plan reads git state required for the branch base

- **WHEN** the plan agent checks the repo status and base branch before creating
  `feature/...` from HEAD
- **THEN** `git status`, `git status *`, `git log *` and `git merge-base *` are allowed
- **AND** each is documented in `ai-specs/agents/plan-agent.md`

#### Scenario: Plan cannot commit or push

- **WHEN** the plan agent attempts `git commit` or `git push`
- **THEN** there is no allow pattern for either command
- **AND** both fall through to the `"*": deny` fallback

#### Scenario: Deny fallback preserved

- **WHEN** the frontmatter of `.opencode/agents/plan.md` is inspected after the change
- **THEN** the bash permission map ends in `"*": deny` and the edit map keeps
  `"openspec/**": allow` + `"*": deny`

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