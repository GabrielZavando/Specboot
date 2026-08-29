# Proposal: Estándar de estructura docs/ + correcciones de framework diferidas

## Change created from ticket

**Ticket ID**: TICKET-0.2
**Original title**: Estándar de estructura docs/ + correcciones de framework diferidas
**Tag (source)**: [docs] (explicit)
**Derived change name**: docs-standard
**Change folder**: openspec/changes/docs-standard/
**Enriched artifact used**: no

### Naming rationale
- Verb: define/establish (estándar de estructura) + fix (correcciones de framework diferidas)
- Noun/entity: docs/ structure standard
- Domain prefix: none (single domain: the framework itself)

### Context loaded
- `docs/base-standards.md` (always via instructions[])
- `docs/documentation-standards.md` (tag [docs])
- `docs/framework-contract.md` (referenced by the ticket; defines the intocable/project frontier and the canonical `openspec/` artifacts path from TICKET-0.1)

## Why

TICKET-0.1 froze the framework contract and declared `openspec/` (sin punto) as the canonical artifacts root, but explicitly deferred two framework corrections for a later ticket: (1) the `.openspec/` → `openspec/` path migration in skills/commands, and (2) the 5 placeholder warnings in `docs/base-standards.md`. In parallel, every new Specboot project needs a predictable `docs/` skeleton so the bridge `AGENTS.md` can load context consistently. Without a documented standard tree, projects scatter docs inconsistently and the "dynamic load" rule cannot be implemented. This change establishes that standard and closes the two deferred framework warnings in one shot.

## What Changes

- **Adds** `docs/docs-standard.md` — the canonical `docs/` tree, an intocable/del-proyecto table for doc files, and the dynamic-load rule for the bridge `AGENTS.md` (always `base-standards.md` + `docs/project/*` read per task tag).
- **Adds** `docs/project/` templates (`domain.md`, `stack.md`, `client.md`) and **moves** the loose `docs/api-spec.yml` → `docs/api/api-spec.yml` and `docs/data-model.md` → `docs/data-model/data-model.md`, reorganizing the repo's own `docs/` to the standard tree.
- **Links** `docs/docs-standard.md` from `docs/framework-contract.md`.
- **Fixes** every `.openspec/` reference in `.opencode/` and `ai-specs/` (skills, commands, agents, examples) → `openspec/`, plus repo-wide consistency fixes in `AGENTS.md`, `.gitignore`, `README.md`, `CHANGELOG.md` (and rewords the deprecated-path prose in `docs/framework-contract.md`) so SDD commands keep using `openspec/changes/` and `openspec/tickets/` with no regressions.
- **Removes** the 5 placeholder patterns from `docs/base-standards.md` (section 8) that `specboot.sh --ci` flags, preserving the SDD/TDD/SOLID principles.

## Capabilities

### New Capabilities
- `docs-standard`: defines the canonical `docs/` tree, the untouchable/project boundary for documentation files, and the dynamic-load rule for the bridge `AGENTS.md`.

### Modified Capabilities
<!-- none -->

## Impact

- Documentation: `docs/docs-standard.md` (new), `docs/framework-contract.md` (link added), `docs/base-standards.md` (placeholders removed), `docs/` tree reorganized.
- Framework files (intocable, dogfooding): `.opencode/commands/*`, `.opencode/agents/*`, `ai-specs/skills/*`, `ai-specs/agents/*`, `ai-specs/examples/*`, `AGENTS.md`, `.gitignore`, `README.md`, `CHANGELOG.md`.
- Validation gates: `specboot.sh --ci` (placeholder warnings), `check-refs.sh` (referential integrity), `openspec validate docs-standard`.
- No runtime code, no API, no data-model change.
