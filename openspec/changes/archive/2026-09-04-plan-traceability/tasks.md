# Implementation Tasks: plan-traceability

## 1. Extender skill enrich-us con metadatos estratégicos (M-101)
- [x] 1.1 Agregar secciones Estimación, Riesgo, Dependencias y Alternativas descartadas a los pasos del proceso en `ai-specs/skills/enrich-us/SKILL.md`
- [x] 1.2 Agregar las 4 secciones a la plantilla de salida (Output Template) en `ai-specs/skills/enrich-us/SKILL.md`
- **Priority**: High
- **Layer**: docs
- **Estimate**: S
- **Suggested Path**: ai-specs/skills/enrich-us/SKILL.md
- **Test Path**: tests/check-refs-test.sh

## 2. Integrar IDs SC-{NNN} en plantilla de escenarios de enrich-us (M-102)
- [x] 2.1 Actualizar el paso 5 (Acceptance Criteria) de `enrich-us/SKILL.md` para prescribir el formato `### SC-{NNN}: [Título]`
- [x] 2.2 Actualizar el Output Template de `enrich-us/SKILL.md` reflejando los identificadores `SC-001`, `SC-002`
- **Priority**: High
- **Layer**: docs
- **Estimate**: S
- **Suggested Path**: ai-specs/skills/enrich-us/SKILL.md
- **Test Path**: tests/check-refs-test.sh

## 3. Actualizar plan-change para prescribir y preservar IDs SC-{NNN} (M-102)
- [x] 3.1 Actualizar el paso 5 (Generar artefactos) en `plan-change/SKILL.md` especificando el prefijo `SC-{NNN}` en `scenarios.md`
- [x] 3.2 Añadir validación de presencia de identificadores `SC-{NNN}` en la lista de verificación del paso 6
- **Priority**: High
- **Layer**: docs
- **Estimate**: S
- **Suggested Path**: ai-specs/skills/plan-change/SKILL.md
- **Test Path**: tests/check-refs-test.sh

## 4. Actualizar skill verify para trazabilidad por patrón SC-{NNN} (M-102)
- [x] 4.1 Actualizar paso 5c (Cobertura de escenarios por tests) en `verify/SKILL.md` para buscar coincidencia del patrón `SC-{NNN}`
- [x] 4.2 Actualizar el formato de informe en el paso 7 para mostrar el mapeo `SC-{NNN} → test → PASS/FAIL/UNTESTED`
- **Priority**: High
- **Layer**: docs
- **Estimate**: S
- **Suggested Path**: ai-specs/skills/verify/SKILL.md
- **Test Path**: tests/check-refs-test.sh

## 5. Actualizar ejemplos de referencia con SC-{NNN} y metadatos (M-101 & M-102)
- [x] 5.1 Agregar las 4 secciones estratégicas y renombrar escenarios a `SC-001`, `SC-002`, `SC-003` en `ai-specs/examples/enrich-us-auth-reset.md`
- [x] 5.2 Actualizar todos los encabezados de escenario a formato `### SC-001: ...` a `SC-007` en `ai-specs/examples/scenarios-example.md`
- **Priority**: Medium
- **Layer**: docs
- **Estimate**: S
- **Suggested Path**: ai-specs/examples/enrich-us-auth-reset.md
- **Test Path**: tests/check-refs-test.sh
