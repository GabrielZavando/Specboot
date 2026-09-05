# Acceptance Scenarios: persist-adversarial-verdict

### SC-001: Adversarial-review persiste el veredicto tras cada ejecución
- **Given** un change activo auditado por `/adversarial-review`
- **When** la auditoría finaliza (con cualquier veredicto: SHIP o NO-SHIP)
- **Then** se escribe `openspec/state/adversarial-result.json` con `schema_version`, `change`, `ticket_id`, `verdict`, `confidence`, `timestamp` y el objeto `findings` (total, critical, warnings, info, discarded)
- **And** el archivo queda trackeado en git (no gitignored) y la última corrida gana (last-run-wins)

### SC-002: Esquema versionado y validado por self-test
- **Given** el esquema canónico de `adversarial-result.json` (`schema_version: 1`)
- **When** se ejecuta `tests/adversarial-state-test.sh`
- **Then** valida claves requeridas, enums (`SHIP|NO-SHIP`), rango de `confidence` (0.0–1.0), timestamp ISO-8601 y contadores del objeto `findings` contra `ai-specs/examples/adversarial-results-example.json`
- **And** el self-test falla si el esquema se desvía del contrato (tests negativos incluidos)

### SC-003: Todo hallazgo CRITICAL pasa por el protocolo de refutación
- **Given** un hallazgo de severidad CRITICAL durante la auditoría
- **When** el reviewer aplica el protocolo de auto-refutación de 4 pasos
- **Then** pregunta si puede ser falso positivo, busca evidencia contradictoria en código/tests, y registra una decisión final (mantener/descartar) con su motivo
- **And** solo los hallazgos que sobreviven aparecen en el veredicto

### SC-004: Descartados van al anexo con motivo
- **Given** hallazgos críticos descartados durante la auto-refutación
- **When** el reporte final se genera
- **Then** los descartados no aparecen en el veredicto pero sí en un anexo "Descartados" (hallazgo original + refutación + motivo)
- **And** el contador `findings.discarded` del JSON refleja la cantidad descartada

### SC-005: Veredicto NO-SHIP también se persiste
- **Given** una auditoría que concluye NO-SHIP
- **When** el paso de persistencia del skill se ejecuta
- **Then** `adversarial-result.json` se escribe igualmente con `verdict: "NO-SHIP"`
- **And** la ausencia de persistencia nunca depende del veredicto

### SC-006: Archive referencia el veredicto en el manifest
- **Given** un change archivado con `adversarial-result.json` existente y campo `change` coincidente
- **When** archive genera la entrada del `manifest.json`
- **Then** la entrada incluye `adversarial: {verdict, timestamp, source: "openspec/state/adversarial-result.json"}`
- **And** archive no lee el detalle de hallazgos del JSON (token-light)

### SC-007: Archive advierte sin bloquear si falta la evidencia o es ajena
- **Given** un change archivado sin `adversarial-result.json`, o con campo `change` distinto al change activo
- **When** archive genera la entrada del manifest
- **Then** omite el campo `adversarial`, imprime una advertencia y sugiere ejecutar `/adversarial-review`
- **And** el archive completa sin error ni bloqueo (el gate duro es M-901)

### SC-008: Commit omite la pregunta con SHIP vigente
- **Given** `/commit` sobre el change activo con `adversarial-result.json` con `verdict: "SHIP"` y campo `change` coincidente
- **When** commit ejecuta su gateway de adversarial-review
- **Then** omite la confirmación manual de la auditoría y reporta la evidencia encontrada (verdict + timestamp)

### SC-009: Commit advierte con NO-SHIP y no continúa en silencio
- **Given** `adversarial-result.json` con `verdict: "NO-SHIP"` para el change activo
- **When** commit ejecuta su gateway de adversarial-review
- **Then** advierte el veredicto registrado y ofrece (a) ejecutar `/adversarial-review` nuevamente o (b) abortar
- **And** no continúa sin decisión explícita del usuario

### SC-010: Commit mantiene el flujo actual si la evidencia falta o es ajena
- **Given** `adversarial-result.json` ausente, o con campo `change` distinto al change activo
- **When** commit ejecuta su gateway de adversarial-review
- **Then** aplica el flujo actual: pide confirmación de que la auditoría pasó
- **And** un timestamp anterior al último commit que tocó código genera solo una advertencia de staleness (warn-only)

### SC-011: Permisos y descripciones del reviewer sincronizados con la persistencia
- **Given** el subagente `reviewer` con `edit: deny` y bash sin permisos de escritura
- **When** el change se aplica
- **Then** el permission block de `.opencode/agents/reviewer.md` incluye la excepción acotada para escribir la evidencia (`mkdir -p openspec/*` y `cat` por redirección, patrón verify)
- **And** `AGENTS.md` (§5.3), `.opencode/commands/adversarial-review.md` y `ai-specs/README.md` dejan de describirlo como read-only absoluto: read-only sobre código, persiste evidencia en `openspec/state/`
- **And** todo comando documentado en el rol tiene su patrón allow en el permission block (y viceversa)
