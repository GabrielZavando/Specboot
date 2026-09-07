# tdd-failure-protocol Specification

## ADDED Requirements

### Requirement: Protocolo explícito ante fallo TDD
- **Descripción**: El flujo de `/apply` SHALL incluir un protocolo de 4 pasos (Detectar → Intentar → Reportar → Detener) cuando un test falle. El agente SHALL generar un `TDD Failure Report` tras 3 intentos fallidos consecutivos.
- **Trazabilidad**: SC-008, SC-009

#### Scenario: TDD Failure Report generado tras 3 fallos
- **Given** una tarea activa siendo implementada por el agente `build`
- **When** un test falla por 3ª vez consecutiva
- **Then** el agente detiene la implementación
- **And** genera un `TDD Failure Report` con los campos: `Task`, `Attempt`, `Error` y `Suggested investigation`

### Requirement: Límite de intentos
- **Descripción**: El agente SHALL detener la implementación de una tarea tras 3 intentos fallidos consecutivos sin passar el test. No SHALL continuar con la siguiente tarea hasta resolver el fallo.
- **Trazabilidad**: SC-008

#### Scenario: Agente se detiene al alcanzar el límite
- **Given** una tarea con 3 intentos fallidos consecutivos
- **When** el agente detecta el 3º fallo
- **Then** se detiene y no continúa con la siguiente tarea

### Requirement: Detención explícita tras completar tarea
- **Descripción**: Tras completar una tarea, el agente SHALL reportar el resultado y esperar instrucción explícita del usuario antes de continuar con la siguiente tarea pendiente.
- **Trazabilidad**: SC-010

#### Scenario: Agente espera instrucción tras completar tarea
- **Given** una tarea completada satisfactoriamente
- **When** el agente marca la tarea como `[x]`
- **Then** el agente reporta el resultado
- **And** espera instrucción explícita del usuario

### Requirement: Plantilla TDD Failure Report
- **Descripción**: El `TDD Failure Report` SHALL incluir los campos: `Task`, `Attempt`, `Error` y `Suggested investigation`.
- **Trazabilidad**: SC-009

#### Scenario: Formato del TDD Failure Report
- **Given** un fallo TDD consecutivo
- **When** el agente genera el reporte
- **Then** el reporte contiene los campos: `Task`, `Attempt`, `Error`, `Suggested investigation`
