# Proposal: fix-agent-permissions

**Ticket ID**: M-908
**Título original**: [docs] Resolver fricción de permisos de agentes en el ciclo SDD
**Tag**: docs (framework tooling)
**Origen**: Hallazgo descubierto durante la ejecución de M-701 (patrón M-403) + auditoría de permisos del ciclo SDD solicitada por el mantenedor

## Resumen

Eliminar la fricción de permisos que hoy afecta a cada paso del ciclo SDD en dos
frentes: (1) el agente primario pide confirmación (`"*": "ask"`) para todos los
comandos de tooling de rutina del framework, y (2) los subagentes con `"*": deny`
tienen permission blocks que no cubren lo que sus propios skills exigen, forzando
delegaciones de emergencia a otros subagentes.

## Motivación

Durante la ejecución de M-701 se observó: el operador tuvo que aprobar comandos
de rutina constantemente (`bash tests/*`, `node -e`, `mkdir -p`, `date`, `gh *`,
`sed -i`, bucles de verificación), y los agentes sin permisos suficientes
intentaron cumplir sus tareas delegándolas a subagentes (verify delegando
verify, plan delegando escrituras). Esto es un obstáculo serio al desarrollo
rápido tanto de este framework como de los proyectos que lo consumen
(`.opencode/` se distribuye con el framework).

## Alcance

- `opencode.json`: allowlist del agente primario ampliada con el tooling de
  rutina del ciclo SDD; comandos destructivos/que bypasean la edit tool
  (`rm -rf *`, `find`, `sed`) permanecen en `ask`.
- Nuevo agente dedicado `sync-specs` + `agent: sync-specs` en el frontmatter
  del comando (bug: era el único comando sin `agent:`).
- `.opencode/agents/verify.md` + `ai-specs/agents/verify-agent.md`: sincronizar
  rol↔permisos (`bash tests/*`, `bash scripts/*`, `node -e *`, `date *`).
- `.opencode/agents/archive.md` + `ai-specs/skills/archive/SKILL.md`: `rm -f
  openspec/tickets/*` y tick de checkboxes vía edit tool (no `sed`).
- Guard `tests/agent-permissions-test.sh` extendido + asserts del nuevo agente.

## Fuera de alcance

- No se cambia el endurecimiento estructural del commit agent (force-push denegado).
- No se tocan backend/frontend subagents (full-allow, sin fricción).
- El toggle plan/build de sesión es del entorno OpenCode, no del repo.

## Change type

tooling (sin spec de dominio; el comportamiento se valida vía guard de tests,
siguiendo el patrón de `agent-permissions`).
