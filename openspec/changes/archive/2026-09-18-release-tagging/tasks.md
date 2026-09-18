# Tasks: release-tagging

## Mandatory Steps

### Pre-implementación

- [x] La **rama activa** sigue la convención vigente del proyecto (ej.
  `feature/*`, `fix/*`); trabajar sobre ella, nunca directamente sobre la rama
  principal.
- [x] Estado **git limpio**: sin cambios sin commitear (ni staged) antes de
  empezar; si hay trabajo en curso, resolverlo primero.

## Durante la implementación

- [x] **Test nuevo que falla antes de implementar (RED)**: escribir el test del
  escenario (`SC-NNN`) y verificar que falla antes de escribir código de
  producción.
- [x] Ejecutar los **tests unitarios del módulo** tocado mientras se itera
  (ciclo RED-GREEN-REFACTOR), no solo al final.

## Post-implementación

- [x] **Ejecutar `verify`**: la verificación del change corre y produce
  evidencia persistente (`openspec/state/verify-results.json`).
- [x] **Ejecutar `adversarial-review`**: la auditoría adversarial corre y
  produce veredicto persistente (`openspec/state/adversarial-result.json`).

> Ambos pasos post alimentan los gates duros de `/commit` (M-901): sin
> `PASS` + `SHIP` vigentes para el change activo, el commit bloquea.

## Task 1 — Guard TDD (RED) — Prioridad: Alta — Capa: framework tooling — Estimación: S

- **Subtarea 1.1**: extender `tests/release-bump-test.sh` con asserts `[SC-001]`..`[SC-004]`:
  - [SC-001] `release-bump.sh` crea el tag local `v{version}` tras un bump exitoso
  - [SC-002] `update.sh --bump` lee `package.json` (no `git describe --tags`) para calcular la nueva versión
  - [SC-003] `docs/versioning-standard.md` documenta la política de tagging (tokens "tag local", "push the tag", "GitHub Release")
  - [SC-004] los tags backfills (existenán localmente, push origin --tags no dispara release.yml)
  - Ejecuta y confirma **RED**.
- Suggested Path: tests/release-bump-test.sh
- Test Path: tests/release-bump-test.sh

## Task 2 — release-bump crea tag local — Prioridad: Alta — Capa: framework tooling — Estimación: S

- **Subtarea 2.1**: en `release-bump.sh`, tras la escritura exitosa, hacer `git tag "v{version}"` con mensaje correcto y warning si el tag ya existe. El bump sigue siendo atómico (versión 2 archivos anidadas).
- Ejecutar test hasta GREEN.
- Suggested Path: release-bump.sh
- Test Path: tests/release-bump-test.sh

## Task 3 — update.sh --bump lee package.json — Prioridad: Alta — Capa: framework tooling — Estimación: S

- **Subtarea 3.1**: en `update.sh --bump`, cambiar la base de cálculo de `git describe --tags` a lectura de `package.json` (usar `node -p require('./package.json').version`); aplicar bump minor/major/patch sobre esa base y crear el tag + CHANGELOG. Ejecutar test hasta GREEN.
- Suggested Path: update.sh
- Test Path: tests/release-bump-test.sh

## Task 4 — Documentación de política de tags — Prioridad: Alta — Capa: framework tooling — Estimación: XS

- **Subtarea 4.1**: en `docs/versioning-standard.md` sección "Release automático", documentar: tag local por el tool de bump; push del tag tras merge; GitHub Release manual desde la UI; y el rol de `release.yml` (publish idempotente en push:main / release:published, sin depender de tags). Ejecutar guard hasta GREEN.
- Suggested Path: docs/versioning-standard.md
- Test Path: tests/release-bump-test.sh

## Task 5 — Backfill de tags retroactivos (ejecución) — Prioridad: Alta — Capa: framework tooling — Estimación: XS

- **Subtarea 5.1**: ejecución en esta sesión (no commiteado como script): crear tags locales y push.
  ```bash
  git tag v0.6.4 a797e2e && git tag v0.7.0 85d92a0 && git tag v0.8.0 9d44db7 && git tag v0.8.1 24d1dbc && git tag v0.9.0 392fb2b
  git push origin v0.6.4 v0.7.0 v0.8.0 v0.8.1 v0.9.0
  ```
- Verificar: `git tag -l 'v*' | sort -V | tail -6` y `git ls-remote --tags origin | grep -E "v0\.(6\.4|7\.0|8\.0|8\.1|9\.0)"` en remoto.
- Suggested Path: no aplica (ejecución operativa)
- Test Path: tests/release-bump-test.sh

## Task 6 — Verificación integral read-only — Prioridad: Alta — Capa: framework tooling — Estimación: XS

- **Subtarea 6.1**: `bash check-refs.sh && bash specboot.sh --ci && bash validate-specboot.sh && bash tests/run-all.sh` — todos en verde. [] gh aislado.

- Suggested Path: no aplica (verificación read-only)
- Test Path: no aplica
