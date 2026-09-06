# Requirements: inject-mandatory-steps

## REQ-001: Documento de mandatory steps con las tres fases (→ SC-001)

- **Descripción**: El framework SHALL proveer el documento
  `docs/openspec-tasks-mandatory-steps.md` como fuente única de verdad del
  checklist obligatorio de implementación, con tres fases: **pre-implementación**
  (rama activa según la convención vigente, estado de git limpio),
  **durante** (tests unitarios del módulo; test nuevo que falla antes de
  implementar — RED) y **post** (ejecutar `verify`; ejecutar
  `adversarial-review`).
- **Racional**: el ticket M-601 exige que los pasos importantes estén
  explícitamente obligados y en un solo doc consultable.

## REQ-002: Inyección de la sección en todo tasks.md generado (→ SC-002)

- **Descripción**: El skill `plan-change` (Step 5) SHALL inyectar en todo
  `tasks.md` generado una sección `## Mandatory Steps` cuyo contenido se copia
  del doc `docs/openspec-tasks-mandatory-steps.md` leído en el momento de
  generación. El skill SHALL NOT contener una copia hardcodeada de los pasos.
- **Racional**: la checklist obligatoria debe viajar dentro del artefacto que el
  agente `build` ejecuta; la lectura dinámica evita drift entre skill y doc.

## REQ-003: Validación de la inyección en el checklist (→ SC-003)

- **Descripción**: El checklist de validación del Step 6 de `plan-change`
  SHALL incluir el check "tasks.md incluye la sección `## Mandatory Steps`",
  y la generación SHALL NOT reportarse como exitosa si el check falla.
- **Racional**: sin el check, un `tasks.md` generado sin la sección no sería
  detectable en el punto de generación.

## REQ-004: Referencia desde el puente AGENTS.md (→ SC-004)

- **Descripción**: La sección de carga dinámica (§2) de `AGENTS.md` SHALL
  referenciar `docs/openspec-tasks-mandatory-steps.md` como contenido inyectado
  por `plan-change` en todo `tasks.md` generado.
- **Racional**: el puente es la interfaz del agente; sin la referencia, el doc
  queda invisible fuera del flujo `/plan-change` (tarea 3 del ticket M-601).

## REQ-005: Distribución del doc como archivo del framework (→ SC-005)

- **Descripción**: El doc SHALL estar incluido en `FRAMEWORK_ITEMS`
  (`specboot.sh`) y en el allowlist `files` de `package.json`; `docs/docs-standard.md`
  SHALL listarlo en su árbol canónico y `docs/framework-contract.md` SHALL
  incluirlo en el skeleton de `docs/` que crea `init`. El doc SHALL NOT agregarse
  a `REQUIRED_FILES` de `specboot.sh`.
- **Racional**: decisión del mantenedor — ownership framework-inyectado (lección
  M-403 de sincronía en los 4 puntos de distribución); excluirlo de
  `REQUIRED_FILES` evita que un consumidor que saltee un update minor vea
  `--ci` en rojo (matriz SemVer: minor no exige acción).

## REQ-006: Registro en el plan de mejoras y follow-ups de auditoría (→ SC-006)

- **Descripción**: `PLAN_MEJORAS_SPECBOOT.md` SHALL marcar `[x]` M-601, SHALL
  añadir la fila v3.6 al historial, y SHALL registrar en una nueva sección
  "Fase 10 — Follow-ups de auditoría (patrón M-403)" los tickets M-904 (W1
  semántica de staleness), M-905 (W2 vocabulario del trailer `Gate-Bypass`),
  M-906 (W3 reconciliar SemVer de M-901) y M-907 (W4 frase residual en spec
  archivada). M-403 SHALL permanecer visible como pendiente en la Fase 4.
- **Racional**: los warnings del adversarial anterior son candidatos a follow-up;
  registrarlos evita perder el contexto de la sesión (pendiente de la sesión
  anterior). Ninguno se implementa en este change.

## REQ-007: Bump minor 0.6.0 con CHANGELOG sin ruptura (→ SC-007)

- **Descripción**: Al completar el change, `package.json` SHALL declarar
  `0.6.0`, `.specboot.json` SHALL reflejar `frameworkVersion: 0.6.0`
  (dogfooding) y `CHANGELOG.md` SHALL incluir la entrada `## [0.6.0]` sin
  sección `### Breaking changes`.
- **Racional**: spec `version-bump` (el mantenedor bumpa antes del merge) +
  matriz de `docs/versioning-standard.md` §3 (nueva capacidad sin ruptura =
  minor).

## REQ-008: Fix del bug update-docs y conjunto de 6 docs (→ SC-008)

- **Descripción**: `replace_framework_files` SHALL NOT saltear ítems `docs/`
  individuales: solo los árboles enteros (`docs`, `.github`) quedan excluidos
  del camino genérico de reemplazo. `UPDATE_ITEMS[]` SHALL incluir
  `docs/openspec-tasks-mandatory-steps.md` junto a los 5 docs estándar (conjunto
  de 6), enmendando la spec archivada `specboot-update` vía delta
  `## MODIFIED` (que reproduce ambos requirements afectados con sus escenarios,
  incluido el de regresión).
- **Racional**: el patrón `docs/*` del `case` impedía que `specboot update`
  reemplazara NUNCA los docs intocables (bug latente, invisible a los tests
  existentes que no asertaban reemplazo de docs), contradiciendo el
  MUST-overwrite de la spec `specboot-update` y bloqueando la distribución del
  doc de M-601 a consumidores existentes. Fix decidido por el mantenedor
  (2026-09-05) dentro de este change; artefactos primero (base-standards §7).
