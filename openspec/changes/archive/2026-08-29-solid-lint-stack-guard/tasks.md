# Tasks: `make solid-lint` — stack guard + eslint@8 pin

## Task 1: Add stack guard to `make solid-lint`
**Status**: [ ]
**Domain**: Tooling (CI)
**Layer**: N/A
**Priority**: High
**Estimate**: M
**Suggested Path**: Makefile (target `solid-lint`)
**Test Path**: `make solid-lint` on the framework repo (skip) + temp node project

**Steps**:
1. In `solid-lint`, read `APP_STACKS` from `.specboot.json` `stack` (string→[string] normalization) via the existing `node -e` pattern.
2. If `.specboot.json` is present and `stack` includes neither `node` nor `python`, print a skip message and `exit 0`.
3. Gate the Node lint family (eslintrc.backend/frontend/astro, dependency-cruiser, madge) behind `node` ∈ `APP_STACKS`; gate the Python family behind `python` ∈ `APP_STACKS`.
4. If `.specboot.json` is absent, preserve the legacy behavior (node from `package.json`, python from `pyproject.toml`/`requirements.txt`).

**Acceptance Criteria**:
- `stack: "framework"` → skip + exit 0 (REQ-001.4).
- Node family only when `node` ∈ stack (REQ-001.2). Python family only when `python` ∈ stack (REQ-001.3).
- No `.specboot.json` → legacy behavior (REQ-001, backward compat).

---

## Task 2: Pin ESLint to v8 in `make solid-lint`
**Status**: [ ]
**Domain**: Tooling (CI)
**Layer**: N/A
**Priority**: High
**Estimate**: S
**Suggested Path**: Makefile (target `solid-lint`)
**Test Path**: `grep` for `eslint@8`; framework `make solid-lint` does not invoke ESLint 10

**Steps**:
1. Replace `npx eslint -c` with `npx eslint@8 -c` in the backend, frontend, and astro ESLint invocations.

**Acceptance Criteria**:
- All three ESLint invocations use `eslint@8` (REQ-002.1).
- No flat-config "root key" error (REQ-002.2).

---

## Task 3: Document the stack guard in `templates/ci/README.md`
**Status**: [ ]
**Domain**: Documentation
**Layer**: N/A
**Priority**: Medium
**Estimate**: S
**Suggested Path**: templates/ci/README.md
**Test Path**: check-refs.sh

**Steps**:
1. Add a note that `make solid-lint` skips app linters when `.specboot.json` `stack` does not include `node`/`python` (e.g. `framework`).

**Acceptance Criteria**:
- README reflects the new behavior (REQ-003).

---

## Task 4: Validate (no regression)
**Status**: [ ]
**Domain**: QA
**Layer**: N/A
**Priority**: High
**Estimate**: M
**Suggested Path**: repo root
**Test Path**: `make solid-lint`, check-refs.sh, specboot.sh --ci

**Steps**:
1. Run `make solid-lint` on the framework repo → expect skip message + exit 0.
2. Run `bash check-refs.sh` → 0 errors (REQ-004.1).
3. Run `bash specboot.sh --ci` → no new errors/warnings vs TICKET-0.3 baseline (REQ-004.2).
4. (Optional) Simulate a node project in a temp dir with `.specboot.json` `stack: ["node"]` and a `.ts` file to confirm `eslint@8` is invoked (requires network + a minimal eslint setup; informational).

**Acceptance Criteria**:
- Framework `make solid-lint` passes (skip).
- `check-refs.sh` and `specboot.sh --ci` green.

---

## Traceability to Requirements
| Task | Requirements |
|------|--------------|
| T1 | REQ-001 |
| T2 | REQ-002 |
| T3 | REQ-003 |
| T4 | REQ-004 |
