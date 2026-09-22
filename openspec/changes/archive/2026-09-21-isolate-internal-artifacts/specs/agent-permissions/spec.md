# agent-permissions Specification Delta

## ADDED Requirements

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

## MODIFIED Requirements

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
