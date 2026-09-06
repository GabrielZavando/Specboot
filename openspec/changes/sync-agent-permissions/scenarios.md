# Scenarios: sync-agent-permissions

> Contrato de sincronía rol↔permission block. Fuente de verdad del
> comportamiento: los pasos reales de cada SKILL (`ai-specs/skills/*/SKILL.md`).

### SC-001: Subagente verify ejecuta pytest en un proyecto Python

- **Given** `.opencode/agents/verify.md` con permission block restrictivo
  (`bash` con patrones allow y `"*": deny`)
- **When** el rol `ai-specs/agents/verify-agent.md` documenta `pytest` en su
  lista "Bash permitido" (Step 5b del skill `verify`)
- **Then** el block contiene el patrón `"pytest *": allow`
- **And** la invocación de `pytest` por el subagente `verify` ya no cae en
  deny en un proyecto Python

### SC-002: Viceversa en verify — todo patrón allow del block está documentado

- **Given** el permission block de `.opencode/agents/verify.md`, que contiene
  el patrón `"npm run test *": allow`
- **When** se audita la lista "Bash permitido" del rol
  `ai-specs/agents/verify-agent.md`
- **Then** el rol documenta `npm run test` junto a `npm test`
- **And** no queda ningún patrón allow del block sin mención en el rol

### SC-003: Archive — todo comando documentado por rol/skill tiene patrón allow

- **Given** `ai-specs/agents/archive-agent.md` y el skill `archive`
  (Steps 2, 3 y 5) que documentan `git status --porcelain`, `git diff --stat`,
  `git log` y lecturas token-light `node -e` de la evidencia
- **When** se audita el permission block de `.opencode/agents/archive.md`
- **Then** existen patrones allow para `git status *`, `git diff`, `git diff *`,
  `git log`, `git log *` y `node -e *`
- **And** los Steps 2, 3 y 5 del skill `archive` ejecutan sin caer en deny

### SC-004: Archive — `rm` acotado al cleanup documentado

- **Given** que el Step 7 del skill `archive` solo elimina
  `openspec/tickets/{TICKET-ID}-enriched.md` y nunca toca `openspec/archive/`
- **When** se audita el permission block de `.opencode/agents/archive.md`
- **Then** el patrón de `rm` permitido es `rm openspec/tickets/*`
- **And** el patrón `rm -rf openspec/changes/*` ya no existe en el block
- **And** ningún patrón de `rm` alcanza archivos de `openspec/archive/` ni de
  `openspec/changes/`

### SC-005: Archive — el rol no promete `git commit`

- **Given** la regla "Commit ownership" del rol `archive-agent.md`
  (`/commit` ejecuta el commit) y el Step 6 del skill ("No ejecutar
  git commit")
- **When** se audita la lista "Bash permitido" de `ai-specs/agents/archive-agent.md`
- **Then** la lista ya no incluye `git commit`
- **And** el block sigue sin patrón allow para `git commit` (cae en deny)

### SC-006: Reviewer sincronizado

- **Given** `ai-specs/skills/code-auditing/SKILL.md` documenta `npm audit`,
  `npx eslint`, `npx dependency-cruiser`, `git diff`, `git status`, `ls`,
  `cat` (con redirección para la evidencia) y `mkdir -p openspec/state`
- **When** se audita el permission block de `.opencode/agents/reviewer.md`
- **Then** cada comando documentado tiene su patrón allow correspondiente
- **And** ningún patrón allow del block carece de documentación en el skill/rol

### SC-007: Plan sincronizado

- **Given** `ai-specs/agents/plan-agent.md` declara "Bash permitido: solo
  `openspec *`" y escritura únicamente dentro de `openspec/**`
- **When** se audita el permission block de `.opencode/agents/plan.md`
- **Then** el block permite bash solo vía `"openspec *"` y edit solo vía
  `"openspec/**"`
- **And** no existe ningún patrón allow sin respaldo documental

### SC-008: Fallback deny intacto en todos los bloques restrictivos

- **Given** los agentes `verify`, `reviewer`, `archive` y `plan`, que usan
  permission blocks restrictivos
- **When** se audita el frontmatter de cada uno
- **Then** cada block conserva `"*": deny` en bash (y en edit donde aplica)
- **And** ninguna corrección de este change afloja el fallback deny

### SC-009: Guard de sincronización ejecutable y en verde

- **Given** el guard `tests/agent-permissions-test.sh` con asserts
  `[SC-001]`..`[SC-008]`
- **When** se ejecuta el guard tras aplicar los cambios
- **Then** todos los asserts pasan
- **And** el guard falla si una sincronía rol↔block se rompe (regresión)

### SC-010: Roadmap registra la completitud del ticket

- **Given** el change completo y archivado
- **When** se revisa `PLAN_MEJORAS_SPECBOOT.md`
- **Then** M-403 está marcado `[x]` y existe la fila de historial v3.7 que
  describe lo entregado por este change
