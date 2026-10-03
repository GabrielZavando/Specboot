# Scenarios — SPECBOOT-PREC-01: permission-baseline

> Fuente: `openspec/tickets/SPECBOOT-PREC-01-enriched.md` (mapeo 1:1 de sus
> criterios de aceptación, IDs `SC-{NNN}` preservados).
>
> Entidades/endpoints: no aplica — el feature es trabajo de framework
> (tests/scripts/docs); no hay entidades de dominio ni endpoints de API que
> verificar contra data-model o api-spec.

### SC-001: Baseline reproducible registrado (happy path)
- Given el repositorio en el estado más reciente de `main` (SHA `b252a63`)
- When se crea la rama `feature/specboot-prec-01-baseline` y se registra el entorno
- Then existe un baseline identificado por el SHA de `main` con versión de Specboot (0.11.1), versión/configuración de OpenCode/OpenSpec, modelo usado y comandos de prueba, sin credenciales, con separación estricta: reporte humano en `docs/` y datos crudos en `openspec/state/`

### SC-002: Validadores existentes ejecutados con resultados reales
- Given los validadores y controles obligatorios del repositorio
- When se ejecutan `scripts/validate-agent-permissions.mjs`, `scripts/validate-command-contracts.mjs`, `bash specboot.sh --ci` y `bash tests/run-all.sh`
- Then los resultados reales se conservan en `openspec/state/` y ningún éxito se atribuye a pruebas no ejecutadas

### SC-003: Matriz de permisos sin diferencias
- Given el baseline registrado
- When se comparan las capacidades efectivas de los 9 agentes contra la referencia (vía `scripts/validate-agent-permissions.mjs`)
- Then el resultado es 0 deltas en edición, comandos, delegación, ownership de evidencia y Git

### SC-004: Regresión detectada — build escribe evidencia ajena
- Given una fixture derivada de `tests/fixtures/permission-contracts/good/` donde build permite escribir `openspec/state/verify-results.json`
- When se ejecuta la prueba de regresión contra esa fixture
- Then falla señalando la violación de ownership de evidencia (agente + capability + regla)

### SC-005: Regresión detectada — verify/reviewer editan código
- Given una fixture donde verify o reviewer obtienen allow general de edición (relajación de `docs/**`/`src/**`)
- When se ejecuta la prueba de regresión
- Then falla señalando el alcance de edición excedido

### SC-006: Regresión detectada — archive stagea
- Given una fixture donde archive obtiene `git add`/`git commit` permitidos
- When se ejecuta la prueba de regresión
- Then falla señalando la violación de ownership de staging (reutilizando `bad-ownership` si su semántica ya lo cubre)

### SC-007: Regresión detectada — commit lanza subagentes
- Given una fixture donde el agente commit declara `task.allow` no vacío
- When se ejecuta la prueba de regresión
- Then falla porque un agente con `can_spawn_subagents=false` resuelve allow para un subagente

### SC-008: Variantes cubiertas de force-push continúan prohibidas
- Given las variantes cubiertas (`--force*`, `--force-with-lease*`, `-f*`, `*-f*` y compuestos con separadores `;`, `&&`, `||`, `|`, newline)
- When se evalúan los permisos efectivos
- Then todas resuelven `deny`, y una fixture que las relaje hace fallar la prueba (reutilizando `bad-force-push` si ya lo cubre)

### SC-009: Métricas etiquetadas como aproximación de volumen
- Given el proceso actual es una caja negra y los agentes no tienen permisos para consultar APIs de billing/usage del proveedor
- When se registran las métricas del ciclo (tamaño de prompts y respuestas)
- Then solo se registra la aproximación de volumen (bytes/caracteres de entrada y salida) etiquetada explícitamente como `aproximación_de_volumen`, y nunca se calcula ni estima tokens matemáticamente

### SC-010: Benchmark inicial semimanual completo
- Given el script auxiliar sencillo en `scripts/` que ejecuta los validadores de permisos existentes y la plantilla de registro (JSON/Markdown)
- When se corren `/adversarial-review` y `/archive` sobre un par de cambios representativos y se asientan los resultados
- Then la plantilla registra duración, llamadas, reintentos, resultado de calidad y bytes medidos, etiquetados como `aproximación_de_volumen`

### SC-011: Reutilización de fixtures y pruebas existentes
- Given las fixtures negativas ya existentes (`bad-ownership`, `bad-force-push`, `bad-excess-scope`, `bad-catchall`, `bad-missing-required`, `bad-unknown-agent`)
- When se mapea cada caso negativo del ticket a cobertura existente o nueva
- Then solo se añaden las fixtures que falten, sin duplicar cobertura

### SC-012: Sin ampliación indirecta de capacidades
- Given los scripts del baseline y del benchmark (permitidos por `opencode.json`)
- When se auditan sus efectos
- Then ningún agente gana capacidades indirectamente: el harness no añade allows, no toca permission blocks ni relaja el manifiesto

## Edge Cases

| Case | Expected Behavior |
|------|-------------------|
| Los agentes no tienen permisos para consultar APIs de billing/usage del proveedor | Registrar solo `aproximación_de_volumen` (bytes/caracteres de prompts y respuestas); nunca calcular ni estimar tokens matemáticamente |
| Sesión interrumpida a mitad del ciclo | Escenario de reanudación incluido en los cambios representativos; se registra el estado de reanudación sin fabricar métricas |
| Evidencia ausente (`verify-results.json` no existe) | Caso representativo: el ciclo falla fail-closed o lo registra; no se fabrica éxito |
| Modificación de código tras una verificación | Escenario post-verify: la evidencia queda desactualizada y el delta se detecta |
| Un validador falla durante el baseline | Se conserva el fallo real en el registro; no se atribuye éxito a pruebas no ejecutadas |
| Fixture negativa duplicaría cobertura existente | Reutilizar la fixture existente; añadir solo la faltante (SC-011) |
| Variante de force-push no cubierta por patrones | Queda gobernada por `can_run_arbitrary_code` y la nota de defensa en profundidad del manifiesto; NO se amplían patrones en este feature |
