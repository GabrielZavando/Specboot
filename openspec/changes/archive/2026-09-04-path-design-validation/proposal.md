# Change Proposal: path-design-validation

- **Ticket ID**: M-201-202
- **Original Title**: [docs] Definir Suggested Path y validación de diseño
- **Tag (source)**: [docs] (explicit)
- **Derived change name**: `path-design-validation`
- **Change folder**: `openspec/changes/path-design-validation/`
- **Enriched artifact used**: no (usará título como única fuente)

## Summary

Este cambio implementa la Fase 2 del plan de mejoras de Specboot (`PLAN_MEJORAS_SPECBOOT.md`), abordando los tickets M-201 y M-202:

1. **M-201 (Suggested Path / Test Path)**: Establece convenciones explícitas de rut `Suggested Path` y `Test Path` en la generación de tareas por `/plan-change`, de modo que `verify` pueda localizar archivos sin fallback estático frágil.

2. **M-202 (Validación de coherencia de diseño)**: Añade un paso de validación preliminar antes de generar tareas, que verifica la consistencia contra `docs/data-model/data-model.md` y `docs/api/api-spec.yml`, y documenta conflictos en una sección `Design Validation` en el output.

## Motivation

- Actualmente, `verify` depende de rutas sugeridas por `plan-change`, pero no existe una convención estricta, lo que fuerza un fallback estático frágil.
- `plan-change` puede generar tareas que contradigan la arquitectura existente (`data-model`, `api-spec`) sin detectarlo previamente.
- Al estandarizar las rutas y añadir validación de diseño, se mejora la trazabilidad, reduce la fricción en la verificación ypreviene errores de arquitectura en implementaciones futuras.

## What Changes

- **M-201**: Convención de `Suggested Path: src/{domain}/{entity}.{ext}` y `Test Path: tests/{domain}/{entity}.{test-ext}`, con reglas para `.specboot.json` services y caps.
- **M-202**: Paso de validación de diseño antes de generar tareas; sección `Design Validation` en output; verificación de entidades y endpoints contra specs existentes.

## Acceptance Criteria

- [ ] `plan-change` genera tareas con campos `Suggested Path` y `Test Path` (o "no aplica")
- [ ] Trazabilidad `SC-NNN → test → PASS/FAIL` mantenida (de Fase 1)
- [ ] Validación de diseño reporta conflictos críticos/minor antes de generar tareas
- [ ] `verify` puede ejecutar tests usando los campos `Suggested Path`/`Test Path`