# specboot-json-standard Specification (delta — change fix-consumer-mode)

> Consumer-safe resolution del contrato `specboot.sh --version`: hoy
> `show_version()` lee el `package.json` del CWD (en consumidores: el del proyecto)
> y `get_framework_version()` falla silenciosamente con rutas bare
> (`require('node_modules/...')` es un bare specifier, no una ruta). Además
> `create_initial_specboot_json()` escribe la versión del proyecto como
> `frameworkVersion` en el `init` de un consumidor. El requisito modificado fija la
> resolución en el origen (helper compartido `resolve_framework_version()`) sin
> cambiar el resto del contrato (`--ci` tolerante se conserva íntegro).

## MODIFIED Requirements

### Requirement: specboot.sh is self-validating
`specboot.sh` MUST expose a `--version` flag printing the FRAMEWORK's version, resolved consumer-safe via the shared helper `resolve_framework_version()` in order: (1) `node_modules/@gabrielzavando/specboot/package.json` relative to the working directory, (2) the `package.json` next to the script (`$SCRIPT_DIR`). Resolution MUST NOT return the consumer project's root `package.json` version. In the framework repo (no self-dependency in `node_modules`) the `$SCRIPT_DIR` fallback MUST return the framework version exactly as before. `get_framework_version` MUST normalize a received directory without an explicit filesystem prefix (`/`, `./`, `../`) into an explicit filesystem path, because Node's `require()` interprets a bare specifier (e.g. `node_modules/...`) as a package name and fails silently. `create_initial_specboot_json` MUST use the same shared helper so `specboot init` writes the framework's version (never the project's) as `frameworkVersion`. `specboot.sh --ci` MUST run `validate-specboot.sh` via a `check_specboot_json` step. The hook MUST be tolerant: a missing `.specboot.json` is a warning, not a CI error.

#### Scenario: specboot.sh --version prints the framework version (dogfooding)
- **Given** the framework repository (no self-dependency in `node_modules`)
- **When** `specboot.sh --version` runs
- **Then** it prints the framework's `package.json` version

#### Scenario: --ci runs validation tolerantly
- **Given** `specboot.sh --ci` executes
- **When** `validate-specboot.sh` is invoked through `check_specboot_json`
- **Then** a missing `.specboot.json` produces a warning and does not increment CI errors

#### Scenario: --ci fails on a hard config error
- **Given** a project whose `.specboot.json` is invalid, missing a required field, or points to a non-existent `services` path
- **When** `specboot.sh --ci` runs `check_specboot_json`
- **Then** the validator's non-zero exit is captured directly and `specboot.sh --ci` increments ERRORS and fails CI

#### Scenario: --version resolves the framework version in a consumer project
- **Given** a consumer project whose root `package.json` declares version `9.9.9`
- **And** `node_modules/@gabrielzavando/specboot/package.json` declares the real framework version
- **When** `bash specboot.sh --version` runs from the project root
- **Then** the output is the framework version, not `9.9.9`

#### Scenario: get_framework_version resolves bare relative paths
- **Given** a directory `node_modules/@gabrielzavando/specboot` with a valid `package.json`
- **When** `get_framework_version "node_modules/@gabrielzavando/specboot"` runs
- **Then** the output is that package's version (not empty)

#### Scenario: init writes the framework version as frameworkVersion
- **Given** a consumer project whose root `package.json` declares version `9.9.9` and `node_modules/@gabrielzavando/specboot/package.json` declares the framework version
- **When** `specboot init` creates `.specboot.json` in the project
- **Then** `frameworkVersion` equals the framework version, not `9.9.9`
