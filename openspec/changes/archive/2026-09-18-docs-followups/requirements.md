# Requirements: docs-followups

1. **REQ-001**: A new `docs/consumer-git-workflow.md` SHALL document GitHub Flow
   for consumer projects (branches `feature/*`/`fix/*`/`chore/*`/`docs/*`,
   Conventional Commit PR titles, CI before merge, semver releases, hotfix
   flow) with an explicit note that it is an optional recommendation that does
   NOT apply to the framework's own development.
   (traces: SC-001)

2. **REQ-002**: `docs/git-workflow-standards.md` SHALL remain unmodified
   relative to `origin/main` (untouchable internal standard).
   (traces: SC-001)

3. **REQ-003**: `docs/framework-contract.md` and `README.md` SHALL reference
   `docs/consumer-git-workflow.md` as the consumer-facing recommendation,
   distinguishing it from the internal standard.
   (traces: SC-002)

4. **REQ-004**: The `verify` skill (Step 8) and the `code-auditing` skill
   (Paso 7) SHALL document the Mandatory Steps tick handoff: the orchestrating
   agent ticks the post-phase checkbox upon producing the persisted evidence;
   the read-only subagent does not.
   (traces: SC-003)

5. **REQ-005**: `PLAN_MEJORAS_SPECBOOT.md` SHALL mark `## [x] M-801`, register
   `## [x] M-910` (M-403 pattern: SemVer `patch`, dependencies M-909/reviewer
   finding F1), record the F-harness investigation as evaluated-no-repo-action,
   and add a history row.
   (traces: SC-004, SC-005)

6. **REQ-006**: `tests/mandatory-steps-test.sh` SHALL be extended with asserts
   for SC-001..SC-005, and `bash check-refs.sh`, `bash specboot.sh --ci`,
   `bash validate-specboot.sh` and all `tests/*-test.sh` SHALL pass after the
   change (no regression).
   (traces: SC-006)
