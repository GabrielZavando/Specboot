# agent-permissions Specification Delta

## ADDED Requirements

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
(permission type, pattern) pair using OpenCode's `last-match-wins` semantics
(the last matching rule wins). It MUST fail when: a catch-all rule appears
before a required exception (annulling it), a trailing generic rule overrides
a required permission, a specific prohibition is shadowed by a preceding
general permission, or any force-push variant is not effectively denied even
when `git push *` is allowed.

#### Scenario: Catch-all after exception fails

- **WHEN** an agent declares a required `allow` pattern followed by a
  matching `"*": deny`
- **THEN** the validator reports the agent, the annulled capability and the
  offending rule, and exits non-zero

#### Scenario: Force-push always denied

- **WHEN** any force-push variant (`git push --force`,
  `git push --force-with-lease`, `git push -f`, intermediate-argument
  variants) is evaluated for any agent
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

The validator MUST: accept an explicit `--root <dir>` argument identifying
the target project (never assuming the cwd is the project); discover
`.opencode/agents/*.md` under that root; parse the front matter YAML with a
real parser (`js-yaml`, declared as a runtime dependency of the Specboot
package and imported so Node resolves it relative to the validator's own
directory, not from the consumer's hoisted `node_modules`); compute effective
permissions with `last-match-wins`; compare each agent against the manifest
(which lives in the Specboot package, not the project); report agent +
capability + offending rule per violation; and exit non-zero on any mismatch.
The validator MUST run from the real framework directory: the repo itself in
dogfooding, `node_modules/@gabrielzavando/specboot` in consumer projects. It
MUST run inside `bash specboot.sh --ci` before
any publication/distribution step, printing the identifiable section
`→ Verificando contratos de permisos de agentes...`.

#### Scenario: Valid contracts pass CI

- **WHEN** `bash specboot.sh --ci` runs with conforming agents and manifest
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
