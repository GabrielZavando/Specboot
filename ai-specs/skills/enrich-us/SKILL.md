# Skill: enrich-us

## Descripción

Analiza y enriquece una user story vaga o ticket de Jira en una descripción lista para implementar, con criterios de aceptación, detalle técnico y edge cases.

Usar ANTES de `/plan-change` para asegurar que el equipo y el agente IA están alineados en el alcance.

## Cuándo usar este skill

- User story con descripción vaga o incompleta
- Ticket sin criterios de aceptación
- Idea nueva que necesita definición antes de planificar

## Proceso

1. Leer el ticket o descripción proporcionada (o fetchar vía Jira MCP si se provee ticket ID)
2. Identificar: ¿qué problema resuelve? ¿quién lo usa? ¿qué casos edge existen?
3. Redactar la user story enriquecida con:
   - **As a** [rol] **I want** [acción] **so that** [beneficio]
   - Criterios de aceptación en formato Gherkin (Given/When/Then)
   - Consideraciones técnicas y constraints
   - Edge cases identificados
   - Definición de Done (DoD)
4. Confirmar con el usuario antes de proceder a `/plan-change`

## Modelo requerido

Ejecutar con el modelo configurado en el plan agent. Verificar config antes de iniciar.

## Output esperado

```markdown
## User Story enriquecida: [TICKET-ID]

**Como** [rol]  
**Quiero** [acción]  
**Para** [beneficio]

### Criterios de aceptación

**Escenario 1: [descripción]**
- Dado que [contexto]
- Cuando [acción]
- Entonces [resultado esperado]

### Consideraciones técnicas
- [constraint o detalle técnico]

### Edge cases
- [caso edge identificado]

### Definición of Done
- [ ] Tests escritos y pasando
- [ ] Documentación actualizada
- [ ] Code review aprobado
- [ ] Specs OpenSpec actualizadas
```
