# Fixtures de cambios representativos para el benchmark — SPECBOOT-PREC-01

> Conjunto pequeño de cambios representativos (REQ-009, SC-010) para el
> benchmark semimanual del ciclo SDD. Deterministas: no dependen de cambios
> reales de producción. El benchmark inicial corre `/adversarial-review` y
> `/archive` sobre un **par** de estas fixtures y asienta las mediciones en
> `openspec/state/benchmark/registro-inicial.md` (etiqueta
> `aproximación_de_volumen` en todos los datos).

## Conjunto

| Fixture | Dominio | Contenido determinista |
|---------|---------|------------------------|
| `backend/` | backend (NestJS/API) | cambio mínimo de servicio + test |
| `frontend/` | frontend (Angular/UI) | cambio mínimo de componente |
| `framework/` | framework (Specboot) | cambio mínimo de test bash |
| `docs/` | documentación | cambio mínimo de sección de doc |

## Escenarios incluidos (los tres del ticket)

El archivo compartido `scenarios.md` documenta las tres condiciones de
medición que el benchmark registra para cada cambio: **reanudación de
sesión**, **evidencia ausente** y **modificación posterior a una
verificación**.

## Selección del par para el benchmark inicial

El benchmark inicial corre sobre un par de estas fixtures (decisión registrada
en la Tarea 5 con confirmación del usuario). Ninguna fixture es código de
producción.
