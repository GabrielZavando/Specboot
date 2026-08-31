# Requirements: Dogfooding — desarrollar Specboot con Specboot

## REQ-DOG-1: README documenta el flujo dogfooding del framework
### Description
El README del framework MUST incluir una sección que documente cómo el propio framework se desarrolla con su flujo SDD.
### Requirements
- **REQ-DOG-1.1:** La sección se titula "Desarrollar Specboot con Specboot (Dogfooding)".
- **REQ-DOG-1.2:** Lista los pasos del flujo: rama `feature/ticket-X.Y-descripcion` desde `main`, `/plan-change` → `/apply` → `/verify` → `/archive` → `/commit`.
- **REQ-DOG-1.3:** Menciona la validación con `bash scripts/dogfood-check.sh` (`check-refs.sh` + `specboot.sh --ci`) y la regla de un PR por fase.
- **REQ-DOG-1.4:** No introduce referencias `{file:...}` rotas (`check-refs.sh` sigue en 0 errores).
### Acceptance Criteria
- [ ] La sección existe y cubre los pasos del flujo.
- [ ] `check-refs.sh` → 0 errores.

---

## REQ-DOG-2: scripts/dogfood-check.sh existe y es ejecutable
### Description
El repo del framework MUST incluir `scripts/dogfood-check.sh` con bit ejecutable.
### Requirements
- **REQ-DOG-2.1:** El archivo existe en `scripts/dogfood-check.sh`.
- **REQ-DOG-2.2:** Tiene shebang `#!/usr/bin/env bash` y `set -euo pipefail`.
- **REQ-DOG-2.3:** Es ejecutable (`chmod +x`, `test -x` pasa).
### Acceptance Criteria
- [ ] `test -x scripts/dogfood-check.sh` pasa.

---

## REQ-DOG-3: scripts/dogfood-check.sh corre las dos validaciones y propaga fallos
### Description
El script MUST ejecutar `check-refs.sh` y `specboot.sh --ci` y fallar (exit != 0) si cualquiera de las dos falla.
### Requirements
- **REQ-DOG-3.1:** Ejecuta `bash check-refs.sh`.
- **REQ-DOG-3.2:** Ejecuta `bash specboot.sh --ci`.
- **REQ-DOG-3.3:** Con `set -e`, aborta (exit != 0) si cualquiera de las dos falla, sin enmascarar el error.
### Acceptance Criteria
- [ ] En estado limpio, el script termina exit 0.
- [ ] Si `check-refs.sh` falla, el script aborta.
- [ ] Si `specboot.sh --ci` falla, el script aborta.

---

## REQ-DOG-4: Sin regresión en las validaciones del framework
### Description
Tras el cambio, `check-refs.sh`, `specboot.sh --ci` y `make ci` MUST seguir en verde en el repo del framework.
### Requirements
- **REQ-DOG-4.1:** `check-refs.sh` → 0 errores.
- **REQ-DOG-4.2:** `specboot.sh --ci` → 0 errores / sin nuevos avisos.
- **REQ-DOG-4.3:** `make ci` en el repo → 0 errores.
### Acceptance Criteria
- [ ] Las tres validaciones en verde.

---

## REQ-DOG-5: Test TDD del script dogfood-check
### Description
El repo MAY incluir `tests/dogfood-check-test.sh` que valide el script (existencia, ejecutabilidad, ejecución limpia).
### Requirements
- **REQ-DOG-5.1:** Afirma que `scripts/dogfood-check.sh` existe y es ejecutable.
- **REQ-DOG-5.2:** Ejecuta el script y afirma exit 0.
- **REQ-DOG-5.3:** En estado RED (antes de crear el script) el test falla.
### Acceptance Criteria
- [ ] El test pasa en verde tras crear el script.
- [ ] El test falla antes de que exista el script.

---

## Technical Constraints
| Constraint | Description |
|------------|-------------|
| Files touched | `README.md`, `scripts/dogfood-check.sh` (nuevo), `tests/dogfood-check-test.sh` (nuevo), artefactos `openspec/` |
| No edits | `AGENTS.md`, `Makefile`, `.github/workflows/`, `specboot.sh`, `update.sh`, `package.json` |
| Self-update | `specboot update` es no-op en el repo (target==source); el dogfooding usa el flujo de comandos |

## Dependencies
- TICKET-4.1 (Makefile, `make ci`), TICKET-4.2 (workflows), TICKET-3.2 (`specboot update`), TICKET-2.1 (`AGENTS.md` puente).

## Out of Scope
- Editar el `Makefile` para añadir un target `dogfood`.
- Editar `AGENTS.md`, `.github/workflows/`, `specboot.sh`, `update.sh`.
- Publicar el script vía `package.json` `files` o añadir un npm script.
