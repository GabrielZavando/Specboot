# Scenarios: plan-agent-git-permissions

> Contrato de capacidad git del agente `plan`. Fuente de verdad del comportamiento:
> `docs/git-workflow-standards.md` §6.1 (el flujo exige crear la rama del ticket al
> iniciar `/plan-change`) y los pasos reales del skill `plan-change`.

### SC-001: El agente plan puede crear la rama del ticket en /plan-change

- **Given** la convención `docs/git-workflow-standards.md` §6.1, que al iniciar un
  ticket exige crear `feature/ticket-X.Y-nombre-corto` desde HEAD
- **When** el agente `plan` ejecuta `/plan-change` y necesita crear la rama
- **Then** el permission block de `.opencode/agents/plan.md` contiene los patrones
  allow de branch-create: `git checkout *`, `git switch *`, `git branch *`
- **And** la creación de la rama no cae en el fallback `"*": deny`

### SC-002: Plan puede verificar el estado de repositorio que necesita el flujo

- **Given** que `plan` debe confirmar el estado git y la base de la rama antes de crear
  `feature/...` desde HEAD (y la doc `git-workflow-standards.md` presupone un árbol
  limpio y la rama base correcta)
- **When** se audita el permission block de `.opencode/agents/plan.md`
- **Then** existen patrones allow para `git status`, `git status *`, `git log *` y
  `git merge-base *`
- **And** cada comando documentado en `ai-specs/agents/plan-agent.md` tiene su patrón
  allow (sincronía bidireccional, criterio del change `sync-agent-permissions`)

### SC-003: Plan NO puede ejecutar git commit ni git push

- **Given** que la propiedad del commit vive en `/commit` y el push en el step final
  del flujo (`git-workflow-standards.md` §6.3: solo al cerrar el grupo de tickets)
- **When** se audita el permission block de `.opencode/agents/plan.md`
- **Then** no existe patrón allow para `git commit` ni para `git push`
- **And** ambos comandos caen en el fallback `"*": deny`

### SC-004: El rol de plan documenta el nuevo contrato bash

- **Given** el contrato role↔block del change `sync-agent-permissions` (todo patrón
  allow del block debe estar documentado en el rol)
- **When** se audita `ai-specs/agents/plan-agent.md`
- **Then** la sección "Bash permitido" documenta `openspec *` y las operaciones git
  acotadas (checkout, switch, branch, status, log, merge-base)
- **And** documenta explícitamente la prohibición de `git commit` y `git push`

### SC-005: El fallback deny se conserva en el block de plan

- **Given** el criterio del change `sync-agent-permissions` (los bloques restrictivos
  conservan `"*": deny`)
- **When** se audita el frontmatter de `.opencode/agents/plan.md`
- **Then** el block bash termina en `"*": deny` y el edit en `"openspec/**": allow` +
  `"*": deny`
- **And** hinchase corrección no afloja el fallback deny

### SC-006: El guard de sincronización queda en verde y protege la capacidad git

- **Given** el guard `tests/agent-permissions-test.sh` con asserts `[SC-NNN]`
- **When** se ejecuta tras aplicar los cambios
- **Then** todos los asserts pasan
- **And** un assert específico verifica que plan permite el branch-create git
- **And** un assert verifica que plan NO permite `git commit` ni `git push`
- **And** el guard falla si la capacidad git de `plan` se revierte o si se introduce
  un allow inesperado de commit/push (regresión)