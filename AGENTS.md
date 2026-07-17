# Zavando Specboot — Agent Instructions

This file is read automatically by OpenCode.

## Context to load

Always read these files before starting any work:

- `docs/base-standards.md` — core principles, single source of truth
- `docs/backend-standards.md` — for any backend task
- `docs/frontend-standards.md` — for any frontend task
- `docs/deploy-standards.md` — for any deploy/release task
- `docs/documentation-standards.md` — for docs, API spec, or data model changes
- `docs/api-spec.yml` — API contracts (update before implementing API changes)
- `docs/data-model.md` — domain entities and database conventions

For implementation, adopt the relevant agent role:
- Backend work → `ai-specs/agents/backend-developer.md`
- Frontend work → `ai-specs/agents/frontend-developer.md`

Use the skills in `ai-specs/skills/` for workflow guidance when applicable. See `ai-specs/README.md` for the full list and descriptions.

## Skills

Skills live in `ai-specs/skills/`. When a request matches a skill's description, load and follow the corresponding `SKILL.md` automatically before continuing.

The canonical, up-to-date list of available skills (with descriptions and use cases) is maintained in [`ai-specs/README.md`](ai-specs/README.md). Reference that file instead of a duplicated list here.

## Custom commands (OpenCode)

The following custom commands are defined in `opencode.json` for the SDD workflow:

| Command | Description |
|---------|-------------|
| `/enrich-us TICKET-ID` | Enrich a vague user story before planning |
| `/plan-change TICKET-ID` | Generate OpenSpec specs and tasks from a ticket |
| `/apply TICKET-ID` | Implement tasks from OpenSpec artifacts (TDD) |
| `/verify TICKET-ID` | Validate implementation against OpenSpec scenarios |
| `/adversarial-review` | Systematic 7-phase code quality audit |
| `/archive TICKET-ID` | Archive OpenSpec artifacts for the completed change |
| `/commit` | Create conventional commits and pull request |
| `/deploy` | Release: version bump, build, deploy, smoke tests, rollback |

## Non-negotiable rules

1. One task at a time. Never skip ahead.
2. Write the failing test first. Never write production code before a failing test exists.
3. All code fully typed. No `any` without explicit justification.
4. If a fix or change appears after `/apply` and before `/archive`: update OpenSpec artifacts first, then code. Never code-only fixes.
5. If anything is ambiguous in the specs, ask before assuming.
6. Documentation is the source of truth — specs before code, always.
