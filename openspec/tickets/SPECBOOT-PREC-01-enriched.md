# User Story enriched: SPECBOOT-PREC-01 — Línea base y protección de permisos

> Artefacto generado por `/enrich-us` (skill `enrich-us`, Step 11) tras
> confirmación del usuario, con las preguntas de clarificación resueltas por
> el usuario (sección `Respuestas a las Preguntas de Clarificación`). Contrato
> con `/plan-change`: ese comando detecta este archivo y lo usa como fuente
> primaria (criterios de aceptación, diseño de componentes, edge cases) en
> lugar del título crudo del ticket. Las resoluciones son vinculantes.

## User Story enriched: SPECBOOT-PREC-01

**As a** mantenedor del framework Specboot
**I want** una línea base reproducible del ciclo SDD y una prueba de regresión que fiscalice los permisos efectivos de los agentes contra esa referencia
**So that** las optimizaciones futuras de tokens y tiempo de ejecución sean medibles contra una referencia congelada y ninguna capacidad de agente pueda alterarse sin detección

### Context

El ciclo SDD actual es una caja negra: no existen métricas reales de tokens, tiempo, llamadas ni reintentos, y cualquier optimización futura podría alterar los permisos efectivos de los agentes sin que nada lo detecte. Este feature es un **precursor** (PREC-01): establece la referencia y la protección **antes** de optimizar. Se apoya en la infraestructura ya existente en `main` —el validador `scripts/validate-agent-permissions.mjs` (semántica `last-match-wins` de OpenCode, fiscalización de `edit`/`bash`/`task`/bypasses compuestos), el manifiesto `docs/agent-permission-contracts.yml` (9 agentes, 5 flags de capacidad) y las fixtures negativas de `tests/fixtures/permission-contracts/`— sin modificarlos. El baseline queda identificado por el SHA de `main` al iniciar el feature, en una rama nueva y limpia (p. ej. `feature/specboot-prec-01-baseline`).

**Alcance** (del ticket original, confirmado en el enriquecimiento):

- Trabajar sobre la versión más reciente de la rama `main` del repositorio.
- Crear una rama nueva y limpia para este feature (ej. `feature/specboot-prec-01-baseline`).
- Registrar versión de Specboot, versión/configuración de OpenCode/OpenSpec, modelo usado y comandos de prueba utilizados. No registrar credenciales.
- Ejecutar los validadores existentes, incluyendo `scripts/validate-agent-permissions.mjs` y `scripts/validate-command-contracts.mjs`, además de los controles obligatorios del repositorio.
- Conservar resultados reales; no atribuir éxito a pruebas que no se ejecutaron.
- Crear una prueba de regresión que compare las capacidades efectivas con la base: edición, comandos permitidos/prohibidos, delegación, ownership de evidencia y Git.
- Añadir casos negativos relevantes: build no escribe evidencia ajena; verify/reviewer no editan código; archive no stagea; commit no lanza subagentes; las variantes cubiertas de force-push continúan prohibidas.
- Preparar un conjunto pequeño de cambios representativos: backend, frontend, framework y documentación. Incluir reanudación, evidencia ausente y modificaciones posteriores a una verificación.
- Registrar tokens de entrada/salida y cacheados si el proveedor los expone. Si solo hay bytes disponibles, etiquetarlos como aproximación de volumen, nunca como tokens medidos. *(Resuelto en clarificación: solo se registra la aproximación por volumen — ver Respuestas.)*

**Fuera de alcance**: cambiar permisos, modelos, roles o etapas; optimizar prompts, contexto o salidas; implementar mejoras de velocidad; tocar staging/commit fuera de las pruebas de permisos; cambiar permission blocks ni relajar el manifiesto para que una prueba pase; ampliar indirectamente capacidades mediante scripts ya permitidos; construir un orquestador de benchmarks automatizado (corresponde a SPECBOOT-REL-01).

**Invariantes**: una tarea a la vez; confirmaciones del usuario; separación de responsabilidades; permisos efectivos de cada agente; ningún agente gana capacidades indirectamente mediante scripts permitidos.

**Resoluciones de clarificación** (vinculantes para `/plan-change`): las tres preguntas pendientes fueron resueltas por el usuario — ver sección `Respuestas a las Preguntas de Clarificación` al final de este artefacto.

### Diseño de Clases/Componentes

- `BaselineSnapshot` (reporte humano + datos crudos): responsabilidad única = "registrar y congelar el entorno reproducible del ciclo con separación estricta de ubicación: en `docs/` el reporte legible por humanos (metodología, cómo reproducirlo, conclusiones de la línea base) y en `openspec/state/` los datos crudos (JSONs con métricas, tiempos, bytes y resultados de validadores) para consumo futuro del framework; incluye versión de Specboot, versión/configuración de OpenCode/OpenSpec, modelo usado, comandos de prueba y SHA de `main`, sin credenciales".
  - Depende de: ejecución de `scripts/validate-agent-permissions.mjs`, `scripts/validate-command-contracts.mjs` y controles obligatorios (`bash specboot.sh --ci`, `bash tests/run-all.sh`), NO de métricas derivadas ni de optimizaciones futuras.
  - Capa: infrastructure
- `BaselineCapabilitiesTest` (p. ej. `tests/baseline-capabilities-test.sh`): responsabilidad única = "comparar las capacidades efectivas (edición, comandos permitidos/prohibidos, delegación `task`, ownership de evidencia y Git) de cada agente contra la línea base registrada, fallando ante cualquier delta".
  - Depende de: `scripts/validate-agent-permissions.mjs` + `docs/agent-permission-contracts.yml` (reutilización de su semántica), NO de un parser de permisos nuevo ni de búsquedas de texto sobre los `.md`.
  - Capa: infrastructure
- `RegressionFixtureSet` (p. ej. `tests/fixtures/permission-contracts/bad-build-evidence/`, `bad-reviewer-edit-code/`, `bad-commit-subagents/`): responsabilidad única = "demostrar que la prueba de regresión detecta regresiones deliberadas en fixtures (una regresión por fixture, derivadas de `good/`)".
  - Depende de: fixtures y validador existentes, NO de modificación del manifiesto real ni de los permission blocks.
  - Capa: infrastructure
- `BenchmarkRecorder` (script auxiliar en `scripts/` + plantilla de registro en `openspec/state/`): responsabilidad única = "ejecutar los validadores de permisos existentes y proveer la plantilla semimanual de registro (JSON/Markdown) donde se asientan tiempos de ejecución, llamadas, reintentos y bytes medidos al correr `/adversarial-review` y `/archive` sobre un par de cambios representativos".
  - Depende de: `scripts/validate-agent-permissions.mjs`, `scripts/validate-command-contracts.mjs` y controles obligatorios existentes, NO de un orquestador de benchmarks automatizado (corresponde a SPECBOOT-REL-01).
  - Capa: infrastructure
- `RepresentativeChangeSet` (p. ej. `tests/fixtures/benchmark-changes/{backend,frontend,framework,docs}/`): responsabilidad única = "proveer escenarios de benchmark pequeños y deterministas: cambio normal, reanudación de sesión, evidencia ausente y modificación posterior a una verificación; el benchmark inicial corre sobre un par de ellos con `/adversarial-review` y `/archive`".
  - Depende de: fixtures controladas, NO de cambios reales de producción.
  - Capa: infrastructure

### Acceptance Criteria

### SC-001: Baseline reproducible registrado (happy path)
- Given el repositorio en el estado más reciente de `main`
- When se crea la rama del feature y se registra el entorno
- Then existe un baseline identificado por el SHA de `main` con versión de Specboot, versión/configuración de OpenCode/OpenSpec, modelo usado y comandos de prueba, sin credenciales

### SC-002: Validadores existentes ejecutados con resultados reales
- Given los validadores y controles obligatorios del repositorio
- When se ejecutan `validate-agent-permissions.mjs`, `validate-command-contracts.mjs`, `bash specboot.sh --ci` y `bash tests/run-all.sh`
- Then los resultados reales se conservan en el baseline y ningún éxito se atribuye a pruebas no ejecutadas

### SC-003: Matriz de permisos sin diferencias
- Given el baseline registrado
- When se comparan las capacidades efectivas de los 9 agentes contra la referencia
- Then el resultado es 0 deltas en edición, comandos, delegación, ownership de evidencia y Git

### SC-004: Regresión detectada — build escribe evidencia ajena
- Given una fixture derivada de `good/` donde build permite escribir `openspec/state/verify-results.json`
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

### Edge Cases

| Case | Expected Behavior |
|------|-------------------|
| Los agentes no tienen permisos para consultar APIs de billing/usage del proveedor | Registrar solo `aproximación_de_volumen` (bytes/caracteres de prompts y respuestas); nunca calcular ni estimar tokens matemáticamente |
| Sesión interrumpida a mitad del ciclo | Escenario de reanudación incluido en los cambios representativos; se registra el estado de reanudación sin fabricar métricas |
| Evidencia ausente (`verify-results.json` no existe) | Caso representativo: el ciclo falla fail-closed o lo registra; no se fabrica éxito |
| Modificación de código tras una verificación | Escenario post-verify: la evidencia queda desactualizada y el delta se detecta |
| Un validador falla durante el baseline | Se conserva el fallo real en el registro; no se atribuye éxito a pruebas no ejecutadas |
| Fixture negativa duplicaría cobertura existente | Reutilizar la fixture existente; añadir solo la faltante (SC-011) |
| Variante de force-push no cubierta por patrones | Queda gobernada por `can_run_arbitrary_code` y la nota de defensa en profundidad del manifiesto; NO se amplían patrones en este feature |

### Estimación
Complejidad: M
Justificación: cinco componentes acotados con alta reutilización (validador, fixtures, `run-all.sh`); el benchmark es semimanual (script auxiliar sencillo + plantilla), lo que descarta el orquestador. Sin cambios en el código de producción del framework.

### Riesgo
Nivel: Medio
Motivo: feature protector sobre el propio sistema de permisos — el mayor riesgo es "arreglar" una prueba relajando permisos o el manifiesto (explícitamente prohibido). La dependencia de métricas del proveedor quedó resuelta por diseño (solo aproximación de volumen, sin tokens). Mitigable con fail-closed, etiquetado honesto y el invariante de no-relajación.

### Dependencias
Tickets relacionados: SPECBOOT-PERM-01 y SPECBOOT-HARDEN-02 (ya en `main`: validador, manifiesto y fixtures existen — sin dependencia bloqueante nueva). Precursor de las optimizaciones de tokens/tiempo (PREC-02+); el orquestador automatizado de benchmarks queda para SPECBOOT-REL-01.

### Alternativas descartadas
- Alternativa: implementar la optimización de tokens en el mismo feature.
  Motivo del descarte: declarada fuera de alcance; sin línea base las optimizaciones no son medibles y podrían alterar permisos sin detección.
- Alternativa: crear un parser de permisos nuevo para la prueba de regresión.
  Motivo del descarte: duplicaría la semántica `last-match-wins` ya implementada y auditada en `validate-agent-permissions.mjs`; reutilizar evita divergencias.
- Alternativa: relajar permission blocks o el manifiesto para que los casos negativos pasen.
  Motivo del descarte: viola el invariante de permisos efectivos; las fixtures negativas deben fallar al introducir la regresión, no al revés.
- Alternativa: benchmark con cambios reales de producción.
  Motivo del descarte: no determinista ni reproducible; los cambios representativos en fixtures son pequeños y controlados.
- Alternativa: construir un orquestador de benchmarks automatizado.
  Motivo del descarte: corresponde al ticket final SPECBOOT-REL-01; en PREC-01 basta el registro semimanual con plantilla.

### Technical Considerations

- Rama nueva y limpia desde `main` más reciente; el SHA de `main` al iniciar queda registrado en el baseline.
- Separación estricta de ubicación del baseline: `docs/` aloja el reporte legible por humanos (metodología, cómo reproducirlo, conclusiones de la línea base); `openspec/state/` aloja los datos crudos (JSONs con métricas, tiempos, bytes y resultados de validadores) para consumo futuro del framework.
- Solo lectura sobre `.opencode/agents/*.md` y `docs/agent-permission-contracts.yml`: prohibido modificar permission blocks o relajar el manifiesto para que una prueba pase.
- No re-implementar el parseo de patrones (`*`, `?`) ni la semántica `last-match-wins`: la prueba de regresión invoca al validador existente.
- Casos negativos como fixtures derivadas de `good/` con una regresión deliberada cada una; verificar cobertura existente antes de añadir (SC-011).
- Tests nuevos integrados a `tests/run-all.sh`; `bash specboot.sh --ci` ya fiscaliza contratos de permisos y se ejecuta dentro del baseline.
- Sin credenciales en el registro (solo versiones, configuración, modelo y comandos de prueba).
- Métricas: SOLO aproximación de volumen (bytes/caracteres de entrada y salida, contando el tamaño de prompts y respuestas), etiquetada explícitamente como `aproximación_de_volumen` en todos los artefactos; NUNCA calcular ni estimar tokens matemáticamente. Los agentes no tienen permisos para consultar APIs de billing/usage del proveedor.
- Benchmark semimanual: script auxiliar sencillo en `scripts/` que ejecuta los validadores de permisos existentes + plantilla de registro (JSON/Markdown) para asentar tiempos y bytes al correr `/adversarial-review` y `/archive` sobre un par de cambios representativos. No construir un orquestador automatizado (SPECBOOT-REL-01).
- `js-yaml` se resuelve desde el directorio del script (nota de distribución del validador).
- Sin cambios de API ni de data model (N/A en DoD).

### Definition of Done

- [ ] Tests written and passing (baseline-capabilities + casos negativos)
- [ ] Casos negativos fallan ante regresión deliberada en fixtures (ciclo RED→GREEN documentado)
- [ ] Documentation updated (reporte humano en `docs/` con metodología, reproducción y conclusiones)
- [ ] Code review approved
- [ ] OpenSpec artifacts updated
- [ ] Matriz de permisos sin diferencias vs referencia (verificado por la prueba de regresión)
- [ ] Métricas etiquetadas explícitamente como `aproximación_de_volumen` en el registro del benchmark (sin cálculo matemático de tokens)
- [ ] Script auxiliar y plantilla de registro del benchmark en su lugar (`scripts/` + `openspec/state/`)
- [ ] Tests integrados en `tests/run-all.sh`

**Capas afectadas**: framework, docs (backend/frontend aparecen solo como fixtures de benchmark, sin código de aplicación)

### Respuestas a las Preguntas de Clarificación (resueltas por el usuario)

1. **Ubicación del baseline**: aceptada la propuesta — ambos lugares con separación estricta. `docs/` contiene el reporte legible por humanos (metodología, cómo reproducirlo, conclusiones de la línea base); `openspec/state/` almacena los datos crudos (JSONs con métricas, tiempos, bytes y resultados de validadores) para que el framework pueda consumirlos en el futuro.
2. **Uso de tokens vs. bytes**: el proceso es una caja negra y los agentes no tienen permisos para consultar APIs de billing o usage del proveedor externo. En este feature se registra únicamente la aproximación por volumen (bytes/caracteres de entrada y salida) contando el tamaño de prompts y respuestas, etiquetada explícitamente como `aproximación_de_volumen`. Nunca intentar calcular o estimar tokens matemáticamente.
3. **Automatización del benchmark**: para esta línea base (PREC-01), el benchmark es semimanual con plantilla de registro. Se crea un script auxiliar sencillo (en `scripts/`) que ejecuta los validadores de permisos existentes y una plantilla (JSON/Markdown) donde se asientan los tiempos de ejecución y los bytes medidos al correr `/adversarial-review` y `/archive` sobre un par de cambios representativos. No se construye un orquestador de benchmarks automatizado: eso corresponde al ticket final SPECBOOT-REL-01.
