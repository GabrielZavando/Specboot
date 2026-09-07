# Change Proposal: fix-consumer-mode

- **Ticket ID**: N/A (reporte upstream del mantenedor — análisis detallado de modo consumidor, 2026-09-07)
- **Original Title**: [FIX] Consumer-mode breaks: ci.yml sin auth de GitHub Packages (E401) y specboot.sh --version resuelve la versión del proyecto en vez de la del framework
- **Tag (source)**: ninguno (framework core — bash/CI/specs del propio Specboot; inferido y confirmado en sesión: ningún tag estándar `backend|frontend|api|docs|fullstack` aplica)
- **Derived change name**: `fix-consumer-mode`
- **Change folder**: `openspec/changes/fix-consumer-mode/`
- **Enriched artifact used**: no (ticket upstream detallado en sesión, con criterios de aceptación SC-001..SC-005)
- **SemVer Impact**: patch (`0.6.3` → `0.6.4`) — bugfixes sin cambios de contrato; `ci.yml` gana claves nuevas pero el comportamiento dogfooding no cambia

## Summary

Ambos bugs comparten una misma causa raíz conceptual: el framework fue probado solo en
modo dogfooding y asume que corre en su propio repo, pero se distribuye como paquete npm
a proyectos consumidores donde sus supuestos no se cumplen. En modo consumidor:

1. **Bug 1 — E401 en CI**: el `ci.yml` distribuido (que `specboot update` reemplaza de
   forma intocable) no incluye el wiring de autenticación de GitHub Packages
   (`packages: read`, `NODE_AUTH_TOKEN`, `registry-url`) que el propio README documenta
   como "Vía A" y que `release.yml` ya tiene. Todo consumidor que haga `specboot update`
   desde un `ci.yml` funcional queda con CI roto (E401) — regresión recurrente, porque
   cada update reinstala la versión rota.
2. **Bug 2 — `--version` miente**: `show_version()` llama `get_framework_version` sin
   argumento (dir=`.` → CWD), así que `bash specboot.sh --version` en la raíz de un
   consumidor devuelve la versión del PROYECTO (p. ej. `0.1.0`) en vez de la del
   framework (`0.6.3`). Esto dispara un error duro en `specboot.sh --ci`: la comparación
   de `validate-specboot.sh` contra `frameworkVersion` (0.6.3) produce el mensaje
   irónico "frameworkVersion (0.6.3) es mayor que la versión instalada (0.1.0)".
   Sub-bug 2b: `get_framework_version` no normaliza rutas bare (`node_modules/...`), que
   `require()` interpreta como bare specifier → falla silenciosa (enmascarada por
   `2>/dev/null`).
3. **Bug 3 — tercera manifestación de la misma causa raíz (descubierta en sesión
   durante el análisis)**: `create_initial_specboot_json()` (línea 209) llama
   `get_framework_version` sin argumento → `specboot init` en un consumidor escribe la
   versión del PROYECTO como `frameworkVersion` en el `.specboot.json` del consumidor.
   La spec `specboot-init` ya exige "`frameworkVersion` from the framework", así que es
   una violación existente: solo fix + test, sin delta.

## Motivation

- `specboot update` reemplaza `.github/workflows/*` archivo por archivo (spec
  `specboot-update`): el wiring roto se reinstala en cada update. Los consumidores en
  `0.1.2` funcionaban porque su `ci.yml` anterior (escrito a mano) incluía el wiring;
  el update lo pisó con la versión rota. Esto convierte el Bug 1 en regresión
  recurrente, no puntual.
- `--version` es contrato público documentado (TICKET-0.3; spec
  `specboot-json-standard`: "specboot.sh is self-validating"): `validate-specboot.sh`
  lo usa como fuente preferida de la versión instalada. Devolver la versión del
  proyecto corrompe a todo consumidor de ese contrato y deja el proyecto en estado de
  validación roja justo después de un `specboot update` exitoso.
- El fix debe ir en el ORIGEN (`specboot.sh`), no invirtiendo precedencia en
  `validate-specboot.sh`: invertir la precedencia dejaría a cualquier otro lector del
  contrato `--version` recibiendo datos incorrectos.

## What Changes

- **`specboot.sh` (Bug 2 + 2b + 3)**:
  - `get_framework_version()`: normaliza rutas relativas bare a rutas de filesystem
    explícitas (`case`: `/*` y `./*` pasan; el resto se prefija `./`) — `require()`
    interpreta un bare specifier como nombre de paquete, no como ruta.
  - Nuevo helper `resolve_framework_version()`: precedencia consumer-safe
    (`node_modules/@gabrielzavando/specboot/package.json` relativo a CWD →
    `package.json` junto al script `$SCRIPT_DIR`). Inofensivo en dogfooding: el repo
    del framework no se auto-depende, así que el fallback `$SCRIPT_DIR` devuelve la
    versión del framework igual que antes.
  - `show_version()` usa el helper (resuelve el Bug 2) y
    `create_initial_specboot_json()` usa el helper (resuelve el Bug 3).
- **`.github/workflows/ci.yml` (Bug 1)**: `permissions` += `packages: read`;
  `env` workflow-level `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}`; ambos jobs
  (`validate`, `project-ci`) usan `actions/setup-node` con
  `registry-url: https://npm.pkg.github.com`. En dogfooding es inofensivo (el
  `GITHUB_TOKEN` del repo puede leer sus propios paquetes). Conserva los contratos
  vigentes: 2 jobs, `make ci` en `project-ci`, actions v5 + node 24, `hashFiles`
  solo a nivel step.
- **`validate-specboot.sh`**: mejora del mensaje de error cuando `installed < declared`,
  sugiriendo verificar la instalación (`npm ls @gabrielzavando/specboot`).
- **Spec deltas** (artefactos primero, base-standards §7):
  - `specboot-json-standard` — delta `## MODIFIED` sobre "specboot.sh is
    self-validating": resolución consumer-safe de `--version`, normalización de rutas
    bare, helper compartido para `init`.
  - `specboot-workflows` — delta `## ADDED` (wiring de auth de consumidor en `ci.yml`)
    + `## MODIFIED` (requisito stale `node-version: 20` → `'24'`, alineado con la
    capability `workflow-node-upgrade`; decisión del mantenedor en sesión).
- **Tests** (TDD, RED primero): `tests/version-resolution-test.sh` (SC-001, SC-002,
  SC-003, SC-005, SC-006, SC-007 con fixture tmp estilo `specboot-update-test.sh`) y
  `tests/consumer-ci-auth-test.sh` (SC-004, guards grep estilo
  `release-workflow-test.sh`).
- **Docs sync**: README §"Autenticación para consumidores (CI)" nota de que el
  `ci.yml` distribuido ya incluye el wiring Vía A; `docs/framework-contract.md`
  §Workflows mención del wiring.
- **Bump `0.6.3` → `0.6.4`** + entrada `## [0.6.4]` en CHANGELOG (sin
  `### Breaking changes`) + migración del pin SC-007 de `tests/mandatory-steps-test.sh`
  (`0.6.3` → `0.6.4`, precedentes 0.6.2→0.6.3).

## Decisions

- **Fix en el origen, no en el consumidor del contrato**: `--version` es contrato
  público; invertir la precedencia en `validate-specboot.sh` dejaría a otros lectores
  recibiendo basura. (Propuesta del ticket upstream, ratificada en sesión.)
- **Helper compartido `resolve_framework_version()` (decisión del mantenedor en
  sesión)**: corrige las TRES manifestaciones de la misma causa raíz
  (`show_version`, sub-bug 2b, `create_initial_specboot_json`) con una sola
  abstracción (base-standards: detectar patrones repetidos), en lugar del parche de
  referencia que solo tocaba `show_version`.
- **Wiring dentro del `ci.yml` distribuido (opción recomendada del ticket)**: resolver
  de raíz la regresión recurrente — cada `specboot update` reinstala el wiring
  correcto en vez de romperlo. Alternativas (segunda variante de template,
  condicionales por `hashFiles`) descartadas por complejidad y por romper la lista
  única de archivos.
- **Requisito stale `node-version: 20` corregido en el mismo delta (decisión del
  mantenedor en sesión)**: contradice el archivo que este mismo change edita (el real
  usa `'24'` por `workflow-node-upgrade`); 2 líneas, elimina una mentira del contrato.
  El nombre del requirement se conserva (`MODIFIED` matchea por nombre).
- **SC-005 como proxy determinista**: el E401 real y el `--ci` completo en consumidor
  no son reproducibles en CI dogfooding; el guard grep de `ci.yml` (estilo
  `release-workflow-test.sh` para `release.yml`) es el proxy a nivel CI, y el fixture
  de `validate-specboot.sh` → `specboot.sh --version` es el proxy determinista de la
  cadena de comparación. El smoke-test real en consumidor es post-release.
- **Edge conocido, fuera de alcance (documentado)**: `specboot.sh --version` con la
  copia raíz ejecutada desde un subdirectorio del consumidor sin `node_modules` en
  CWD cae al fallback `$SCRIPT_DIR` (= raíz del proyecto). La resolución por walk-up
  se descarta por sobre-ingeniería para un patch; el flujo principal (raíz del
  proyecto, donde vive `validate-specboot.sh`) queda cubierto.
- **Validación de diseño (Step 4½)**: change de framework core (bash/CI/specs); no
  toca entidades de `docs/data-model/data-model.md` ni endpoints de
  `docs/api/api-spec.yml` (no aplican en el repo framework, `stack: "framework"`).
  Conflictos: ninguno. Guards verificados como compatibles: `ci-evaluation-test.sh`
  (2 jobs se conservan), `solid-templates-test.sh` (`make ci` se conserva),
  `workflow-node-upgrade` (v5 + node 24 se conservan), `specboot-update`
  (`.github` file-by-file intacto), `package-files-test.sh` (allowlist sin cambios).

## Acceptance Criteria

- [ ] `bash specboot.sh --version` en un consumidor (fixture: `package.json` raíz
      señuelo `9.9.9` + `node_modules/@gabrielzavando/specboot`) devuelve la versión
      del framework (SC-001)
- [ ] `get_framework_version "node_modules/@gabrielzavando/specboot"` resuelve la
      versión (no vacío) — rutas bare normalizadas (SC-002)
- [ ] En dogfooding, `--version` sigue devolviendo la versión del framework (SC-003)
- [ ] El `ci.yml` distribuido declara `packages: read`, `NODE_AUTH_TOKEN` y
      `registry-url: https://npm.pkg.github.com` en ambos jobs (SC-004)
- [ ] La cadena `validate-specboot.sh` → `specboot.sh --version` pasa en un fixture
      consumer-like con `frameworkVersion` igual a la instalada (SC-005)
- [ ] `specboot init` escribe el `frameworkVersion` del framework, no el del proyecto
      (SC-006)
- [ ] El mensaje de error de `validate-specboot.sh` cuando `installed < declared`
      sugiere verificar la instalación (SC-007)
- [ ] La spec `specboot-workflows` declara node `'24'` (coherente con el archivo y
      con `workflow-node-upgrade`) y el wiring de auth como requisito (SC-008)
- [ ] `tests/version-resolution-test.sh` y `tests/consumer-ci-auth-test.sh` verdes con
      asserts `[SC-NNN]`; `tests/mandatory-steps-test.sh` migrado al pin `0.6.4`
- [ ] `package.json` en `0.6.4` + entrada `## [0.6.4]` en CHANGELOG sin
      `### Breaking changes`
- [ ] `bash check-refs.sh` y `bash specboot.sh --ci` reportan 0 errores
