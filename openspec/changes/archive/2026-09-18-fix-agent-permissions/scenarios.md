# Scenarios: fix-agent-permissions

### SC-001: El agente primario ejecuta tooling de rutina sin prompt
- Given el agente primario con la allowlist ampliada en `opencode.json`
- When el ciclo SDD ejecuta comandos de rutina (`bash tests/*-test.sh`, `bash check-refs.sh`, `bash specboot.sh --ci`, `bash validate-specboot.sh`, `bash scripts/*`, `node`, `mkdir *`, `date *`, `python3 *`)
- Then ninguno de esos comandos requiere confirmación del usuario (allow); `gh *` no está en la allowlist del primario (sin uso en el flujo del mantenedor; los PRs viven en el agente commit)

### SC-002: Comandos destructivos permanecen gated
- Given el agente primario con la allowlist ampliada
- When un agente intenta ejecutar `rm -rf *`, `find` con flags destructivos, `sed -i` o cualquier comando no listado
- Then el comando cae en `ask` y requiere confirmación explícita (las ediciones de archivos van por la edit tool, ya permitida)

### SC-003: El comando /sync-specs corre bajo su agente dedicado
- Given `.opencode/commands/sync-specs.md` con frontmatter `agent: sync-specs`
- When el usuario ejecuta `/sync-specs`
- Then el agente dedicado `.opencode/agents/sync-specs.md` existe con permisos acotados (edit `openspec/**` allow, `openspec *`, `git status/diff`, `ls *`, `cat *`, fallback `*`: deny)

### SC-004: El subagente verify ejecuta los guards del framework sin delegar
- Given el agente `verify` con la allowlist sincronizada con su rol
- When verify corre los guards bash del framework (`bash tests/*-test.sh`, `bash scripts/*`), extrae evidencias token-light (`node -e *`) y genera timestamps (`date *`)
- Then ninguno requiere delegación a otro subagente ni confirmación (rol y permission block sincronizados)

### SC-005: El agente archive hace cleanup y tick de checkboxes sin fricción
- Given el agente `archive` con `rm -f openspec/tickets/*` allow y `edit: openspec/**` allow
- When archive elimina el ticket enriquecido (`rm -f openspec/tickets/*`, silencioso si no existe) y marca checkboxes del Mandatory Steps
- Then el cleanup no falla si el archivo no existe y el tick se hace vía edit tool (no `sed -i`, que permanece gated)

### SC-006: Sin regresión tras el change
- Given el change aplicado
- When se ejecuta la verificación integral del framework
- Then `bash check-refs.sh`, `bash specboot.sh --ci`, `bash validate-specboot.sh` y todos los `tests/*-test.sh` pasan en verde
