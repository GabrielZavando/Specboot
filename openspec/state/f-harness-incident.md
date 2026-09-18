# F-Harness — Investigación de degrado de tool calls (OpenCode)

## Síntomas detectados en este ciclo (M-801/M-908/M-909/M-701)

| Fecha | Incidencia |
|---|---|
| 2026-09-18 (esta sesión) | `bash` no disponible en tools list tras cambio de modo plan→build; timeouts de `task` (subagente) en 3 sesiones; lecturas en bucle pese a edit disponible |
| 2026-09-18 (más temprano) | `write` rechazado por schema en algunos payloads (Sharing); llamada task cancelada |

## Conclusión (recordado por la sesión)

- **Es del harness/entorno OpenCode**, no de la configuración del repo: los permission blocks ya estaban sincronizados correctamente tras la auditoría M-908.
- **No se ve el código en el repo** como fuente de regresión — los hooks y ci.yml siguen en verde, los tests pasan antes/después del problema.
- **Mitigación operativa**: sesiones cortas + reintentos tras el mensaje del usuario; si persiste, reporte a OpenCode con el hash de sesión específico.
- **Estado**: evaluado — sin acción en el repositorio (requiere observación continua si aparece de nuevo).
