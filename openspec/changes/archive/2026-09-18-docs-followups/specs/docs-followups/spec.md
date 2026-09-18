# docs-followups (delta)

## ADDED Requirements

### Requirement: Consumer Git workflow recommendation

The framework SHALL ship `docs/consumer-git-workflow.md` documenting GitHub Flow for consumer projects — branches `feature/*`, `fix/*`, `chore/*`, `docs/*`, Conventional Commit PR titles, mandatory CI before merge, semver releases and hotfix flow — with an explicit note that it is an optional recommendation for consumers and does NOT apply to the framework's own development (governed by `docs/git-workflow-standards.md`, which SHALL remain unmodified). `docs/framework-contract.md` and `README.md` SHALL reference it, distinguishing both scopes.

#### Scenario: Consumer git workflow documented
- **GIVEN** a consumer project installing the framework
- **WHEN** it consults the recommended Git strategy
- **THEN** `docs/consumer-git-workflow.md` exists with the GitHub Flow recommendation and the optional/doesn't-apply-here note, `docs/framework-contract.md` and `README.md` reference it, and `docs/git-workflow-standards.md` is unmodified

### Requirement: Mandatory Steps tick handoff is documented

The `verify` skill (Step 8) and the `code-auditing` skill (Paso 7) SHALL document the Mandatory Steps tick handoff: the persisted evidence is produced by the read-only subagent, and the orchestrating agent (build/primary) ticks the post-phase checkbox in `tasks.md` upon validating that evidence. The subagent never edits `tasks.md`.

#### Scenario: verify and code-auditing document the handoff
- **GIVEN** a change with a `## Mandatory Steps` section whose post phase is satisfied
- **WHEN** the `verify` or `adversarial-review` evidence is produced
- **THEN** the corresponding skill documents that the orchestrating agent ticks the checkbox upon obtaining the evidence and that the read-only subagent does not

### Requirement: The F-harness investigation is recorded

`PLAN_MEJORAS_SPECBOOT.md` SHALL record the F-harness investigation (tool-call degradation incidents during the M-701/M-908/M-909 cycles) as evaluated with no repo-side action, noting that the harness-side symptoms (write schema rejection, cancelled subagents, read loops) are outside the repository, and recording the operational mitigations (short sessions, retries after a user message).

#### Scenario: F-harness recorded as evaluated
- **GIVEN** the M-701/M-908/M-909 session incidents
- **WHEN** the roadmap is updated
- **THEN** `PLAN_MEJORAS_SPECBOOT.md` documents F-harness as evaluated-no-repo-action with its mitigations
