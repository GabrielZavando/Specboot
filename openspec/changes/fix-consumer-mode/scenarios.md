# Scenarios: fix-consumer-mode

> IDs estables `SC-{NNN}` (convención M-102). SC-001..SC-005 preservan 1:1 los IDs
> propuestos en el ticket upstream; SC-006..SC-008 cubren la tercera manifestación
> del Bug 2, la mejora de mensaje y la coherencia de spec añadidas en sesión. Cada
> escenario es trazable a al menos un requisito de `requirements.md` y a un assert
> `[SC-NNN]` en `tests/version-resolution-test.sh` o `tests/consumer-ci-auth-test.sh`.

### SC-001: `--version` resuelve la versión del framework en modo consumidor

- **Given** un proyecto consumidor con `package.json` raíz version `9.9.9`
- **And** `node_modules/@gabrielzavando/specboot/package.json` con la versión real
  del framework (`0.6.4` en el fixture)
- **When** ejecuto `bash specboot.sh --version` desde la raíz del proyecto
- **Then** la salida es la versión del framework (no `9.9.9`)

### SC-002: `get_framework_version` resuelve rutas relativas bare

- **Given** un directorio `node_modules/@gabrielzavando/specboot` con un
  `package.json` válido
- **When** llamo a `get_framework_version "node_modules/@gabrielzavando/specboot"`
- **Then** la salida es la versión de ese `package.json` (no vacío)
- **And** la ruta bare fue normalizada a ruta de filesystem explícita antes del
  `require()` (un bare specifier no resuelve como archivo)

### SC-003: Dogfooding no se rompe

- **Given** el repo del framework (sin self-dependency en `node_modules`)
- **When** ejecuto `bash specboot.sh --version` desde la raíz del framework
- **Then** la salida es la versión del `package.json` del framework (fallback
  `$SCRIPT_DIR`, comportamiento idéntico al previo al fix)

### SC-004: `ci.yml` del template trae auth de consumidor

- **Given** el `ci.yml` distribuido por el framework (`.github/workflows/ci.yml`,
  que `specboot update` reemplaza archivo por archivo)
- **Then** declara `packages: read` en `permissions` (workflow-level)
- **And** declara `env` `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}`
- **And** cada job con `npm install` (`validate` y `project-ci`) usa
  `actions/setup-node` con `registry-url: https://npm.pkg.github.com`
- **And** conserva los contratos vigentes: jobs `validate` + `project-ci`,
  `make ci` en `project-ci`, actions v5 + node `'24'`, `hashFiles` solo a nivel step

### SC-005: La cadena de validación de versión pasa en un consumidor (fixture)

- **Given** un fixture consumer-like: `package.json` raíz señuelo `9.9.9`,
  `node_modules/@gabrielzavando/specboot/package.json` con la versión del framework,
  y un `.specboot.json` cuyo `frameworkVersion` coincide con la instalada
- **When** ejecuto `bash validate-specboot.sh` desde el fixture (la misma cadena que
  dispara `specboot.sh --ci` vía `check_specboot_json`)
- **Then** exit 0 con el pass "frameworkVersion coincide con la instalada"
- **And** ningún error duro de comparación de versiones (proxy determinista del
  escenario "specboot.sh --ci pasa en un consumidor recién actualizado"; el E401 real
  y el `--ci` completo se smookean post-release — el guard grep de SC-004 es el proxy
  a nivel CI, igual que `release-workflow-test.sh` para `release.yml`)

### SC-006: `specboot init` escribe el frameworkVersion del framework

- **Given** un proyecto consumidor con `package.json` raíz version `9.9.9` y
  `node_modules/@gabrielzavando/specboot/package.json` con la versión del framework
- **When** `specboot init` crea el `.specboot.json` del proyecto
  (`create_initial_specboot_json` con la resolución consumer-safe)
- **Then** `frameworkVersion` es la versión del framework (no `9.9.9`)
- **And** el comportamiento es consistente con la spec `specboot-init`
  ("`frameworkVersion` from the framework")

### SC-007: Mensaje de error orientativo cuando installed < declared

- **Given** un proyecto cuyo `frameworkVersion` declarado es menor que la versión
  instalada del framework (p. ej. tras el fix, cuando el contrato `--version` ya no
  enmascara el estado real)
- **When** `validate-specboot.sh` compara ambas versiones y el resultado es "menor"
- **Then** el warning incluye la sugerencia de verificar la instalación
  (`npm ls @gabrielzavando/specboot`) además del aviso de correr `specboot update`

### SC-008: La spec specboot-workflows es coherente con el archivo

- **Given** la capability `specboot-workflows` y el `ci.yml` real (que usa
  `node-version: '24'` por la capability `workflow-node-upgrade`)
- **When** la spec se enmienda vía delta `## MODIFIED` de este change
- **Then** el requisito de versión declara node `'24'` (eliminando la contradicción
  stale `node-version: 20`)
- **And** el wiring de autenticación de consumidor queda declarado como requisito
  `## ADDED` con sus escenarios
- **And** los requisitos de los jobs `validate` y `project-ci` no cambian de nombre
  ni de esencia (los guards `ci-evaluation-test.sh` y `solid-templates-test.sh`
  dependen de ellos)
