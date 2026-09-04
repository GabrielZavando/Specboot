# Change Requirements: tdd-failure-protocol

## REQ-001: Protocolo explícito ante fallo TDD
- **Descripción**: El flujo de `/apply` SHALL incluir un protocolo de 4 pasos (Detectar → Intentar → Reportar → Detener) cuando un test falle. El agente SHALL generar un `TDD Failure Report` tras 3 intentos fallidos consecutivos.
- **Trazabilidad**: SC-008, SC-009

## REQ-002: Límite de intentos
- **Descripción**: El agente SHALL detener la implementación de una tarea tras 3 intentos fallidos consecutivos sin passar el test. No SHALL continuar con la siguiente tarea hasta resolver el fallo.
- **Trazabilidad**: SC-008

## REQ-003: Detención explícita tras completar tarea
- **Descripción**: Tras completar una tarea, el agente SHALL reportar el resultado y esperar instrucción explícita del usuario antes de continuar con la siguiente tarea pendiente.
- **Trazabilidad**: SC-010

## REQ-004: Plantilla TDD Failure Report
- **Descripción**: El `TDD Failure Report` SHALL incluir los campos: `Task`, `Attempt`, `Error` y `Suggested investigation`.
- **Trazabilidad**: SC-009
