# Scenarios: inject-mandatory-steps

> IDs estables `SC-{NNN}` (convención M-102). Cada escenario es trazable a al
> menos un requisito de `requirements.md` y a un assert `[SC-NNN]` en
> `tests/mandatory-steps-test.sh`.

### SC-001: El documento mandatory steps existe con las tres fases

- **Given** el repositorio del framework Specboot en la rama
  `feature/plan-mejoras-specboot`
- **When** un agente o desarrollador consulta `docs/openspec-tasks-mandatory-steps.md`
- **Then** el documento existe
- **And** define la fase **pre-implementación**: rama activa según la convención
  vigente y estado de git limpio
- **And** define la fase **durante**: tests unitarios del módulo y un test nuevo
  que falla antes de implementar (RED)
- **And** define la fase **post**: ejecutar `verify` y ejecutar
  `adversarial-review`

### SC-002: plan-change inyecta la sección Mandatory Steps en todo tasks.md generado

- **Given** el skill `plan-change` con la inyección implementada (Step 5)
- **When** `/plan-change` genera los artefactos de un change, incluido `tasks.md`
- **Then** el `tasks.md` generado incluye una sección `## Mandatory Steps`
- **And** el contenido de la sección se copia del doc
  `docs/openspec-tasks-mandatory-steps.md` leído en el momento de generación
- **And** el skill no contiene una copia hardcodeada de los pasos (fuente única
  de verdad = el doc)

### SC-003: El checklist de validación de plan-change verifica la sección

- **Given** `/plan-change` está en el Step 6 (validación) de un change recién
  generado
- **When** aplica el checklist de validación a los artefactos
- **Then** el checklist incluye el check "tasks.md incluye la sección
  `## Mandatory Steps`"
- **And** la generación no se reporta como exitosa si el check falla

### SC-004: AGENTS.md referencia el doc en la carga dinámica

- **Given** el puente `AGENTS.md` del framework
- **When** un agente resuelve el contexto dinámico de una tarea de
  implementación
- **Then** la sección de carga dinámica (§2) referencia
  `docs/openspec-tasks-mandatory-steps.md` como contenido inyectado por
  `plan-change` en todo `tasks.md` generado

### SC-005: El doc se distribuye como archivo del framework

- **Given** un proyecto consumidor que ejecuta `specboot init` o
  `specboot update` con el framework versión `0.6.0`
- **When** el framework copia los archivos inyectados (`FRAMEWORK_ITEMS`)
- **Then** `docs/openspec-tasks-mandatory-steps.md` queda presente en el
  proyecto consumidor
- **And** el allowlist `files` de `package.json` incluye el doc (distribución
  npm)
- **And** `docs/docs-standard.md` lista el doc en su árbol canónico y
  `docs/framework-contract.md` lo incluye en el skeleton de `docs/` que crea
  `init`
- **And** el doc NO fue agregado a `REQUIRED_FILES` de `specboot.sh` (un
  consumidor que saltee un update minor no debe fallar `--ci`)

### SC-006: PLAN_MEJORAS refleja el cierre de M-601 y registra los follow-ups

- **Given** la auditoría adversarial del change `enforce-commit-gates` dejó 4
  warnings (W1–W4) como candidatos a follow-up
- **When** el change `inject-mandatory-steps` se cierra
- **Then** `PLAN_MEJORAS_SPECBOOT.md` marca `[x]` el ticket M-601
- **And** el historial incluye la fila v3.6 describiendo lo entregado
- **And** una nueva sección "Fase 10 — Follow-ups de auditoría (patrón M-403)"
  registra M-904 (W1 semántica de staleness), M-905 (W2 vocabulario del trailer
  `Gate-Bypass`), M-906 (W3 reconciliar SemVer de M-901) y M-907 (W4 frase
  residual en spec archivada) como tickets pendientes, sin implementar en este
  change
- **And** M-403 permanece visible como pendiente en su sección de la Fase 4

### SC-007: Release minor 0.6.0 documentado antes del merge

- **Given** el framework en versión `0.5.0` (`package.json` y `frameworkVersion`
  de `.specboot.json`)
- **When** el change se completa y se versiona (bump del mantenedor antes del
  merge, spec `version-bump`)
- **Then** `package.json` declara `0.6.0` y `.specboot.json` refleja
  `frameworkVersion: 0.6.0` (dogfooding)
- **And** `CHANGELOG.md` incluye la entrada `## [0.6.0]` sin sección
  `### Breaking changes`

### SC-008: specboot update reemplaza los docs intocables (fix de bug latente)

- **Given** el bug latente descubierto en `replace_framework_files`: el patrón
  `docs/*` del `case` salteaba todos los ítems `docs/` de `UPDATE_ITEMS[]`
  (incluidos los 5 docs estándar), contradiciendo la spec archivada
  `specboot-update`
- **When** `specboot update` corre en un proyecto consumidor con la versión
  `0.6.0`
- **Then** los 6 docs intocables (los 5 estándar +
  `docs/openspec-tasks-mandatory-steps.md`) se copian al proyecto
- **And** los docs del proyecto (`docs/backend-standards.md`, `docs/project/*`,
  `docs/api/api-spec.yml`, `docs/data-model/*`) permanecen intactos
- **And** el delta `## MODIFIED` sobre la capability `specboot-update` fija el
  conjunto de 6 docs y la regla del fix (solo árboles enteros excluidos)
