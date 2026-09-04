# Acceptance Scenarios: plan-traceability

### SC-001: enrich-us incluye metadatos estratégicos de estimación, riesgo, dependencias y alternativas

**Given** un desarrollador o agente ejecutando el skill `enrich-us` sobre una historia de usuario
**When** el skill genera el archivo de salida o el documento enriquecido
**Then** el documento incluye las 4 secciones estratégicas: Estimación (complejidad y justificación), Riesgo (nivel y motivo), Dependencias (tickets relacionados) y Alternativas descartadas
**And** las 4 secciones forman parte de la plantilla oficial de salida de `enrich-us`

---

### SC-002: enrich-us genera escenarios Gherkin con identificadores estables SC-NNN

**Given** la plantilla y las instrucciones de proceso en `ai-specs/skills/enrich-us/SKILL.md`
**When** se redactan los criterios de aceptación en formato Gherkin
**Then** cada escenario tiene un identificador con prefijo `SC-{NNN}` (por ejemplo `### SC-001: Usuario recupera contraseña`)
**And** el identificador es único dentro del artefacto enriquecido

---

### SC-003: plan-change preserva y genera IDs SC-NNN en escenarios.md

**Given** un ticket enriquecido con escenarios `SC-{NNN}` o un título de ticket procesado por `/plan-change`
**When** `plan-change` genera el archivo `openspec/changes/<change>/scenarios.md`
**Then** todos los escenarios preservan o incorporan identificadores `SC-{NNN}` únicos dentro del change
**And** la plantilla e instrucciones de `plan-change` especifican la obligatoriedad del prefijo `SC-{NNN}`

---

### SC-004: verify realiza trazabilidad de pruebas buscando patrón SC-NNN

**Given** el skill `verify` inspeccionando las pruebas unitarias e integrales de un cambio activo
**When** se evalúa la cobertura de los escenarios de `scenarios.md`
**Then** `verify` busca referencias de pruebas asociadas usando el patrón `SC-{NNN}`
**And** el reporte YAML emite la correspondencia `SC-{NNN} → test → PASS/FAIL/UNTESTED`

---

### SC-005: Ejemplos del framework actualizados con la nueva convención SC-NNN y metadatos

**Given** la carpeta de ejemplos de referencia `ai-specs/examples/`
**When** un desarrollador o agente consulta `enrich-us-auth-reset.md` y `scenarios-example.md`
**Then** los escenarios en dichos archivos utilizan el formato `SC-{NNN}`
**And** `enrich-us-auth-reset.md` incluye ejemplos concretos de Estimación, Riesgo, Dependencias y Alternativas descartadas
