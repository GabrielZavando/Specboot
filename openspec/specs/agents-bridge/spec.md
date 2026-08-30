# agents-bridge Specification

## Purpose
TBD - created by archiving change agents-bridge. Update Purpose after archive.
## Requirements
### Requirement: AGENTS.md is a framework-injected bridge with four explicit sections

`AGENTS.md` MUST be a short, framework-injected interface file (not a copy of
project context) and MUST contain four sections in this order:

1. **Carga base (intocable)** — declares that `docs/base-standards.md` is always
   loaded by OpenCode via `opencode.json`'s `instructions[]` and is part of the
   framework's intocable frontier.
2. **Carga dinámica** — instructs the agent to read `docs/project/domain.md`
   and `docs/project/stack.md` **if they exist**, falling back to the default
   placeholder content described in `docs/docs-standard.md` §3. The section
   MUST also preserve the tag-based loading matrix
   (`[backend]`, `[frontend]`, `[api]`, `[docs]`, `[deploy]`) and the
   "no leas por si acaso" directive. `docs/project/*` MUST NOT be referenced via
   OpenCode `{file:...}` (those files are project-owned and may be absent).
3. **Herramientas** — references `check-refs.sh` and `specboot.sh --ci` as the
   validation entry points for the bridge's integrity.
4. **Nota de puente** — states that `AGENTS.md` is only the interface, the
   project's heavy content lives in `docs/`, and `specboot update` replaces
   `AGENTS.md` without losing the project context because that context lives in
   `docs/`.

#### Scenario: Bridge has the four required sections

- **Given** a Specboot project cloned from the framework
- **When** a developer or agent opens `AGENTS.md`
- **Then** it contains the four sections in the order "Carga base (intocable)",
  "Carga dinámica", "Herramientas", "Nota de puente"

#### Scenario: Base-standards always-loaded rule is declared

- **Given** the "Carga base (intocable)" section
- **When** an agent processes it
- **Then** it states that `docs/base-standards.md` is always loaded via
  `opencode.json` `instructions[]`
- **And** it states that this file is part of the framework's intocable
  frontier

#### Scenario: docs/project/* conditional loading with placeholder fallback

- **Given** the "Carga dinámica" section
- **When** the agent evaluates the context to load
- **Then** it instructs reading `docs/project/domain.md` and
  `docs/project/stack.md` if they exist
- **And** it instructs falling back to a default placeholder content (marked
  as "placeholder por proyecto") otherwise
- **And** the tag-based loading matrix (`[backend]`, `[frontend]`, `[api]`,
  `[docs]`, `[deploy]`) is preserved
- **And** the "no leas por si acaso" directive is preserved

#### Scenario: Tools section references the validation scripts

- **Given** the "Herramientas" section
- **When** a reviewer or agent looks for the bridge's validation entry points
- **Then** `check-refs.sh` and `specboot.sh --ci` are referenced

#### Scenario: Bridge note explains the update contract

- **Given** the "Nota de puente" section
- **When** a developer or agent reads it
- **Then** it explains that `AGENTS.md` is only the interface
- **And** it explains that the heavy content lives in `docs/`
- **And** it explains that `specboot update` replaces `AGENTS.md` without
  losing the project context because that context lives in `docs/`

### Requirement: docs-standard.md §3 MUST keep its title and declare the conditional placeholder rule

`docs/docs-standard.md` section 3 MUST keep its current title (it MUST NOT
be renamed) and MUST declare the explicit conditional rule for
`docs/project/*`:

- `docs/base-standards.md` is always loaded via `instructions[]`.
- If `docs/project/domain.md` and `docs/project/stack.md` exist → the agent
  reads them.
- If they are missing → the agent applies the default placeholder content
  marked as placeholder por proyecto.

The section MUST also still cover the tag-based dynamic loading
(`[backend]`, `[frontend]`, etc.).

#### Scenario: Conditional placeholder rule is present in §3

- **Given** `docs/docs-standard.md` with its §3
- **When** the change lands
- **Then** §3 still covers the tag-based dynamic loading
- **And** §3 declares the conditional rule for `docs/project/domain.md` and
  `docs/project/stack.md`
- **And** §3 declares the placeholder fallback ("placeholder por proyecto")
  when those files are absent
- **And** §3 keeps its current title (not renamed)

### Requirement: framework-contract.md has a "Puente AGENTS.md ↔ docs/" subsection

`docs/framework-contract.md` MUST contain a subsection titled
"Puente AGENTS.md ↔ docs/" that documents the bridge contract: `AGENTS.md` is
framework-injected (intocable), it always loads `docs/base-standards.md` via
`opencode.json` `instructions[]`, it reads `docs/project/*` dynamically, and it
never hardcodes the project's domain or stack (those live in `docs/`). The
subsection MUST link to `docs/docs-standard.md` §3 for the detailed
conditional rule.

#### Scenario: Contract documents the bridge

- **Given** `docs/framework-contract.md` defines the intocable/project frontier
- **When** the change lands
- **Then** the file contains a subsection titled "Puente AGENTS.md ↔ docs/"
- **And** the subsection states that `AGENTS.md` is framework-injected
  (intocable)
- **And** the subsection states that `AGENTS.md` always loads
  `docs/base-standards.md` via `opencode.json` `instructions[]`
- **And** the subsection states that `AGENTS.md` reads `docs/project/*`
  dynamically
- **And** the subsection states that domain/stack content lives in `docs/`,
  not in the bridge
- **And** the subsection links to `docs/docs-standard.md` §3 for the detailed
  conditional rule

### Requirement: check-refs.sh and specboot.sh --ci remain at 0 errors

After the change, running `bash check-refs.sh` from the project root MUST
report 0 errors and `bash specboot.sh --ci` MUST also report 0 errors. The
change MUST NOT alter the list of files returned by `check-refs.sh` Step 3
(every skill name in `ai-specs/skills/*/` MUST still appear in `AGENTS.md`),
and MUST NOT alter `specboot.sh`'s `REQUIRED_FILES` or `PLACEHOLDER_PATTERNS`
arrays.

#### Scenario: check-refs.sh reports 0 errors

- **Given** the rewritten `AGENTS.md`
- **When** `bash check-refs.sh` is executed from the project root
- **Then** it reports 0 errors
- **And** all skill names in `ai-specs/skills/*/` still appear in `AGENTS.md`

#### Scenario: specboot.sh --ci reports 0 errors

- **Given** the updated `AGENTS.md`, `docs/docs-standard.md` and
  `docs/framework-contract.md`
- **When** `bash specboot.sh --ci` is executed from the project root
- **Then** it reports 0 errors
- **And** no `PLACEHOLDER_PATTERNS` are detected in `docs/`
- **And** the `REQUIRED_FILES` list is not modified by this change

### Requirement: specboot update replaces AGENTS.md without losing project context

When `specboot update` runs, the framework MUST replace `AGENTS.md` entirely
with the new bridge version, and the project's context (domain, stack, etc.)
MUST NOT be lost because the bridge does not hardcode it.

#### Scenario: specboot update preserves project context via docs/

- **Given** a project installed with `@gabrielzavando/specboot` and a
  project-customized `docs/project/`
- **When** `specboot update` runs
- **Then** `AGENTS.md` is replaced with the bridge version from the package
- **And** `docs/project/domain.md`, `docs/project/stack.md` and
  `docs/project/client.md` are not touched by `specboot update`
- **And** the project context previously captured in `docs/project/*` is still
  available to the agent after the update

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

