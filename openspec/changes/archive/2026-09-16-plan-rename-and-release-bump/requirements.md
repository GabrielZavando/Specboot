# Requirements: plan-rename-and-release-bump

1. **REQ-001 — Agent rename without reserved collision.** `.opencode/agents/plan.md` MUST be renamed to `sdd-plan.md` preserving frontmatter permissions and role content; the commands `plan-change.md`, `enrich-us.md`, `explain.md` MUST declare `agent: sdd-plan`; no command may declare `agent: plan`. References in `AGENTS.md`, `ai-specs/README.md`, guards and the `agent-permissions` spec MUST be updated (M-403 mirror). → SC-001, SC-002

2. **REQ-002 — No plan-mode capture.** After the rename, running `/plan-change` in a build-mode session MUST NOT switch the editor to plan mode; `sdd-plan` is not an OpenCode reserved name. → SC-003

3. **REQ-003 — Atomic release-bump.** A root script `release-bump.sh <semver>` MUST update `package.json → version` and `.specboot.json → frameworkVersion` atomically (both files parsed and validated BEFORE any write); MUST abort with a clear error and no writes if the version is not valid semver, if it is not strictly greater than the current version, or if the CHANGELOG lacks the target section; MUST NOT create git tags or commits. → SC-004, SC-005, SC-009, SC-010

4. **REQ-004 — Script distributed with the package.** `release-bump.sh` MUST be in `package.json → files` and in `UPDATE_ITEMS` (and init copy set) like `check-refs.sh`, with distribution guards updated. → SC-006

5. **REQ-005 — Breaking change documented and verified.** CHANGELOG 0.9.0 MUST contain a `### Breaking changes` entry documenting the `plan → sdd-plan` rename with migration instructions; all guards, `check-refs.sh` and `specboot.sh --ci` MUST pass at closure. → SC-007, SC-008
