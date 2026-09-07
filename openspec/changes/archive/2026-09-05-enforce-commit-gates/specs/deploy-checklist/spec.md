# deploy-checklist Specification

## ADDED Requirements

### Requirement: deploy skill MUST enforce a project-agnostic minimum checklist
The `deploy` skill SHALL define a mandatory minimum checklist that `/deploy` MUST pass before any release step: tests green, lint without critical errors, build succeeds, security audit without critical vulnerabilities (`npm audit` / `pip-audit`), rollback procedure defined, and the OpenSpec change archived. If any check fails, the deploy SHALL stop before the version bump and report the failed items.

#### Scenario: Deploy blocks when the minimum checklist fails
- **GIVEN** a `/deploy` execution with any checklist item failing (e.g., red tests or no rollback defined)
- **WHEN** the pre-deploy checklist runs
- **THEN** the deploy stops before the version bump with a report of the failed items
- **AND** it does not proceed until every item passes

#### Scenario: Deploy proceeds with the checklist green
- **GIVEN** all six checklist items pass
- **WHEN** `/deploy` continues
- **THEN** it follows the project-specific flow in `docs/deploy-standards.md` (bump, build & push, staging, production)

### Requirement: deploy-standards template MUST include rollback and archived change in the pre-deploy checklist
The template `docs/deploy-standards.md` SHALL list in its Pre-deploy Checklist at least "Rollback procedure defined" and "OpenSpec change archived", alongside the existing items (tests, lint/typecheck, build, security audit), consistent with the mandatory checklist of the `deploy` skill.

#### Scenario: Template checklist includes rollback and archived change
- **GIVEN** the template `docs/deploy-standards.md`
- **WHEN** a maintainer personalizes it for a project
- **THEN** the Pre-deploy Checklist contains "Rollback procedure defined" and "OpenSpec change archived"
- **AND** the `deploy` skill checklist declares them mandatory
