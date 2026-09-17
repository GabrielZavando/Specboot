# Scenarios: sync-specs

### SC-001: Sync aplica deltas del change activo sin archivar
- Given un change activo en `openspec/changes/<change>/` con deltas en `specs/` y specs existentes en `openspec/specs/`
- When el usuario ejecuta `/sync-specs`
- Then los deltas (Added/Modified/Removed/Renamed) se aplican a `openspec/specs/` y el change sigue activo (no archivado, `openspec/state/manifest.json` intacto)

### SC-002: Reporte resumido token-light
- Given un change activo con deltas en varias specs
- When `/sync-specs` completa la sincronización
- Then el reporte muestra un resumen cuantitativo (N reqs añadidos, M modificados, etc.) sin volcar el contenido completo de las specs al contexto

### SC-003: Sin change activo
- Given `openspec/changes/` no existe o no contiene ningún change activo
- When el usuario ejecuta `/sync-specs`
- Then el comando reporta "no hay change activo" y termina sin modificar ningún archivo

### SC-004: Sin cambios pendientes (idempotencia)
- Given un change activo cuyos deltas ya están aplicados en `openspec/specs/`
- When el usuario ejecuta `/sync-specs`
- Then el comando reporta "sin diferencias" y no modifica archivos

### SC-005: Comando registrado e invocable
- Given el framework instalado
- When se listan `.opencode/commands/`, `AGENTS.md` y se corre `bash check-refs.sh`
- Then existe `.opencode/commands/sync-specs.md`, el skill `sync-specs` aparece en la tabla de skills de `AGENTS.md`, y `check-refs.sh` pasa con 0 errores
