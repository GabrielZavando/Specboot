# Change Proposal: plan-traceability

- **Ticket ID**: M-101-102
- **Original Title**: [docs] Fortalecer planificacion y trazabilidad con SC-NNN y metadatos en enrich-us
- **Tag**: [docs]
- **SemVer Impact**: minor

## Summary

Este cambio implementa la Fase 1 del plan de mejoras de Specboot (`PLAN_MEJORAS_SPECBOOT.md`), abordando los tickets M-101 y M-102:

1. **M-101 (Metadatos estratégicos en `enrich-us`)**: Extiende la plantilla y el proceso de `enrich-us` para incluir obligatoriamente 4 campos de evaluación estratégica: *Estimación* (complejidad y justificación), *Riesgo* (nivel y motivo), *Dependencias* (tickets relacionados) y *Alternativas descartadas*.
2. **M-102 (IDs estables `SC-{NNN}` en escenarios Gherkin)**: Introduce la convención de IDs estables `SC-{NNN}: Nombre del escenario` en `enrich-us`, `plan-change` y `verify`, permitiendo la trazabilidad directa e ininterrumpida `Requisito ↔ Escenario (SC-NNN) ↔ Test ↔ Reporte Verify`.

## Motivation

- Actualmente, `enrich-us` no produce información sobre complejidad, riesgos ni alternativas, lo que dificulta a `plan-change` dimensionar y priorizar adecuadamente las tareas.
- Los escenarios Gherkin carecen de un identificador persistente único dentro del cambio. Esto obliga a `verify` a depender de coincidencias textuales frágiles para relacionar tests con escenarios.
- Al estandarizar los IDs `SC-{NNN}`, habilitamos el mapeo determinista entre escenarios y evidencia de pruebas en la verificación y en los reportes persistentes futuros.
