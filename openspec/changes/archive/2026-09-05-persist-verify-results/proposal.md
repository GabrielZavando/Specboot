# Change Proposal: persist-verify-results

- **Ticket ID**: M-401-402
- **Original Title**: [docs] Fase 4: persistir resultados de verificación y mapeo SC→Test
- **Tag (source)**: [docs] (explicit)
- **Derived change name**: `persist-verify-results`
- **Change folder**: `openspec/changes/persist-verify-results/`
- **Enriched artifact used**: no
- **SemVer Impact**: minor

## Summary

Este cambio implementa la **Fase 4** del plan de mejoras de Specboot
(`PLAN_MEJORAS_SPECBOOT.md`), abordando los tickets **M-401** y **M-402**:

1. **M-401 (Persistir resultados de verificación)**: `/verify` escribe
   `openspec/state/verify-results.json` después de cada ejecución, con un esquema
   versionado y alineado con el vocabulario que `verify` ya usa en pantalla
   (`PASS|PARTIAL|FAIL` global, `PASS|FAIL|UNTESTED` por escenario). El skill
   `commit` usa ese archivo como **gate informado suave** (deja de depender solo de
   la honestidad del usuario). El skill `archive` referencia la verificación en la
   entrada del manifiesto.

2. **M-402 (Mapeo explícito Scenario → Test)**: convención de nombrado de tests
   con el ID de escenario en el nombre público del test (`[SC-NNN]` en JS/TS,
   `test_sc{NNN}_` en Python), documentada en los subagentes que generan tests,
   y `verify` establece prioridad de evidencia (match por nombre → fuerte;
   mención textual → débil; nada → UNTESTED).

## Motivation

- Hoy `verify` reporta **solo en pantalla** (Step 7: "solo pantalla, no persistido").
  No hay estado que `/commit` pueda usar como gate: su Step 2 pregunta al usuario
  "¿Ejecutaste `/verify`?" basándose en su palabra, con una nota explícita de que
  **no** se dependa de un archivo `.verify-passed` (decisión previa que este cambio
  revierte de forma controlada).
- La cobertura de escenarios (Step 5c) se valida por coincidencia textual frágil,
  sin priorizar el nombre público del test.
- **M-901** (gate duro de commit, futuro) depende de esta evidencia persistente;
  este change entrega el estado y el gate suave; M-901 lo endurecerá con
  `adversarial-result.json` (M-502) + `--force`.

## What Changes

- **M-401**:
  - `verify` (nuevo Step 8): persiste `openspec/state/verify-results.json` tras
    cada ejecución con el esquema `schema_version=1`, campo `evidence_mode`
    (`executable|static`) y vocabulario de estados existente.
  - `commit` (Step 2): gate informado suave — `PASS` vigente para el change activo
    omite la pregunta; `PARTIAL|FAIL` advierte y ofrece re-ejecutar; archivo
    ausente o de otro change mantiene el flujo actual de pregunta; staleness
    check warn-only.
  - `archive` (Step 5): campo opcional `verification: {status, timestamp, source}`
    en la entrada del `manifest.json`; se omite si no hay archivo (no bloquea).
  - Claims "Read-only" de `verify` actualizados (read-only sobre código; persiste
    evidencia bajo `openspec/state/`).
- **M-402**:
  - Convención de nombrado documentada en `ai-specs/agents/build-agent.md` y
    referenciada por `backend-developer.md` / `frontend-developer.md`.
    **No** se toca `docs/base-standards.md` (intocable, inyectado por el framework).
  - `verify` Step 5c: prioridad de evidencia por nombre/identificador (fuerte) >
    mención textual (débil ⚠️) > UNTESTED.
- **Cierre**:
  - Self-test ejecutable del esquema: `tests/verify-state-test.sh` (jq) validando
    `ai-specs/examples/verify-results-example.json`.
  - Bump de versión `0.2.0` → `0.3.0` (minor) + entrada CHANGELOG (spec
    `version-bump`: el mantenedor bumpa antes del merge para no bloquear
    `release.yml`).
  - `PLAN_MEJORAS_SPECBOOT.md`: marcar `[x]` M-401/M-402 + historial v3.3.

## Decisions

- **Gate suave informado en M-401**: `commit` lee la evidencia pero no bloquea de
  forma dura. El gate duro (con `adversarial-result.json` y `--force`) es **M-901**,
  fuera de alcance aquí.
- **`verify-results.json` trackeado en git**: evidencia auditable en PRs;
  `openspec/state/` ya está excluido de los warnings de `archive` Step 2.
- **Última corrida gana**: el archivo refleja la última ejecución de `verify`;
  el match por `change` + staleness warn-only protegen contra evidencia ajena o
  desactualizada.
- **Convención en subagentes**: `base-standards.md` permanece intocable; el
  requisito normativo vive en el delta spec de `plan-traceability`.

## Acceptance Criteria

- [ ] Tras `/verify` existe `openspec/state/verify-results.json` con el esquema versionado
- [ ] `/commit` omite la pregunta de verify cuando el archivo reporta `PASS` para el change activo
- [ ] `/commit` advierte (y no continúa en silencio) con `PARTIAL`/`FAIL`, y mantiene el flujo actual si el archivo falta o corresponde a otro change
- [ ] `/archive` añade `verification` a la entrada del manifest cuando hay archivo, y omite el campo sin bloquear cuando no lo hay
- [ ] `tests/verify-state-test.sh` valida el esquema y pasa (evidencia ejecutable)
- [ ] `verify` reporta prioridad de evidencia: nombre (fuerte) > textual (débil) > `UNTESTED`
- [ ] La convención de nombrado `SC-NNN` está documentada en `build-agent.md` y referenciada por los subagentes backend/frontend
- [ ] Ninguna descripción de `verify` declara ya "Read-only" absoluto
- [ ] `bash check-refs.sh` y `bash specboot.sh --ci` reportan 0 errores