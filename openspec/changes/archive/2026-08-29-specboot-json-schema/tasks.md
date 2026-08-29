# Tasks: Esquema y validación de `.specboot.json`

## Task 1: Author `docs/specboot-json-standard.md`
**Status**: [x]
**Domain**: Documentation
**Layer**: N/A (documentation deliverable)
**Priority**: High
**Estimate**: M
**Suggested Path**: docs/specboot-json-standard.md
**Test Path**: check-refs.sh / specboot.sh --ci (validation)

**Steps**:
1. Create `docs/specboot-json-standard.md` with: purpose, canonical schema (required + optional, `layers` optional), per-field semantics, examples (mono-repo `["."]`; multi-service node+python; `layers` map), validation behavior (6 cases), link back to `framework-contract.md`.
2. Cover REQ-001 fully (esquema + validación + `layers`).

**Acceptance Criteria**:
- Doc exists and documents full schema + validation (REQ-001).
- `layers` documented as optional project-owned metadata (REQ-001.3).

---

## Task 2: Create `validate-specboot.sh`
**Status**: [x]
**Domain**: Tooling
**Layer**: N/A (script)
**Priority**: High
**Estimate**: M
**Suggested Path**: validate-specboot.sh
**Test Path**: manual runs (repo + temp dir sin .specboot.json)

**Steps**:
1. Create `validate-specboot.sh` (executable, POSIX/bash) reusing `specboot.sh` color/print style.
2. Implement: locate `.specboot.json`; missing → warn + exit 0 (REQ-005.1).
3. Validate JSON via `node` if available (else warn+skip non-block); invalid → error exit 1 (REQ-005.2).
4. Validate required fields `frameworkVersion`, `services`, `stack` (REQ-002).
5. Implement `get_framework_version`: (a) `specboot.sh --version`; (b) `node_modules/@gabrielzavando/specboot/package.json`; (c) repo `./package.json`. Compare SemVer: mayor→error exit1, menor→warn exit0, igual→pass (REQ-003).
6. Validate each `services` path exists; `.` = root (REQ-004).
7. If `layers` present, require object type (REQ-006).
8. Print summary; exit code per cases.

**Acceptance Criteria**:
- Required-field check (REQ-002). Version compare (REQ-003). Services paths (REQ-004). Missing→warn (REQ-005.1). Invalid→err (REQ-005.2). `layers` object (REQ-006).

---

## Task 3: Rewrite `.specboot.example.json` + add `.specboot.example.README.md`
**Status**: [x]
**Domain**: Documentation
**Layer**: N/A
**Priority**: Medium
**Estimate**: S
**Suggested Path**: .specboot.example.json + .specboot.example.README.md
**Test Path**: `node -e JSON.parse` on example

**Steps**:
1. Rewrite `.specboot.example.json` as valid JSON with full schema: `frameworkVersion`, `name`, `description`, `services`, `stack`, `extraStandards`, `layers` (optional).
2. Create `.specboot.example.README.md` commenting each field (JSON has no comments).

**Acceptance Criteria**:
- Example is valid JSON with all fields (REQ-007.1).
- README comments each field (REQ-007.2).

---

## Task 4: Rewrite repo `.specboot.json` to final schema
**Status**: [x]
**Domain**: Configuration
**Layer**: N/A
**Priority**: High
**Estimate**: S
**Suggested Path**: .specboot.json
**Test Path**: validate-specboot.sh on repo

**Steps**:
1. Rewrite `.specboot.json`: `frameworkVersion:"0.1.1"`, `name`, `description`, `services:["."]`, `stack:"framework"` (no `layers` needed for the framework repo itself).

**Acceptance Criteria**:
- Conforms to schema (REQ-008.1).
- `validate-specboot.sh` passes on repo (REQ-008.2).

---

## Task 5: Link from `framework-contract.md` and `docs-standard.md`
**Status**: [x]
**Domain**: Documentation
**Layer**: N/A
**Priority**: Medium
**Estimate**: S
**Suggested Path**: docs/framework-contract.md + docs/docs-standard.md
**Test Path**: check-refs.sh

**Steps**:
1. In `docs/framework-contract.md` add a Markdown link to `docs/specboot-json-standard.md` (dependency/notes area).
2. In `docs/docs-standard.md` add a Markdown link near the `extraStandards`/`services` mention.

**Acceptance Criteria**:
- Both docs link the standard (REQ-009).

---

## Task 6: Evolve `specboot.sh` + `package.json` (dogfooding)
**Status**: [x]
**Domain**: Tooling
**Layer**: N/A
**Priority**: High
**Estimate**: M
**Suggested Path**: specboot.sh + package.json
**Test Path**: specboot.sh --version ; specboot.sh --ci

**Steps**:
1. Add `--version` to `specboot.sh` printing `package.json` version (REQ-010.1).
2. Add `check_specboot_json` to `run_ci` that runs `bash validate-specboot.sh`; tolerant (missing → warning, not error) (REQ-010.2, REQ-010.3).
3. Add `"validate-specboot.sh"` to `package.json` `files` (REQ-011).

**Acceptance Criteria**:
- `--version` works. `--ci` runs validation tolerantly. Script shipped in `files`.

---

## Task 7: Validate (no regression)
**Status**: [x]
**Domain**: QA
**Layer**: N/A
**Priority**: High
**Estimate**: M
**Suggested Path**: repo root
**Test Path**: check-refs.sh, specboot.sh --ci, validate-specboot.sh

**Steps**:
1. Capture `specboot.sh --ci` baseline (pre-change) — if not captured, compare post-change against TICKET-0.2 known-good state.
2. Run `bash check-refs.sh` → 0 errors (REQ-012.1).
3. Run `bash specboot.sh --ci` → no new errors/warnings vs baseline (REQ-012.2).
4. Run `bash validate-specboot.sh` in repo → pass (REQ-008.2).
5. Run `bash validate-specboot.sh` in a temp dir without `.specboot.json` → warning + exit 0 (REQ-005.1).

**Acceptance Criteria**:
- All four checks green.

---

## Task 8: Harden validation (exit-code propagation, layers read, semver normalization)
**Status**: [x]
**Domain**: Tooling
**Layer**: N/A
**Priority**: High
**Estimate**: S
**Suggested Path**: specboot.sh + validate-specboot.sh
**Test Path**: specboot.sh --ci on broken .specboot.json; validate-specboot.sh edge cases

**Steps**:
1. In `specboot.sh` `check_specboot_json`: run `bash validate-specboot.sh; local rc=$?` and increment `ERRORS` when `rc != 0` (REQ-013.1).
2. In `validate-specboot.sh` `layers` check: re-read the file via `node -e` `fs.readFileSync` instead of interpolating `LAYERS_JSON` (REQ-013.2).
3. In `validate-specboot.sh` `semver_cmp`: strip pre-release/build metadata before numeric compare (REQ-013.3).

**Acceptance Criteria**:
- Broken `.specboot.json` makes `specboot.sh --ci` fail (REQ-013.1).
- `layers` with apostrophe in a value does not false-positive (REQ-013.2).
- Pre-release versions compare without arithmetic error (REQ-013.3).

---

## Traceability to Requirements
| Task | Requirements |
|------|--------------|
| T1 | REQ-001 |
| T2 | REQ-002, REQ-003, REQ-004, REQ-005, REQ-006 |
| T3 | REQ-007 |
| T4 | REQ-008 |
| T5 | REQ-009 |
| T6 | REQ-010, REQ-011 |
| T7 | REQ-012 |
| T8 | REQ-013 |
