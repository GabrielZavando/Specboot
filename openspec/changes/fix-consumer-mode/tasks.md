# Implementation Tasks: fix-consumer-mode

## Mandatory Steps

> Checklist **obligatoria, no sugerida**, inyectada por `plan-change` desde
> `docs/openspec-tasks-mandatory-steps.md` (fuente única de verdad, leída en el
> momento de generación). Aplica a cada tarea de implementación de este change.

### Pre-implementación

Antes de escribir la primera línea de la tarea actual:

- [ ] La **rama activa** sigue la convención vigente del proyecto (ej.
  `feature/*`, `fix/*`); trabajar sobre ella, nunca directamente sobre la rama
  principal.
- [ ] Estado **git limpio**: sin cambios sin commitear (ni staged) antes de
  empezar; si hay trabajo en curso, resolverlo primero.

### Durante la implementación

- [ ] **Test nuevo que falla antes de implementar (RED)**: escribir el test del
  escenario (`SC-NNN`) y verificar que falla antes de escribir código de
  producción.
- [ ] Ejecutar los **tests unitarios del módulo** tocado mientras se itera
  (ciclo RED-GREEN-REFACTOR), no solo al final.

### Post-implementación

Antes de dar la tarea por cerrada:

- [ ] **Ejecutar `verify`**: la verificación del change corre y produce
  evidencia persistente (`openspec/state/verify-results.json`).
- [ ] **Ejecutar `adversarial-review`**: la auditoría adversarial corre y
  produce veredicto persistente (`openspec/state/adversarial-result.json`).

> Ambos pasos post alimentan los gates duros de `/commit` (M-901): sin
> `PASS` + `SHIP` vigentes para el change activo, el commit bloquea.

## 1. Resolución de versión consumer-safe (Bug 2 + 2b + 3 — TDD primero)

- [ ] 1.1 Crear `tests/version-resolution-test.sh` (RED): fixture tmp (estilo
      `specboot-update-test.sh`) con `package.json` raíz señuelo `9.9.9`,
      `node_modules/@gabrielzavando/specboot/package.json` (`0.6.4`) y copias de
      `specboot.sh` / `validate-specboot.sh`. Asserts con prefijo `[SC-NNN]`:
      `[SC-001]` `bash specboot.sh --version` en el fixture → `0.6.4` (no `9.9.9`);
      `[SC-002]` `source specboot.sh` (safe por el guard `BASH_SOURCE[0] = $0`) +
      `get_framework_version "node_modules/@gabrielzavando/specboot"` → `0.6.4`;
      `[SC-003]` en la raíz del framework → versión del `package.json` del framework;
      `[SC-005]` fixture con `.specboot.json` (`frameworkVersion: 0.6.4`) →
      `bash validate-specboot.sh` exit 0 con "coincide"; `[SC-006]`
      `create_initial_specboot_json "$tmp" 0` (vía source) → `frameworkVersion`
      `0.6.4` (no `9.9.9`); `[SC-007]` el warning de `validate-specboot.sh` cuando
      installed < declared menciona `npm ls @gabrielzavando/specboot`. Debe fallar
      (RED) antes de 1.2–1.3.
  - **Priority**: High
  - **Layer**: tests
  - **Estimate**: M
  - **Suggested Path**: tests/version-resolution-test.sh
  - **Test Path**: tests/version-resolution-test.sh

- [ ] 1.2 Implementar la resolución consumer-safe en `specboot.sh` (GREEN):
      normalización de rutas bare en `get_framework_version` (`case`:
      `/*|./*` pasan; el resto se prefija `./`); nuevo helper
      `resolve_framework_version()` con precedencia
      `node_modules/@gabrielzavando/specboot/package.json` (CWD) → `$SCRIPT_DIR`;
      `show_version()` usa el helper; `create_initial_specboot_json()` (línea 209)
      usa el helper. Compatibilidad dogfooding: sin self-dependency en
      `node_modules`, el fallback `$SCRIPT_DIR` devuelve la versión igual que antes.
  - **Priority**: High
  - **Layer**: cli
  - **Estimate**: M
  - **Suggested Path**: specboot.sh
  - **Test Path**: tests/version-resolution-test.sh

- [ ] 1.3 Mejorar el mensaje de error de `validate-specboot.sh` (GREEN): en la
      rama `installed < declared`, añadir la sugerencia de verificar la instalación
      (`npm ls @gabrielzavando/specboot`) al warning existente.
  - **Priority**: Medium
  - **Layer**: cli
  - **Estimate**: S
  - **Suggested Path**: validate-specboot.sh
  - **Test Path**: tests/version-resolution-test.sh

## 2. Wiring de autenticación de consumidor en `ci.yml` (Bug 1 — TDD primero)

- [ ] 2.1 Crear `tests/consumer-ci-auth-test.sh` (RED): guards grep sobre
      `.github/workflows/ci.yml` (estilo `release-workflow-test.sh`) con asserts
      `[SC-004]`: `packages: read` presente en `permissions` workflow-level;
      `NODE_AUTH_TOKEN` + `secrets.GITHUB_TOKEN` presentes en `env`;
      `registry-url: https://npm.pkg.github.com` con count ≥ 2 (ambos jobs); y
      contra-regresiones: `make ci` sigue en `project-ci`, `setup-node@v5` y
      `node-version: '24'` se conservan. Debe fallar (RED) antes de 2.2.
  - **Priority**: High
  - **Layer**: tests
  - **Estimate**: S
  - **Suggested Path**: tests/consumer-ci-auth-test.sh
  - **Test Path**: tests/consumer-ci-auth-test.sh

- [ ] 2.2 Añadir el wiring a `.github/workflows/ci.yml` (GREEN): `permissions` +=
      `packages: read`; `env` workflow-level
      `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}`; ambos `actions/setup-node`
      con `registry-url: https://npm.pkg.github.com`. Conservar sin cambios: jobs
      `validate` + `project-ci`, `make ci`, actions v5, node `'24'`, `hashFiles`
      solo a nivel step (requisito de `specboot-workflows`).
  - **Priority**: High
  - **Layer**: ci
  - **Estimate**: S
  - **Suggested Path**: .github/workflows/ci.yml
  - **Test Path**: tests/consumer-ci-auth-test.sh

## 3. Coherencia de docs, spec y versión

- [ ] 3.1 Sincronizar docs (GREEN): `README.md` §"Autenticación para consumidores
      (CI)" — nota de que el `ci.yml` distribuido ya incluye el wiring Vía A (con
      `GITHUB_TOKEN` funciona out-of-the-box; owner distinto sigue documentado con
      PAT); `docs/framework-contract.md` §"Workflows del framework" — mención del
      wiring consumer-safe en `ci.yml`. `bash check-refs.sh` debe seguir en 0
      errores.
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: README.md
  - **Test Path**: no aplica (los refs los valida `check-refs.sh`; sin assert
    dedicado — SC-004 cubre el wiring, SC-008 la spec)

- [ ] 3.2 Bump de versión `0.6.3` → `0.6.4` (GREEN, spec `version-bump`: el
      mantenedor bumpa antes del merge): `package.json` `version`, `.specboot.json`
      `frameworkVersion` (dogfooding), entrada `## [0.6.4]` en `CHANGELOG.md` sin
      `### Breaking changes` (resumen de ambos fixes), y migración del pin de
      `tests/mandatory-steps-test.sh` SC-007 (`0.6.3` → `0.6.4`, precedente
      0.6.2→0.6.3 en el comentario del guard).
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: package.json
  - **Test Path**: tests/mandatory-steps-test.sh

## 4. Verificación de cierre

- [ ] 4.1 Suite completa verde: `bash check-refs.sh` (0 errores), `bash
      specboot.sh --ci` (0 errores / 0 warnings), todos los `tests/*-test.sh` en
      verde (los nuevos `tests/version-resolution-test.sh` y
      `tests/consumer-ci-auth-test.sh` corren automáticamente en el loop de
      `ci.yml` y `release.yml`). Post: ejecutar `verify` y `adversarial-review`
      (Mandatory Steps — alimentan los gates de `/commit`).
  - **Priority**: High
  - **Layer**: tests
  - **Estimate**: S
  - **Suggested Path**: no aplica (verificación integral, sin archivo de
    implementación propio)
  - **Test Path**: tests/
