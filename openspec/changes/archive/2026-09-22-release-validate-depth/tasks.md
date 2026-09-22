# Tasks — SPECBOOT-HARDEN-03: release-validate-depth

> Rastro: REQ-### ↔ SC-### definidos en `requirements.md` / `scenarios.md`.
> Este repo no usa `.specboot.json` con `layers`; los paths usan las carpetas
> reales del framework (`.github/workflows/`, `tests/`).

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
- [x] **Ejecutar `adversarial-review`**: la auditoría adversarial corre y
  produce veredicto persistente (`openspec/state/adversarial-result.json`).

> Ambos pasos post alimentan los gates duros de `/commit` (M-901): sin
> `PASS` + `SHIP` vigentes para el change activo, el commit bloquea.

---

## 1. Historial completo en validate (REQ-001)

Prioridad: crítica | Capa: infrastructure | Estimación: media

- [x] 1.1 Escribir primero el test de contrato (RED) en
  `tests/release-workflow-test.sh`: añadir SC-004 — verificar que `fetch-depth: 0`
  aparece SOLO dentro del bloque del job `validate` (no en el job `publish`), de
  modo que el test falle antes de la corrección en `.github/workflows/release.yml`.
- [x] 1.2 Añadir `with: fetch-depth: 0` al paso `actions/checkout` del job
  `validate` en `.github/workflows/release.yml` (GREEN). Verificar SC-001.
- [x] 1.3 Verificar que el job `publish` queda intacto: su checkout sin
  `fetch-depth: 0` y `needs: validate` conservado (SC-002, SC-003).

Suggested Path: `.github/workflows/release.yml`
Test Path: `tests/release-workflow-test.sh`

## 2. Regresión verde (REQ-004)

Prioridad: alta | Capa: infrastructure | Estimación: baja

- [x] 2.1 Ejecutar `bash tests/release-workflow-test.sh` (incluye el nuevo assert
  de contrato SC-004) y `bash tests/specboot-update-test.sh` — ambos en verde.
  Nota: Test 12 (reparación legacy de HARDEN-02) copiaba el `release.yml` interno
  vivo como "variante legacy exacta", lo que solo funcionaba porque el archivo
  interno coincidía con el variante distribuido v3; REQ-001 lo evolucionó. El
  fixture ahora deriva del commit pre-aislamiento v3 del historial git (sin
  tocar la allowlist de fingerprints), preservando el contrato HARDEN-02.
- [x] 2.2 Ejecutar `bash tests/run-all.sh` — todos los tests del framework en
  verde.
- [x] 2.3 Ejecutar `bash specboot.sh --ci` y `bash check-refs.sh` — ambos reportan
  0 errores.

Suggested Path: `.github/workflows/release.yml`
Test Path: `tests/release-workflow-test.sh`, `tests/specboot-update-test.sh`, `tests/run-all.sh`