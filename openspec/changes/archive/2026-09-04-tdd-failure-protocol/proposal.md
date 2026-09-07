# Change Proposal: tdd-failure-protocol

- **Ticket ID**: M-301-302
- **Original Title**: [docs] Implementar protocolo de fallo TDD y detención explícita
- **Tag (source)**: [docs] (explicit)
- **Derived change name**: `tdd-failure-protocol`
- **Change folder**: `openspec/changes/tdd-failure-protocol/`
- **Enriched artifact used**: no

## Summary

Este cambio implementa la **Fase 3** del plan de mejoras de Specboot (`PLAN_MEJORAS_SPECBOOT.md`), abordando los tickets **M-301** y **M-302**:

1. **M-301 (Protocolo explícito ante fallo TDD)**: Define un protocolo estructurado que el agente `build` debe seguir cuando un test falla. Establece un límite de 3 intentos y requiere la generación de un `TDD Failure Report` antes de detenerse.

2. **M-302 (Detención explícita tras completar una tarea)**: Formaliza el comportamiento de detención obligatoria del agente después de completar cada tarea. El agente debe reportar el resultado y esperar instrucción explícita del usuario antes de continuar con la siguiente tarea.

## Motivation

- Actualmente, no existe un protocolo definido para manejar fallos TDD repetidos, lo que puede causar que el agente continúe implementando sobre código roto.
- El agente no se detiene explícitamente tras completar una tarea, dependiendo de que el usuario le pida "seguí con la próxima" en el mismo turno.
- Al formalizar ambos comportamientos, se mejora la calidad, se previenen desviaciones de diseño y se asegura la trazabilidad del ciclo TDD.

## What Changes

- **M-301**: Protocolo de 4 pasos (Detectar → Intentar → Reportar → Detener) con límite de 3 intentos. Plantilla `TDD Failure Report` con campos `task`, `attempt`, `error`, `suggested_investigation`.
- **M-302**: Paso final explícito en el flujo de `build-agent.md`: marcar tarea completa, reportar resultado y esperar nueva instrucción.

## Acceptance Criteria

- [ ] Todo fallo TDD genera un `TDD Failure Report` después de 3 intentos fallidos
- [ ] El agente se detiene al alcanzar el límite de intentos
- [ ] Tras completar una tarea, el agente no continúa automáticamente con la siguiente
- [ ] El agente reporta el resultado de cada tarea completada
