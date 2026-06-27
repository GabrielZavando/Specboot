# Zavando Specboot — Agent Instructions

This file is read automatically by OpenCode, Codex, and other compatible agents.

## Context to load

Always read these files before starting any work:

- `docs/base-standards.md` — core principles, single source of truth
- `docs/backend-standards.md` — for any backend task
- `docs/frontend-standards.md` — for any frontend task
- `docs/documentation-standards.md` — for docs, API spec, or data model changes
- `docs/api-spec.yml` — API contracts (update before implementing API changes)
- `docs/data-model.md` — domain entities and database conventions

For implementation, adopt the relevant agent role:
- Backend work → `ai-specs/agents/backend-developer.md`
- Frontend work → `ai-specs/agents/frontend-developer.md`

Use `ai-specs/skills/` for workflow guidance when applicable (enrich-us, commit, code-auditing, using-git-worktrees).

## Skills

Skills live in `ai-specs/skills/`. When a request matches a skill's description, load and follow the corresponding `SKILL.md` automatically before continuing.

Available skills:
- `ai-specs/skills/enrich-us/SKILL.md` — enrich a vague user story before planning
- `ai-specs/skills/using-git-worktrees/SKILL.md` — isolated workspace per feature
- `ai-specs/skills/code-auditing/SKILL.md` — systematic 7-phase code audit
- `ai-specs/skills/commit/SKILL.md` — conventional commits and PR creation

## Custom commands (OpenCode)

The following custom commands are defined in `opencode.json` for the SSD workflow:

| Command | Description |
|---------|-------------|
| `/enrich-us TICKET-ID` | Enrich a vague user story before planning |
| `/plan-change TICKET-ID` | Generate OpenSpec specs and tasks from a ticket |
| `/apply TICKET-ID` | Implement tasks from OpenSpec artifacts (TDD) |
| `/verify TICKET-ID` | Validate implementation against OpenSpec scenarios |
| `/adversarial-review` | Systematic 7-phase code quality audit |
| `/archive TICKET-ID` | Archive OpenSpec artifacts for the completed change |
| `/commit` | Create conventional commits and pull request |

## Non-negotiable rules

1. One task at a time. Never skip ahead.
2. Write the failing test first. Never write production code before a failing test exists.
3. All code fully typed. No `any` without explicit justification.
4. If a fix or change appears after `/apply` and before `/archive`: update OpenSpec artifacts first, then code. Never code-only fixes.
5. If anything is ambiguous in the specs, ask before assuming.
6. Documentation is the source of truth — specs before code, always.
