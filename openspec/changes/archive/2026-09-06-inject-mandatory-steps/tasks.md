# Implementation Tasks: inject-mandatory-steps

> **Nota dogfooding (chicken-and-egg)**: este `tasks.md` fue generado *antes* de
> actualizar el skill `plan-change` (tarea 1.3), por lo que no lleva la sección
> `## Mandatory Steps` inyectada — ver Decisions del proposal. El mecanismo de
> inyección queda verificado por el guard test (tarea 1.1).

## 1. Mandatory steps doc e inyección (M-601 — TDD primero)

- [x] 1.1 Crear el self-test del contrato `tests/mandatory-steps-test.sh` (RED): aserta que `docs/openspec-tasks-mandatory-steps.md` existe con las tres fases (pre: rama según convención + git limpio; durante: test nuevo falla antes de implementar — RED — y tests unitarios del módulo; post: `verify` + `adversarial-review`); que el SKILL `plan-change` instruye inyectar la sección `## Mandatory Steps` en todo `tasks.md` leyendo el doc en el momento de generación (sin copia hardcodeada) y que su checklist Step 6 incluye el check; que `AGENTS.md` §2 referencia el doc; que la distribución está sincronizada (`FRAMEWORK_ITEMS` en `specboot.sh` + allowlist `files` en `package.json`) y el doc NO está en `REQUIRED_FILES`; que `PLAN_MEJORAS_SPECBOOT.md` registra la Fase 10 con M-904..M-907; y que `package.json`/`.specboot.json` declaran `0.6.0` con entrada `## [0.6.0]` en CHANGELOG. Debe fallar (RED) antes de implementar 1.2–1.5 y 2.1–2.3. Asserts con prefijo `[SC-NNN]` (SC-001..SC-007).
  - **Priority**: High
  - **Layer**: tests
  - **Estimate**: M
  - **Suggested Path**: docs/openspec-tasks-mandatory-steps.md
  - **Test Path**: tests/mandatory-steps-test.sh

- [x] 1.2 Crear el documento `docs/openspec-tasks-mandatory-steps.md` (GREEN): encabezado que declare su rol (fuente única de verdad, inyectado por `plan-change` en todo `tasks.md`), las tres fases del ticket M-601 — pre-implementación (rama activa según convención, estado git limpio), durante (tests unitarios del módulo; test nuevo falla antes de implementar, RED), post (ejecutar `verify`, ejecutar `adversarial-review`) — y una nota de que la checklist es obligatoria, no sugerida.
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: docs/openspec-tasks-mandatory-steps.md
  - **Test Path**: tests/mandatory-steps-test.sh

- [x] 1.3 Actualizar `ai-specs/skills/plan-change/SKILL.md` (GREEN): en Step 5, ítem 4 (tasks.md) — instrucción de inyectar la sección `## Mandatory Steps` leyendo `docs/openspec-tasks-mandatory-steps.md` en el momento de generación (sin copiar el contenido al skill); en Step 6 — nuevo check del checklist "tasks.md incluye la sección `## Mandatory Steps`" y regla de no reportar éxito si falla.
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: M
  - **Suggested Path**: ai-specs/skills/plan-change/SKILL.md
  - **Test Path**: tests/mandatory-steps-test.sh

- [x] 1.4 Referenciar el doc desde `AGENTS.md` §2 (Carga dinámica) (GREEN): nota que `docs/openspec-tasks-mandatory-steps.md` es contenido del framework inyectado por `plan-change` en todo `tasks.md` generado y aplica a toda tarea de implementación.
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: AGENTS.md
  - **Test Path**: tests/mandatory-steps-test.sh

- [x] 1.5 Ampliar los self-tests del contrato de distribución (RED, descubrimiento del bug update-docs): `tests/specboot-update-test.sh` — el fixture `make_template` crea el doc (`FW-msteps`) y el Test 2 (minor) aserta `[SC-008]` que tras `update` el proyecto recibe los 6 docs intocables (`docs/openspec-tasks-mandatory-steps.md` y `docs/base-standards.md` representativos) mientras los docs del proyecto permanecen intactos (hoy falla: el patrón `docs/*` del `case` de `replace_framework_files` saltea todos los docs — bug latente contra la spec archivada `specboot-update`); `tests/package-files-test.sh` — `allowedDocs` incluye `docs/openspec-tasks-mandatory-steps.md` (6 docs). Deben fallar antes de 1.6.
  - **Priority**: High
  - **Layer**: tests
  - **Estimate**: S
  - **Suggested Path**: tests/specboot-update-test.sh
  - **Test Path**: tests/specboot-update-test.sh

- [x] 1.6 Sincronizar la distribución del doc y fix del bug update-docs (GREEN, lección M-403): `specboot.sh` → `FRAMEWORK_ITEMS` += `docs/openspec-tasks-mandatory-steps.md`, `UPDATE_ITEMS` += ídem, y fix del `case` de `replace_framework_files` (solo saltea árboles enteros `docs|.github`, ya no `docs/*` — alinea el código con la spec archivada `specboot-update`); `package.json` → allowlist `files` += ídem; `docs/docs-standard.md` → árbol canónico §1 + fila de frontera §2 + nota de alcance (doc del framework, llega vía `init`/`update`); `docs/framework-contract.md` → las 3 menciones "5 documentos estándar" pasan a 6 con el doc listado, fila en la tabla de frontera y skeleton del paso 5 de `init`. Delta `## MODIFIED` ya creado en `specs/specboot-update/spec.md` (artefactos primero, base-standards §7). NO agregar el doc a `REQUIRED_FILES` (decisión del proposal: minor no fuerza acción al consumidor).
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: M
  - **Suggested Path**: specboot.sh
  - **Test Path**: tests/mandatory-steps-test.sh

- [x] 1.7 Sumar la sección `## Mandatory Steps` al ejemplo canónico `ai-specs/examples/tasks.md` (coherencia del material distribuido; sin assert dedicado — SC-002 cubre el mecanismo de inyección, no el ejemplo).
  - **Priority**: Low
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/examples/tasks.md
  - **Test Path**: no aplica

## 2. Registro en el plan y cierre

- [x] 2.1 Registrar los follow-ups de auditoría en `PLAN_MEJORAS_SPECBOOT.md` (GREEN): nueva sección "FASE 10 — Follow-ups de auditoría (patrón M-403)" con los tickets M-904 (W1 semántica de staleness), M-905 (W2 vocabulario del trailer `Gate-Bypass`), M-906 (W3 reconciliar SemVer de M-901) y M-907 (W4 frase residual en spec archivada) — solo descripción del problema y propuesto, marcados como pendientes; sin implementación en este change. M-403 permanece pendiente en su sección de la Fase 4.
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: M
  - **Suggested Path**: PLAN_MEJORAS_SPECBOOT.md
  - **Test Path**: tests/mandatory-steps-test.sh

- [x] 2.2 Cerrar M-601 en `PLAN_MEJORAS_SPECBOOT.md` (GREEN): marcar `[x]` el ticket M-601 (Fase 6) y añadir la fila v3.6 al historial describiendo lo entregado (doc + inyección en `plan-change` + referencia en `AGENTS.md` + distribución + guard test + bump).
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: PLAN_MEJORAS_SPECBOOT.md
  - **Test Path**: tests/mandatory-steps-test.sh

- [x] 2.3 Bump de versión `0.5.0` → `0.6.0` (GREEN, spec `version-bump`: el mantenedor bumpa antes del merge): `package.json` `version`, `.specboot.json` `frameworkVersion` (dogfooding) y entrada `## [0.6.0]` en `CHANGELOG.md` sin `### Breaking changes` (resumen de M-601 + follow-ups registrados).
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: package.json
  - **Test Path**: tests/mandatory-steps-test.sh
