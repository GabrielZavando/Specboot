# fix-agent-permissions Specification

## Purpose
TBD - created by archiving change fix-agent-permissions. Update Purpose after archive.
## Requirements
### Requirement: The /sync-specs command runs under its dedicated agent

The command `.opencode/commands/sync-specs.md` SHALL declare `agent: sync-specs` in its frontmatter, and `.opencode/agents/sync-specs.md` SHALL exist as a primary agent with scoped permissions: `edit` limited to `openspec/**` allow with `"*": deny` fallback, bash limited to `openspec *`, `git status` and `git diff` (with their variants), `ls *`, `cat *`, and `"*": deny` fallback. No other commands or permissions are granted.

#### Scenario: Command declares its dedicated agent
- **GIVEN** `.opencode/commands/sync-specs.md`
- **WHEN** its frontmatter is inspected
- **THEN** it declares `agent: sync-specs`

#### Scenario: Dedicated agent exists with scoped permissions
- **GIVEN** the installed framework
- **WHEN** `.opencode/agents/sync-specs.md` is inspected
- **THEN** it exists with `edit` limited to `openspec/**`, bash limited to `openspec *`, `git status`/`git diff` variants, `ls *`, `cat *`, and `"*": deny` fallback

### Requirement: Routine framework tooling runs without prompts

The primary agent bash allowlist in `opencode.json` SHALL include the framework's routine SDD-cycle commands — `bash tests/*`, `bash scripts/*`, `bash check-refs.sh`, `bash specboot.sh *`, `bash validate-specboot.sh`, `node *`, `mkdir *`, `date *`, `python3 *` — so that no routine command of the cycle requires user confirmation. `gh *` SHALL NOT be in the primary allowlist (the maintainer flow does not use gh; PR creation lives in the commit agent, which keeps its own `gh *` allow with its force-push deny set). Destructive or edit-bypassing commands (`rm -rf *`, `find *`, `sed -i *`) SHALL remain gated as `ask` via the `"*": "ask"` fallback.

#### Scenario: Routine commands are allowed
- **GIVEN** the primary agent allowlist in `opencode.json`
- **WHEN** the SDD cycle runs `bash tests/*-test.sh`, `bash check-refs.sh`, `bash specboot.sh --ci`, `bash validate-specboot.sh`, `bash scripts/*`, `node`, `mkdir`, `date`, or `python3` commands
- **THEN** none of them requires user confirmation

#### Scenario: Destructive commands stay gated
- **GIVEN** the primary agent allowlist in `opencode.json`
- **WHEN** an agent attempts `rm -rf *`, `find *`, `sed -i *`, or any unlisted command
- **THEN** the command falls into `ask` and requires explicit confirmation

### Requirement: verify and archive agents cover what their skills require

The `verify` agent SHALL allow `bash tests/*`, `bash scripts/*`, `node -e *`, and `date *`, with `ai-specs/agents/verify-agent.md` documenting these in its "Bash permitido" section. The `archive` agent SHALL allow `rm -f openspec/tickets/*`, and the `archive` skill SHALL instruct Mandatory Steps checkbox ticking via the edit tool scoped to `openspec/**` instead of `sed -i`. Neither agent needs to delegate its own tasks to another subagent due to missing permissions.

#### Scenario: verify runs framework guards without delegating
- **GIVEN** the `verify` agent with the synchronized allowlist
- **WHEN** verify runs `bash tests/*-test.sh`, `bash scripts/*`, `node -e *` evidence reads, and `date *` timestamps
- **THEN** none requires delegation to another subagent nor user confirmation

#### Scenario: archive cleanup and checkbox ticking without friction
- **GIVEN** the `archive` agent
- **WHEN** archive removes the enriched ticket with `rm -f openspec/tickets/*` (absent file is a no-op) and ticks Mandatory Steps checkboxes
- **THEN** the cleanup succeeds silently and the tick is done via the edit tool, not `sed -i`

