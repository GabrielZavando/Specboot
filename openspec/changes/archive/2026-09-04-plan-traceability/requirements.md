# Change Requirements: plan-traceability

## REQ-001: Secciones de metadatos estratégicos en enrich-us
- **Descripción**: `ai-specs/skills/enrich-us/SKILL.md` debe incluir en sus instrucciones de proceso y en su plantilla final de salida las secciones *Estimación*, *Riesgo*, *Dependencias* y *Alternativas descartadas*.
- **Trazabilidad**: SC-001

## REQ-002: Identificadores estables SC-{NNN} en enrich-us
- **Descripción**: La plantilla y la instrucción de criterios de aceptación de `enrich-us` deben exigir el uso de IDs en formato `### SC-{NNN}: [Título]` para cada escenario Gherkin.
- **Trazabilidad**: SC-002

## REQ-003: Preservación de IDs SC-{NNN} en plan-change
- **Descripción**: `ai-specs/skills/plan-change/SKILL.md` debe incluir la regla explícita de generar y preservar identificadores `SC-{NNN}` en `scenarios.md` durante el paso 5.
- **Trazabilidad**: SC-003

## REQ-004: Trazabilidad de escenarios en verify usando SC-{NNN}
- **Descripción**: `ai-specs/skills/verify/SKILL.md` debe actualizar su proceso de trazabilidad y cobertura (paso 5c y paso 7) para buscar referencias de pruebas usando la convención `SC-{NNN}`.
- **Trazabilidad**: SC-004

## REQ-005: Actualización de ejemplos de referencia
- **Descripción**: Actualizar los archivos `ai-specs/examples/enrich-us-auth-reset.md` y `ai-specs/examples/scenarios-example.md` para reflejar la convención `SC-{NNN}` y la estructura enriquecida de M-101.
- **Trazabilidad**: SC-005
