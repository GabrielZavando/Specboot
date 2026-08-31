# Scenarios: specboot-update

Todos los escenarios asumen que `specboot update` se invoca desde el directorio raíz del
proyecto consumidor (el framework resuelve su origen a `$SCRIPT_DIR`, que es el paquete
instalado o el repo en dogfooding).

## 1. Happy path — salto minor/patch (reemplazo silencioso)

- **GIVEN** un proyecto con `.specboot.json` cuyo `frameworkVersion` es `0.1.1`
- **AND** la versión instalada del framework es `0.1.5` (o `0.2.0`)
- **WHEN** el developer corre `specboot update`
- **THEN** los archivos intocables se reemplazan sin advertencia de breaking change
- **AND** se crea un directorio `.specboot-backup-<timestamp>/` con los archivos reemplazados
- **AND** `.specboot.json` queda con `frameworkVersion: "0.1.5"`
- **AND** el comando termina con exit 0

## 2. Salto major — advertencia y confirmación

- **GIVEN** un proyecto con `.specboot.json` cuyo `frameworkVersion` es `0.2.0`
- **AND** la versión instalada del framework es `1.0.0`
- **WHEN** el developer corre `specboot update`
- **THEN** se imprime `⚠️ Breaking change. Lee CHANGELOG/release notes de v1.0.0`
- **AND** se solicita confirmación
- **AND** si la respuesta es `y` (o se pasó `--yes`), los archivos se reemplazan y termina exit 0
- **AND** si la respuesta es `N`, imprime `Cancelado.` y termina exit 0 sin modificar nada

## 3. Error — falta `.specboot.json`

- **GIVEN** un directorio que no contiene `.specboot.json`
- **WHEN** el developer corre `specboot update`
- **THEN** imprime `❌ No existe .specboot.json. Usa 'specboot init' para crearlo.`
- **AND** termina con exit 1 sin modificar nada

## 4. Installed version menor que la del proyecto — rechazo

- **GIVEN** un proyecto con `.specboot.json` cuyo `frameworkVersion` es `1.2.0`
- **AND** la versión instalada del framework es `1.1.0`
- **WHEN** el developer corre `specboot update`
- **THEN** imprime un error indicando que la versión instalada es menor que la requerida
- **AND** termina con exit 1 sin modificar nada

## 5. Versiones iguales — modo reparación

- **GIVEN** un proyecto con `.specboot.json` cuyo `frameworkVersion` coincide con la instalada
- **AND** el developer editó a mano un archivo intocable (p.ej. borró una sección de `AGENTS.md`)
- **WHEN** el developer corre `specboot update`
- **THEN** los archivos intocables se reemplazan íntegramente (reparando el editado a mano)
- **AND** `.specboot.json` queda byte-identical a su estado previo
- **AND** termina con exit 0
- **AND** NO se imprime advertencia de breaking change

## 6. Preservación de `docs/` del proyecto y del código

- **GIVEN** un proyecto con archivos propios:
  - `docs/backend-standards.md` (personalizado)
  - `docs/project/domain.md`, `docs/project/stack.md`, `docs/project/client.md`
  - `docs/api/api-spec.yml`, `docs/data-model/data-model.md`
  - `README.md`, `LICENSE`
  - `backend/src/server.ts`, `frontend/src/app.tsx`
  - `.github/workflows/my-own-ci.yml` (escrito por el dev)
- **WHEN** el developer corre `specboot update`
- **THEN** todos los archivos listados arriba quedan byte-identical tras el run
- **AND** los archivos del framework (`.opencode/`, `ai-specs/`, `AGENTS.md`, los 5 docs,
  `opencode.json`, `Makefile`, `templates/ci/`, `check-refs.sh`, `specboot.sh`,
  `validate-specboot.sh`, y los `.github/workflows/` del framework) SÍ se reemplazan

## 7. `README.md` y `LICENSE` del proyecto nunca se tocan

- **GIVEN** un proyecto con un `README.md` y `LICENSE` propios
- **WHEN** el developer corre `specboot update`
- **THEN** `README.md` y `LICENSE` NO aparecen en `UPDATE_ITEMS` y permanecen intactos

## 8. `--dry-run` no modifica nada

- **GIVEN** un proyecto con `.specboot.json`
- **WHEN** el developer corre `specboot update --dry-run`
- **THEN** lista los items que se reemplazarían y el nivel de salto detectado (major/minor/patch/eq)
- **AND** no reemplaza ningún archivo, no crea backup, no modifica `.specboot.json`
- **AND** termina con exit 0

## 9. Dogfooding — destino == origen

- **GIVEN** el repo del framework ejecutándose sobre sí mismo (target == source)
- **WHEN** el developer corre `specboot update`
- **THEN** imprime una nota de que target y origen son iguales y no sincroniza
- **AND** termina con exit 0 sin modificar nada

## 10. Post-check — `check-refs.sh` estricto

- **GIVEN** un proyecto donde el reemplazo deja una referencia `{file:...}` rota en `AGENTS.md`
- **WHEN** el developer corre `specboot update`
- **AND** `bash check-refs.sh` termina con exit != 0
- **THEN** `specboot update` imprime `❌ check-refs.sh falló.` y la ruta del backup para rollback
- **AND** termina con exit 1

## 11. Post-check — `specboot.sh --ci` sólo avisa

- **GIVEN** un proyecto consumidor con `docs/` incompleto (p.ej. falta `docs/api/api-spec.yml`)
- **WHEN** el developer corre `specboot update`
- **AND** `bash check-refs.sh` termina 0 pero `bash specboot.sh --ci` termina con warnings/errores de completitud
- **THEN** `specboot update` reporta los warnings de `--ci` y termina con exit 0 (no bloquea)

## 12. `--no-backup` omite la copia de respaldo

- **GIVEN** un proyecto con `.specboot.json`
- **WHEN** el developer corre `specboot update --no-backup`
- **THEN** los archivos se reemplazan pero NO se crea `.specboot-backup-<timestamp>/`
- **AND** termina con exit 0

## 13. `--template DIR` aplica un origen explícito

- **GIVEN** un directorio `--template /ruta/framework` con archivos nuevos
- **WHEN** el developer corre `specboot update --template /ruta/framework`
- **THEN** los archivos intocables se resuelven y reemplazan desde `/ruta/framework`
