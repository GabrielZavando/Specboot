# Requirements: sync-agent-permissions

## R1: El subagente verify puede ejecutar pytest (fix core M-403)

El permission block de `.opencode/agents/verify.md` DEBE incluir el patrón
`"pytest *": allow`, de modo que el comando `pytest` documentado en la lista
"Bash permitido" de `ai-specs/agents/verify-agent.md` sea ejecutable por el
subagente en proyectos Python (Step 5b del skill `verify`).
El rol DEBE documentar a su vez todo patrón allow del block que no mencione
(viceversa): `npm run test`.

*Traza: SC-001, SC-002.*

## R2: El permission block del agente archive coincide con su comportamiento real

El permission block de `.opencode/agents/archive.md` DEBE cubrir los comandos
que su rol y su skill documentan: `git status *`, `git diff`, `git diff *`,
`git log`, `git log *` y `node -e *` (lecturas token-light del Step 5).
El patrón de `rm` DEBE quedar acotado a `rm openspec/tickets/*` (cleanup del
Step 7), eliminando `rm -rf openspec/changes/*`. El rol
`ai-specs/agents/archive-agent.md` DEBE dejar de listar `git commit` en
"Bash permitido" y DEBE documentar `node -e`.

*Traza: SC-003, SC-004, SC-005.*

## R3: Sincronía bidireccional rol↔block verificada para todos los agentes restrictivos

Para cada agente con permission block restrictivo (`verify`, `reviewer`,
`archive`, `plan`): todo comando documentado en el rol DEBE tener patrón allow
en el block y todo patrón allow del block DEBE estar documentado en el rol.
El criterio de resolución de desacuerdos es el SKILL.md de cada skill (fuente
de verdad del comportamiento). Los bloques restrictivos DEBEN conservar el
fallback `"*": deny` en bash (y en edit donde aplica). Los agentes con
`bash: allow` (backend, frontend, build) quedan fuera del contrato.

*Traza: SC-006, SC-007, SC-008.*

## R4: La sincronía queda protegida por un guard ejecutable

DEBE existir `tests/agent-permissions-test.sh` con asserts con prefijo
`[SC-NNN]` que valide R1–R3 y falle ante regresiones de sincronía. El guard
DEBE verificar también que `PLAN_MEJORAS_SPECBOOT.md` marca M-403 como
completado con su fila de historial v3.7.

*Traza: SC-009, SC-010.*
