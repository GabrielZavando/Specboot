# Requirements — agents-bridge

> Requirements are numbered and each one is traceable to at least one scenario
> in `scenarios.md`. Source ticket: TICKET-2.1.

## REQ-1 — AGENTS.md declara explícitamente su sección de carga base intocable

`AGENTS.md` MUST contain a section titled "Carga base (intocable)" that documents
that `docs/base-standards.md` is always loaded by OpenCode via `opencode.json`'s
`instructions[]` and that this file is part of the framework's intocable frontier.

- Traceability: Scenario 1, Scenario 4.

## REQ-2 — AGENTS.md declara la carga dinámica de docs/project/* con fallback a placeholder

`AGENTS.md` MUST contain a section titled "Carga dinámica" that instructs the
agent to read `docs/project/domain.md` and `docs/project/stack.md` **if they
exist**, and to fall back to a default placeholder content (marked as "placeholder
por proyecto") otherwise. The section MUST also preserve the existing tag-based
loading matrix (`[backend]`, `[frontend]`, `[api]`, `[docs]`, `[deploy]`) and the
"no leas por si acaso" directive. It MUST NOT use OpenCode `{file:...}` references
for `docs/project/*` (those files are project-owned and may not exist).

- Traceability: Scenario 2, Edge case (docs/project/* missing), Edge case (update).

## REQ-3 — AGENTS.md declara herramientas de validación del puente

`AGENTS.md` MUST contain a section titled "Herramientas" that references
`check-refs.sh` and `specboot.sh --ci` as the validation entry points for the
bridge's integrity (no broken `{file:...}` refs and no missing skill names).

- Traceability: Scenario 3, Scenario 5.

## REQ-4 — AGENTS.md incluye una "Nota de puente"

`AGENTS.md` MUST contain a "Nota de puente" that states: the file is only the
interface; the project's heavy content lives in `docs/`; `specboot update`
replaces `AGENTS.md` without losing the project context because that context lives
in `docs/`.

- Traceability: Scenario 4, Edge case (update).

## REQ-5 — check-refs.sh y specboot.sh --ci siguen pasando tras el cambio

After the change, running `bash check-refs.sh` from the project root MUST report
0 errors, and `bash specboot.sh --ci` MUST also report 0 errors. The change MUST
NOT alter the list of files returned by `check-refs.sh` Step 3 (every skill name
must still appear in `AGENTS.md`) and MUST NOT alter `specboot.sh`'s
`REQUIRED_FILES` or `PLACEHOLDER_PATTERNS` arrays.

- Traceability: Scenario 5, Scenario 6.

## REQ-6 — docs/docs-standard.md §3 documenta la regla condicional de carga

`docs/docs-standard.md` §3 ("Regla de carga dinámica del puente AGENTS.md") MUST
be extended (NOT renamed) to add the explicit conditional rule for
`docs/project/domain.md` and `docs/project/stack.md`: read them if they exist;
otherwise apply the default placeholder content marked as "placeholder por
proyecto". The section MUST still cover the task-tag based dynamic loading
(`[backend]`, `[frontend]`, etc.).

- Traceability: Scenario 7, Edge case (docs/project/* missing).

## REQ-7 — framework-contract.md documenta el contrato del puente

`docs/framework-contract.md` MUST contain a subsection titled "Puente AGENTS.md
↔ docs/" that documents: `AGENTS.md` is framework-injected (intocable), it always
loads `docs/base-standards.md` via `opencode.json` `instructions[]`, it reads
`docs/project/*` dynamically, and it never hardcodes the project's domain/stack
content (which lives in `docs/`).

- Traceability: Scenario 8.
