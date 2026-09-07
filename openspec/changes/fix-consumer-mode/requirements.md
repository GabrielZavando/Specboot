# Requirements: fix-consumer-mode

## REQ-001: `--version` consumer-safe (→ SC-001, SC-003)

- **Descripción**: `specboot.sh` SHALL resolver la versión del framework de forma
  consumer-safe mediante el helper `resolve_framework_version()`, con precedencia:
  (1) `node_modules/@gabrielzavando/specboot/package.json` relativo al directorio de
  trabajo, (2) el `package.json` junto al script (`$SCRIPT_DIR`). La resolución SHALL
  NOT devolver la versión del `package.json` raíz del proyecto consumidor. En
  dogfooding (sin self-dependency en `node_modules`) el fallback `$SCRIPT_DIR` SHALL
  devolver la versión del framework igual que antes del fix.
- **Racional**: `--version` es contrato público (spec `specboot-json-standard`,
  "specboot.sh is self-validating") usado por `validate-specboot.sh` como fuente
  preferida; hoy devuelve la versión del proyecto en consumidores y dispara el error
  duro irónico en `--ci`. Fix en el origen, no en el consumidor del contrato.

## REQ-002: Normalización de rutas bare en `get_framework_version` (→ SC-002)

- **Descripción**: `get_framework_version()` en `specboot.sh` SHALL normalizar el
  directorio recibido a una ruta de filesystem explícita antes del `require()`
  (`case`: `/*` y `./*` pasan sin cambios; el resto se prefija `./`), porque Node
  interpreta un bare specifier (`node_modules/...`) como nombre de paquete y falla
  silenciosamente bajo `2>/dev/null`.
- **Racional**: sub-bug 2b del ticket — cualquier llamada con rutas bare devuelve
  vacío sin rastro y enmascara el resto del fix.

## REQ-003: `specboot init` escribe el frameworkVersion del framework (→ SC-006)

- **Descripción**: `create_initial_specboot_json()` SHALL usar el helper compartido
  `resolve_framework_version()` (en lugar de la llamada bare a
  `get_framework_version`) para escribir `frameworkVersion` en el `.specboot.json`
  que `init` crea, de modo que siempre refleje la versión del framework.
- **Racional**: tercera manifestación de la misma causa raíz (descubierta en sesión):
  hoy un consumidor con `package.json` raíz recibe su propia versión como
  `frameworkVersion`, violando la spec `specboot-init` ("`frameworkVersion` from the
  framework") y provocando un warning espurio de "framework desactualizado" en la
  primera validación.

## REQ-004: Wiring de autenticación de consumidor en `ci.yml` (→ SC-004)

- **Descripción**: El `ci.yml` distribuido SHALL incluir, a nivel workflow,
  `permissions` con `contents: read` y `packages: read`, y `env`
  `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}`. Cada job que ejecute `npm install`
  (`validate` y `project-ci`) SHALL usar `actions/setup-node` con
  `registry-url: https://npm.pkg.github.com`. SHALL conservar los contratos vigentes:
  jobs `validate` + `project-ci`, `make ci` en `project-ci`, actions v5 + node `'24'`,
  `hashFiles` solo a nivel step.
- **Racional**: el mecanismo de auth depende de la cadena completa (`registry-url`
  escribe `~/.npmrc` con el placeholder `_authToken=${NODE_AUTH_TOKEN}`; el token
  necesita scope `packages: read`). Sin los tres eslabones, npm llega a GitHub
  Packages sin credenciales (E401) — y `specboot update` reinstala el wiring roto en
  cada update (regresión recurrente). En dogfooding es inofensivo: el `GITHUB_TOKEN`
  del repo del framework puede leer sus propios paquetes.

## REQ-005: Cadena de validación de versión verde en consumidor (→ SC-005)

- **Descripción**: La cadena `validate-specboot.sh` → `specboot.sh --version` SHALL
  resolver la versión instalada correctamente en un contexto consumer-like (fixture:
  `package.json` raíz señuelo + `node_modules/@gabrielzavando/specboot`), de modo que
  la comparación contra `frameworkVersion` produzca pass/warn/error correctos y no el
  falso "proyecto requiere versión más nueva del framework".
- **Racional**: es la ruta exacta por la que `specboot.sh --ci` fallaba en
  consumidores recién actualizados (proxy determinista; el E401 real y el `--ci`
  completo se smookean post-release).

## REQ-006: Mensaje de error orientativo en `validate-specboot.sh` (→ SC-007)

- **Descripción**: Cuando la comparación determina `installed < declared`, el warning
  de `validate-specboot.sh` SHALL incluir además la sugerencia de verificar la
  instalación (`npm ls @gabrielzavando/specboot`).
- **Racional**: mejora adicional del ticket (aceptada por el mantenedor) — orienta el
  diagnóstico exactamente en el escenario que dispara el error/warning.

## REQ-007: Coherencia de la spec `specboot-workflows` con el archivo (→ SC-008)

- **Descripción**: La capability `specboot-workflows` SHALL declarar, vía delta de
  este change, el requisito `## ADDED` de wiring de autenticación de consumidor
  (REQ-004) y el `## MODIFIED` del requisito de versión de Node a `'24'` (alineado
  con la capability `workflow-node-upgrade`), conservando el nombre del requirement
  original para que el delta matchee.
- **Racional**: el requisito stale (`node-version: 20`) contradice el archivo que este
  mismo change edita; los requisitos de los jobs `validate`/`project-ci` no cambian
  (los guards dependen de sus headers literales).

## REQ-008: Bump patch `0.6.4` con CHANGELOG sin ruptura y pins migrados (→ SC-003, SC-005)

- **Descripción**: Al completar el change, `package.json` SHALL declarar `0.6.4`,
  `.specboot.json` SHALL reflejar `frameworkVersion: 0.6.4` (dogfooding) y
  `CHANGELOG.md` SHALL incluir la entrada `## [0.6.4]` sin sección
  `### Breaking changes`. El pin de versión de `tests/mandatory-steps-test.sh`
  (SC-007 de ese guard) SHALL migrarse de `0.6.3` a `0.6.4`.
- **Racional**: spec `version-bump` (el mantenedor bumpa antes del merge) + matriz de
  `docs/versioning-standard.md` §3 (bugfix sin cambio de contrato = patch). El pin
  hardcodeado del guard debe viajar con el bump (precedente 0.6.2→0.6.3).
