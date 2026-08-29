# Tasks: Contrato del Framework Specboot

## Task 1: Author the 7-section framework-contract.md document

**Status**: [x]
**Domain**: Documentation
**Layer**: N/A (documentation deliverable, not code layer)
**Priority**: High
**Estimate**: M
**Suggested Path**: docs/framework-contract.md
**Test Path**: check-refs.sh / specboot.sh --ci (validation, not unit test)

**Steps**:
1. Create `docs/framework-contract.md` in the Specboot repo root.
2. Write the "Resumen ejecutivo" section as a single defining sentence (REQ-006).
3. Write the "Principios rectores" section as a numbered list of the 10 validated design answers (REQ-007).
4. Write the "Arquitectura de distribución" section declaring npm `@gabrielzavando/specboot` as the only distribution and `devDependency` install model (no implementation detail).
5. Write the "Flujo SDD obligatorio" section listing `/plan-change → /apply → /verify → /archive → /commit` with a one-line description each, self-contained (REQ-008).
6. Write the "Modelo de actualización" section declaring "opción A: `specboot update` reemplaza sin piedad; nunca toca `docs/` del dev ni código" (REQ-009).
7. Write the "Dogfooding" section declaring Specboot evolves via its own SDD flow, self-contained (REQ-010).

**Acceptance Criteria**:
- The file exists with all 7 sections in the required order (REQ-001).
- Executive summary is one sentence (REQ-006).
- 10 principles are numbered and faithful (REQ-007).
- SDD flow is self-contained and correctly ordered (REQ-008).
- Update model declares option A (REQ-009).
- Dogfooding is self-contained (REQ-010).
- No implementation code, JSON schema, or scripts are present (REQ-005).

---

## Task 2: Build the untouchable / project frontier table

**Status**: [x]
**Domain**: Documentation
**Layer**: N/A (documentation deliverable, not code layer)
**Priority**: High
**Estimate**: S
**Suggested Path**: docs/framework-contract.md (Frontera intocable / del proyecto)
**Test Path**: check-refs.sh / specboot.sh --ci (validation)

**Steps**:
1. Add a Markdown table with two explicit columns: "Intocable (del framework)" and "Del proyecto (editado por el dev)".
2. Populate the intocable column with the 10 entries from REQ-002.1.
3. Populate the project column with the entries from REQ-003.1.
4. Add a one-line note under the table clarifying that intouchable files are injected/updated by the framework and must not be hand-edited.

**Acceptance Criteria**:
- The table lists all 10 untouchable entries (REQ-002).
- The table lists all project-owned entries, with `docs/base-standards.md` excluded from project `docs/` (REQ-003).
- A developer can unambiguously tell what they may and may not edit (REQ-002, REQ-003).

---

## Task 3: Validate the document with framework scripts

**Status**: [x]
**Domain**: Documentation
**Layer**: N/A (documentation deliverable, not code layer)
**Priority**: High
**Estimate**: S
**Suggested Path**: docs/framework-contract.md
**Test Path**: check-refs.sh / specboot.sh --ci

**Steps**:
1. Run `bash check-refs.sh` and confirm exit code 0 with no broken `{file:...}` references (REQ-004.1).
2. Run `bash specboot.sh --ci` and confirm exit code 0 (REQ-004.2).
3. Fix any broken references or CI failures before reporting done.

**Acceptance Criteria**:
- `check-refs.sh` exits 0 (REQ-004.1).
- `specboot.sh --ci` exits 0 (REQ-004.2).

---

## Task 4: Reference the contract from AGENTS.md (coherence)

**Status**: [deferred]
**Domain**: Documentation
**Layer**: N/A (documentation deliverable, not code layer)
**Priority**: Low
**Estimate**: S
**Suggested Path**: AGENTS.md (frontier note) + docs/framework-contract.md
**Test Path**: check-refs.sh / specboot.sh --ci

**Deferred with rationale**: `AGENTS.md` is declared **intocable** by the very contract this change delivers (sección *Frontera intocable / del proyecto*). Editing it inside this same change would contradict the principle being established. The DoD marks this step as *opcional pero recomendado*. Recommended execution: a **separate framework-evolution change** under dogfooding (e.g. `framework-contract-agencies-link`) that modifies `AGENTS.md` as framework code, keeping the frontier coherent.

**Steps** (for the future change):
1. Add a short line in `AGENTS.md` pointing to `docs/framework-contract.md` as the authoritative framework contract.
2. Re-run `check-refs.sh` to ensure the new reference is not broken.

**Acceptance Criteria**:
- `AGENTS.md` references the contract document.
- Reference validation still passes.

---

## Traceability to Diseño de Secciones (from enriched artifact)

| Section | Mapped Task(s) | Requirements |
|---------|----------------|--------------|
| Resumen ejecutivo | Task 1 | REQ-006 |
| Principios rectores | Task 1 | REQ-007 |
| Arquitectura de distribución | Task 1 | REQ-001 (structure) |
| Frontera intocable / del proyecto | Task 2 | REQ-002, REQ-003 |
| Flujo SDD obligatorio | Task 1 | REQ-008 |
| Modelo de actualización | Task 1 | REQ-009 |
| Dogfooding | Task 1 | REQ-010 |
| Validation (cross-cutting) | Task 3, Task 4 | REQ-004, REQ-005 |
