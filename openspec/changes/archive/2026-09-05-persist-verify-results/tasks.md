# Implementation Tasks: persist-verify-results

## 1. Persistir resultados de verificación (M-401)

- [x] 1.1 Crear self-test del esquema `tests/verify-state-test.sh` (jq): valida claves requeridas (`schema_version`, `change`, `ticket_id`, `status`, `evidence_mode`, `timestamp`, `tasks`, `scenarios[]`), enums de estado y `schema_version` contra el fixture. Debe fallar (RED) antes de crear el fixture.
  - **Priority**: High
  - **Layer**: tests
  - **Estimate**: S
  - **Suggested Path**: tests/verify-state-test.sh
  - **Test Path**: tests/verify-state-test.sh

- [x] 1.2 Crear fixture canónico del esquema con el ejemplo de la spec
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/examples/verify-results-example.json
  - **Test Path**: tests/verify-state-test.sh

- [x] 1.3 Añadir Step 8 "Persistencia de resultados" al SKILL de `verify`: escribir `openspec/state/verify-results.json` tras cada ejecución (last-run-wins), actualizar Description y Step 7 (quitar "solo pantalla, no persistido")
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: M
  - **Suggested Path**: ai-specs/skills/verify/SKILL.md
  - **Test Path**: tests/verify-state-test.sh

- [x] 1.4 Rewritar Step 2 del SKILL `commit` como gate informado suave: `PASS` omite pregunta · `PARTIAL|FAIL` advierte y ofrece re-ejecutar · ausente o `change` no coincidente mantiene pregunta · staleness warn-only · eliminar nota `.verify-passed`
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: M
  - **Suggested Path**: ai-specs/skills/commit/SKILL.md
  - **Test Path**: no aplica

- [x] 1.5 Añadir campo opcional `verification: {status, timestamp, source}` al Step 5 del SKILL `archive` (entrada del manifest; omitir si no hay archivo; token-light)
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/skills/archive/SKILL.md
  - **Test Path**: no aplica

- [x] 1.6 Actualizar claims "Read-only" de verify: `AGENTS.md` (§4.1 y §5.2), `.opencode/agents/verify.md`, `.opencode/commands/verify.md`, `ai-specs/README.md`
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: AGENTS.md
  - **Test Path**: no aplica

- [x] 1.7 Renombrar asserts de `tests/verify-state-test.sh` con prefijos `[SC-002]`/`[SC-003]` para que el self-test provea evidencia fuerte (match por nombre, Step 5c) de los escenarios que cubre
  - **Priority**: Medium
  - **Layer**: tests
  - **Estimate**: S
  - **Suggested Path**: tests/verify-state-test.sh
  - **Test Path**: tests/verify-state-test.sh

## 2. Mapeo explícito Scenario → Test (M-402)

- [x] 2.1 Documentar convención de nombrado de tests con `SC-NNN` (JS/TS: prefijo `[SC-NNN]` en el título; Python: identificador `test_sc{NNN}_`) en la sección TDD de `build-agent.md`, y añadir referencia en `backend-developer.md` y `frontend-developer.md`
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/agents/build-agent.md
  - **Test Path**: no aplica

- [x] 2.2 Actualizar Step 5c del SKILL `verify` con prioridad de evidencia: match por nombre/identificador (fuerte) > mención textual (débil ⚠️, nunca `PASS`) > `UNTESTED`
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/skills/verify/SKILL.md
  - **Test Path**: tests/verify-state-test.sh

## 3. Cierre del change

- [x] 3.1 Bump de versión `0.2.0` → `0.3.0` (minor) y entrada `## [0.3.0]` en CHANGELOG con los cambios de Fase 4
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: package.json
  - **Test Path**: no aplica

- [x] 3.2 Marcar `[x]` M-401 y M-402 en `PLAN_MEJORAS_SPECBOOT.md` y añadir fila v3.3 al historial de correcciones
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: PLAN_MEJORAS_SPECBOOT.md
  - **Test Path**: no aplica