# Requirements: sdd-cycle-hardening

1. **REQ-001 — plan-change branch step.** The `plan-change` skill MUST contain an explicit step (between parsing and context loading) that verifies a clean git state and creates the ticket branch per `docs/git-workflow-standards.md`; its design-validation step (4½) MUST reference the real scenario source (enriched artifact or title), not a not-yet-generated `scenarios.md`. → SC-001, SC-002

2. **REQ-002 — enrich-us direct input.** The `enrich-us` skill MUST describe its input as direct user-provided text and MUST NOT reference Jira MCP, `curl`, or the Atlassian API. → SC-003

3. **REQ-003 — canonical TDD Failure Protocol.** The normative content of the TDD Failure Protocol MUST live in `docs/tdd-failure-protocol.md`; `apply.md`, `build-agent.md` and `examples/tasks.md` MUST reference it without duplicating steps or templates. → SC-004

4. **REQ-004 — dedicated commit agent.** A new `.opencode/agents/commit.md` MUST exist with `mode: primary`, `edit: deny`, a minimal own role (no build-agent role), and a bash block limited to the commit skill's commands with `"git push --force*": deny`. `.opencode/commands/commit.md` MUST declare `agent: commit`. Registered in `AGENTS.md` §5.4 and `ai-specs/README.md`; `check-refs.sh` MUST pass. → SC-005, SC-006

5. **REQ-005 — single adversarial skill injection.** `code-auditing/SKILL.md` MUST be injected exactly once in `/adversarial-review` execution: kept in `.opencode/agents/reviewer.md`, removed from `.opencode/commands/adversarial-review.md`. → SC-007

6. **REQ-006 — archive CHANGELOG permission.** The `archive` agent permission block MUST NOT allow editing `CHANGELOG.md` while its skill documents no changelog write; if a future skill step documents it, the permission is re-added (M-403 mirror rule). → SC-008

7. **REQ-007 — apply preconditions.** The `apply` command MUST verify, before dispatching any task, that the active branch matches the project convention (`feature/*`) and git is clean; on failure it MUST abort with an explicit message suggesting `/plan-change` when the branch is missing. → SC-009

8. **REQ-008 — verify npm test bare.** The `verify` agent permission block MUST include `"npm test": allow` in addition to `"npm test *": allow`, and `agent-permissions-test.sh` MUST assert it. → SC-011

9. **REQ-009 — TDD order and guards (M-403).** Guards (`tests/agent-permissions-test.sh`, `tests/commit-gate-test.sh`) MUST be extended first and observed failing before any agent/command file changes; at completion ALL guards, `check-refs.sh` and `specboot.sh --ci` MUST pass. Delta specs for `agent-permissions` and `commit-gates` MUST be updated under this change. → SC-010
