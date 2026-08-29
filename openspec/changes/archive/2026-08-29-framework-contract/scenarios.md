# Scenarios: Contrato del Framework Specboot

## Acceptance Criteria

### Scenario 1: El documento existe y es navegable
- Given el repo de Specboot en cualquier estado limpio
- When un dev abre `docs/framework-contract.md`
- Then el archivo existe y contiene las 7 secciones numeradas en este orden: Resumen ejecutivo, Principios rectores, Arquitectura de distribución, Frontera intocable / del proyecto, Flujo SDD obligatorio, Modelo de actualización, Dogfooding.

### Scenario 2: La frontera intocable/del proyecto es inequívoca
- Given un dev que lee la sección "Frontera intocable / del proyecto"
- When revisa cualquier archivo listado en la columna "Intocable" (`AGENTS.md`, `.opencode/commands/*`, `.opencode/agents/*`, `ai-specs/*`, `check-refs.sh`, `specboot.sh`, `Makefile`, `templates/ci/*`, `.github/workflows/*` del framework, `docs/base-standards.md`)
- Then sabe con certeza que NO debe editarlo manualmente porque es inyectado/actualizado por el framework.

### Scenario 3: La frontera del proyecto es explícita
- Given un dev que lee la misma sección
- When revisa cualquier archivo listado en la columna "Del proyecto" (`docs/` salvo `base-standards.md`, `.specboot.json`, código de `backend/`/`frontend/`, variables de entorno, GitHub vars, MCP del proyecto)
- Then sabe que es de su propiedad y responsabilidad.

### Scenario 4: El documento pasa las validaciones automáticas
- Given `framework-contract.md` recién escrito
- When se ejecuta `check-refs.sh` y `specboot.sh --ci`
- Then no hay referencias `{file:...}` rotas y la validación CI pasa limpia.

### Scenario 5: No contiene código ni implementación
- Given el documento completo
- When se hace grep de bloques de código (```), definiciones de funciones, esquemas JSON, scripts de bash
- Then los únicos bloques permitidos son la tabla de frontera y ejemplos puramente documentales; no hay funciones, no hay JSON Schema, no hay scripts ejecutables.
