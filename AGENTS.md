# Zavando Specboot — Agent Instructions

This file is read automatically by OpenCode.

## Context to load

`docs/base-standards.md` y este archivo se cargan siempre automáticamente vía `instructions[]`.

El resto del contexto es condicional a la tarea y el agente activo ya lo resuelve por ti:

- Tarea backend detectada por `build` → carga `docs/backend-standards.md`
- Tarea frontend detectada por `build` → carga `docs/frontend-standards.md`
- Tarea que modifica la API → carga `docs/api-spec.yml`
- Tarea que modifica el modelo de datos → carga `docs/data-model.md`
- Tarea de deploy → carga `docs/deploy-standards.md` (vía skill `deploy`)
- Tarea de docs → carga `docs/documentation-standards.md`

**No leas estos archivos "por si acaso": si la tarea actual no los necesita, no los cargues.**

## Skills

Skills live in `ai-specs/skills/`. When a request matches one of the triggers below, load and follow the corresponding `SKILL.md` automatically before continuing.

### Standard cycle skills

| Skill | Trigger |
| --- | --- |
| `commit` | End of the SDD cycle, via `/commit` |
| `plan-change` | Generate OpenSpec specs with descriptive change name, via `/plan-change`. Persisted artifacts from `enrich-us` live in `.openspec/tickets/`. |
| `using-git-worktrees` | Parallel feature work during `/plan-change` |
| `deploy` | Release to staging/production, via `/deploy` |
| `onboarding` | A new developer is starting on the project |

### Optional skills (use only when needed)

| Skill | Trigger | When to use |
| --- | --- | --- |
| `enrich-us` | Ticket is vague or poorly formed | **Only before `/plan-change`** if the ticket lacks acceptance criteria or context. Skip if ticket is already well-formed. |
| `code-auditing` | Something went wrong during implementation | **Rescue tool only**: use via `/adversarial-review` when tests fail unexpectedly or implementation diverges from spec. Not part of standard cycle. |
| `show-spec-working` | Debug command registered in `opencode.json` | **Debug tool**: use `/show-spec-working` when the agent is confused about current tasks, the user wants to see progress, verification fails, or before `/apply` to confirm the right task. Read-only. |
| `explain` | User asks "why did you do X?" or needs decision context | **On-demand**: use when explaining technical decisions, tradeoffs, or rationale. Not part of standard cycle. |

For extended detail (phases, full descriptions, examples) see `ai-specs/README.md` — that file is for humans and is not auto-loaded, so it can go deeper than this table without duplicating what agents need at request time.

## Custom commands (OpenCode)

The following custom commands are defined in `opencode.json` for the SDD workflow:

### Recomendación de modelos (no obligatoria)

Para fases de **planificación** (`/enrich-us`, `/plan-change`), se recomienda usar un modelo con alto razonamiento (ej: Claude Opus, GPT-4, Gemini 1.5 Pro) si tu proveedor lo soporta. Esto mejora la calidad de specs y escenarios.

Para fases de **implementación** (`/apply`, `/verify`, `/commit`, `/deploy`), cualquier modelo funcional es suficiente.

El template no fija ningún modelo en `opencode.json` — el agente usa el modelo activo de tu sesión.

### Standard cycle

| Command | Description |
| --- | --- |
| `/plan-change TICKET-ID:"[tag] Título"` | Generate validated, context-enriched OpenSpec specs from a ticket. Tag is optional (`[backend\|frontend\|api\|docs\|fullstack]`) and drives selective standards loading; if omitted, the agent infers it and asks for confirmation. If `.openspec/tickets/{TICKET-ID}-enriched.md` exists (from `/enrich-us`), it is used as the primary source. |
| `/apply TICKET-ID` | Implement tasks from OpenSpec artifacts (TDD) |
| `/verify TICKET-ID` | Execute tests and verify the active change works (files per Suggested Path, traceability, delta-incremental), reporting a compact YAML summary. Read-only agent. Ticket ID taken from the active change in `.openspec/changes/`. |
| `/archive TICKET-ID` | Close the SDD cycle: pre-checks, preview of specs updated, `openspec archive`, append to manifest JSON, stage commit for `/commit`, cleanup. Token-light (no content reading). Ticket ID taken from the active change in `.openspec/changes/`. |
| `/commit` | Create conventional commits and pull request (token-light diff, commit plan approval, TICKET-ID auto-extracted from proposal.md, push/PR only after explicit confirmation. Reuses openspec/ staged by /archive). |
| `/deploy` | **Optional**: Release to staging/production. Not every `/commit` triggers a `/deploy` — use only when the change is ready for release. |

### Optional tools

| Command | Description | When to use |
| --- | --- | --- |
| `/enrich-us TICKET-ID` | Enrich a vague user story before planning | Only for poorly formed tickets without acceptance criteria |
| `/adversarial-review` | Adversarial red-team code audit — runs eslint+dependency-cruiser+npm audit, emits SHIP/NO-SHIP verdict, complements /verify (does NOT re-check OpenSpec alignment). Read-only agent. Ticket ID taken from the active change in `.openspec/changes/`. |

## Non-negotiable rules

1. One task at a time. Never skip ahead.
2. Write the failing test first. Never write production code before a failing test exists.
3. All code fully typed. No `any` without explicit justification.
4. If a fix or change appears after `/apply` and before `/archive`: update OpenSpec artifacts first, then code. Never code-only fixes.
5. If anything is ambiguous in the specs, ask before assuming.
6. Documentation is the source of truth — specs before code, always.