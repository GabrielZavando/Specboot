# agents-bridge Delta — Validación de escenarios (TICKET-2.2a)

Este delta **añade** requisitos a la capability `agents-bridge` (no modifica
ni elimina requisitos existentes). Los requisitos nuevos codifican el
comportamiento del puente `AGENTS.md ↔ docs/` que los 3 escenarios Gherkin
del ticket TICKET-2.2a §3.1 y los 4 edge cases (A–D) documentan como
esperado.

> Los escenarios Gherkin completos viven en
> `openspec/changes/validate-agents-bridge/scenarios.md` y la sección de
> resultados en `docs/docs-standard.md` (sección "Validación del puente
> AGENTS.md", a continuación de §3.1). Este delta es la **codificación
> normativa** de ese comportamiento en la spec.

## ADDED Requirements

### Requirement: docs/base-standards.md is unconditionally loaded

`AGENTS.md` MUST guarantee that `docs/base-standards.md` is loaded on every
task, regardless of the task's tag, the state of the rest of `docs/`, or
the presence or absence of project-owned files.

#### Scenario: base-standards.md is in the intocable frontier
- **WHEN** an agent processes the "Carga base (intocable)" section of `AGENTS.md`
- **THEN** it states that `docs/base-standards.md` is always loaded via `opencode.json` `instructions[]`
- **AND** it states that this file is part of the framework's intocable frontier

#### Scenario: Missing base-standards.md surfaces a reference error
- **WHEN** `docs/base-standards.md` is absent from the project
- **THEN** `bash check-refs.sh` exits non-zero with a reference-resolution error
- **AND** the corrective action is to run `specboot update`, not to edit the file by hand

### Requirement: Tag-based standards loading is selective

`AGENTS.md` MUST load only the standards files corresponding to the active
task's tag (`[backend]`, `[frontend]`, `[api]`, `[docs]`, `[deploy]`,
`[fullstack]`), without preloading additional files "just in case".

#### Scenario: docs tag loads only documentation-standards.md
- **WHEN** a task carries the `[docs]` tag
- **THEN** the agent loads `docs/documentation-standards.md`
- **AND** it does not load `docs/backend-standards.md` or `docs/frontend-standards.md`

#### Scenario: Unknown tag triggers inference and explicit confirmation
- **WHEN** a task carries a tag not listed in the matrix (or no tag at all)
- **THEN** the agent infers the most likely tag from the ticket title
- **AND** asks the user to confirm before loading any standards file

### Requirement: docs/project/* is loaded as conditional prose, not as {file:} include

`docs/project/{domain,stack,client}.md` MUST be resolved as **conditional
prose** documented in `AGENTS.md`, not as OpenCode `{file:...}` references
or `instructions[]` entries. This is required because `check-refs.sh`
fails if the referenced files do not exist.

#### Scenario: Conditional loading rule is declared in the bridge
- **WHEN** a reviewer reads `AGENTS.md` §2.2 ("Project context (docs/project/*) — conditional load")
- **THEN** the section states that project files are read as soon as the task needs them, if they exist
- **AND** it states that placeholder content is applied if they are missing
- **AND** `opencode.json` does NOT list `docs/project/*` in `instructions[]`

### Requirement: Missing project files fall back to documented placeholders

When a file in `docs/project/*` does not exist, the agent MUST apply the
default placeholder content marked as "placeholder por proyecto" (HTML
`<!-- … -->` comments) and document that the file is pending creation.

#### Scenario: Missing domain.md uses placeholder
- **WHEN** `docs/project/domain.md` does not exist
- **THEN** the agent applies the placeholder content described in `docs/docs-standard.md` §3.1
- **AND** the placeholder uses HTML `<!-- … -->` comments so the dev can identify and replace it
- **AND** the absence does NOT abort the SDD flow

### Requirement: Bridge does not break the SDD flow on incomplete docs/

The bridge SHALL keep the SDD flow unbroken when the structure of `docs/`
is incomplete, provided the framework's intocable files are present. The
SDD flow (`/plan-change` → `/apply` → `/verify` → `/archive` → `/commit`)
MUST NOT break for a missing `docs/project/*` file, and the bridge MUST
allow tag-based loading to proceed with the standards that exist and MUST
delegate missing-project-files to the placeholder fallback.

#### Scenario: docs/ without project/, api/, data-model/ subfolders
- **WHEN** the project has `docs/base-standards.md` but no `docs/project/`, `docs/api/`, or `docs/data-model/`
- **THEN** the bridge loads `base-standards.md` and the tag-selected standards
- **AND** the agent emits a warning that the project is in bootstrap phase (visible from `docs/docs-standard.md` §4)
- **AND** the SDD flow continues without aborting

#### Scenario: check-refs.sh and specboot.sh --ci stay at 0 errors
- **WHEN** `bash check-refs.sh` and `bash specboot.sh --ci` are executed after the change
- **THEN** both report 0 errors
- **AND** placeholders pending in `docs/project/*` are reported as informational warnings, not fatal errors
- **AND** the intocable files (`AGENTS.md`, `docs/base-standards.md`, `docs/framework-contract.md`, `docs/versioning-standard.md`, `specboot.sh`, `validate-specboot.sh`) are not modified by this change

### Requirement: Validation section in docs-standard.md is preserved as evidence

`docs/docs-standard.md` MUST contain a "Validación del puente AGENTS.md"
section, placed immediately after §3.1, that documents the 3 Gherkin
scenarios from TICKET-2.2a §3.1 and the 4 edge cases (A: unknown tag;
B: missing `base-standards.md`; C: missing `AGENTS.md`; D: missing
`opencode.json`).

#### Scenario: Validation section exists and covers the required scenarios
- **WHEN** a reviewer inspects `docs/docs-standard.md`
- **THEN** a "Validación del puente AGENTS.md" section is present after §3.1
- **AND** it documents the 3 Gherkin scenarios (complete project, partial project, docs/ without subfolders)
- **AND** it documents the 4 edge cases (A–D)
- **AND** it includes a results matrix that distinguishes "OK with fallback" from "intentional break (requires specboot update)"

#### Scenario: The §3.1 contract is not renamed or replaced
- **WHEN** the validation section is inserted
- **THEN** §3.1 keeps its current title (no rename)
- **AND** the conditional placeholder rule in §3.1 is preserved verbatim
- **AND** the new section is an addition, not a replacement of the contract
