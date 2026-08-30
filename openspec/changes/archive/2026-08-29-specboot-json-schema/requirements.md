# Requirements: Esquema y validación de `.specboot.json`

## REQ-001: Documento de esquema canónico
### Description
`docs/specboot-json-standard.md` debe existir y documentar el esquema completo (campos requeridos y opcionales, incl. `layers` opcional) y el comportamiento de validación.
### Requirements
- **REQ-001.1:** El archivo existe en `docs/specboot-json-standard.md`.
- **REQ-001.2:** Documenta `frameworkVersion` (requerido, SemVer), `services` (requerido, array de rutas), `stack` (requerido, string o array), y los opcionales `name`, `description`, `extraStandards`, `layers`.
- **REQ-001.3:** Documenta la semántica de `layers` (mapa servicio → [capas], opt-in, del proyecto).
- **REQ-001.4:** Documenta los 6 casos de validación (ausente, JSON inválido, campos faltantes, versión, rutas).
### Acceptance Criteria
- [ ] El doc cubre esquema + validación.
- [ ] `layers` aparece como opcional y documentado.

---

## REQ-002: Validación de campos requeridos
### Description
`validate-specboot.sh` debe validar presencia y tipo de `frameworkVersion`, `services`, `stack`.
### Requirements
- **REQ-002.1:** Si falta alguno de los tres → error y exit 1.
- **REQ-002.2:** `services` debe ser array; `stack` string o array; `frameworkVersion` string no vacío.
### Acceptance Criteria
- [ ] Falta campo → exit 1.
- [ ] Tipos correctos validados.

---

## REQ-003: Comparación de versión de framework
### Description
El script compara `frameworkVersion` con la versión instalada del framework.
### Requirements
- **REQ-003.1:** Resolución de versión instalada: (a) `specboot.sh --version`; (b) `node_modules/@gabrielzavando/specboot/package.json`; (c) repo `./package.json` (dogfooding).
- **REQ-003.2:** `frameworkVersion` > instalada → error "proyecto requiere versión más nueva" + exit 1.
- **REQ-003.3:** `frameworkVersion` < instalada → warning "framework desactualizado, corre specboot update" + exit 0.
- **REQ-003.4:** Igual → pass.
### Acceptance Criteria
- [ ] Mayor → error/exit1. Menor → warn/exit0. Igual → ok.

---

## REQ-004: Validación de rutas de `services`
### Description
Cada entrada de `services` debe ser una ruta existente (`.` = raíz).
### Requirements
- **REQ-004.1:** Ruta inexistente → error + exit 1.
- **REQ-004.2:** `"."` se acepta como raíz existente.
### Acceptance Criteria
- [ ] Ruta inválida → exit 1.

---

## REQ-005: Comportamiento ante ausencia / JSON inválido
### Description
Casos no bloqueantes y bloqueantes.
### Requirements
- **REQ-005.1:** `.specboot.json` ausente → mensaje warning exacto + exit 0.
- **REQ-005.2:** JSON inválido → error + exit 1.
### Acceptance Criteria
- [ ] Ausente → exit 0 con warning.
- [ ] Inválido → exit 1.

---

## REQ-006: `layers` opcional y tolerado
### Description
Si está presente, `layers` debe ser un objeto; no se valida profundamente.
### Requirements
- **REQ-006.1:** `layers` ausente → válido.
- **REQ-006.2:** `layers` presente y no objeto → error + exit 1.
### Acceptance Criteria
- [ ] Presente como objeto → ok.

---

## REQ-007: Ejemplo completo del repo
### Description
`.specboot.example.json` refleja el esquema final y existe un README comentado.
### Requirements
- **REQ-007.1:** `.specboot.example.json` es JSON válido con todos los campos (incl. `layers` opcional).
- **REQ-007.2:** `.specboot.example.README.md` comenta cada campo (JSON no permite comentarios).
### Acceptance Criteria
- [ ] Ejemplo válido y documentado.

---

## REQ-008: .specboot.json del repo conforme
### Description
El repo dogfooding usa el esquema final y pasa la validación.
### Requirements
- **REQ-008.1:** `.specboot.json` tiene `frameworkVersion:"0.1.1"`, `services:["."]`, `stack:"framework"`.
- **REQ-008.2:** `bash validate-specboot.sh` pasa sobre el repo.
### Acceptance Criteria
- [ ] `validate-specboot.sh` exit 0 en el repo.

---

## REQ-009: Enlaces desde doc padres
### Description
`framework-contract.md` y `docs-standard.md` enlazan el nuevo estándar.
### Requirements
- **REQ-009.1:** Link Markdown válido en ambos doc.
### Acceptance Criteria
- [ ] Ambos doc enlazan.

---

## REQ-010: specboot.sh auto-validable
### Description
`specboot.sh` expone `--version` y un hook tolerante en `--ci`.
### Requirements
- **REQ-010.1:** `specboot.sh --version` imprime la versión de `package.json`.
- **REQ-010.2:** `run_ci` llama `check_specboot_json` que ejecuta `validate-specboot.sh`.
- **REQ-010.3:** El hook es tolerante: si `.specboot.json` falta → warning, no error (no incrementa ERRORS).
### Acceptance Criteria
- [ ] `--version` funciona.
- [ ] `--ci` corre la validación sin romper por ausencia.

---

## REQ-011: Distribución del script
### Description
`validate-specboot.sh` se incluye en el paquete publicado.
### Requirements
- **REQ-011.1:** `package.json` `files` incluye `"validate-specboot.sh"`.
### Acceptance Criteria
- [ ] Presente en `files`.

---

## REQ-012: Validaciones del framework sin regresión
### Description
`check-refs.sh` y `specboot.sh --ci` no introducen errores nuevos.
### Requirements
- **REQ-012.1:** `check-refs.sh` → 0 errores.
- **REQ-012.2:** `specboot.sh --ci` no regresa nuevos errores/warnings vs baseline 0.2.
### Acceptance Criteria
- [ ] Sin regresión.

---

## REQ-013: CI gate propaga errores del validador + chequeos robustos
### Description
`check_specboot_json` en `specboot.sh` debe convertir un exit distinto de 0 de `validate-specboot.sh` en error de CI (debe capturar el exit code del hijo directamente, NO vía un `if` sin `else` que devuelve 0). `validate-specboot.sh` debe leer `layers` desde la ruta del archivo (no interpolando JSON serializado en un string node entrecomillado) y debe normalizar metadata de pre-release/build de SemVer antes de comparar.
### Requirements
- **REQ-013.1:** `check_specboot_json` ejecuta `bash validate-specboot.sh; local rc=$?` e incrementa `ERRORS` cuando `rc != 0`.
- **REQ-013.2:** El chequeo de tipo de `layers` re-lee el archivo vía `node` `fs.readFileSync` (sin interpolar el valor serializado).
- **REQ-013.3:** `semver_cmp` elimina pre-release (`-`) y build (`+`) antes de comparar.
### Acceptance Criteria
- [ ] Un `.specboot.json` roto hace que `specboot.sh --ci` falle.
- [ ] `layers` con apóstrofe en una etiqueta no da falso positivo.
- [ ] Versiones con pre-release comparan sin error aritmético.

---

## Technical Constraints
| Constraint | Description |
|------------|-------------|
| Language | Spanish for docs; script messages in Spanish |
| Script | POSIX/bash, reusa estilo de `specboot.sh` (colores, pass/fail/warn) |
| JSON parse | `node` si disponible; si no, warning y skip no bloqueante |
| Frontier | `specboot.sh` intocable para el dev; tocado aquí por dogfooding |

## Dependencies
- TICKET-0.1 (frontera; `.specboot.json` es del proyecto).
- TICKET-0.2 (`extraStandards` apunta a `docs/`).

## Out of Scope
- `specboot init`/`update` (Fase 3/4).
- Reglas SemVer (TICKET-0.4).
- Empaquetado npm (Fase 1).
- Makefile (Fase 5).
