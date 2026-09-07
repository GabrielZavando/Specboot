# path-design-validation Specification

## Purpose
TBD - created by archiving change path-design-validation. Update Purpose after archive.
## Requirements
### Requirement: Suggested Path y Test Path en tasks.md
- **Descripción**: Todo task generado por `/plan-change` SHALL incluir los campos `Suggested Path` y `Test Path`, o el valor `"no aplica"` explicito. SHALL incluirse en todo task generado.
- **Trazabilidad**: SC-001

#### Scenario: Task incluye Suggested Path y Test Path
- **GIVEN** un task generado por `/plan-change`
- **WHEN** se inspecciona el campo `Suggested Path`
- **THEN** el campo tiene un valor con formato `src/{domain}/{entity}.{ext}` o `tests/{domain}/{entity}.{test-ext}`
- **And** el campo `Test Path` tiene un formato similar de test files

### Requirement: Convención de rutas coherente
- **Descripción**: Las rutas SHALL seguir `src/{domain}/{entity}.{ext}` o `tests/{domain}/{entity}.{test-ext}`, o la configuración de `.specboot.json` si existe. SHALL incluirse en todo task generado.
- **Trazabilidad**: SC-002

#### Scenario: Rutas consistentes con .specboot.json
- **GIVEN** un proyecto con `.specboot.json` definido
- **WHEN** `/plan-change` genera tareas para ese proyecto
- **THEN** las rutas `Suggested Path` y `Test Path` reemplazan `src/` por la configuración de `.specboot.json`

### Requirement: Validación de diseño preliminar
- **Descripción**: `plan-change` SHALL ejecutar validación preliminar antes de generar tareas, verificando entidades contra `data-model` y endpoints contra `api-spec.yml`. SHALL detener la generación si hay conflictos críticos; SHALL documentar conflictos menores en `Design Validation`.
- **Trazabilidad**: SC-003

#### Scenario: Validación de diseño con .data-model
- **GIVEN** un task que menciona entidades del dominio
- **WHEN** se ejecuta la validación preliminar
- **THEN** se verifica que las entidades existan en `docs/data-model/data-model.md`
- **And** si faltan entidades → generar advertencia en `Design Validation`

### Requirement: Trazabilidad SC-NNN en verify
- **Descripción**: `verify` SHALL poder mapear `SC-{NNN} → test → PASS/FAIL/UNTESTED` usando la convención establecida en Fase 1. SHALL incluirse en el reporte YAML.
- **Trazabilidad**: SC-004

#### Scenario: verify mapea SC-NNN a tests
- **GIVEN** un change con scenarios que tienen IDs `SC-{NNN}`
- **WHEN** `verify` ejecuta la verificación
- **THEN** mapea cada `SC-{NNN} → test → PASS/FAIL/UNTESTED` en el reporte YAML

