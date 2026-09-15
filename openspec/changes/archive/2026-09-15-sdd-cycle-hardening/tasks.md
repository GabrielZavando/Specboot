# Tasks: sdd-cycle-hardening (TICKET-AUDIT-1)

> Implements requirements REQ-001…REQ-009 covering scenarios SC-001…SC-011.
> TDD: guards are extended and observed failing (RED) before any
> agent/command/skill file is modified (GREEN).

---

## Mandatory Steps

> Injected by `plan-change` from `docs/openspec-tasks-mandatory-steps.md`
> (single source of truth, read at generation time). This checklist is
> **mandatory, not suggested**, and applies to every implementation task
> executed via `/apply`.

**Pre-implementation**

- [x] Active branch follows the project's current convention (`feature/*`); never work directly on the main branch — `feature/ticket-audit-1-sdd-cycle-hardening`
- [x] Clean git state at start (spec artifacts uncommitted as part of the flow)

**During implementation**

- [x] New test fails before implementing (RED): Tasks 1-2 guards extended and observed failing before any agent/command change
- [x] Guards re-run while iterating (RED-GREEN per task), not only at the end

**Post-implementation**

- [x] Run `verify`: produces `openspec/state/verify-results.json` (PASS, executable)
- [x] Run `adversarial-review`: produces `openspec/state/adversarial-result.json` (SHIP, 0.85)

---

## Phase 1 — Guards first (RED)

### Task 1: Extend agent-permissions guard with new invariants ✅ COMPLETED (RED observed: 10 failing asserts)

- [x] Add asserts: `.opencode/agents/commit.md` exists; `edit: deny`; `"git push --force*": deny` present; `bash` limited to allowed set; command `commit.md` declares `agent: commit`
- [x] Add assert: verify agent includes `"npm test": allow` (SC-011)
- [x] Add assert: archive agent block does NOT allow `CHANGELOG.md` (SC-008)
- [x] Run guard → observe failures (RED)
- Priority: High
- Layer: Framework infra (guards)
- Suggested Path: tests/agent-permissions-test.sh
- Test Path: tests/agent-permissions-test.sh
- Estimated: 1 hour

### Task 2: Extend commit-gate guard for the dedicated agent ✅ COMPLETED (RED observed: 2 failing asserts)

- [x] Add assert: `.opencode/commands/commit.md` frontmatter `agent: commit` (SC-005)
- [x] Add assert: commit agent file does NOT inject `build-agent.md`
- [x] Run guard → observe failures (RED)
- Priority: High
- Layer: Framework infra (guards)
- Suggested Path: tests/commit-gate-test.sh
- Test Path: tests/commit-gate-test.sh
- Estimated: 0.5 hours

## Phase 2 — Agents and commands (GREEN)

### Task 3: Create dedicated commit agent and rewire the command ✅ COMPLETED (GREEN: commit asserts pass; SC-011/SC-008 remain RED pending Task 4)

- [x] Create `.opencode/agents/commit.md` per SC-005/SC-006
- [x] Update `.opencode/commands/commit.md` frontmatter to `agent: commit`
- [x] Register agent in `AGENTS.md` §5.4 and `ai-specs/README.md`
- [x] Re-run Tasks 1-2 guards → GREEN
- Priority: High
- Layer: Framework infra
- Suggested Path: .opencode/agents/commit.md, .opencode/commands/commit.md, AGENTS.md, ai-specs/README.md
- Test Path: tests/agent-permissions-test.sh, tests/commit-gate-test.sh
- Estimated: 1.5 hours

### Task 4: Fix verify, archive and adversarial permission sync ✅ COMPLETED (GREEN: 39/39 agent-permissions, 15/15 adversarial-state)

- [x] Add `"npm test": allow` to `.opencode/agents/verify.md`, documented (role already listed `npm test`)
- [x] Remove `CHANGELOG.md` allow from `.opencode/agents/archive.md`
- [x] Remove `{file:...code-auditing...}` from `.opencode/commands/adversarial-review.md` (kept in `reviewer.md`)
- [x] Re-run agent-permissions + adversarial-state guards → GREEN
- Priority: High
- Layer: Framework infra
- Suggested Path: .opencode/agents/verify.md, ai-specs/agents/verify-agent.md, .opencode/agents/archive.md, .opencode/commands/adversarial-review.md
- Test Path: tests/agent-permissions-test.sh, tests/adversarial-state-test.sh
- Estimated: 1 hour

### Task 5: Add apply preconditions ✅ COMPLETED

- [x] Add pre-flight section to `.opencode/commands/apply.md`: verify `feature/*` branch + clean git; abort message suggests `/plan-change` when branch is missing (SC-009)
- Priority: High
- Layer: Framework docs/commands
- Suggested Path: .opencode/commands/apply.md
- Test Path: no aplica (documentación de comando; cubierto por check-refs)
- Estimated: 0.5 hours

## Phase 3 — Skills and canonical docs

### Task 6: Create canonical TDD Failure Protocol and de-duplicate references ✅ COMPLETED

- [x] Create `docs/tdd-failure-protocol.md` with the normative protocol (3 attempts, report fields, stop rule, retry reset)
- [x] Replace inline protocol in `.opencode/commands/apply.md` with a reference
- [x] Update references in `ai-specs/agents/build-agent.md` and `ai-specs/examples/tasks.md` to the canonical doc (SC-004)
- Priority: High
- Layer: Framework docs
- Suggested Path: docs/tdd-failure-protocol.md, .opencode/commands/apply.md, ai-specs/agents/build-agent.md, ai-specs/examples/tasks.md
- Test Path: tests/check-refs.sh (via check-refs run)
- Estimated: 1 hour

### Task 7: Clean enrich-us (no Jira) ✅ COMPLETED

- [x] Remove Jira MCP / `curl` block from `ai-specs/skills/enrich-us/SKILL.md` Step 1; input described as direct user-provided text (SC-003)
- Priority: Medium
- Layer: Framework docs
- Suggested Path: ai-specs/skills/enrich-us/SKILL.md
- Test Path: no aplica (grep guard: no "jira" in ai-specs/)
- Estimated: 0.25 hours

### Task 8: plan-change branch step and 4½ fix ✅ COMPLETED

- [x] Insert explicit branch-creation step (Step 1½) in `ai-specs/skills/plan-change/SKILL.md`: git-clean check, create `feature/ticket-X-nombre` per git-workflow-standards, confirm name, ask before reusing existing branch (SC-001)
- [x] Rewrite Step 4½ to reference entity/endpoint checks against enriched-artifact scenarios or title-derived scenarios, not a non-existent scenarios.md (SC-002)
- Priority: High
- Layer: Framework docs
- Suggested Path: ai-specs/skills/plan-change/SKILL.md
- Test Path: no aplica (cubiertos por spec delta + verify)
- Estimated: 1 hour

## Phase 4 — Spec deltas and closure

### Task 9: Update delta specs ✅ COMPLETED

- [x] `openspec/specs/agent-permissions/spec.md` delta: commit agent requirements, npm test bare for verify, archive CHANGELOG removal — written at plan time, verified to match final implementation
- [x] `openspec/specs/commit-gates/spec.md` delta: command wires to commit agent — verified
- [x] Run `openspec validate sdd-cycle-hardening` ✅
- Priority: High
- Layer: Framework docs
- Suggested Path: openspec/specs/agent-permissions/spec.md, openspec/specs/commit-gates/spec.md
- Test Path: openspec validate output
- Estimated: 1 hour

### Task 10: Full guard suite, CI check and version bump ✅ COMPLETED

- [x] Run all `tests/*.sh` (18/18 verdes), `bash check-refs.sh`, `bash specboot.sh --ci` → 0 errores (SC-010)
- [x] CHANGELOG entry + minor version bump 0.7.0 → 0.8.0 (nuevo agente = feature)
- [x] **Fix post-apply (verify)**: `.specboot.json` no subió a 0.8.0 con `npm version`; actualizado frameworkVersion y generalizado el assert SC-007 de `mandatory-steps-test.sh` (consistencia dinámica package.json ↔ .specboot.json)
- Priority: High
- Layer: Framework infra
- Suggested Path: CHANGELOG.md, package.json
- Test Path: tests/specboot-ci
- Estimated: 0.5 hours
