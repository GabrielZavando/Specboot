# Change Proposal: plan-agent-git-permissions

- **Ticket ID**: N/A (auditoría del mantenedor — análisis de permisos del agente plan, 2026-09-09)
- **Original Title**: [docs] El agente plan no puede ejecutar git: `/plan-change` no crea la rama `feature/ticket-X.Y-*` que exige `docs/git-workflow-standards.md` §6.1
- **Tag (source)**: ninguno (framework core — agentes OpenCode/specs del propio Specboot; ningún tag estándar `backend|frontend|api|docs|fullstack` aplica)
- **Derived change name**: `plan-agent-git-permissions`
- **Change folder**: `openspec/changes/plan-agent-git-permissions/`
- **Enriched artifact used**: no (ticket del mantenedor detallado en sesión, con criterios de aceptación SC-001..SC-006)
- **SemVer Impact**: minor (`0.6.4` → `0.7.0`) — agrega capacidad git al agente `plan` (creación de rama según convención) sin romper contratos existentes ni esquema obligatorio

## Summary

El agente `plan` (que ejecuta `/plan-change`) tiene un permission block de bash
restringido a **solo `openspec *`** (`.opencode/agents/plan.md`). Su rol lo declara
explicitamente: `ai-specs/agents/plan-agent.md` → "Bash permitido: solo `openspec *`".

Sin embargo, `docs/git-workflow-standards.md` §6.1 define que al iniciar un ticket con
`/plan-change` se debe **crear la rama `feature/ticket-X.Y-nombre-corto` desde HEAD**:

> "1. `/plan-change TICKET-X.Y` → crear `feature/ticket-X.Y-nombre-corto` desde HEAD."

Con el permission block actual, el agente `plan` **no puede ejecutar ningún comando git**
(`git checkout`, `git branch`, `git switch`...), así que **no puede cumplir la convención
de rama por ticket**. La rama pasaba a crearse manualmente, rompiendo el flujo
dogfooding que exige `docs/framework-contract.md` ("el framework se desarrolla con su
propio flujo SDD, rama por ticket").

Configure the block so the plan agent can create the ticket branch (remaining
scoped to read + branch creation), while explicitly **denying** `git commit` and
`git push` (ownership of the commit flow lives in `/commit`).

## Motivation

El permission block es contrato para el runtime; la doc `git-workflow-standards.md` es
contrato para el flujo. Cuando divergen, ninguna de las dos partes cumple: la doc promete
que `/plan-change` crea la rama, pero los permisos lo niegan (todo `git *` cae en
`"*": deny`). Es la misma clase de desincronía rol↔block que el change previo
`sync-agent-permissions` (M-403) auditó para `verify`, `archive`, `reviewer` y `plan`,
pero con un matiz nuevo: aquí **no** se sincroniza una capacidad ya documentada que el
block negaba, sino que se **añade** una capacidad nueva (branch-create git) que la doc de
flujo exige explícitamente.

Diferencias con el change análogo `sync-agent-permissions`:

- Ese change fue **`patch`** porque solo alineaba permisos con documentación ya existente
  (sin capacidad nueva).
- Este change es **`minor`**: añade permisos git al agente `plan` para habilitar la
  creación de la rama del ticket, que la convención `git-workflow-standards.md` §6.1 ya
  declaraba como responsabilidad de `/plan-change` pero que el runtime negaba.

La decisión de diseño mantiene el principio de menor privilegio: se permite solo lo que
el flujo necesita para crear la rama (`checkout`, `switch`, `branch`, `status`, `log`,
`merge-base`) y se deniega explícitamente el commit y el push.

## Scope

**In scope:**

- Ampliar el permission block de `.opencode/agents/plan.md` con patrones bash allow para
  branch-create/read git: `git checkout`, `git switch`, `git branch`, `git status`,
  `git log`, `git merge-base`.
- Denegar explícitamente `git commit` y `git push` en el block de `plan`.
- Actualizar `ai-specs/agents/plan-agent.md` para documentar el nuevo contrato bash
  ("Bash permitido: `openspec *` + operaciones git acotadas para crear la rama del
  ticket; prohibido `git commit`/`git push`").
- Ampliar el guard `tests/agent-permissions-test.sh` (SC-007) con asserts que verifiquen
  que plan permite el branch-create git y deniega commit/push.
- Bump `0.6.4` → `0.7.0` (minor) + entrada en `CHANGELOG.md`.

**Out of scope:**

- Cambiar la convención `git-workflow-standards.md` §6 (la creación de rama por
  `/plan-change` sigue siendo la fuente de verdad del flujo; este change la habilita).
- Dar a `plan` capacidad de commit/push (decisión activa: se deniega).
- Cambiar el flujo de worktrees paralelos (el skill `using-git-worktrees` sigue siendo el
  mecanismo para worktrees; este change cubre el caso de creación de rama simple del
  §6.1).
- Cambiar los permisos de otros agentes (`verify`, `archive`, `reviewer`, `backend`,
  `frontend`, `build`) — solo se toca `plan`.

## Design Validation

- **Entities checked against data-model:** none (change de framework; no aplica data model
  de dominio).
- **API endpoints checked against api-spec.yml:** none.
- **Conflicts:**
  - Critical: none.
  - Minor: el change `sync-agent-permissions` documentó a `plan` como "solo `openspec *`"
    y fijó ese contrato en la spec `agent-permissions`. Este change **amend** esa spec
    (delta) para elevar el contrato de `plan` a "openspec + branch-create git, sin
    commit/push". El criterio de resolución es **et contrato de flujo**
    (`git-workflow-standards.md` §6.1) sobre la documentación del agente: la convención
    exige la rama, por lo que el block debe habilitarla. Ambos remain compatibles: el
    fallback `"*": deny` y la prohibición de commit/push se conservan.