# Scenarios — agents-bridge

> Source ticket: TICKET-2.1.
> No enriched artifact exists (`openspec/tickets/` is empty), so scenarios are
> derived from the ticket acceptance criteria (3.1, 3.2, 5) and applied NFRs
> from `docs/base-standards.md` (S/TDD/SOLID, documentation is source of truth)
> and `docs/documentation-standards.md` (specs before code).

## Scenario 1 — AGENTS.md tiene una sección "Carga base (intocable)"

- **GIVEN** un proyecto Specboot recién clonado con `AGENTS.md` y `opencode.json`
- **AND** `opencode.json` declara `["docs/base-standards.md", "AGENTS.md"]` en
  `instructions[]`
- **WHEN** un desarrollador o agente abre `AGENTS.md`
- **THEN** existe una sección titulada "Carga base (intocable)" que declara que
  `docs/base-standards.md` se carga siempre vía `instructions[]`
- **AND** declara explícitamente que ese archivo es intocable del framework

## Scenario 2 — AGENTS.md tiene una sección "Carga dinámica" con regla condicional

- **GIVEN** el `AGENTS.md` del proyecto
- **WHEN** un agente evalúa el contexto a cargar
- **THEN** existe una sección "Carga dinámica" que instruye a leer
  `docs/project/domain.md` y `docs/project/stack.md` **si existen**
- **AND** en caso de ausencia, instruye a usar el contenido por defecto marcado
  como "placeholder por proyecto" descrito en `docs/docs-standard.md` §3
- **AND** conserva la matriz existente de carga por tag de tarea
  (`[backend]`, `[frontend]`, `[api]`, `[docs]`, `[deploy]`)
- **AND** preserva el aviso "No leas estos archivos por si acaso"

## Scenario 3 — AGENTS.md tiene una sección "Herramientas"

- **GIVEN** el `AGENTS.md` del proyecto
- **WHEN** se valida la integridad del puente
- **THEN** existe una sección "Herramientas" que referencia `check-refs.sh` y
  `specboot.sh --ci` como puntos de validación de la integridad del puente
  (referencias `{file:...}` y nombres de skills)

## Scenario 4 — AGENTS.md tiene una "Nota de puente"

- **GIVEN** el `AGENTS.md` del proyecto
- **WHEN** un dev o agente quiere entender dónde vive el contexto real
- **THEN** existe una "Nota de puente" que indica que `AGENTS.md` es solo la
  interfaz
- **AND** explica que el contenido "pesado" del proyecto vive en `docs/`
- **AND** explica que `specboot update` reemplaza `AGENTS.md` sin perder el
  contexto del proyecto, porque ese contexto reside en `docs/`

## Scenario 5 — check-refs.sh sigue en 0 errores tras el cambio

- **GIVEN** `AGENTS.md` reescrito como puente
- **WHEN** se ejecuta `bash check-refs.sh` desde la raíz del proyecto
- **THEN** la salida reporta 0 errores
- **AND** todos los nombres de skills presentes en `ai-specs/skills/*` siguen
  apareciendo en `AGENTS.md` (no se rompe el registro del paso 3)
- **AND** todas las referencias `{file:...}` en `opencode.json` y en
  `ai-specs/**/*.md` / `.opencode/**/*.md` siguen resolviendo a archivos
  existentes

## Scenario 6 — specboot.sh --ci sigue en 0 errores tras el cambio

- **GIVEN** `AGENTS.md`, `docs/docs-standard.md` y `docs/framework-contract.md`
  actualizados
- **WHEN** se ejecuta `bash specboot.sh --ci` desde la raíz
- **THEN** el validador reporta 0 errores
- **AND** ningún placeholder de `PLACEHOLDER_PATTERNS` aparece en `docs/`
- **AND** la lista `REQUIRED_FILES` no se ve afectada (no se añade ni se quita
  archivo requerido por este cambio)

## Scenario 7 — docs/docs-standard.md §3 documenta la carga condicional con placeholder

- **GIVEN** `docs/docs-standard.md` con su §3 actual
  ("Regla de carga dinámica del puente AGENTS.md")
- **WHEN** se aplica el cambio
- **THEN** §3 se extiende (sin renombrarse) para declarar explícitamente la regla
  condicional: `docs/base-standards.md` siempre se carga vía `instructions[]`; si
  `docs/project/domain.md` y `docs/project/stack.md` existen, el agente los lee;
  si faltan, aplica el contenido por defecto marcado "placeholder por proyecto"

## Scenario 8 — framework-contract.md tiene subsección "Puente AGENTS.md ↔ docs/"

- **GIVEN** `docs/framework-contract.md` con la tabla de frontera intocable/del
  proyecto
- **WHEN** se aplica el cambio
- **THEN** existe una subsección titulada "Puente AGENTS.md ↔ docs/" que documenta
  el contrato del puente: `AGENTS.md` es inyectado por el framework (intocable),
  carga `base-standards.md` siempre, lee `docs/project/*` dinámicamente y nunca
  hardcodea el dominio/stack del proyecto (esos viven en `docs/`)

## Edge case — docs/project/* no existen en el proyecto hijo

- **GIVEN** un proyecto hijo que aún no ha personalizado `docs/project/`
- **WHEN** el agente procesa el puente
- **THEN** aplica la rama de fallback de §3 (placeholder por proyecto) sin fallar
  y sin tratar la ausencia como un error

## Edge case — Cambio de versión del framework vía specboot update

- **GIVEN** un proyecto instalado con `@gabrielzavando/specboot` y un `docs/`
  personalizado por el dev
- **WHEN** se ejecuta `specboot update`
- **THEN** `AGENTS.md` se reemplaza íntegramente con la versión del paquete sin
  perder la información de dominio/stack del proyecto, porque esa información
  reside en `docs/project/*` y el puente no la duplica
