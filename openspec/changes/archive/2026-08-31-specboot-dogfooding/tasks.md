# Tasks: Dogfooding — desarrollar Specboot con Specboot

## Task 1: Test TDD (RED) del script dogfood-check
**Status**: [x]
**Domain**: QA / Tooling
**Layer**: N/A
**Priority**: High
**Estimate**: S
**Suggested Path**: tests/dogfood-check-test.sh
**Test Path**: `bash tests/dogfood-check-test.sh`

**Steps**:
1. Crear `tests/dogfood-check-test.sh` que afirme:
   - `scripts/dogfood-check.sh` existe (`test -f`).
   - `scripts/dogfood-check.sh` es ejecutable (`test -x`).
   - Ejecutar `bash scripts/dogfood-check.sh` y afirmar exit 0.
2. (RED) Confirmar que el test falla antes de crear el script (el archivo no existe).
3. Mantener el test ejecutable (`chmod +x`).

**Acceptance Criteria**:
- El test falla en estado RED (script ausente).
- Cubre existencia, ejecutabilidad y ejecución exitosa.

---

## Task 2: Crear scripts/dogfood-check.sh
**Status**: [x]
**Domain**: Tooling
**Layer**: N/A
**Priority**: High
**Estimate**: S
**Suggested Path**: scripts/dogfood-check.sh
**Test Path**: `bash scripts/dogfood-check.sh`

**Steps**:
1. Crear el directorio `scripts/` si no existe.
2. Escribir el script con shebang `#!/usr/bin/env bash` y `set -euo pipefail` que corra, en orden:
   - `bash check-refs.sh`
   - `bash specboot.sh --ci`
   - e imprima un mensaje de éxito al final.
3. `chmod +x scripts/dogfood-check.sh`.
4. Verificar que el test de la Task 1 pasa ahora (GREEN).

**Acceptance Criteria**:
- Existe y es ejecutable (REQ-DOG-2).
- Corre las dos validaciones y falla si alguna falla (REQ-DOG-3).
- `bash scripts/dogfood-check.sh` termina exit 0 en repo limpio.

---

## Task 3: Documentación README (sección Dogfooding)
**Status**: [x]
**Domain**: Documentation
**Layer**: N/A
**Priority**: High
**Estimate**: S
**Suggested Path**: README.md
**Test Path**: `bash check-refs.sh`

**Steps**:
1. Insertar la sección `## Desarrollar Specboot con Specboot (Dogfooding)` **después** de la sección "Workflows del framework" (justo antes de `## Requisitos`).
2. Incluir los pasos del flujo SDD (rama por ticket + un PR por fase) y la validación con `bash scripts/dogfood-check.sh` (`check-refs.sh` + `specboot.sh --ci`).
3. No introducir referencias `{file:...}` rotas.

**Acceptance Criteria**:
- Sección presente y cubre el flujo (REQ-DOG-1).
- `check-refs.sh` → 0 errores (REQ-DOG-1.4).

---

## Task 4: Validación final (sin regresión)
**Status**: [x]
**Domain**: QA
**Layer**: N/A
**Priority**: High
**Estimate**: M
**Suggested Path**: repo root
**Test Path**: `bash check-refs.sh`, `bash specboot.sh --ci`, `bash scripts/dogfood-check.sh`, `make ci`

**Steps**:
1. `bash check-refs.sh` → 0 errores (REQ-DOG-4.1).
2. `bash specboot.sh --ci` → 0 errores / sin nuevos avisos (REQ-DOG-4.2).
3. `bash scripts/dogfood-check.sh` → pasa (REQ-DOG-3).
4. `make ci` en el repo del framework → 0 errores (REQ-DOG-4.3).
5. `bash tests/dogfood-check-test.sh` → verde (REQ-DOG-5).

**Acceptance Criteria**:
- Las cuatro validaciones en verde.
- El test TDD en verde.

---

## Traceability to Requirements
| Task | Requirements |
|------|--------------|
| T1 | REQ-DOG-5 |
| T2 | REQ-DOG-2, REQ-DOG-3 |
| T3 | REQ-DOG-1 |
| T4 | REQ-DOG-4, REQ-DOG-5 |
