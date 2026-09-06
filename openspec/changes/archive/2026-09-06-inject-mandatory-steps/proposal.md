# Change Proposal: inject-mandatory-steps

- **Ticket ID**: M-601
- **Original Title**: [docs] Mandatory steps document
- **Tag (source)**: [docs] (explicit)
- **Derived change name**: `inject-mandatory-steps`
- **Change folder**: `openspec/changes/inject-mandatory-steps/`
- **Enriched artifact used**: no (ticket de `PLAN_MEJORAS_SPECBOOT.md` §Fase 6 + decisiones validadas en sesión, 2026-09-05)
- **SemVer Impact**: minor (`0.5.0` → `0.6.0`) — nueva capacidad del framework (inyección de mandatory steps en `tasks.md`), sin ruptura de contratos existentes

## Summary

Este cambio implementa la **Fase 6** del plan de mejoras de Specboot
(`PLAN_MEJORAS_SPECBOOT.md`), abordando el ticket **M-601**:

**M-601 (Mandatory steps document)**: los agentes pueden omitir pasos importantes
(tests, verificación manual) porque no están explícitamente obligados en el artefacto
que el implementador lee. Se crea `docs/openspec-tasks-mandatory-steps.md` — con las
tres fases del ticket (pre-implementación: rama según convención y git limpio;
durante: test nuevo que falla antes de implementar (RED) + tests unitarios del
módulo; post: ejecutar `verify` y ejecutar `adversarial-review`) — y el skill
`plan-change` **inyecta ese contenido** como sección `## Mandatory Steps` en todo
`tasks.md` generado, de modo que la checklist obligatoria viaja dentro del artefacto
de implementación. El documento se distribuye como archivo del framework (llega a
todo proyecto consumidor vía `init`/`update`), `AGENTS.md` lo referencia en su
carga dinámica, y el cierre registra en el plan los follow-ups de auditoría
(W1–W4 → M-904..M-907, patrón M-403).

## Motivation

- Hoy los pasos obligatorios del ciclo (RED primero, tests del módulo, `verify`,
  `adversarial-review`) viven dispersos en `base-standards.md`, skills y agentes.
  El `tasks.md` que el agente `build` ejecuta no los lista, así que su omisión no
  es detectable en el punto de trabajo.
- Los pasos son proceso SDD genérico del framework, no específicos del proyecto:
  su fuente de verdad debe ser un doc del framework distribuido a consumidores,
  no una copia por proyecto (misma lógica de distribución que M-403 enseñó a
  sincronizar).
- `plan-change` es el único generador de `tasks.md`: es el punto natural de
  inyección, y su checklist de validación (Step 6) puede verificar la presencia
  de la sección antes de reportar éxito.

## What Changes

- **M-601**:
  - **Nuevo** `docs/openspec-tasks-mandatory-steps.md`: tres fases —
    pre-implementación (rama activa según convención, estado git limpio),
    durante (tests unitarios del módulo; test nuevo falla antes de implementar,
    RED), post (ejecutar `verify`, ejecutar `adversarial-review`). Es la **fuente
    única de verdad** del contenido inyectado.
  - `ai-specs/skills/plan-change/SKILL.md` (Step 5): todo `tasks.md` generado
    incluye la sección `## Mandatory Steps`, cuyo contenido se **lee del doc en el
    momento de generación** (no copia hardcodeada en el skill — evita drift entre
    skill y doc). Step 6: checklist += check de la sección.
  - `AGENTS.md` §2 (Carga dinámica): referencia al doc como contenido inyectado
    por `plan-change` en todo `tasks.md`.
  - **Distribución framework** (lección M-403 — sincronía en los 5 puntos):
    `FRAMEWORK_ITEMS` y `UPDATE_ITEMS` en `specboot.sh`, allowlist `files` en
    `package.json`, árbol canónico en `docs/docs-standard.md`, y lista de
    skeleton en `docs/framework-contract.md`.
  - **Fix de bug latente (descubierto en 1.5, decidido por el mantenedor
    2026-09-05)**: `replace_framework_files` salteaba TODOS los ítems `docs/` de
    `UPDATE_ITEMS[]` (patrón `docs/*` en el `case`) — `specboot update` nunca
    reemplazó los 5 docs estándar, contradiciendo la spec archivada
    `specboot-update` y bloqueando la distribución del doc a consumidores
    existentes. Fix: el `case` solo saltea árboles enteros (`docs`, `.github`);
    el doc se agrega a `UPDATE_ITEMS` (conjunto de 6); assert de regresión
    `[SC-008]` en `tests/specboot-update-test.sh`; `allowedDocs` de
    `tests/package-files-test.sh` pasa a 6; enmienda vía delta `## MODIFIED`
    sobre la capability `specboot-update` (artefactos primero, base-standards
    §7).
  - Self-test `tests/mandatory-steps-test.sh` con asserts `[SC-NNN]`.
- **Registro y cierre**:
  - `PLAN_MEJORAS_SPECBOOT.md`: marcar `[x]` M-601, fila de historial **v3.6** y
    nueva sección **"Fase 10 — Follow-ups de auditoría (patrón M-403)"** con los
    tickets M-904..M-907 (solo registro descriptivo, sin implementación en este
    change).
  - Bump `0.5.0` → `0.6.0` + entrada `## [0.6.0]` en CHANGELOG (sin
    `### Breaking changes`).

## Decisions

- **Ownership: doc inyectado por framework (decisión del mantenedor, 2026-09-05)**.
  `plan-change` es un skill del framework y su inyección aplica en todo proyecto
  consumidor; si el doc fuera del proyecto, un consumidor nuevo generaría
  `tasks.md` con una referencia rota. Los pasos son proceso SDD genérico. Por lo
  tanto el doc es intocable-distribuible: se agrega a `FRAMEWORK_ITEMS` y al
  allowlist `files`, y se documenta en `docs-standard.md` y `framework-contract.md`.
- **Inyección por lectura, no por copia hardcodeada**: `plan-change` lee el doc en
  el momento de generar `tasks.md` y copia su contenido vigente. Fuente única de
  verdad = el doc; el skill solo instruye el mecanismo. Evita que una edición
  futura del doc quede desincronizada del texto dentro del skill.
- **No se agrega a `REQUIRED_FILES` de `specboot.sh`**: un consumidor que saltee
  un update minor no debe ver `--ci` en rojo (matriz de `docs/versioning-standard.md`
  §3: minor no exige acción del consumidor). La integridad del doc en este repo
  queda cubierta por el guard test; para consumidores llega vía `init`/`update`.
- **Follow-ups de auditoría registrados, no implementados** (decisión del
  mantenedor, 2026-09-05): los 4 warnings del adversarial del change
  `enforce-commit-gates` se registran como M-904 (W1 semántica de staleness),
  M-905 (W2 vocabulario del trailer `Gate-Bypass`), M-906 (W3 reconciliar SemVer
  de M-901) y M-907 (W4 frase residual en spec archivada), en una nueva Fase 10.
  M-403 (permisos `pytest` del subagente verify) permanece pendiente en su
  sección de la Fase 4. Ninguno se implementa en este change.
- **Chicken-and-egg aceptado**: el `tasks.md` de este propio change se genera
  *antes* de actualizar el skill `plan-change`, por lo que no lleva la sección
  `## Mandatory Steps` inyectada (igual que el dogfooding documentado en
  `enforce-commit-gates`). El mecanismo queda verificado por el guard test, no
  por este artefacto.
- **Fix del bug update-docs incluido en este change (decisión del mantenedor,
  2026-09-05)**: sin el fix, `specboot update` no entregaría el doc a los
  consumidores existentes (y seguiría sin entregar NINGÚN doc intocable,
  contradiciendo la spec archivada `specboot-update`). La enmienda de la spec se
  hace por la vía canónica: delta `## MODIFIED` en este change (no edición
  directa de la spec archivada), y el fix del código va precedido por el assert
  de regresión RED en `tests/specboot-update-test.sh`.
- **Validación de diseño (Step 4½)**: change de docs + skill; no toca entidades
  de `docs/data-model/data-model.md` ni endpoints de `docs/api/api-spec.yml`.
  Conflictos: ninguno. Nota menor: toca dos docs intocables del framework
  (`docs-standard.md`, `framework-contract.md`) por la vía correcta (flujo SDD de
  dogfooding, no edición ad-hoc).

## Acceptance Criteria

- [ ] `docs/openspec-tasks-mandatory-steps.md` existe con las tres fases
      (pre: rama según convención + git limpio; durante: RED primero + tests del
      módulo; post: `verify` + `adversarial-review`)
- [ ] Todo `tasks.md` generado por `plan-change` después del cambio incluye la
      sección `## Mandatory Steps`, con contenido leído del doc en el momento de
      generación
- [ ] El checklist de validación (Step 6) de `plan-change` incluye el check de la
      sección y no reporta éxito con el check fallando
- [ ] `AGENTS.md` §2 (Carga dinámica) referencia el doc
- [ ] El doc está distribuido como archivo del framework: `FRAMEWORK_ITEMS` y
      `UPDATE_ITEMS` (`specboot.sh`) + allowlist `files` (`package.json`) + árbol
      `docs/docs-standard.md` + skeleton `docs/framework-contract.md`
- [ ] `specboot update` reemplaza los 6 docs intocables (fix del bug `docs/*`;
      assert de regresión `[SC-008]` en `tests/specboot-update-test.sh` en verde)
- [ ] `tests/mandatory-steps-test.sh` pasa con asserts `[SC-NNN]`
- [ ] `PLAN_MEJORAS_SPECBOOT.md`: M-601 marcado `[x]`, fila v3.6 en el historial,
      Fase 10 con M-904..M-907 registrados
- [ ] `package.json` en `0.6.0` + entrada `## [0.6.0]` en CHANGELOG sin
      `### Breaking changes`
- [ ] `bash check-refs.sh` y `bash specboot.sh --ci` reportan 0 errores
