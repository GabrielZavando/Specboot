# Change Requirements: persist-verify-results

## REQ-001: Verify persiste resultados de verificación
- **Descripción**: `/verify` SHALL escribir `openspec/state/verify-results.json` después de cada ejecución (incluyendo fallos), con `change`, `ticket_id`, `status`, `evidence_mode`, `timestamp`, totales de tareas y el mapeo de escenarios. El archivo SHALL quedar trackeado en git.
- **Trazabilidad**: SC-001

## REQ-002: Esquema versionado y estable del archivo de resultados
- **Descripción**: `verify-results.json` SHALL usar `schema_version: 1` con claves requeridas y enums de estado (`PASS|PARTIAL|FAIL` global; `PASS|FAIL|UNTESTED` por escenario). Un self-test (`tests/verify-state-test.sh`) SHALL validar el esquema contra un fixture canónico.
- **Trazabilidad**: SC-002

## REQ-003: Semántica de evidence_mode
- **Descripción**: El archivo SHALL declarar `evidence_mode: executable|static`. Cuando la verificación sea solo estática (fallback Step 5e), el status global SHALL ser `PARTIAL` y ningún escenario SHALL marcarse `PASS` en el JSON.
- **Trazabilidad**: SC-003

## REQ-004: Gate informado suave en commit
- **Descripción**: `/commit` SHALL leer `verify-results.json` como gate informado suave: con `status: PASS` del change activo SHALL omitir la pregunta de verify; con `PARTIAL|FAIL` SHALL advertir y ofrecer re-ejecutar o abortar; si el archivo falta o el `change` no coincide SHALL aplicar el flujo actual de pregunta. El chequeo de staleness SHALL ser warn-only. El gate duro queda para M-901 (fuera de alcance).
- **Trazabilidad**: SC-004, SC-005, SC-006, SC-007

## REQ-005: Referencia de verificación en el manifiesto de archive
- **Descripción**: `archive` SHALL añadir el campo opcional `verification: {status, timestamp, source}` a la entrada del `manifest.json` cuando `verify-results.json` exista, y SHALL omitirlo sin bloquear cuando no exista. Archive SHALL leer solo el resumen (token-light, nunca el array de escenarios).
- **Trazabilidad**: SC-008, SC-009

## REQ-006: Convención de nombrado de tests con SC-NNN
- **Descripción**: Los tests generados por `/apply` SHALL incluir el ID de escenario en el nombre público del test: `[SC-NNN]` en el título para JS/TS, `test_sc{NNN}_` en el identificador para Python. La convención SHALL documentarse en `ai-specs/agents/build-agent.md` y SHALL ser referenciada por los subagentes `backend-developer.md` y `frontend-developer.md` (sin modificar `docs/base-standards.md`, intocable).
- **Trazabilidad**: SC-010

## REQ-007: Prioridad de evidencia en el mapeo scenario → test
- **Descripción**: `verify` (Step 5c) SHALL mapear `SC-NNN → test → PASS/FAIL/UNTESTED` con prioridad de evidencia: match por nombre/identificador del test (fuerte) > mención textual (débil, nunca cuenta como `PASS`) > `UNTESTED`. El reporte SHALL mostrar la trazabilidad explícita.
- **Trazabilidad**: SC-011

## REQ-008: Descripciones de verify consistentes con la persistencia
- **Descripción**: Las descripciones de `verify` en `AGENTS.md`, `.opencode/agents/verify.md`, `.opencode/commands/verify.md` y `ai-specs/README.md` SHALL declarar que el skill es read-only sobre el código y persiste evidencia en `openspec/state/`. El SKILL de verify SHALL eliminar "solo pantalla, no persistido" de su informe final.
- **Trazabilidad**: SC-012