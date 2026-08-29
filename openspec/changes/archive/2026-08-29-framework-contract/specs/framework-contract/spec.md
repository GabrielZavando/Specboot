# Capability: framework-contract

Consolidate and freeze the Specboot model into a single authoritative contract document (`docs/framework-contract.md`) that defines what the framework is, what it provides, what is untouchable, and what is the project's responsibility.

## ADDED Requirements

### Requirement: Document existence and 7-section structure

The contract document SHALL exist at `docs/framework-contract.md` and SHALL contain exactly the seven sections — Resumen ejecutivo, Principios rectores, Arquitectura de distribución, Frontera intocable / del proyecto, Flujo SDD obligatorio, Modelo de actualización, Dogfooding — each as a level-2 heading in that order.

#### Scenario: Document is created with the seven required sections

- **Given** the Specboot repository in a clean state
- **When** a developer opens `docs/framework-contract.md`
- **Then** the file exists and contains the 7 sections numbered in the specified order
- **And** each section uses a level-2 heading

### Requirement: Untouchable frontier is unambiguous

The "Frontera intocable / del proyecto" section SHALL list, in an explicit two-column Markdown table, the framework-owned (untouchable) files and the project-owned files, declaring that untouchable files are injected/updated by the framework and must not be hand-edited.

The intouchable column SHALL include: `AGENTS.md` (puente), `.opencode/commands/*`, `.opencode/agents/*`, `ai-specs/*`, `check-refs.sh`, `specboot.sh`, `Makefile` (genérico), `templates/ci/*`, `.github/workflows/*` (del framework), `docs/base-standards.md`.

#### Scenario: Developer recognizes untouchable files

- **Given** a developer reads the "Frontera intocable / del proyecto" section
- **When** they review any file listed in the "Intocable" column
- **Then** they know with certainty they must not manually edit it because it is injected/updated by the framework

### Requirement: Project frontier is explicit

The same table SHALL explicitly list the project-owned surface: `docs/` (except `base-standards.md`), `.specboot.json`, project code (`backend/`, `frontend/`), environment variables / GitHub vars, and project MCP, declaring these are the developer's responsibility.

#### Scenario: Developer recognizes project-owned files

- **Given** a developer reads the same section
- **When** they review any file listed in the "Del proyecto" column
- **Then** they know it is their own responsibility and may be edited

### Requirement: Passes automated validation

The document SHALL pass the framework's own reference and CI validation scripts without errors: no broken `{file:...}` references (`check-refs.sh`) and a clean `specboot.sh --ci` run.

#### Scenario: Document passes framework validation

- **Given** `docs/framework-contract.md` freshly written
- **When** `check-refs.sh` and `specboot.sh --ci` are executed
- **Then** no broken `{file:...}` references exist and the CI validation exits 0

### Requirement: Document is definition-only

The contract SHALL contain only definition and policy. It SHALL NOT contain executable code, JSON schema, or implementation scripts. The only code-fence blocks allowed are the frontier table (Markdown) and purely documentary examples.

#### Scenario: Document contains no implementation

- **Given** the complete document
- **When** a search is made for code fences, function definitions, JSON Schema, and bash scripts
- **Then** only the allowed documentary blocks are found; no functions, no JSON Schema, no executable scripts

### Requirement: Executive summary is a single phrase

The "Resumen ejecutivo" section SHALL define Specboot in a single sentence that a developer who has never seen it can understand.

#### Scenario: Executive summary is one sentence

- **Given** the "Resumen ejecutivo" section
- **When** a reviewer reads it
- **Then** it is a single sentence defining Specboot as an SDD framework / development environment

### Requirement: Ten governing principles numbered

The "Principios rectores" section SHALL transcribe the canonical 10 principles from the foundational session as a numbered list (1–10), faithful to that source and not duplicating `base-standards.md` (referenced instead).

#### Scenario: Ten principles are numbered and faithful

- **Given** the "Principios rectores" section
- **When** a reviewer counts the items
- **Then** exactly 10 numbered items appear, each traceable to a validated design answer

### Requirement: Mandatory SDD workflow documented

The "Flujo SDD obligatorio" section SHALL list the commands `/plan-change → /apply → /verify → /archive → /commit` in order, each with a one-line description, and SHALL be self-contained (not dependent on reading `AGENTS.md`).

#### Scenario: SDD flow is self-contained and correctly ordered

- **Given** the "Flujo SDD obligatorio" section
- **When** a developer reads it
- **Then** they understand the flow from this section alone
- **And** the command order matches the framework's actual flow

### Requirement: Update model "option A" declared

The "Modelo de actualización" section SHALL declare that `specboot update` replaces framework files without mercy (opción A) and never touches developer `docs/` or project code.

#### Scenario: Update rule is unambiguous

- **Given** the "Modelo de actualización" section
- **When** a reviewer reads it
- **Then** it explicitly states "opción A: `specboot update` reemplaza los archivos del framework sin piedad"
- **And** it states the update never touches developer `docs/` nor project code

### Requirement: Dogfooding section self-contained

The "Dogfooding" section SHALL declare that Specboot evolves using its own SDD flow, in a self-contained way.

#### Scenario: Dogfooding principle is clear standalone

- **Given** the "Dogfooding" section
- **When** a reader reviews it
- **Then** they understand the principle without needing external examples

### Requirement: Canonical SDD artifact routes declared

The document SHALL declare `openspec/` (no dot) as the canonical root for SDD artifacts, list the concrete sub-paths, and state that `.openspec/` (with dot) references are outdated.

#### Scenario: Developer knows the canonical artifacts root

- **Given** the "Arquitectura de distribución" section and its "Rutas canónicas de artefactos SDD" subsection
- **When** a developer reads where SDD artifacts live
- **Then** they learn the canonical root is `openspec/` (no dot), consistent with the `openspec` 1.3.1 CLI
- **And** the three paths `openspec/changes/<change-name>/`, `openspec/tickets/<TICKET-ID>-enriched.md`, and `openspec/specs/` are listed
- **And** the deprecation of `.openspec/` (with dot) is stated
