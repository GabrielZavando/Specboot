# Requirements: `Makefile` del framework parametrizado por `.specboot.json`

## REQ-001: Makefile lee `.specboot.json` con `node -e` (sin `jq`)
### Description
El Makefile del framework MUST leer `services` y `stack` desde `.specboot.json` usando `node -e` (convención del framework), nunca `jq`. Si el archivo o los campos faltan, aplica defaults seguros.
### Requirements
- **REQ-001.1:** `SERVICES` se lee de `.specboot.json` `services`; si falta/está vacío → default `["."]`.
- **REQ-001.2:** `RAW_STACK` se lee de `.specboot.json` `stack` (string o array normalizado a espacios).
- **REQ-001.3:** Si `stack` está ausente o es `"auto"`, `FINAL_STACK` se autodetecta por presencia de manifiestos (`package.json` → node, `pyproject.toml`/`requirements.txt` → python) en los `SERVICES`.
- **REQ-001.4:** No se introduce dependencia `jq`.
### Acceptance Criteria
- [ ] `make` resuelve servicios/stack sin `jq`.
- [ ] `services` ausente → `["."]`.
- [ ] `stack: "auto"` (o ausente) → autodetección por manifiesto.

---

## REQ-002: Iteración por servicio con guarda de stack
### Description
Los targets `install`, `lint`, `test`, `build`, `audit` y `solid-lint` MUST iterar sobre `SERVICES` y aplicar las herramientas solo si el stack del servicio aplica.
### Requirements
- **REQ-002.1:** Cada target itera `for d in $(SERVICES)` (bucle shell, no pattern rules generadas).
- **REQ-002.2:** Node commands run only if `node` ∈ `FINAL_STACK`; python commands only if `python` ∈ `FINAL_STACK`.
- **REQ-002.3:** `stack: "framework"` → todos los targets de app (install/lint/test/build/audit) saltan sin ejecutar linters/builds de node/python.
### Acceptance Criteria
- [ ] Proyecto node multi-servicio → lint/test por servicio.
- [ ] `stack: "framework"` → app targets skip.

---

## REQ-003: `lint` es lint propio del proyecto; `solid-lint` es SOLID del framework
### Description
`make lint` MUST ejecutar el lint propio del proyecto (`npm run lint` / `ruff check .`); `make solid-lint` MUST ejecutar la toolchain SOLID del framework (eslint@8 + dependency-cruiser + ruff + import-linter), manteniendo la guarda de stack ya existente.
### Requirements
- **REQ-003.1:** `lint` invoca el script `lint` del servicio (node) o `ruff check .` (python).
- **REQ-003.2:** `solid-lint` NO se confunde con `lint`: aplica las configs `templates/ci/` del framework.
- **REQ-003.3:** `solid-lint` conserva `npx eslint@8` (pin de TICKET-0.5).
### Acceptance Criteria
- [ ] `make lint` no corre `eslintrc.backend.js` del framework.
- [ ] `make solid-lint` corre la toolchain SOLID del framework.

---

## REQ-004: Saltos graceful (sin error) para casos no aplicables
### Description
El Makefile MUST no generar errores cuando un servicio no existe, no tiene el stack activo, o no tiene el script/manifest requerido; en su lugar imprime advertencia y continúa (exit 0).
### Requirements
- **REQ-004.1:** Servicio inexistente en disco → advertencia `servicio no existe, saltando`, skip, exit 0.
- **REQ-004.2:** Servicio sin `package.json` (o sin `pyproject.toml`) para el stack declarado → skip con advertencia.
- **REQ-004.3:** Servicio con `package.json` pero sin el script (`lint`/`test`/`build`) → skip con advertencia (no "Missing script" error).
### Acceptance Criteria
- [ ] `make lint` con servicio fantasma → warning + exit 0.
- [ ] Servicio sin script de lint → warning + skip.
- [ ] `make ci` en repo `framework` → verde.

---

## REQ-005: Target `ci` = gate del proyecto; `specboot.sh --ci` excluido
### Description
`make ci` MUST ser el CI gate del proyecto consumidor: `refs` + `solid-lint` + `lint` + `test` + `audit`. `specboot.sh --ci` (framework self-check / dogfooding) MUST NOT formar parte del target `ci`.
### Requirements
- **REQ-005.1:** `ci: refs solid-lint lint test audit`.
- **REQ-005.2:** `ci` NO invoca `specboot.sh --ci`.
- **REQ-005.3:** `refs` ejecuta `check-refs.sh` del proyecto.
### Acceptance Criteria
- [ ] `make ci` corre los 5 targets y no llama `specboot.sh --ci`.
- [ ] `specboot.sh --ci` sigue siendo un comando aparte del framework.

---

## REQ-006: Target opcional `validate-specboot`
### Description
El Makefile MAY ofrecer `validate-specboot` que ejecuta `validate-specboot.sh` del proyecto si existe; si no, imprime advertencia y sale 0.
### Requirements
- **REQ-006.1:** `validate-specboot` corre `bash validate-specboot.sh` si el archivo existe.
- **REQ-006.2:** Si no existe, imprime advertencia y exit 0 (sin error).
### Acceptance Criteria
- [ ] `make validate-specboot` no falla si el script falta.

---

## REQ-007: Documentación (framework-contract.md + README.md)
### Description
La documentación del framework MUST describir el Makefile parametrizable y la distinción CI del proyecto vs framework self-check.
### Requirements
- **REQ-007.1:** `docs/framework-contract.md` incluye sección "Makefile del framework" (intocable, parametrizable vía `services`/`stack`, `ci` = gate del proyecto, `specboot.sh --ci` = framework self-check).
- **REQ-007.2:** `README.md` incluye ejemplo de `.specboot.json` con `services`/`stack` y los comandos Makefile.
- **REQ-007.3:** Ninguna edición introduce referencias `{file:...}` rotas (check-refs.sh sigue en 0).
### Acceptance Criteria
- [ ] Doc refleja el comportamiento.
- [ ] `check-refs.sh` → 0 errores.

---

## REQ-008: Sin regresión en validaciones del framework ni en CI existente
### Description
Tras el cambio, `check-refs.sh`, `specboot.sh --ci` y los 6 jobs de CI existentes (`.github/workflows/ci.yml`) MUST seguir en verde.
### Requirements
- **REQ-008.1:** `check-refs.sh` → 0 errores.
- **REQ-008.2:** `specboot.sh --ci` → sin nuevos errores/avisos.
- **REQ-008.3:** Los jobs `make install/lint/test/build/audit/solid-lint/commitlint` siguen funcionando en proyectos de servicio único/raíz.
### Acceptance Criteria
- [ ] Ambos verdes.
- [ ] CI de GitHub no rompe.

---

## Technical Constraints
| Constraint | Description |
|------------|-------------|
| Files touched | `Makefile`, `docs/framework-contract.md`, `README.md` (intocables framework, evolucionados por dogfooding) |
| Lectura de config | `node -e` sobre `.specboot.json` (TICKET-0.3) — sin `jq` |
| Stack input | `.specboot.json` `services` (rutas) + `stack` (`node`/`python`/`framework`/array/`auto`) |
| Dependencias externas | ninguna nueva; `eslint@8` ya pinneado en `solid-lint` (TICKET-0.5) |

## Dependencies
- TICKET-0.3 (`.specboot.json` `services`/`stack`).
- TICKET-0.5 (base de `solid-lint` por servicio/stack).
- TICKET-3.2 (`specboot update` reemplaza el Makefile).

## Out of Scope
- Editar `update.sh` para tocar el Makefile.
- Cambiar `specboot.sh` ni `validate-specboot.sh`.
- Migración flat-config de `eslintrc.*.js`.
