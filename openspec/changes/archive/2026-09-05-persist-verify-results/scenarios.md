# Acceptance Scenarios: persist-verify-results

### SC-001: Verify persiste resultados tras cada ejecución
- **Given** un change activo verificado por `/verify`
- **When** la ejecución de verify finaliza (con cualquier resultado: PASS, PARTIAL o FAIL)
- **Then** se escribe `openspec/state/verify-results.json` con `change`, `ticket_id`, `status`, `evidence_mode`, `timestamp`, totales de tareas y mapeo de escenarios
- **And** el archivo queda trackeado en git (no gitignored)

### SC-002: Esquema versionado y validado por self-test
- **Given** el esquema canónico de `verify-results.json` (`schema_version: 1`)
- **When** se ejecuta `tests/verify-state-test.sh`
- **Then** valida claves requeridas, enums de estado (`PASS|PARTIAL|FAIL` global; `PASS|FAIL|UNTESTED` por escenario) y `schema_version` contra `ai-specs/examples/verify-results-example.json`
- **And** el self-test falla si el esquema se desvía del contrato

### SC-003: Evidencia estática nunca produce PASS global
- **Given** un change sin tests ejecutables (fallback estático del Step 5e de verify)
- **When** verify completa la verificación
- **Then** el status global es `PARTIAL` y `evidence_mode` es `static`
- **And** ningún escenario se marca `PASS` en el JSON

### SC-004: Commit omite la pregunta con PASS vigente
- **Given** `/commit` sobre el change activo con `verify-results.json` con `status: PASS` y campo `change` coincidente
- **When** commit ejecuta su Step 2 (gateway de verify)
- **Then** omite la pregunta "¿Ejecutaste `/verify`?" y reporta la evidencia encontrada (status + timestamp)

### SC-005: Commit advierte con PARTIAL o FAIL
- **Given** `verify-results.json` con `status: PARTIAL` o `FAIL` para el change activo
- **When** commit ejecuta su Step 2
- **Then** advierte el estado registrado y ofrece (a) re-ejecutar `/verify` o (b) abortar
- **And** no continúa sin decisión explícita del usuario

### SC-006: Fallback a pregunta si falta el archivo o no coincide el change
- **Given** `verify-results.json` ausente, o con campo `change` distinto al change activo
- **When** commit ejecuta su Step 2
- **Then** aplica el flujo actual: pregunta al usuario si ejecutó `/verify`
- **And** no continúa sin confirmación

### SC-007: Staleness warn-only
- **Given** `verify-results.json` vigente pero con timestamp anterior al último commit que tocó código
- **When** commit ejecuta su Step 2
- **Then** imprime una advertencia de evidencia posiblemente desactualizada
- **And** no bloquea por sí solo (la decisión queda en el usuario; el gate duro es M-901)

### SC-008: Archive referencia la verificación en el manifest
- **Given** un change archivado con `verify-results.json` existente
- **When** archive genera la entrada del `manifest.json`
- **Then** la entrada incluye `verification: {status, timestamp, source: "openspec/state/verify-results.json"}`
- **And** archive no lee el array de escenarios del JSON (token-light)

### SC-009: Archive no bloquea sin archivo de verificación
- **Given** un change archivado sin `verify-results.json`
- **When** archive genera la entrada del manifest
- **Then** omite el campo `verification`
- **And** el archive completa sin error ni bloqueo

### SC-010: Tests generados llevan SC-NNN en el nombre público
- **Given** una tarea de `/apply` con `Test Path` y un escenario `SC-NNN` asociado
- **When** el subagente genera el test (JS/TS o Python)
- **Then** en JS/TS el título del test lleva el prefijo: `test("[SC-001] ...")` / `it("[SC-001] ...")`
- **And** en Python el identificador lleva el prefijo: `def test_sc001_...`
- **And** la convención está documentada en `ai-specs/agents/build-agent.md` y referenciada por `backend-developer.md` y `frontend-developer.md`

### SC-011: Prioridad de evidencia en el mapeo de verify
- **Given** un escenario `SC-NNN` y tests que lo referencian de distintas formas
- **When** verify mapea evidencia en su Step 5c
- **Then** match por nombre/identificador del test → evidencia fuerte (`PASS`/`FAIL`)
- **And** mención textual (comentarios o descripción) → evidencia débil (⚠️, nunca `PASS`)
- **And** sin ninguna referencia → `UNTESTED`

### SC-012: Descripciones de verify dejan de declarar read-only absoluto
- **Given** los archivos que hoy describen a `verify` como "Read-only"
- **When** el change se aplica
- **Then** `AGENTS.md`, `.opencode/agents/verify.md`, `.opencode/commands/verify.md` y `ai-specs/README.md` declaran: read-only sobre el código, persiste evidencia en `openspec/state/`
- **And** `ai-specs/skills/verify/SKILL.md` ya no dice "solo pantalla, no persistido" para su informe final