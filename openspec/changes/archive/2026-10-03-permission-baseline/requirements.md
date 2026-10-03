# Requirements — SPECBOOT-PREC-01: permission-baseline

> Cada requisito es trazable a al menos un escenario de `scenarios.md`
> (fuente: `openspec/tickets/SPECBOOT-PREC-01-enriched.md`).

## REQ-001: Línea base reproducible con separación estricta de ubicación

El baseline queda identificado por el SHA de `main` al iniciar el feature y registra versión de Specboot, versión/configuración de OpenCode/OpenSpec, modelo usado y comandos de prueba, sin credenciales. `docs/` aloja el reporte legible por humanos (metodología, cómo reproducirlo, conclusiones de la línea base); `openspec/state/` aloja los datos crudos (JSONs con métricas, tiempos, bytes y resultados de validadores) para consumo futuro del framework.

**Escenarios**: SC-001, SC-002

## REQ-002: Resultados reales conservados

Los validadores existentes (`scripts/validate-agent-permissions.mjs`, `scripts/validate-command-contracts.mjs`) y los controles obligatorios (`bash specboot.sh --ci`, `bash tests/run-all.sh`) se ejecutan y sus resultados reales se conservan; ningún éxito se atribuye a pruebas no ejecutadas. Si un validador falla, el fallo real se registra tal cual.

**Escenarios**: SC-002 (edge: un validador falla durante el baseline)

## REQ-003: Matriz de capacidades efectivas sin diferencias

La prueba de regresión compara las capacidades efectivas de los 9 agentes (edición, comandos permitidos/prohibidos, delegación `task`, ownership de evidencia y Git) contra la referencia registrada, fallando ante cualquier delta.

**Escenarios**: SC-003

## REQ-004: Casos negativos detectan regresiones deliberadas

La prueba de regresión falla al introducir deliberadamente una regresión en fixtures (una regresión por fixture): build escribe evidencia ajena, verify/reviewer editan código, archive stagea, commit lanza subagentes, variantes cubiertas de force-push se relajan.

**Escenarios**: SC-004, SC-005, SC-006, SC-007, SC-008

## REQ-005: Reutilización de fixtures y pruebas existentes

Las fixtures y pruebas existentes (`bad-ownership`, `bad-force-push`, `bad-excess-scope`, `bad-catchall`, `bad-missing-required`, `bad-unknown-agent`) se reutilizan cuando sea posible; solo se añaden las faltantes, sin duplicar cobertura.

**Escenarios**: SC-011

## REQ-006: Métricas solo como aproximación de volumen

El registro de métricas usa únicamente la aproximación por volumen (bytes/caracteres de entrada y salida de prompts y respuestas), etiquetada explícitamente como `aproximación_de_volumen` en todos los artefactos; prohibido calcular o estimar tokens matemáticamente. Los agentes no tienen permisos para consultar APIs de billing/usage del proveedor externo.

**Escenarios**: SC-009

## REQ-007: Benchmark semimanual con plantilla de registro

El benchmark inicial es semimanual: script auxiliar sencillo en `scripts/` que ejecuta los validadores de permisos existentes + plantilla de registro (JSON/Markdown) donde se asientan duración, llamadas, reintentos, resultado de calidad y bytes medidos al correr `/adversarial-review` y `/archive` sobre un par de cambios representativos. No se construye un orquestador de benchmarks automatizado (corresponde a SPECBOOT-REL-01).

**Escenarios**: SC-010

## REQ-008: Sin ampliación indirecta de capacidades

Ningún agente gana capacidades indirectamente mediante scripts del baseline o del benchmark; los permission blocks (`.opencode/agents/*.md`) y el manifiesto `docs/agent-permission-contracts.yml` quedan intactos (solo lectura durante todo el feature).

**Escenarios**: SC-012

## REQ-009: Cambios representativos para el benchmark

Un conjunto pequeño de cambios representativos (backend, frontend, framework y documentación) como fixtures deterministas, incluyendo reanudación de sesión, evidencia ausente y modificaciones posteriores a una verificación.

**Escenarios**: SC-010 (edge: reanudación, evidencia ausente, post-verify)
