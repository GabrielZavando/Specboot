# Scenarios: Dogfooding — desarrollar Specboot con Specboot

## Acceptance Criteria

### Scenario 1: README documenta el flujo dogfooding del framework
- Given el README del framework
- When se añade la sección "Desarrollar Specboot con Specboot (Dogfooding)"
- Then describe los pasos del flujo: rama `feature/ticket-X.Y-descripcion` desde `main`, `/plan-change` → `/apply` → `/verify` → `/archive` → `/commit`, validación con `bash scripts/dogfood-check.sh`, y la regla de "un PR por fase"

### Scenario 2: scripts/dogfood-check.sh corre las dos validaciones y pasa en repo limpio
- Given el repo de Specboot en estado limpio (check-refs y specboot --ci en verde)
- When se ejecuta `bash scripts/dogfood-check.sh`
- Then ejecuta `check-refs.sh` y luego `specboot.sh --ci` en orden y termina con éxito (exit 0)

### Scenario 3: scripts/dogfood-check.sh aborta si check-refs.sh falla
- Given un estado donde `check-refs.sh` reporta errores (exit != 0)
- When se ejecuta `bash scripts/dogfood-check.sh`
- Then el script aborta (exit != 0) y no continúa a `specboot.sh --ci` (por `set -e`)

### Scenario 4: scripts/dogfood-check.sh aborta si specboot.sh --ci falla
- Given un estado donde `check-refs.sh` pasa pero `specboot.sh --ci` falla (exit != 0)
- When se ejecuta `bash scripts/dogfood-check.sh`
- Then el script aborta (exit != 0)

### Scenario 5: Sin regresión en las validaciones del framework
- Given el cambio aplicado al repo
- When se ejecutan `bash check-refs.sh`, `bash specboot.sh --ci` y `make ci`
- Then las tres reportan 0 errores (el script y la sección de README no introducen referencias rotas ni rompen el gate del proyecto)

### Scenario 6: El test TDD del script pasa en verde
- Given `tests/dogfood-check-test.sh`
- When corre
- Then afirma que `scripts/dogfood-check.sh` existe, es ejecutable, y su ejecución termina con exit 0
