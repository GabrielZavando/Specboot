# Acceptance Scenarios: tdd-failure-protocol

### SC-008: Protocolo de detención ante fallo TDD consecutivo
- **Given** una tarea activa siendo implementada por el agente `build`
- **When** un test falla por 3ª vez consecutiva
- **Then** el agente detiene la implementación
- **And** genera un `TDD Failure Report`
- **And** no continúa con la siguiente tarea

### SC-009: Reporte de fallo TDD
- **Given** un fallo TDD consecutivo
- **When** el agente genera el `TDD Failure Report`
- **Then** el reporte incluye: `Task`, `Attempt`, `Error` y `Suggested investigation`

### SC-010: Detención explícita tras completar tarea
- **Given** una tarea completada satisfactoriamente
- **When** el agente marca la tarea como `[x]`
- **Then** el agente reporta el resultado
- **And** espera instrucción explícita del usuario antes de proceder a la siguiente
