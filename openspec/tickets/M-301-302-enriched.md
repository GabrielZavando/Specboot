## User Story enriched: M-301-302

**As a** desarrollador/agente `build` del framework Specboot
**I want** un protocolo explícito ante fallos TDD repetidos y una detención obligatoria tras completar cada tarea
**So that** el agente nunca implemente sobre código roto, nunca marque tareas completas sin evidencia TDD y siempre espere confirmación antes de avanzar

### Context

La Fase 3 del plan de mejoras (`PLAN_MEJORAS_SPECBOOT.md`) identifica dos brechas en `/apply`:

- **M-301**: El ciclo RED-GREEN-REFACTOR ya está definido como regla no negociable en `ai-specs/agents/build-agent.md`, pero **no existe un límite de intentos ni un formato de reporte** cuando una tarea no logra pasar TDD. El agente podría quedar en un bucle indefinido o, peor, marcar la tarea como completa sin evidencia.
- **M-302**: `build-agent.md` ya restringe el trabajo a una sola tarea por ejecución ("identificar la tarea actual (una sola)", "nunca implementar más de lo que pide la tarea actual"), pero **no está escrito explícitamente** que el agente deba parar y reportar tras cada tarea — depende de que nadie le pida "seguí con la próxima" en el mismo turno.

### Diseño de Clases/Componentes

- `TDD Failure Protocol` (sección en `.opencode/commands/apply.md`): responsabilidad única = "definir el comportamiento obligatorio del agente cuando un test falla: 3 intentos → reporte → detención"
  - Depende de: del ciclo RED-GREEN-REFACTOR ya definido en `build-agent.md` (lo **extiende**, no lo reescribe), NO de scripts o gates automáticos
  - Capa: docs (instrucciones de agente/comando del framework)
- `TDD Failure Report` (plantilla embebida en el protocolo): responsabilidad única = "capturar el estado del fallo de forma auditable"
  - Depende de: nada (plantilla de texto autocontenida)
  - Capa: docs
- `Stop-and-report step` (paso final en `ai-specs/agents/build-agent.md`): responsabilidad única = "garantizar que tras marcar `[x]` una tarea, el agente reporte y espere instrucción explícita"
  - Depende de: del flujo "Comportamiento en cada tarea" existente (se añade como paso 8), NO de mecanismos externos
  - Capa: docs

### Acceptance Criteria

### SC-008: Protocolo de detención ante fallo TDD consecutivo
- Given una tarea activa siendo implementada por el agente `build`
- When un test falla por 3ª vez consecutiva
- Then el agente detiene la implementación de esa tarea
- And genera un `TDD Failure Report`
- And no marca la tarea como completada ni continúa con la siguiente

### SC-009: Reporte de fallo TDD con formato auditable
- Given un fallo TDD que alcanza el límite de intentos
- When el agente genera el `TDD Failure Report`
- Then el reporte incluye exactamente los campos: `Task`, `Attempt`, `Error`, `Suggested investigation`

### SC-010: Detención explícita tras completar tarea
- Given una tarea completada satisfactoriamente con evidencia TDD (RED→GREEN)
- When el agente marca la tarea como `[x]` en `tasks.md`
- Then el agente reporta el resultado de la tarea
- And espera una instrucción explícita del usuario antes de continuar con la siguiente tarea pendiente

### Edge Cases

| Case | Expected Behavior |
|------|-------------------|
| Usuario ordena explícitamente "reintentar" tras un TDD Failure Report | El contador de intentos se resetea y el protocolo vuelve a aplicar (nuevo ciclo de 3) |
| Tarea marcada "no aplica" para tests | No aplica el protocolo de fallo (no hay test que falle), pero sí la detención explícita tras completar |
| El test falla en el intento 1 o 2 | El agente analiza el error, corrige y reintenta — no genera reporte ni se detiene |
| Fallo en tareas de documentación (sin runner) | Se aplica el fallback de verificación estática del skill `verify`; el fallo se reporta igualmente |

### Estimación
Complejidad: S
Justificación: Dos archivos de documentación del framework con cambios acotados y bien delimitados; no hay código ejecutable ni lógica nueva.

### Riesgo
Nivel: Bajo
Motivo: Son cambios a instrucciones de agentes (docs). El único riesgo real es contradecir el ciclo TDD existente, mitigado por el acotamiento explícito del plan: "no se reescribe ese ciclo aquí, solo se añade lo que falta".

### Dependencias
Tickets relacionados: M-302 depende de M-301 (comparten el mismo punto de parada en `build-agent.md`). Ambos se implementan en el mismo change `tdd-failure-protocol`. Beneficiario futuro: M-901 (gate duro de commit) consumirá la evidencia TDD que este protocolo garantiza.

### Alternativas descartadas
- Alternativa: Implementar el límite de 3 intentos como gate automático en `specboot.sh` (script)
  Motivo del descarte: El protocolo es conductual del agente durante `/apply`, no verificable por script estático; además rompería el alcance `minor` documental del ticket.
- Alternativa: Reescribir el ciclo RED-GREEN-REFACTOR completo en `build-agent.md`
  Motivo del descarte: El plan M-301 lo prohíbe explícitamente — la auditoría M-001 verificó que el ciclo ya existe; solo se añade el protocolo de fallo como extensión.

### Technical Considerations

- ⚠️ **Corrección de ruta detectada durante el análisis**: el `tasks.md` del change referenciaba `ai-specs/skills/apply/SKILL.md`, que **no existe**. El flujo real de `/apply` vive en `.opencode/commands/apply.md`. Los `Suggested Path` deben corregirse a `.opencode/commands/apply.md` y `ai-specs/agents/build-agent.md` antes de `/apply` (regla base-standards §7: artefactos primero, luego código).
- `build-agent.md` es referenciado por `{file:...}` desde `opencode.json` — los cambios de contenido no rompen `check-refs.sh` (solo valida existencia del archivo).
- La plantilla `TDD Failure Report` debe ser copiable como bloque de código para que el agente la emita tal cual en su reporte.
- No hay cambios de API, data model ni base de datos.

### Definition of Done

- [ ] `.opencode/commands/apply.md` incluye el protocolo de 4 pasos y la plantilla `TDD Failure Report`
- [ ] `ai-specs/agents/build-agent.md` referencia el límite de 3 intentos como extensión de su ciclo TDD
- [ ] `ai-specs/agents/build-agent.md` incluye el paso final "detener y reportar"
- [ ] Ejemplo del `TDD Failure Report` en `ai-specs/examples/tasks.md`
- [ ] `bash check-refs.sh` y `bash specboot.sh --ci` con 0 errores
- [ ] Artefactos OpenSpec actualizados (scenarios, requirements, tasks corregidos)

### Questions for Clarification

1. Ninguna pendiente — el alcance está completamente acotado por `PLAN_MEJORAS_SPECBOOT.md` (Fase 3, M-301 y M-302).

---

**Capas afectadas**: docs

*Generated from `ai-specs/skills/enrich-us/SKILL.md` — Fase 3 del plan de mejoras.*
