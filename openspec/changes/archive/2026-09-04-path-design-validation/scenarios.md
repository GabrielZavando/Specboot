# Acceptance Scenarios: path-design-validation

### SC-001: plan-change genera tareas con Suggested Path y Test Path

**Given** un ticket con tag `[docs]` procesado por `/plan-change`
**When** el skill genera el archivo `tasks.md`
**Then** cada tarea incluye los campos `Suggested Path` y `Test Path` (o "no aplica" explicito)
**And** las rutas siguen la convención `src/{domain}/{entity}.{ext}` o `tests/{domain}/{entity}.{test-ext}`

---

### SC-002: plan-change valida coherencia de diseño antes de generar tareas

**Given** un ticket que menciona entidades o endpoints de la API
**When** `/plan-change` ejecuta el paso de validación de diseño (Step 4½)
**Then** verifica que las entidades mencionadas existan en `docs/data-model/data-model.md`
**And** verifica que los endpoints mencionados existan en `docs/api/api-spec.yml`
**And** si faltan entidades o endpoints → genera advertencia en sección `Design Validation` y no oculta el conflicto

---

### SC-003: plan-change usa rutas consistentes cuando .specboot.json existe

**Given** un proyecto con `.specboot.json` definido con `services` y `layers`
**When** `/plan-change` genera tareas para ese proyecto
**Then** las rutas `Suggested Path` y `Test Path` reemplazan `src/` por la configuración de `.specboot.json`
**And** cada servicio se analiza independientemente (segúlar `make solid-lint`)
**And** si `.specboot.json` no existe → las rutas default a `src/` y `tests/` con advertencia

---

### SC-004: verify lee Suggested Path/Test Path para ejecutar tests

**Given** un change con tareas que incluyen `Suggested Path` y `Test Path`
**When** `verify` ejecuta la verificación
**Then** localiza los archivos usando exactamente los paths definidos en las tareas
**And** si un `Suggested Path` no existe → marcar tarea como `❌ Archivo no implementado` y pasar a la siguiente
**And** si todos los paths existen → proceder a la ejecución de tests completa