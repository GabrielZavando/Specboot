# agent-permissions Delta

## MODIFIED Requirements

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
