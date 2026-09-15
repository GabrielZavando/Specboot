# agent-permissions Delta

## ADDED Requirements

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

## MODIFIED Requirements

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
