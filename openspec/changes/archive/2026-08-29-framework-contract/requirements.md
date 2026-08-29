# Requirements: Contrato del Framework Specboot

## REQ-001: Document existence and 7-section structure

### Description

The contract document must exist at `docs/framework-contract.md` and contain exactly the seven sections defined in the enriched ticket, in the specified order.

### Requirements

- **REQ-001.1:** File `docs/framework-contract.md` exists in the Specboot repo root.
- **REQ-001.2:** Section order is: Resumen ejecutivo, Principios rectores, Arquitectura de distribución, Frontera intocable / del proyecto, Flujo SDD obligatorio, Modelo de actualización, Dogfooding.
- **REQ-001.3:** Each section uses a level-2 heading (`##`).

### Acceptance Criteria

- [ ] Opening `docs/framework-contract.md` reveals the 7 sections in the exact order.
- [ ] No extra mandatory sections are introduced.

---

## REQ-002: Untouchable frontier is unambiguous

### Description

The "Frontera intocable / del proyecto" section must list, in an explicit Markdown table, the framework-owned (untouchable) files and the project-owned files, leaving no ambiguity about what a developer must not edit.

### Requirements

- **REQ-002.1:** The table lists the 10 untouchable entries: `AGENTS.md` (puente), `.opencode/commands/*`, `.opencode/agents/*`, `ai-specs/*`, `check-refs.sh`, `specboot.sh`, `Makefile` (genérico), `templates/ci/*`, `.github/workflows/*` (del framework), `docs/base-standards.md`.
- **REQ-002.2:** The table declares that untouchable files are injected/updated by the framework, not edited by the developer.
- **REQ-002.3:** The table uses two explicit columns: "Intocable (del framework)" and "Del proyecto (editado por el dev)".

### Acceptance Criteria

- [ ] A developer reading the table knows with certainty they must not manually edit any listed untouchable file.
- [ ] No untouchable file is left without an explicit owner column.

---

## REQ-003: Project frontier is explicit

### Description

The same table must explicitly list the project-owned surface so the developer knows what is theirs to customize.

### Requirements

- **REQ-003.1:** The table lists the project-owned entries: `docs/` (except `base-standards.md`), `.specboot.json`, project code (`backend/`, `frontend/`), environment variables / GitHub vars, project MCP.
- **REQ-003.2:** The table declares that project-owned files are the developer's responsibility.

### Acceptance Criteria

- [ ] A developer reading the table knows exactly what they own and may edit.
- [ ] `docs/base-standards.md` is correctly excluded from the project-owned `docs/` surface.

---

## REQ-004: Passes automated validation

### Description

The document must pass the framework's own reference and CI validation scripts without errors.

### Requirements

- **REQ-004.1:** No broken `{file:...}` references exist (validated by `check-refs.sh`).
- **REQ-004.2:** `specboot.sh --ci` passes cleanly.

### Acceptance Criteria

- [ ] `check-refs.sh` exits 0 with no broken references.
- [ ] `specboot.sh --ci` exits 0.

---

## REQ-005: Document is definition-only (no implementation)

### Description

The contract must contain only definition and policy. It must not contain executable code, JSON schema, or implementation scripts.

### Requirements

- **REQ-005.1:** No function definitions, no executable bash scripts, no JSON Schema blocks exist in the document.
- **REQ-005.2:** The only code-fence blocks allowed are the frontier table (Markdown) and purely documentary examples.

### Acceptance Criteria

- [ ] Grep for code fences, function definitions, and JSON schema returns only the allowed documentary blocks.
- [ ] No `.specboot.json` schema is defined inline (that is TICKET-0.3).

---

## REQ-006: Executive summary is a single phrase

### Description

A one-phrase definition of Specboot that a developer who has never seen it can understand.

### Requirements

- **REQ-006.1:** The "Resumen ejecutivo" section fits in a single sentence.
- **REQ-006.2:** The phrase defines Specboot as an SDD framework / development environment.

### Acceptance Criteria

- [ ] The executive summary is one sentence and understandable standalone.

---

## REQ-007: Ten governing principles numbered

### Description

The "Principios rectores" section must transcribe the **canonical 10 principles from the foundational session** as a numbered list.

### Requirements

- **REQ-007.1:** The 10 principles are listed and numbered 1–10.
- **REQ-007.2:** The principles are faithful to the canonical foundational-session list (not duplicated from `base-standards.md`; referenced instead).

### Acceptance Criteria

- [ ] The numbered list contains exactly 10 items matching the canonical foundational list.
- [ ] Each item traces to a validated design answer.

---

## REQ-008: Mandatory SDD workflow documented

### Description

The "Flujo SDD obligatorio" section must list the commands in order with a one-line description each, self-contained (not dependent on reading `AGENTS.md`).

### Requirements

- **REQ-008.1:** Order is `/plan-change → /apply → /verify → /archive → /commit`.
- **REQ-008.2:** Each command has a one-line description of what it does.
- **REQ-008.3:** The section is self-contained (does not require reading `AGENTS.md` to understand).

### Acceptance Criteria

- [ ] A developer understands the SDD flow from this section alone.
- [ ] Command order matches the framework's actual flow.

---

## REQ-009: Update model "option A" declared

### Description

The "Modelo de actualización" section must declare that `specboot update` replaces framework files without mercy and never touches developer `docs/` or code.

### Requirements

- **REQ-009.1:** The section explicitly states "opción A: `specboot update` reemplaza los archivos del framework sin piedad".
- **REQ-009.2:** The section states the update never touches developer `docs/` nor project code.

### Acceptance Criteria

- [ ] The update rule is unambiguous and matches the validated "option A" decision.

---

## REQ-010: Dogfooding section self-contained

### Description

The "Dogfooding" section must declare that Specboot evolves using its own SDD flow, in a self-contained way.

### Requirements

- **REQ-010.1:** The section states Specboot is developed with its own SDD cycle.
- **REQ-010.2:** The section does not depend on external examples to be understood.

### Acceptance Criteria

- [ ] A reader understands the dogfooding principle without further context.

---

## REQ-011: Canonical SDD artifact routes declared

### Description

The document SHALL declare `openspec/` (no dot) as the canonical root for SDD artifacts, list the concrete sub-paths, and state that `.openspec/` (with dot) references are outdated.

### Requirements

- **REQ-011.1:** The document declares `openspec/` (without dot) as the canonical artifacts root, consistent with the `openspec` 1.3.1 CLI.
- **REQ-011.2:** The document lists the three concrete paths: `openspec/changes/<change-name>/`, `openspec/tickets/<TICKET-ID>-enriched.md`, `openspec/specs/`.
- **REQ-011.3:** The document states that any documentation or skill referencing `.openspec/` (with dot) is outdated and must be migrated in a later framework ticket.

### Acceptance Criteria

- [ ] A developer reading the doc knows the canonical artifacts root is `openspec/`.
- [ ] The three concrete paths are listed.
- [ ] The deprecation of `.openspec/` is stated.

---

## Technical Constraints

| Constraint | Description |
|------------|-------------|
| Language | Spanish (consistent with `docs/` and `base-standards.md` §2) |
| Format | Single Markdown file, `##` headings, Markdown tables |
| Tooling | Must render in any Markdown viewer (GitHub, IDE, browser) |
| Validation | Must pass `check-refs.sh` and `specboot.sh --ci` |

---

## Dependencies (downstream)

- **TICKET-0.2** (docs/ layout): must respect that `docs/` is project-owned except `base-standards.md`.
- **TICKET-0.3** (.specboot.json schema): must not introduce fields violating the frontier.
- **TICKET-0.4** (SemVer rules): must be compatible with "option A" update model.

---

## Out of Scope

- Concrete `docs/` folder layout (TICKET-0.2).
- `.specboot.json` JSON schema (TICKET-0.3).
- SemVer rules (TICKET-0.4).
- Any code or scripts (Phase 1+).
