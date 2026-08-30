# Tasks: Estándar SemVer + matriz de ruptura de compatibilidad

## Task 1: Author `docs/versioning-standard.md` (SemVer + matriz de ruptura)

**Status**: [x]
**Domain**: Documentation
**Layer**: N/A (documentation deliverable, not code layer)
**Priority**: High
**Estimate**: M
**Suggested Path**: docs/versioning-standard.md
**Test Path**: check-refs.sh / specboot.sh --ci (validation, not unit test)

**Steps**:
1. Create `docs/versioning-standard.md` as a framework doc (intocable).
2. Write "Propósito" — por qué existe el estándar (opción A de `specboot update` exige semántica de major).
3. Write "Reglas SemVer" — `MAJOR.MINOR.PATCH`; vive en `package.json` y se refleja en `frameworkVersion`; salvedad `0.x`; al `1.0.0` SemVer estricto (REQ-001).
4. Write "Matriz de ruptura (canónica)" — tabla con columnas (Tipo de cambio | Nivel | ¿El proyecto debe actuar?) cubriendo todas las filas del ticket §3.2, incluyendo las de 0.1–0.3 (rutas `.openspec/`→`openspec/` = patch; placeholder `base-standards.md` = patch; `layers` opcional = minor; reestructuración `docs/` = major) (REQ-002).
5. Write "Significado por nivel para el consumidor" — patch/minor/major (REQ-003).
6. Write "Comportamiento de `specboot update` ante versiones" — major → ⚠️ + reemplaza; minor/patch → silente; nunca toca `docs/`/código (REQ-004).
7. Write "Formato de CHANGELOG / Release notes" — Keep a Changelog + SemVer; sección `### Breaking changes` + migración; cómo se declara la ruptura (REQ-005).
8. Add a relative markdown link back to `framework-contract.md` at the end of the doc.

**Acceptance Criteria**:
- File exists with all required sections (REQ-001, REQ-002, REQ-003, REQ-004, REQ-005).
- Matrix classifies tickets 0.1–0.3 correctly (REQ-002).
- `specboot update` behavior is defined for major/minor/patch (REQ-004).
- Links back to `framework-contract.md` (REQ-006).

---

## Task 2: Update `CHANGELOG.md` to standard format + breaking-changes template

**Status**: [x]
**Domain**: Documentation
**Layer**: N/A
**Priority**: High
**Estimate**: S
**Suggested Path**: CHANGELOG.md
**Test Path**: check-refs.sh / specboot.sh --ci

**Steps**:
1. Move the current `[Unreleased]` content into a new `## [0.1.1] - 2026-08-29` entry.
2. Add `### Breaking changes` subsection to the `0.1.1` entry with `None` as the canonical template example.
3. Leave a fresh empty `## [Unreleased]` section at the top.
4. Keep the Keep a Changelog + SemVer header intact.

**Acceptance Criteria**:
- `0.1.1` entry exists and exemplifies the format (REQ-005).
- `### Breaking changes` template present (REQ-005).
- `## [Unreleased]` empty section retained (REQ-005).

---

## Task 3: Link and mark `versioning-standard.md` intocable in the frontier

**Status**: [x]
**Domain**: Documentation
**Layer**: N/A
**Priority**: Medium
**Estimate**: S
**Suggested Path**: docs/framework-contract.md (Frontera intocable / del proyecto) + docs/docs-standard.md (nota de alcance)
**Test Path**: check-refs.sh / specboot.sh --ci

**Steps**:
1. In `framework-contract.md`, add `docs/versioning-standard.md` to the Intocable column of the frontier table.
2. In `framework-contract.md`, add a relative markdown link `[...](versioning-standard.md)` to the new doc in the relevant section.
3. In `docs/docs-standard.md`, note `versioning-standard.md` as a framework doc (intocable) in its scope note.

**Acceptance Criteria**:
- `versioning-standard.md` appears in the Intocable column (REQ-007).
- `framework-contract.md` links to the new doc (REQ-006).
- `docs-standard.md` notes it as framework doc (REQ-007).

---

## Task 4: Validate references and CI

**Status**: [x]
**Domain**: Documentation
**Layer**: N/A
**Priority**: High
**Estimate**: S
**Suggested Path**: check-refs.sh / specboot.sh --ci
**Test Path**: check-refs.sh / specboot.sh --ci

**Steps**:
1. Run `bash check-refs.sh` and confirm 0 errors (link uses relative markdown, not `{file:...}`) (REQ-008).
2. Run `bash specboot.sh --ci` and confirm no new errors/warnings vs baseline 0.3 (REQ-008).
3. Fix any broken references or CI issues before reporting done.

**Acceptance Criteria**:
- `check-refs.sh` exits 0 (REQ-008).
- `specboot.sh --ci` exits 0 with no new errors/warnings (REQ-008).

---

## Traceability

| Requirement | Mapped Task(s) |
|-------------|----------------|
| REQ-001 | Task 1 |
| REQ-002 | Task 1 |
| REQ-003 | Task 1 |
| REQ-004 | Task 1 |
| REQ-005 | Task 1, Task 2 |
| REQ-006 | Task 1, Task 3 |
| REQ-007 | Task 3 |
| REQ-008 | Task 4 |
