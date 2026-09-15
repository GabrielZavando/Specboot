# Scenarios: sdd-cycle-hardening

### SC-001: plan-change crea la rama feature
- Given un ticket parseado con título válido
- When el agente plan ejecuta el skill
- Then el skill ordena (paso explícito entre Step 1 y Step 2) verificar git limpio y crear `feature/ticket-X-nombre` desde HEAD siguiendo `docs/git-workflow-standards.md`, con confirmación del nombre; si la rama ya existe, pregunta antes de reutilizarla

### SC-002: Step 4½ referencia la fuente real de escenarios
- Given el skill plan-change
- When se lee su validación de diseño preliminar
- Then el texto indica verificar entidades/endpoints contra los escenarios del artefacto enriquecido o derivados del título, no contra un `scenarios.md` aún inexistente

### SC-003: enrich-us sin Jira
- Given el skill enrich-us
- When se lee el Step 1
- Then no aparece ninguna referencia a Jira MCP, `curl` ni API de Atlassian; la entrada del ticket se describe como texto directo provisto por el usuario

### SC-004: TDD Failure Protocol canónico
- Given la necesidad del protocolo de fallo TDD
- When cualquier documento lo aplica o referencia
- Then el contenido normativo vive en `docs/tdd-failure-protocol.md`, y `apply.md`, `build-agent.md` y `examples/tasks.md` contienen solo una referencia a ese documento (sin duplicar pasos ni plantilla)

### SC-005: agente commit dedicado
- Given una sesión de `/commit`
- When se inicializa el comando
- Then corre bajo `.opencode/agents/commit.md` con `edit: deny`, sin cargar el rol de `build-agent.md`

### SC-006: permission block acotado de commit
- Given el agente commit
- When se inspecciona su frontmatter
- Then bash permite únicamente `git status/diff/log/add/commit/push/fetch/merge-base/branch/show-current`, `gh *`, `node -e *`, `ls *`, `cat *`, `mkdir -p openspec/*`, con `"git push --force*": deny` y `"*": deny`

### SC-007: inyección única del skill adversarial
- Given `/adversarial-review`
- When se cargan comando y agente
- Then `code-auditing/SKILL.md` se inyecta una sola vez (se mantiene en `reviewer.md`, se elimina del comando)

### SC-008: permiso CHANGELOG huérfano resuelto
- Given el agente archive
- When se compara su permission block con los pasos de su skill
- Then `CHANGELOG.md` ya no figura en los edit allow (el skill no documenta escritura de changelog)

### SC-009: apply verifica pre-condiciones
- Given una invocación de `/apply`
- When inicia antes de despachar cualquier tarea
- Then verifica rama `feature/*` y git limpio, y aborta con mensaje explícito si alguna falla (sugiriendo volver a `/plan-change` si falta la rama)

### SC-010: guards verdes (invariante M-403)
- Given todos los cambios aplicados
- When corren `check-refs.sh`, `specboot.sh --ci` y todos los `tests/*.sh`
- Then todos pasan, incluyendo los asserts nuevos escritos en RED

### SC-011: verify permite npm test sin args
- Given el agente verify
- When se inspecciona su permission block
- Then incluye `"npm test": allow` además de `"npm test *": allow`, con assert correspondiente en `agent-permissions-test.sh`
