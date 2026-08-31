# Tasks: Fix npm publish — bump to 0.1.2 and normalize bin path

## Task 1: Bump package.json a 0.1.2 y normalizar bin
**Status**: pending
**Domain**: Packaging / Release
**Layer**: N/A (framework infrastructure)
**Priority**: High
**Estimate**: XS
**Suggested Path**: package.json
**Test Path**: `grep '"version": "0.1.2"' package.json`; `grep '"specboot": "specboot.sh"' package.json`; `npm publish --dry-run 2>&1 | grep -c "bin\["` (0)

**Steps**:
1. Editar `package.json`:
   - `"version": "0.1.1"` → `"version": "0.1.2"`
   - `"bin": { "specboot": "./specboot.sh" }` → `"bin": { "specboot": "specboot.sh" }`
2. Verificar que `npm pkg fix` no propone cambios adicionales.

**Acceptance Criteria**:
- Versión `0.1.2` declarada (REQ-001).
- Bin sin prefijo `./` (REQ-003).
- `npm publish --dry-run` sin warning de bin (REQ-003, REQ-005).

---

## Task 2: Añadir entrada 0.1.2 a CHANGELOG.md
**Status**: pending
**Domain**: Documentation
**Layer**: N/A
**Priority**: High
**Estimate**: XS
**Suggested Path**: CHANGELOG.md
**Test Path**: `grep -n "## \[0.1.2\]" CHANGELOG.md`

**Steps**:
1. Añadir bajo `## [Unreleased]` la entrada `## [0.1.2] - 2026-08-31` con sección
   `### Fixed` documentando: desbloqueo del publish (bump de 0.1.1 ya publicada a
   0.1.2) y normalización del path de `bin` (silencia el warning de npm; el entry
   CLI sobrevive en el tarball).

**Acceptance Criteria**:
- Entrada `## [0.1.2]` presente (REQ-002).

---

## Task 3: Reconciliar spec npm-distribution (Requirement Package configuration)
**Status**: pending
**Domain**: Framework specs
**Layer**: N/A (documentation/contracts)
**Priority**: High
**Estimate**: XS
**Suggested Path**: openspec/changes/fix-npm-publish-bin/specs/npm-distribution/spec.md
**Test Path**: `openspec validate fix-npm-publish-bin`; `grep -n "\./specboot\.sh" openspec/specs/npm-distribution/spec.md` (0 tras archive)

**Steps**:
1. Crear delta `## MODIFIED Requirements` del Requirement "Package configuration" con:
   - bin entry pointing to `specboot.sh` (sin `./`).
   - versión de referencia `0.1.2`.
   - resto del requirement (allowlist, exclusiones, description/keywords) intacto.

**Acceptance Criteria**:
- Delta MODIFIED válido y aplicable (REQ-004).
- Tras el archive, la spec activa no contiene `./specboot.sh` (REQ-004).

---

## Task 4: Verificación integral sin regresión
**Status**: pending
**Domain**: QA
**Layer**: N/A
**Priority**: High
**Estimate**: S
**Suggested Path**: repo root
**Test Path**: `npm publish --dry-run` + `bash check-refs.sh` + `bash specboot.sh --ci` + `make ci` + `for t in tests/*-test.sh; do bash "$t"; done`

**Steps**:
1. `npm publish --dry-run 2>&1 | grep -c "bin\["` → 0.
2. `bash check-refs.sh` → 0 errores.
3. `bash specboot.sh --ci` → 0 errores.
4. `make ci` → exit 0.
5. Todos los `tests/*-test.sh` pasan (9/9).

**Acceptance Criteria**:
- Todas las validaciones en verde (REQ-005).

---

## Traceability to Requirements
| Task | Requirements |
|------|-------------|
| T1 | REQ-001, REQ-003, REQ-005 |
| T2 | REQ-002 |
| T3 | REQ-004 |
| T4 | REQ-005 |
