# Tasks: specboot-update

Layer nomenclature (`.specboot.json` del framework: `services: ["."]`, `stack: "framework"`, sin
mapa `layers`): se usan las capas `cli` (lógica de `specboot.sh`/`update.sh`), `docs`
(documentación del framework), `test` (suites de bash).

Estimaciones: S = <1h, M = 1-3h, L = 3-6h.

## T-001 — RED: test de aceptación `specboot-update-test.sh`  (priority: high, layer: test, est: M)

Crear `tests/specboot-update-test.sh` calcado de `tests/specboot-init-test.sh` (mismos helpers
`assert_exit`/`assert_eq`/`assert_exists`, fixtures `mktemp -d`, ejecución en subshell con
`cd`). Debe cubrir: guard sin `.specboot.json`, salto minor (silent replace + `.specboot.json`
rewrite), salto major (`--yes` procede / sin `--yes` cancela), versión instalada menor
(rechazo), preservación de `docs/` del proyecto y código, exclusión de `README.md`/`LICENSE`,
`--dry-run`, `--no-backup`, `--template`, y la guarda dogfooding (target == source).

- **Scenarios:** 1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 13
- **Suggested Path:** `tests/specboot-update-test.sh`
- **Test Path:** `tests/specboot-update-test.sh`

## T-002 — Helper `semver_jump()` en `specboot.sh`  (priority: high, layer: cli, est: S)

Añadir `semver_jump()` que devuelve `major|minor|patch|eq|older|bad`. Portar el saneo de
pre-release/build de `validate-specboot.sh:89` (`${a%%+*}`; `${a%%-*}`) para que versiones como
`1.2.3-rc.1` no rompan la comparación aritmética. Reutilizable por `run_update_project`.

- **Scenarios:** 4, 5, 8
- **Suggested Path:** `specboot.sh`
- **Test Path:** `tests/specboot-update-test.sh`

## T-003 — `UPDATE_ITEMS[]` + `replace_framework_files()`  (priority: high, layer: cli, est: M)

Definir `UPDATE_ITEMS[]` (excluye `README.md`, `LICENSE`; incluye los 5 docs, `.opencode/`,
`ai-specs/`, los 3 scripts, `templates/ci/`, `opencode.json`, `AGENTS.md`, `Makefile`,
`.github/workflows`). Implementar `replace_framework_files()` con overwrite; para `.github/`
reemplazar sólo los archivos del framework dentro de `.github/workflows/` (nunca `rm -rf`
`.github/`). Reusar `determine_framework_dir()` para el origen.

- **Scenarios:** 6, 7, 8, 13
- **Suggested Path:** `specboot.sh`
- **Test Path:** `tests/specboot-update-test.sh`

## T-004 — `backup_framework_files()` + `.gitignore`  (priority: high, layer: cli, est: S)

Crear backup de los items a reemplazar en `.specboot-backup-<timestamp>/` salvo `--no-backup`.
Si existe `.gitignore` en el destino y no contiene `.specboot-backup-*`, añadir el patrón.

- **Scenarios:** 1, 12
- **Suggested Path:** `specboot.sh`
- **Test Path:** `tests/specboot-update-test.sh`

## T-005 — Lectura/escritura de `frameworkVersion`  (priority: high, layer: cli, est: M)

Añadir `read_specboot_json_version()` y `write_specboot_json_version()` (node-based, preservando
todos los demás campos y el formato de 2 espacios; fallback con `sed` si node no está disponible).
`write` NO debe tocar el archivo si la versión ya coincide (modo reparación eq).

- **Scenarios:** 1, 4, 5, 10
- **Suggested Path:** `specboot.sh`
- **Test Path:** `tests/specboot-update-test.sh`

## T-006 — `run_update_project()` + dispatcher + flags  (priority: high, layer: cli, est: L)

Implementar `run_update_project` con el flujo: guard → leer versión → resolver origen →
`semver_jump` → advertencia major (con `--yes` o `read`) → `UPDATE_ITEMS` → backup → reemplazo →
reescritura `.specboot.json` → post-checks (`check-refs.sh` estricto, `specboot.sh --ci` warn-only)
corridos en el destino (`$ORIGINAL_PWD`). Añadir el caso `update)` en el dispatcher y parseo de
`--dry-run`, `--yes`, `--template`, `--no-backup`. Incluir guarda dogfooding (target == source).

- **Scenarios:** 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13
- **Suggested Path:** `specboot.sh`
- **Test Path:** `tests/specboot-update-test.sh`

## T-007 — `update` en `show_help` y mensaje de opción desconocida  (priority: low, layer: cli, est: S)

Listar `update` en `show_help` y añadirlo al hint de opción desconocida del dispatcher.

- **Scenarios:** (UX)
- **Suggested Path:** `specboot.sh`
- **Test Path:** `tests/specboot-update-test.sh`

## T-008 — Deprecación del sync de `update.sh`  (priority: medium, layer: cli, est: S)

En el modo sync de `update.sh` (no en `--bump`), imprimir un aviso indicando que `specboot update`
es el camino canónico y que `update.sh` sólo se mantiene para `--bump`. No cambiar el resto.

- **Scenarios:** (deprecación; tests/update-test.sh sigue verde)
- **Suggested Path:** `update.sh`
- **Test Path:** `tests/update-test.sh`

## T-009 — Sección en `docs/framework-contract.md`  (priority: high, layer: docs, est: M)

Añadir "## Actualización con `specboot update`" tras "## Inicialización con `specboot init`",
documentando el modelo opción A, las exclusiones (`README.md`/`LICENSE`/`.github` del proyecto),
el backup, los flags y el comportamiento por nivel (major advierte, minor/patch silente). Corregir
la línea 146 ("TICKET-3.2, futuro") que ya no aplica.

- **Scenarios:** (documentación)
- **Suggested Path:** `docs/framework-contract.md`

## T-010 — Ejemplo en `README.md`  (priority: medium, layer: docs, est: S)

Añadir `bash .../specboot.sh update` en §"Uso desde node_modules" y §"Actualización". Corregir
la línea 101 que etiqueta `update.sh` como "(TICKET-3.2)".

- **Scenarios:** (documentación)
- **Suggested Path:** `README.md`

## T-011 — `specs/specboot-update/spec.md` del cambio  (priority: medium, layer: docs, est: M)

Escribir la spec consolidada del capability `specboot-update` (propuesta/archivo) con los
requisitos derivados de REQ-001..012, lista para `/archive`.

- **Scenarios:** (spec)
- **Suggested Path:** `openspec/changes/specboot-update/specs/specboot-update/spec.md`

## T-012 — Validación final  (priority: high, layer: test, est: S)

Correr (en este orden) `bash tests/specboot-update-test.sh`, `bash tests/specboot-init-test.sh`,
`bash tests/update-test.sh`, `bash check-refs.sh`, `bash specboot.sh --ci`, y
`openspec validate specboot-update`. Todos deben quedar en 0 errores.

- **Scenarios:** 1-13
- **Suggested Path:** (raíz)
