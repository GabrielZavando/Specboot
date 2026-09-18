# Scenarios: permissions-cycle-completion

### SC-001: El agente archive puede crear el directorio de estado
- Given el agente `archive` con `"mkdir -p openspec/*": allow`
- When archive necesita crear `openspec/state/` (Step 5, manifest inexistente)
- Then el comando corre sin confirmación ni delegación (consistente con verify/commit)

### SC-002: Runner canónico de la verificación integral sin patrón for
- Given el framework con `tests/run-all.sh`
- When un agente (primario o subagente) ejecuta la verificación integral como `bash tests/run-all.sh`
- Then el comando está cubierto por la allowlist (`"bash tests/*"`) y ejecuta todos los `tests/*-test.sh` sin prompt

### SC-003: Staleness configurable vía .specboot.json (W5)
- Given un proyecto consumidor con `"stalenessPaths": ["lib", "server"]` en su `.specboot.json`
- When `/commit` computa el staleness de la evidencia
- Then el skill `commit` lee las rutas configuradas token-light (`node -e`) y un commit posterior que toque `lib/`/`server/` marca la evidencia como stale

### SC-004: Fallback del staleness al default
- Given un proyecto sin campo `stalenessPaths` en `.specboot.json`
- When `/commit` computa el staleness
- Then usa el default (`src`, `app`, `tests`, `ai-specs`, `.opencode`) — comportamiento idéntico al actual

### SC-005: Comando canónico del cómputo documentado
- Given el skill `commit` con el staleness git-based
- When el guard o un agente consulta cómo computar el staleness
- Then el skill documenta el comando canónico (`git log --format="%H %ad" --date=iso -5 -- <stalenessPaths>`) y el guard aserta su presencia

### SC-006: Trust model y check-refs documentados
- Given el contrato del framework
- When se consulta el trust model de bash del primario
- Then `framework-contract.md` documenta que `node *`/`python3 *` son ejecución arbitraria consistente con `npm *`/`npx *`, y `opencode.json` incluye `"bash check-refs.sh *"` allow

### SC-007: Sin regresión tras el change
- Given el change aplicado
- When se ejecuta la verificación integral
- Then `bash check-refs.sh`, `bash specboot.sh --ci`, `bash validate-specboot.sh`, `bash tests/run-all.sh` y todos los `tests/*-test.sh` pasan en verde
