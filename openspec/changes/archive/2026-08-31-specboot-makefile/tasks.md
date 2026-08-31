# Tasks: `Makefile` del framework parametrizado por `.specboot.json`

## Task 1: Test TDD (RED) para el Makefile parametrizado
**Status**: [x]
**Domain**: QA / Tooling
**Layer**: N/A
**Priority**: High
**Estimate**: M
**Suggested Path**: tests/makefile-test.sh
**Test Path**: `bash tests/makefile-test.sh`

**Steps**:
1. Crear `tests/makefile-test.sh` que, en un directorio temporal, genera un proyecto fixture con `.specboot.json` `services: ["s1","s2"]`, `stack: ["node"]`, y dos carpetas cada una con `package.json` que tiene scripts `lint`/`test` que hacen `echo`.
2. Ejecutar `make lint` y `make test` dentro del fixture y afirmar que **ambos** servicios corrieron (mediante archivos de marca / salida).
3. Caso negativo: fixture con `services: ["ghost"]` inexistente → afirmar que `make lint` sale 0 y emite advertencia.
4. Caso `stack: "framework"` → afirmar que `make lint` sale 0 sin ejecutar linters de node.
5. (RED primero) Confirmar que el test falla contra el `Makefile` actual antes de implementar.

**Acceptance Criteria**:
- El test falla en estado RED (Makefile actual no itera servicios en `lint`).
- Cubre multi-servicio, servicio fantasma y `framework`.

---

## Task 2: Refactor del `Makefile` (bucle shell + guardas)
**Status**: [x]
**Domain**: Tooling (CI)
**Layer**: N/A
**Priority**: High
**Estimate**: L
**Suggested Path**: Makefile
**Test Path**: `make ci` en repo framework + `make lint`/`make test` en fixtures + `tests/makefile-test.sh`

**Steps**:
1. Añadir cabecera de comentario: Makefile intocable, parametrizado vía `.specboot.json`.
2. Calcular variables con `node -e` (REQ-001):
   - `SERVICES` (default `["."]`), `RAW_STACK`, `DETECT_STACK`, `FINAL_STACK` (auto si vacío/`auto`), `HAS_NODE := $(findstring node,$(FINAL_STACK))`, `HAS_PYTHON := $(findstring python,$(FINAL_STACK))`.
3. Reescribir `install`, `lint`, `test`, `build`, `audit` como bucle `for d in $(SERVICES)` con (REQ-002/003/004):
   - salto si el dir no existe (advertencia, `continue`);
   - node: solo si `HAS_NODE` y `package.json` presente; comprobar existencia del script vía `node -e "process.exit(Object.keys(require('./'+d+'/package.json').scripts||{}).includes('<cmd>')?0:1)"` → si no existe, advertencia y skip;
   - python: solo si `HAS_PYTHON` y `pyproject.toml`/`requirements.txt`;
   - si nada aplica → advertencia y skip. `echo` (no `@echo`) dentro de `if/else`.
4. `solid-lint`: mantener la toolchain SOLID del framework (eslint@8 + dependency-cruiser + ruff + import-linter) pero en bucle `for d in $(SERVICES)`, con glob **relativo** tras `cd` (p.ej. `"**/*.{ts,tsx}"`), respetando `HAS_NODE`/`HAS_PYTHON` (REQ-003.2/003.3).
5. Añadir target `ci: refs solid-lint lint test audit` + eco resumen (REQ-005).
6. Añadir target `validate-specboot` (REQ-006): `if [ -f validate-specboot.sh ]; then bash validate-specboot.sh; else echo "..."; fi`.
7. Mejorar `help` para imprimir `$(SERVICES)` y `$(FINAL_STACK)`.
8. Mantener `commitlint` con comportamiento actual (`HEAD~1..HEAD`, guarda `command -v`) usando `echo` dentro del `if`.

**Acceptance Criteria**:
- `make ci` en repo framework (`services:["."]`, `stack:"framework"`) → `refs` pasa, app targets skip, exit 0.
- Fixture multi-servicio node → `make lint`/`make test` corren por servicio.
- `stack:"framework"` → no corre linters de node/python.
- Servicio fantasma / sin script → advertencia + exit 0.
- `make lint` NO corre `eslintrc.backend.js` (usa `npm run lint` del proyecto).

---

## Task 3: Documentación (framework-contract.md + README.md)
**Status**: [x]
**Domain**: Documentation
**Layer**: N/A
**Priority**: Medium
**Estimate**: S
**Suggested Path**: docs/framework-contract.md, README.md
**Test Path**: bash check-refs.sh

**Steps**:
1. En `docs/framework-contract.md` añadir sección "Makefile del framework": intocable, parametrizable vía `services`/`stack`, lista de targets (`install`, `lint`, `test`, `build`, `audit`, `solid-lint`, `commitlint`, `refs`, `validate-specboot`, `ci`, `help`), `ci` = gate del proyecto (`refs + solid-lint + lint + test + audit`), y `specboot.sh --ci` = framework self-check (no confundir). Mencionar relación con `specboot update` (reemplaza el Makefile; `update.sh` no lo toca).
2. En `README.md` añadir ejemplo de `.specboot.json` con `services`/`stack` y los comandos `make ci` / `make solid-lint` / `make lint` / `make install`, aclarando que el proyecto no edita el Makefile.
3. No introducir referencias `{file:...}` rotas.

**Acceptance Criteria**:
- Doc refleja el comportamiento (REQ-007.1/007.2).
- `check-refs.sh` → 0 errores (REQ-007.3).

---

## Task 4: Validación final (sin regresión)
**Status**: [x]
**Domain**: QA
**Layer**: N/A
**Priority**: High
**Estimate**: M
**Suggested Path**: repo root
**Test Path**: `bash check-refs.sh`, `bash specboot.sh --ci`, `make ci`, fixtures

**Steps**:
1. `bash check-refs.sh` → 0 errores (REQ-008.1).
2. `bash specboot.sh --ci` → sin nuevos errores/avisos (REQ-008.2).
3. `make ci` en el repo del framework → verde (REQ-004 / REQ-008.3).
4. `tests/makefile-test.sh` → verde (Task 1).
5. (Opcional) fixture manual multi-servicio node para confirmar lint/test por servicio.

**Acceptance Criteria**:
- `check-refs.sh` y `specboot.sh --ci` en verde.
- `make ci` del framework en verde.
- Tests del Makefile en verde.

---

## Traceability to Requirements
| Task | Requirements |
|------|--------------|
| T1 | REQ-002, REQ-004 (cubre comportamiento en tests) |
| T2 | REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006 |
| T3 | REQ-007 |
| T4 | REQ-008 |
