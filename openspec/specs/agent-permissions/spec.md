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

### Requirement: Declarative permission contracts manifest

The framework MUST ship a declarative manifest (YAML, framework-owned) that is
the single source of truth for the permission contract of every OpenCode
agent. For each agent the manifest MUST declare: editable paths, required bash
commands, explicitly forbidden operations, evidence files the agent must
persist, and the capability flags `can_commit`, `can_push`, `can_manage_prs`,
`can_run_arbitrary_code` and `can_spawn_subagents`. The validator MUST NOT
infer responsibilities from free prose; it MUST only compare effective
permissions against the manifest.

#### Scenario: Manifest covers every agent

- **WHEN** the validator discovers `.opencode/agents/*.md`
- **THEN** every discovered agent has an entry in the manifest
- **AND** an agent without an entry is reported as a contract violation

#### Scenario: Manifest declares capability flags

- **WHEN** the manifest is parsed
- **THEN** each agent entry carries the flags `can_commit`, `can_push`,
  `can_manage_prs`, `can_run_arbitrary_code` and `can_spawn_subagents`
- **AND** no responsibility is inferred from prose

### Requirement: Effective permission evaluation honors last-match-wins

The validator MUST compute the effective permission for every
(permission type, pattern) pair using OpenCode's semantics, faithful to the
documented model: it MUST read the project's `opencode.json` (via `--root`) and
merge effective permissions in the order defaults → global (`opencode.json`) →
agent (front matter); `*` and `?` MUST be implemented as OpenCode wildcards
(multi-character and single-character respectively — `?` is never a literal);
the last matching rule wins inside each block. It MUST compare the agent's real
`mode` with the manifest, MUST validate `permission.task`, and MUST fail when a
catch-all rule appears before a required exception, a required permission is
shadowed, or any force-push variant is not effectively denied even when
`git push *` is allowed.

#### Scenario: Global and agent permissions merge in order

- **GIVEN** `opencode.json` declaring a global permission and the agent front
  matter declaring an override
- **WHEN** the effective permission is computed
- **THEN** defaults apply first, the global rule next and the agent rule last
  (last-match-wins per block)

#### Scenario: `?` acts as a single-character wildcard

- **WHEN** a pattern containing `?` is evaluated against a probe command
- **THEN** `?` matches exactly one character (OpenCode wildcard semantics), not
  a literal `?`

#### Scenario: Agent mode is compared with the manifest

- **GIVEN** an agent whose front matter `mode` differs from the manifest
- **WHEN** the validator runs
- **THEN** the mismatch is reported (agent + capability + rule) and the
  validation exits non-zero

#### Scenario: Catch-all after exception fails

- **WHEN** an agent declares a required `allow` pattern followed by a matching
  `"*": deny`
- **THEN** the validator reports the agent, the annulled capability and the
  offending rule, and exits non-zero

#### Scenario: Force-push always denied

- **WHEN** any force-push variant (`git push --force`,
  `git push --force-with-lease`, `git push -f`, intermediate-argument variants)
  is evaluated for any agent
- **THEN** the effective permission is `deny`

### Requirement: Verify and reviewer evidence write scoping

The `verify` agent MUST be able to modify only
`openspec/state/verify-results.json`, and the `reviewer` agent only
`openspec/state/adversarial-result.json`; both MUST keep `edit` effectively
`deny` for code, documentation, `tasks.md` and other states, MUST be able to
create `openspec/state`, MUST be able to obtain UTC timestamps, and MUST be
able to run the toolchain documented in their roles/skills.

#### Scenario: Verify writes only its evidence

- **WHEN** the effective `edit` permissions of `verify` are evaluated
- **THEN** only `openspec/state/verify-results.json` resolves to `allow`
- **AND** `verify` can create `openspec/state` and run its documented test
  runners plus `date` for timestamps

#### Scenario: Reviewer writes only its evidence

- **WHEN** the effective `edit` permissions of `reviewer` are evaluated
- **THEN** only `openspec/state/adversarial-result.json` resolves to `allow`
- **AND** `reviewer` can run `npm audit *`, `npx eslint *`,
  `npx dependency-cruiser *`, create `openspec/state` and get UTC timestamps

### Requirement: Commit ownership is exclusive

The `commit` agent SHALL be the only agent allowed to effectively run
`git add`, `git commit`, `git push` and authorized `gh` PR operations.
Every other agent (`build`, `backend`, `frontend`, `sdd-plan`, `verify`,
`reviewer`, `archive`, `sync-specs`) MUST resolve `git commit` and
`git push` to `deny`.

#### Scenario: Non-commit agent denied git commit/push

- **WHEN** `git commit` or `git push` is evaluated for any agent other than
  `commit`
- **THEN** the effective permission is `deny`

#### Scenario: Commit agent keeps scoped ownership

- **WHEN** `git add *`, `git commit *` and `git push *` are evaluated for the
  `commit` agent
- **THEN** the effective permission is `allow`
- **AND** every force-push variant remains `deny`

### Requirement: No write-bypass via arbitrary code execution

Agents needing only JSON field reads MUST NOT carry generic arbitrary-code
permissions such as `node -e *`, `python -c *`, `python3 -c *`, `cat >`,
`tee` or `sed -i`. The framework MUST provide `scripts/read-json-field.mjs`
(fixed, read-only, ESM) that reads ONLY a closed allowlist of authorized JSON
files and fields hardcoded in the helper itself — it MUST NOT accept
arbitrary JSON paths from the caller. The `archive` and `commit` agents MUST
use it instead of `node -e *`.

#### Scenario: Archive and commit lack arbitrary-JS allow

- **WHEN** the bash permissions of `archive` and `commit` are evaluated
- **THEN** no pattern allows arbitrary JavaScript execution (`node -e *` is
  absent or effectively denied)
- **AND** the fixed read-only JSON helper `scripts/read-json-field.mjs` is
  allowed instead, with its allowlist of files/fields hardcoded inside the
  helper

### Requirement: Automated validator integrated into CI

The validator MUST: accept an explicit `--root <dir>` argument identifying the
target project (never assuming the cwd is the project); discover
`.opencode/agents/*.md` under that root; parse the front matter YAML with a
real parser (`js-yaml`, declared as a runtime dependency of the Specboot
package and imported so Node resolves it relative to the validator's own
directory, not from the consumer's hoisted `node_modules`); compute effective
permissions faithful to OpenCode (defaults → global → agent, `*`/`?`
wildcards); compare each agent against the manifest (which lives in the
Specboot package, not the project); report agent + capability + offending rule
per violation; and exit non-zero on any mismatch. The validation target of the
`--ci`/`--init` modes (the invocation directory, even when executed from
`node_modules/@gabrielzavando/specboot`) is normative in the `specboot-update`
capability delta (REQ-008) — this capability does not duplicate that rule; the
validator itself keeps running from the package location with an explicit
`--root`, and framework-owned helpers (check-refs, validate-specboot.sh, the
permission validator) keep resolving from the package location. The
permission-contracts section MUST run inside `bash specboot.sh --ci` before any
publication/distribution step, printing the identifiable section
`→ Verificando contratos de permisos de agentes...`, and
`check_permission_contracts()` MUST be defined outside `check_ci_cd()` so no
implicit call-order dependency exists.

#### Scenario: Valid contracts pass CI

- **WHEN** `bash specboot.sh --ci` runs with conforming agents, commands and
  manifest
- **THEN** the permission-contracts section passes and CI exits 0

#### Scenario: Drift blocks CI

- **WHEN** any agent's effective permissions diverge from the manifest
  (missing required permission or exceeded scope)
- **THEN** the validator reports agent, capability and rule, and
  `specboot.sh --ci` exits non-zero

### Requirement: Contracts distribution via init/update

`specboot init` and `specboot update` MUST install the corrected agents and
the `scripts/read-json-field.mjs` helper into consumer projects (the helper
is invoked directly by the project's agents, so it MUST be copied). The
validator and the manifest MUST be packaged in `package.json#files` but MUST
NOT be copied into consumer projects nor be part of `UPDATE_ITEMS` /
`REQUIRED_FILES`: they are executed from the package directory
(`node_modules/@gabrielzavando/specboot`). The helper MUST be listed in
`package.json#files`, the `UPDATE_ITEMS` array (as the file-level entry
`scripts/read-json-field.mjs`) and the `REQUIRED_FILES` array of
`specboot.sh`, all covered by the `specboot init`/`specboot update` tests,
including a consumer project without `js-yaml` hoisted at its root. The
structural validation must list every agent, skill, helper and contract file
required by `/plan-change`, `/verify`, `/adversarial-review`, `/archive` and
`/commit`.

#### Scenario: Fresh init installs conforming contracts

- **WHEN** a temporary project runs `specboot init`
- **THEN** the installed agents and helper match the framework, the
  validator and manifest run from the installed package, and the validator
  passes with `--root` pointing at the consumer project

#### Scenario: Update keeps contracts in sync

- **WHEN** an existing project runs `specboot update`
- **THEN** the installed agents and helper match the framework and the
  validator passes from the installed package path

#### Scenario: Validator runs without hoisted js-yaml

- **WHEN** the validator runs from the framework package directory in a
  consumer project whose own `node_modules` does not contain `js-yaml`
- **THEN** `js-yaml` resolves from the package's own dependencies and the
  validation completes

### Requirement: Subagent spawn contract in manifest and front matter

The manifest MUST declare, for every agent, an explicit subagent contract:

```yaml
task:
  allow: []
  forbidden:
    - "*"
```

`build` MUST allow only `backend` and `frontend` (with `forbidden: ["*"]` for
everything else); `reviewer`, `verify`, `commit`, `archive`, `sdd-plan`,
`sync-specs`, `backend` and `frontend` MUST NOT be able to launch subagents.
Every agent front matter MUST declare `permission.task` so that agents with
`can_spawn_subagents: false` resolve `task` effectively to `deny` for any
subagent name. `/adversarial-review` MAY keep invoking a single `reviewer` via
`subtask: true`; the `reviewer` agent itself MUST NOT spawn children.

#### Scenario: Non-spawner agents resolve task deny

- **WHEN** the effective `task` permission is evaluated for any subagent name
  on an agent with `can_spawn_subagents: false`
- **THEN** the effective result is `deny`

#### Scenario: build can only invoke backend and frontend

- **WHEN** the effective `task` permission of `build` is evaluated for
  `backend` and `frontend`
- **THEN** both resolve to `allow`
- **AND** any other subagent name (`verify`, `reviewer`, `commit`, `archive`,
  `sdd-plan`, `sync-specs`) resolves to `deny`

### Requirement: Command contracts validated from front matter

The framework MUST validate `.opencode/commands/*.md` automatically (integrated
into the CI validation), reading each command's front matter with a real parser
— the TUI label MUST NOT be treated as proof of the effective agent. Every
command MUST declare `agent`, with the mappings `/apply` → `build`,
`/plan-change` → `sdd-plan`, `/verify` → `verify`, `/archive` → `archive`,
`/commit` → `commit`, and `/adversarial-review` → `reviewer` with
`subtask: true`. A command missing `agent`, with a mismatched agent, or
missing `subtask: true` on `/adversarial-review` MUST fail the validation with
the command and the offending rule reported.

#### Scenario: Valid command contracts pass

- **WHEN** the command contracts are validated with all commands declaring the
  contracted `agent` values
- **THEN** the validation passes

#### Scenario: Mismatched or missing agent fails

- **GIVEN** a fixture command without `agent`, with a wrong `agent`, or
  `/adversarial-review` without `subtask: true`
- **WHEN** the command contracts are validated
- **THEN** the violation is reported (command + rule) and the validation exits
  non-zero

### Requirement: Capability flags are fiscalized independently with bypass detection

The validator MUST audit each capability flag independently — `can_commit`,
`can_push`, `can_manage_prs`, `can_run_arbitrary_code` and
`can_spawn_subagents` — without deriving `can_push` or PR management from
`can_commit`. It MUST detect bypasses through Git variants, GitHub CLI variants
and compound commands embedding forbidden commands in a non-initial position,
covering at least the separators `;`, `&&`, `||`, `|` and newline, each with
and without surrounding spaces. The validator's comment and documentation MUST
promise exactly the coverage it checks — never a broader claim ("total
coverage"). For agents with `can_run_arbitrary_code: true`, pattern-based
denials of git write operations MUST be documented as defense against
accidental mistakes (defense-in-depth), not as a security boundary against
deliberate evasion via arbitrary-code wrappers (`bash -c`, `node -e`,
subshells, backticks); the safe `git push` wrapper for the `commit` agent
stays documented as future hardening. Implementer agents MUST prefer read-only
Git allowlists in the manifest (with their scope justification updated). A safe
wrapper for the `commit` agent's `git push` MUST be evaluated, rejecting any
force variant; the effective denial of every force variant remains validated
automatically either way.

#### Scenario: Each flag fails CI independently

- **GIVEN** fixtures violating each flag independently (for example
  `can_push: false` with `git push` effectively allow, `can_manage_prs: false`
  with `gh pr create *` allow, `can_spawn_subagents: false` with a permissive
  `task` contract)
- **WHEN** the validator runs
- **THEN** each violation is reported independently (agent + capability + rule)
  and `specboot.sh --ci` exits non-zero
- **AND** removing a `can_commit` violation does not hide a `can_push` or PR
  management violation

#### Scenario: Compound command bypass is detected

- **GIVEN** probe commands embedding a forbidden command in a non-initial
  segment using each supported separator — `;`, `&&`, `||`, `|` and newline,
  each with and without surrounding spaces (e.g. `echo hi; git push --force`,
  `echo hi;git push --force`, `echo hi&&git push --force`,
  `echo hi || git push --force`, `echo hi||git push --force`,
  `echo hi|git push --force`)
- **WHEN** the validator evaluates the compound command for an agent whose
  contract forbids them
- **THEN** every separator variant is detected (the bypass is reported or the
  denial enforced per contract)
- **AND** the validator's comment and documentation promise exactly this
  coverage; wrappers (`bash -c`, `node -e`, subshells, backticks) are governed
  by `can_run_arbitrary_code` and the defense-in-depth note, not claimed as
  pattern-covered

