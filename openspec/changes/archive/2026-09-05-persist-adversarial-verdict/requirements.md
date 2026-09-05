# Change Requirements: persist-adversarial-verdict

## REQ-001: Auto-refutación estructurada de hallazgos críticos
- **Descripción**: El skill `code-auditing` SHALL formalizar la auto-refutación como protocolo de 4 pasos (hallazgo → ¿puede ser falso positivo? → buscar evidencia contradictoria en código/tests → decisión final mantener/descartar con motivo), reemplazando la heurística de una línea actual. Todo hallazgo CRITICAL SHALL pasar por el protocolo antes de aparecer en el veredicto final.
- **Trazabilidad**: SC-003

## REQ-002: Anexo de descartados en el reporte
- **Descripción**: El reporte de la auditoría SHALL incluir un anexo "Descartados" con el hallazgo original, la refutación y el motivo de descarte de cada hallazgo crítico refutado. Los hallazgos descartados SHALL NOT aparecer en el veredicto. El contador `findings.discarded` del JSON SHALL reflejar la cantidad descartada.
- **Trazabilidad**: SC-004

## REQ-003: Persistencia del veredicto adversarial
- **Descripción**: El skill `code-auditing` SHALL escribir `openspec/state/adversarial-result.json` al finalizar cada auditoría (incluidos veredictos NO-SHIP), con `schema_version`, `change`, `ticket_id`, `verdict`, `confidence`, `timestamp` ISO-8601 y el objeto `findings` (`total`, `critical`, `warnings`, `info`, `discarded`). El archivo SHALL quedar trackeado en git y la última corrida gana (last-run-wins).
- **Trazabilidad**: SC-001, SC-005

## REQ-004: Esquema versionado y estable del archivo adversarial
- **Descripción**: `adversarial-result.json` SHALL usar `schema_version: 1` con claves requeridas, enum `verdict: SHIP|NO-SHIP`, `confidence` numérico 0.0–1.0, timestamp ISO-8601, y contadores enteros no negativos en `findings` con el invariante `critical ≤ total` y `total = critical + warnings + info`. Un self-test (`tests/adversarial-state-test.sh`) SHALL validar el esquema contra un fixture canónico con tests negativos.
- **Trazabilidad**: SC-002

## REQ-005: Referencia del veredicto en el manifiesto de archive (gate informado suave)
- **Descripción**: El skill `archive` SHALL añadir el campo opcional `adversarial: {verdict, timestamp, source}` a la entrada del `manifest.json` cuando `adversarial-result.json` exista con campo `change` coincidente, y SHALL omitirlo sin bloquear cuando falte o sea de otro change (advirtiendo y sugiriendo ejecutar `/adversarial-review`). Archive SHALL leer solo el resumen (token-light, nunca el detalle de hallazgos). El gate duro queda para M-901 (fuera de alcance).
- **Trazabilidad**: SC-006, SC-007

## REQ-006: Veredicto como evidencia informada en commit
- **Descripción**: El skill `commit` SHALL leer `adversarial-result.json` como gate informado suave: con `verdict: SHIP` del change activo SHALL omitir la confirmación manual y reportar la evidencia; con `NO-SHIP` SHALL advertir y ofrecer re-auditar o abortar sin continuar en silencio; si el archivo falta o el `change` no coincide SHALL mantener el flujo actual. El chequeo de staleness SHALL ser warn-only. El gate duro queda para M-901 (fuera de alcance).
- **Trazabilidad**: SC-008, SC-009, SC-010

## REQ-007: Permisos y descripciones del reviewer sincronizados con la persistencia
- **Descripción**: El permission block de `.opencode/agents/reviewer.md` SHALL incluir la excepción acotada de escritura de evidencia (`mkdir -p openspec/*` y `cat` por redirección, patrón del agente verify) manteniendo `edit: deny` y el resto de bash denegado. Las descripciones en `AGENTS.md` (§5.3), `.opencode/commands/adversarial-review.md` y `ai-specs/README.md` SHALL declarar: read-only sobre código, persiste evidencia en `openspec/state/`. Todo comando documentado en el rol SHALL tener su patrón allow en el permission block y viceversa (lección M-403).
- **Trazabilidad**: SC-011
