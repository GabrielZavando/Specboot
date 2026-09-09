# Requirements: plan-agent-git-permissions

## R1: El agente plan puede crear la rama del ticket en `/plan-change`

El permission block de `.opencode/agents/plan.md` DEBE incluir patrones bash allow para
branch-create: `git checkout *`, `git checkout`, `git switch *`, `git switch`,
`git branch *` y `git branch`, de modo que el agente que ejecuta `/plan-change` pueda
crear `feature/ticket-X.Y-nombre-corto` desde HEAD según `docs/git-workflow-standards.md`
§6.1, sin caer en `"*": deny`.

*Traza: SC-001.*

## R2: Plan puede verificar el estado de repositorio necesario para la rama

El permission block DEBE incluir patrones bash allow para plant read del estado git que
el flujo necesita antes de crear la rama: `git status`, `git status *`, `git log *` y
`git merge-base *`. Todo patrón allow del block DEBE estar documentado en
`ai-specs/agents/plan-agent.md` (sincronía role↔block, criterio de `sync-agent-permissions`).

*Traza: SC-002.*

## R3: Plan NO ejecuta git commit ni git push

El permission block de `.opencode/agents/plan.md` DEBE denegar `git commit` y `git push`
(no ofrece pattern allow; ambos caen en `"*": deny`). El rol `ai-specs/agents/plan-agent.md`
DEBE declarar esta prohibición explícitamente. La propiedad del commit y el push reside
en `/commit` y en el cierre del grupo de tickets (`git-workflow-standards.md` §6.3).

*Traza: SC-003, SC-004.*

## R4: El rol de plan documenta el contrato bash ampliado

`ai-specs/agents/plan-agent.md` DEBE documentar, en su sección de restricciones, que el
bash permitido es `openspec *` más las operaciones git acotadas para crear la rama del
ticket (checkout, switch, branch, status, log, merge-base), y que `git commit` y
`git push` están prohibidos. Mantiene las restricciones de "no builds/tests/installs".

*Traza: SC-004.*

## R5: El fallback deny se conserva en el block de plan

El permission block de `.opencode/agents/plan.md` DEBE conservar `"*": deny` en bash y
`"openspec/**": allow` + `"*": deny` en edit. Ningún cambio de este change puede
eliminar o aflojar el fallback deny.

*Traza: SC-005.*

## R6: La capacidad git de plan queda protegida por un guard ejecutable

DEBE existir un assert en `tests/agent-permissions-test.sh` (SC-007) que verifique que
`plan` permite el branch-create git (`git checkout *`, `git switch *`, `git branch *`,
`git status`) y que NO permite `git commit`/`git push`. El guard DEBE fallar si la
capacidad se revierte o si se introduce un allow inesperado de commit/push.

*Traza: SC-006.*