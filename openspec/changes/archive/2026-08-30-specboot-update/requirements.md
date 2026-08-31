# Requirements: specboot-update

## REQ-001 — Subcomando `update` existe

`specboot.sh` DEBE exponer un subcomando `update` (distinto de `--init`/`--ci`) que actualiza
un proyecto ya inicializado reemplazando los archivos intocables del framework.

- **Scenarios:** 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13

## REQ-002 — Guard de `.specboot.json`

`update` DEBE abortar con exit 1 si `.specboot.json` no existe en el directorio actual,
imprimiendo `❌ No existe .specboot.json. Usa 'specboot init' para crearlo.`

- **Scenarios:** 3

## REQ-003 — Lectura y resolución de versiones

`update` DEBE leer `frameworkVersion` desde `.specboot.json` y resolver la versión instalada del
framework, en orden: `specboot.sh --version`, `node_modules/@gabrielzavando/specboot/package.json`,
o el `package.json` propio del repo (dogfooding).

- **Scenarios:** 1, 2, 4, 5, 8

## REQ-004 — Clasificación del salto de versión

`update` DEBE clasificar el salto como `major` | `minor` | `patch` | `eq` | `older` | `bad`,
comparando las versiones SemVer (limpiando pre-release/build antes de la comparación numérica).

- **Scenarios:** 1, 2, 4, 5, 8

## REQ-005 — Advertencia de breaking change en major

Si el salto es `major`, `update` DEBE imprimir
`⚠️ Breaking change. Lee CHANGELOG/release notes de vX.Y.Z` y solicitar confirmación; procede
con `y`/`--yes`, cancela (exit 0, sin cambios) con `N`. En minor/patch no imprime la advertencia.

- **Scenarios:** 2, 5

## REQ-006 — Resolución del origen del framework

`update` DEBE resolver el directorio origen de los archivos del framework, prefiriendo
`--template <dir>` y cayendo por defecto al directorio del propio `specboot.sh` (`$SCRIPT_DIR`).

- **Scenarios:** 13

## REQ-007 — Backup antes del reemplazo

`update` DEBE crear un backup de los archivos intocables que va a reemplazar en
`.specboot-backup-<timestamp>/`, salvo que se pase `--no-backup`. Si existe un `.gitignore`,
DEBE añadir el patrón `.specboot-backup-*` para que los backups no se commiteen.

- **Scenarios:** 1, 12

## REQ-008 — Reemplazo sin piedad de intocables (con exclusiones)

`update` DEBE sobrescribir íntegramente los archivos de `UPDATE_ITEMS[]`:
`.opencode/commands`, `.opencode/agents`, `ai-specs`, `check-refs.sh`, `specboot.sh`,
`validate-specboot.sh`, `templates/ci`, los 5 documentos estándar
(`docs/base-standards.md`, `docs/framework-contract.md`, `docs/docs-standard.md`,
`docs/specboot-json-standard.md`, `docs/versioning-standard.md`), `opencode.json`, `AGENTS.md`,
`Makefile`, más los workflows del framework dentro de `.github/workflows/` (archivo por archivo,
nunca `rm -rf` de `.github/`). `README.md` y `LICENSE` NO deben estar en `UPDATE_ITEMS[]`.

- **Scenarios:** 1, 2, 5, 6, 7

## REQ-009 — Nunca toca `docs/` del proyecto ni el código

`update` NO DEBE modificar ningún archivo de `docs/` que no sea uno de los 5 documentos estándar,
ni ningún archivo de código del proyecto (`backend/`, `frontend/`, etc.), ni un
`.github/workflows/` escrito por el proyecto.

- **Scenarios:** 6

## REQ-010 — Reescritura de `.specboot.json`

Si la versión instalada difiere de la del proyecto (`eq`/`older` NO aplican), `update` DEBE
reescribir `frameworkVersion` en `.specboot.json` preservando el resto de campos y el formato
JSON. En `eq`, el archivo DEBE quedar igual.

- **Scenarios:** 1, 4 (rechazo, sin cambio), 5

## REQ-011 — Post-validación con criticidad dividida

Tras el reemplazo, `update` DEBE correr `bash check-refs.sh` y `bash specboot.sh --ci` en el
directorio destino. Si `check-refs.sh` falla → exit 1 (mostrando la ruta del backup). Si
`specboot.sh --ci` falla/avisa → se reporta pero NO bloquea (exit 0).

- **Scenarios:** 10, 11

## REQ-012 — Documentación y deprecación

`docs/framework-contract.md` DEBE incluir una sección "Actualización con `specboot update`" y
`README.md` DEBE documentar el ejemplo de uso. El modo sync de `update.sh` DEBE imprimir un aviso
de deprecación apuntando a `specboot update`.

- **Scenarios:** (documentación, verificada por `check-refs.sh`/`--ci` y revisión)
