# Zavando Specboot — Agent Instructions

This file is read automatically by OpenCode.

## Context to load

`docs/base-standards.md` y este archivo se cargan siempre automáticamente vía `instructions[]`.

El resto del contexto es condicional a la tarea y el agente activo ya lo resuelve por ti:

- Tarea backend detectada por `build` → carga `docs/backend-standards.md`
- Tarea frontend detectada por `build` → carga `docs/frontend-standards.md`
- Tarea que modifica la API → carga `docs/api/api-spec.yml`
- Tarea que modifica el modelo de datos → carga `docs/data-model/data-model.md`
- Tarea de deploy → carga `docs/deploy-standards.md` (vía skill `deploy`)
- Tarea de docs → carga `docs/documentation-standards.md`

**No leas estos archivos "por si acaso": si la tarea actual no los necesita, no los cargues.**

## Skills

Skills live in `ai-specs/skills/`. When a request matches one of the triggers below, load and follow the corresponding `SKILL.md` automatically before continuing.

### Standard cycle skills

| Skill | Trigger |
| --- | --- |
| `commit` | End of the SDD cycle, via `/commit` |
| `plan-change` | Generate OpenSpec specs with descriptive change name, via `/plan-change`. Persisted artifacts from `enrich-us` live in `openspec/tickets/`. |
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

### Modelo de IA (agnóstico — gestionado externamente)

El template **no fija ningún modelo** en `opencode.json`. La selección de modelo la
gestiona tu gestor externo (p.ej. **Omniroute**) o el modelo activo de tu sesión en
OpenCode, no este template.

> Nota: una *recomendación* previa sugería usar un modelo de alto razonamiento para
> las fases de planificación (`/enrich-us`, `/plan-change`). Eso **no está cableado**
> en el template y, en uso personal con control de tokens, queda a tu criterio
> activarlo en tu gestor de modelos. El framework NO fuerza ni cambia el modelo por
> fase por sí mismo.

Cómo aplicarlo en la práctica:
- Si quieres más calidad en specs, selecciona un modelo fuerte en tu gestor (Omniroute)
  antes de correr `/plan-change` — el template lo respetará sin configuración extra.
- Si priorizas ahorro de tokens, usa un modelo económico; el ciclo SDD funciona igual.
- `opencode.json` debe seguir sin el campo `model` para preservar esta agnosticidad.

### Standard cycle

| Command | Description |
| --- | --- |
| `/plan-change TICKET-ID:"[tag] Título"` | Generate validated, context-enriched OpenSpec specs from a ticket. Tag is optional (`[backend\|frontend\|api\|docs\|fullstack]`) and drives selective standards loading; if omitted, the agent infers it and asks for confirmation. If `openspec/tickets/{TICKET-ID}-enriched.md` exists (from `/enrich-us`), it is used as the primary source. |
| `/apply TICKET-ID` | Implement tasks from OpenSpec artifacts (TDD) |
| `/verify TICKET-ID` | Execute tests and verify the active change works (files per Suggested Path, traceability, delta-incremental), reporting a compact YAML summary. Read-only agent. Ticket ID taken from the active change in `openspec/changes/`. |
| `/archive TICKET-ID` | Close the SDD cycle: pre-checks, preview of specs updated, `openspec archive`, append to manifest JSON, stage commit for `/commit`, cleanup. Token-light (no content reading). Ticket ID taken from the active change in `openspec/changes/`. |
| `/commit` | Create conventional commits and pull request (token-light diff, commit plan approval, TICKET-ID auto-extracted from proposal.md, push/PR only after explicit confirmation. Reuses openspec/ staged by /archive). |
| `/deploy` | **Optional**: Release to staging/production. Not every `/commit` triggers a `/deploy` — use only when the change is ready for release. |

### Optional tools

| Command | Description | When to use |
| --- | --- | --- |
| `/enrich-us TICKET-ID` | Enrich a vague user story before planning | Only for poorly formed tickets without acceptance criteria |
| `/adversarial-review` | Adversarial red-team code audit — runs eslint+dependency-cruiser+npm audit, emits SHIP/NO-SHIP verdict, complements /verify (does NOT re-check OpenSpec alignment). Read-only agent. Ticket ID taken from the active change in `openspec/changes/`. |

### Subagents (wired via {file:} references)

These are dispatched by `/apply` (and can be invoked directly). Each loads its role
and standards automatically through its {file:} reference, so the primary agent must delegate
to them instead of re-reading the role docs manually.

| Subagent | File | Use |
| --- | --- | --- |
| `backend` | `.opencode/agents/backend.md` → `ai-specs/agents/backend-developer.md` | Backend tasks (NestJS, API, DB, migrations) |
| `frontend` | `.opencode/agents/frontend.md` → `ai-specs/agents/frontend-developer.md` | Frontend tasks (Angular, Astro, UI) |
| `reviewer` | `.opencode/agents/reviewer.md` | Adversarial red-team audit (`/adversarial-review`) |

## Non-negotiable rules

1. One task at a time. Never skip ahead.
2. Write the failing test first. Never write production code before a failing test exists.
3. All code fully typed. No `any` without explicit justification.
4. If a fix or change appears after `/apply` and before `/archive`: update OpenSpec artifacts first, then code. Never code-only fixes.
5. If anything is ambiguous in the specs, ask before assuming.
6. Documentation is the source of truth — specs before code, always.