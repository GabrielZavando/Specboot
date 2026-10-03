# Tasks — SPECBOOT-PREC-01: permission-baseline

> Rastro: REQ-### ↔ SC-### definidos en `requirements.md` / `scenarios.md`.
> `.specboot.json` declara `services: ["."]` (el servicio es la raíz del repo)
> y `stack: framework`: los paths usan las carpetas reales del framework
> (`tests/`, `scripts/`, `docs/`, `openspec/state/`).

## Mandatory Steps

Esta checklist es **obligatoria, no sugerida**. Aplica a toda tarea de
implementación ejecutada vía `/apply`, tanto en el propio framework Specboot
(dogfooding) como en cualquier proyecto consumidor.

### Pre-implementación

Antes de escribir la primera línea de la tarea actual:

- [x] La **rama activa** sigue la convención vigente del proyecto (ej.
  `feature/*`, `fix/*`); trabajar sobre ella, nunca directamente sobre la rama
  principal.
- [x] Estado **git limpio**: sin cambios sin commitear (ni staged) antes de
  empezar; si hay trabajo en curso, resolverlo primero.

### Durante la implementación

- [x] **Test nuevo que falla antes de implementar (RED)**: escribir el test del
  escenario (`SC-NNN`) y verificar que falla antes de escribir código de
  producción.
- [x] Ejecutar los **tests unitarios del módulo** tocado mientras se itera
  (ciclo RED-GREEN-REFACTOR), no solo al final.

### Post-implementación

Antes de dar la tarea por cerrada:

- [x] **Ejecutar `verify`**: la verificación del change corre y produce
  evidencia persistente (`openspec/state/verify-results.json`).
- [ ] **Ejecutar `adversarial-review`**: la auditoría adversarial corre y
  produce veredicto persistente (`openspec/state/adversarial-result.json`).

> Ambos pasos post alimentan los gates duros de `/commit` (M-901): sin
> `PASS` + `SHIP` vigentes para el change activo, el commit bloquea.

### Nota de plan (excepción confirmada por el usuario)

- [ ] `openspec/tickets/SPECBOOT-PREC-01-enriched.md` permanece **sin
  commitear** durante el ciclo (decisión explícita del usuario tras el
  stash/rama): se incluirá en el commit final junto con la implementación.
  No commitearlo antes ni hacer stash de nuevo. El ítem "Estado git limpio"
  de Pre-implementación aplica al resto del árbol de trabajo; este único
  archivo untracked es la excepción acordada.

---

## 1. Línea base reproducible: snapshot y prueba de regresión (REQ-001, REQ-002, REQ-003)

Prioridad: alta | Capa: infrastructure | Estimación: media

Componentes: `BaselineSnapshot`, `BaselineCapabilitiesTest`

- [x] 1.1 Test RED: escribir `tests/baseline-capabilities-test.sh` con aserciones de que el snapshot del baseline existe y carga (SC-001) y de que el validador de permisos corre limpio contra los agentes reales (SC-002, SC-003); ejecutarlo y verificar que FALLA antes de crear el snapshot (aún no existe).
- [x] 1.2 GREEN: registrar el entorno en `openspec/state/` (datos crudos JSON): versión de Specboot (0.11.1), versión/configuración de OpenCode (`opencode.json`: provider OmniRoute, sin campo `model`) y OpenSpec, modelo usado, comandos de prueba y SHA de `main` (b252a63). Sin credenciales: la `apiKey` es `{env:OMNIROUTE_API_KEY}`; nunca registrar su valor.
- [x] 1.3 GREEN: ejecutar los validadores existentes y conservar resultados reales en `openspec/state/`: `scripts/validate-agent-permissions.mjs`, `scripts/validate-command-contracts.mjs`, `bash specboot.sh --ci`, `bash tests/run-all.sh`. Si un validador falla o no puede ejecutarse, registrar el fallo real tal cual (REQ-002).
- [x] 1.4 GREEN: escribir el reporte humano en `docs/` (metodología, cómo reproducirlo, conclusiones de la línea base), actualizado junto con el resto del cambio, no después.

Suggested Path: `docs/baseline/specboot-prec-01-baseline.md`, `openspec/state/baseline/*.json`
Test Path: `tests/baseline-capabilities-test.sh`

## 2. Fixtures negativas de regresión (REQ-004, REQ-005)

Prioridad: alta | Capa: infrastructure | Estimación: baja

Componente: `RegressionFixtureSet`

- [x] 2.1 Mapeo SC-011: verificar cobertura existente (`bad-ownership` cubre ownership de staging, `bad-force-push` cubre force-push, `bad-excess-scope` cubre alcance de edición) y documentar qué casos negativos del ticket ya están cubiertos.
- [x] 2.2 Test RED: añadir a `tests/baseline-capabilities-test.sh` aserciones para los casos NO cubiertos — build escribe evidencia ajena (SC-004), verify/reviewer editan código (SC-005), commit lanza subagentes (SC-007); verificar que fallan porque las fixtures no existen.
- [x] 2.3 GREEN: crear las fixtures que falten derivadas de `good/` con UNA regresión deliberada cada una (p. ej. `bad-build-evidence/`, `bad-reviewer-edit-code/`, `bad-commit-subagents/`); verificar que el validador falla sobre cada una señalando agente + capability + regla.
- [x] 2.4 Iteración post-verify (base-standards §7): añadir aserciones etiquetadas `[SC-011]` y `[SC-012]` a `tests/baseline-capabilities-test.sh` (cobertura fuerte de evidencia, convención build-agent de nombres públicos con SC-NNN): SC-011 = reutilización de fixtures sin duplicados (mapeo SC-011 del header); SC-012 = permission blocks, manifiesto y `opencode.json` intactos (los scripts del baseline no escriben sobre ellos). Guardias de regresión: pasan hoy y deben seguir pasando — REQ-005, REQ-008.

Suggested Path: `tests/fixtures/permission-contracts/bad-build-evidence/`, `tests/fixtures/permission-contracts/bad-reviewer-edit-code/`, `tests/fixtures/permission-contracts/bad-commit-subagents/`
Test Path: `tests/baseline-capabilities-test.sh`

## 3. Benchmark semimanual: script auxiliar y plantilla de registro (REQ-006, REQ-007)

Prioridad: media | Capa: infrastructure | Estimación: baja

Componente: `BenchmarkRecorder`

- [x] 3.1 Test RED: escribir `tests/benchmark-recorder-test.sh` — aserciones de que el script auxiliar existe y ejecuta los validadores de permisos existentes, que la plantilla de registro existe con etiqueta `aproximación_de_volumen` y campos duración/llamadas/reintentos/resultado de calidad/bytes; verificar que FALLA antes de implementar.
- [x] 3.2 GREEN: implementar el script auxiliar sencillo en `scripts/` que ejecuta los validadores de permisos existentes. Sin orquestador automatizado (SPECBOOT-REL-01).
- [x] 3.3 GREEN: crear la plantilla de registro (JSON/Markdown) en `openspec/state/` donde se asientan los tiempos de ejecución y los bytes medidos al correr `/adversarial-review` y `/archive` sobre un par de cambios representativos; etiqueta `aproximación_de_volumen` explícita; prohibido calcular o estimar tokens matemáticamente (REQ-006).

Suggested Path: `scripts/benchmark-permissions.mjs`, `openspec/state/benchmark/registro-inicial.md`
Test Path: `tests/benchmark-recorder-test.sh`

## 4. Cambios representativos para el benchmark (REQ-009)

Prioridad: media | Capa: infrastructure | Estimación: baja

Componente: `RepresentativeChangeSet`

- [x] 4.1 Crear el par de cambios representativos como fixtures deterministas (backend, frontend, framework y documentación) incluyendo los tres escenarios del ticket: reanudación de sesión, evidencia ausente y modificación posterior a una verificación.
- [x] 4.2 Verificar que la plantilla de registro del benchmark referencia el par de cambios representativos (trazabilidad template ↔ fixtures).

Suggested Path: `tests/fixtures/benchmark-changes/`
Test Path: `tests/benchmark-recorder-test.sh`

## 5. Ejecución del benchmark inicial (REQ-006, REQ-007)

Prioridad: media | Capa: infrastructure | Estimación: baja

Componentes: `BenchmarkRecorder` (ejecución), `RepresentativeChangeSet` (entrada)

- [x] 5.1 Con confirmaciones del usuario, correr `/adversarial-review` y `/archive` sobre el par de cambios representativos y asentar en la plantilla: duración, llamadas, reintentos, resultado de calidad y bytes medidos, etiquetados como `aproximación_de_volumen` (SC-010).
- [x] 5.2 Registrar las conclusiones del benchmark inicial en el reporte humano de `docs/` (metodología aplicada y resultados), manteniendo datos crudos en `openspec/state/` (separación estricta, REQ-001).

Suggested Path: `openspec/state/benchmark/registro-inicial.md`
Test Path: no aplica (registro semimanual de ejecución; su estructura la valida `tests/benchmark-recorder-test.sh`)
