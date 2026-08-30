# Git Workflow Standards — Regla de Fluidez

> **Alcance:** Transversal (cross-phase) · **Prioridad:** P0 · **Tipo:** proceso/guidelines
> **Origen:** TICKET-3.1 — Git Workflow Guidelines: Commit, Phase Closure, and PR Management
>
> Este documento **extiende** las reglas básicas de git ya presentes en `AGENTS.md`
> (Conventional Commits, rama por ticket, commits en inglés) y en
> `docs/documentation-standards.md` (sección "Commits y PRs"). No las **reemplaza**:
> AGENTS.md sigue vigente para el flujo de commits y esta guía profundiza con la lógica
> de **fase**, **rebase** y la **matriz de decisión push/PR**.
>
> **No modifica archivos intocables del framework** (`AGENTS.md`,
> `docs/base-standards.md`, `docs/framework-contract.md`, `docs/docs-standard.md`,
> `docs/versioning-standard.md`, `docs/specboot-json-standard.md`).

## 1. Rama por ticket (Siempre)

- Al iniciar un nuevo ticket (`/plan-change`), se crea una rama
  `feature/ticket-X.Y-nombre-corto` **desde el HEAD actual** (que ya trae los
  tickets/commits anteriores sin fusionar a main).
- **Naming:** `feature/ticket-X.Y-nombre-corto` (kebab-case, descripción corta).
- No reutilizar ramas de tickets anteriores, a menos que sea intención de
  **acumulación de fase** (ver "Cierre de fase" abajo).

## 2. Commits local-first

- Los commits se realizan siempre sobre la rama feature del ticket.
- **Headers:** Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`,
  `test:`, `chore:`) — un commit = un cambio lógico.
- La referencia del commit incluye `Closes TICKET-X.Y`.
- **Sin push obligatorio:** los commits pueden permanecer locales. No se fuerza
  push/PR si no se quiere (ver "Matriz de decisión" abajo).

## 3. Cierre de Fase (la regla clave para evitar el "drama")

Dado que se votó **"un PR por fase"** (regla A), pero entendemos que a veces no se
quiere push/PR, el cierre de una **Fase** (grupo de tickets, ej. 1.1, 1.2, 2.1)
sigue este procedimiento:

1. **Acumulación:** Los tickets de la fase quedan commiteados en la rama base
   (ej. `feature/ticket-1.2-distribution-docs`).
2. **Revisión en local:** El dev/agente revisa que la fase está completa y correcta.
3. **Decisión de Push/PR:**
   - **Si quieres PR:** hacer `git rebase main` (actualizar la rama con los
     últimos de main, resolver conflictos **UNA SOLA VEZ**), luego `git push` y
     crear el Pull Request a `main`. **Un solo PR por fase** (squash/merge de
     todos los commits de la fase).
   - **Si NO quieres push/PR:** marcar la fase como "completa en local". Los
     commits quedan en la rama feature (historial propio) y listo. No se fuerza push.
4. **Rama resultante:** al finalizar, la rama del último ticket de la fase pasa a
   la siguiente fase acumulando el historial, o se puede pedir un rebase suave si se
   desea limpiar. Lo obligatorio es la decisión 3.

## 4. Matriz de decisión Push/PR

| ¿Hay token `gh` autenticado? | ¿La fase está "lista para revisar"? | Acción |
| :--- | :--- | :--- |
| **Sí** | **Sí** | Hacer rebase a main, push, crear PR automático/manual. |
| **Sí** | **No** (trabajo interno) | Commit local. No push. Marcar ticket como "en local". |
| **No** | **Sí** | Crear PR manual en GitHub.com (copiar título/cuerpo). Sin rebase previo forzoso, usar la rama actual. |
| **No** | **No** | Commit local. Guardar estado. Revisar después. |

## 5. Modo solo local (sin "ramas fantasma")

- El usuario **puede elegir "solo commits locales"** sin que el sistema le exija
  push/PR.
- Una fase/ticket cerrado en local se marca como **"completa en local"** con los
  commits en la rama feature.
- **Invariante "no ghost branch":** los commits nunca se pierden por falta de
  actualización. El rebase se hace **UNA SOLA VEZ al cerrar la fase**, no por cada
  ticket; si saltan tickets sueltos (sin fase), el rebase es individual, pero la
  carga es mínima al haber votado "PR por fase".

## 6. Flujo resumido para OpenCode

1. `/plan-change TICKET-X.Y` → crear `feature/ticket-X.Y-nombre-corto` desde HEAD.
2. `/apply` → `/verify` → `/archive` → `/commit`.
3. **Al terminar el grupo de tickets (Fase):**
   - Verificar si se quiere Push/PR.
   - Si YES: `git rebase main`, resolver conflictos, `git push`, crear PR en
     GitHub.com (manual si no hay `gh`).
   - Si NO: queda en local; el ticket cierra con estado "local".
4. Continuar al siguiente ticket, cuya rama se creará del HEAD actual (que ya trae
   el historial del grupo anterior si acumulaste).

## 7. Relación con la documentación existente

| Documento | Rol |
| --- | --- |
| `AGENTS.md` | Reglas básicas: rama por ticket, Conventional Commits, commits en inglés (sigue vigente). |
| `docs/documentation-standards.md` | Sección "Commits y PRs": Conventional Commits y PR description (sigue siendo autoritativa). |
| Este documento | Profundiza con fase, rebase único y matriz de decisión push/PR. |