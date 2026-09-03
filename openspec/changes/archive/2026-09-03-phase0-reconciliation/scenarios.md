# Scenarios: Fase 0 — Reconciliación del plan y documentación de auth

Los identificadores de escenario siguen la convención `SC-{NNN}`.

## SC-001: Registro verificado de la auditoría M-001
```gherkin
Feature: Auditoría de funcionalidades ya implementadas (M-001)

Scenario: La auditoría queda registrada como verificada en el plan
  Given el documento PLAN_MEJORAS_SPECBOOT.md existe en la raíz del proyecto
  And la sección M-001 contiene la tabla de verificación de tickets originales
  When el change phase0-reconciliation se completa
  Then cada ticket original de la tabla tiene su estado real y acción documentados
  And M-001 queda marcado como completado ([x]) en el plan
```

## SC-002: Documento de autenticación accesible para consumidores
```gherkin
Feature: Autenticación GitHub Packages para consumidores

Scenario: Consumidor del mismo owner/org con acceso concedido
  Given el paquete @gabrielzavando/specboot se publica en GitHub Packages
  And el repositorio consumidor tiene acceso concedido en Package settings
  When el consumidor lee la sección "Autenticación para consumidores (CI)" en README.md
  Then encuentra un snippet YAML que usa secrets.GITHUB_TOKEN con permissions packages: read
  And puede copiar y configurar directamente su workflow de CI

Scenario: Consumidor de owner distinto o sin acceso concedido
  Given el repositorio consumidor no tiene acceso concedido al paquete
  When el consumidor lee la sección "Autenticación para consumidores (CI)" en README.md
  Then encuentra la alternativa de usar un PAT con scope read:packages como secret
  And encuentra las instrucciones equivalentes a las de uso local (.npmrc)
```

## SC-003: Troubleshooting de errores de autenticación
```gherkin
Feature: Diagnóstico de errores de autenticación

Scenario: Error 401 al instalar
  Given un consumidor configura su CI con el snippet del README
  When su flujo de instalación devuelve un error 401
  Then el README explica las causas típicas: falta NODE_AUTH_TOKEN o PAT sin scope read:packages

Scenario: Error 403 al instalar
  Given un consumidor configura su CI con el snippet del README
  When su flujo de instalación devuelve un error 403
  Then el README explica que el repo no tiene acceso concedido en Package settings
  And sugiere gestionar el acceso en Package → Manage Actions access
```

## SC-004: Verificación real del snippet en un repo de prueba
```gherkin
Feature: Verificación del snippet YAML

Scenario: El snippet funciona en un repo real del mismo org
  Given un repositorio de prueba del mismo org con acceso al paquete
  When se configura un workflow con el snippet del README
  Then npm install del paquete @gabrielzavando/specboot se ejecuta sin errores 401/403
```

## SC-005: Marcado de completado del plan
```gherkin
Feature: Marcado de tareas completadas en el plan

Scenario: M-001 y M-002 quedan marcados como completados
  Given las tareas M-001 y M-002 de la Fase 0 están implementadas
  When se actualiza PLAN_MEJORAS_SPECBOOT.md
  Then el encabezado de M-001 muestra [x]
  And el encabezado de M-002 muestra [x]
  And se añade una fila al historial de correcciones documentando el cambio
```
