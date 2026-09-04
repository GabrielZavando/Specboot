# Change Requirements: path-design-validation

## REQ-001: Suggested Path y Test Path en tasks.md
- **Descripción**: Todo task generado por `/plan-change` debe incluir los campos `Suggested Path` (ruta de implementación) y `Test Path` (ruta de test), o el valor `"no aplica"` explicito si no corresponde.
- **Trazabilidad**: SC-001

## REQ-002: Convención de rutas coherente
- **Descripción**: Las rutas deben seguir `src/{domain}/{entity}.{ext}` o `tests/{domain}/{entity}.{test-ext}`, o la configuración de `.specboot.json` si existe. Si `.specboot.json` es ausente, default a `src/` y `tests/` con advertencia en el output.
- **Trazabilidad**: SC-002

## REQ-003: Validación de diseño preliminar
- **Descripción**: `plan-change` debe ejecutar Step 4½ (validación de diseño) antes de generar tareas, verificando entidades contra `data-model` y endpoints contra `api-spec.yml`. Conflictos críticos detienen la generación; conflictos menores se documentan en `Design Validation`.
- **Trazabilidad**: SC-003

## REQ-004: Trazabilidad SC-NNN en verify
- **Descripción**: `verify` debe poder mapear `SC-{NNN} → test → PASS/FAIL/UNTESTED` usando la convención establecida en Fase 1.
- **Trazabilidad**: SC-004