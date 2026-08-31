# Scenarios: Fix npm publish — bump to 0.1.2 and normalize bin path

## Acceptance Criteria

### Scenario 1: Versión 0.1.2 con entrada de CHANGELOG
- **Given** `package.json` declara `"version": "0.1.1"` (ya publicada en GitHub Packages) y el release anterior falló con `You cannot publish over the previously published versions: 0.1.1`
- **When** se aplica el change
- **Then** `package.json` declara `"version": "0.1.2"`
- **And** `CHANGELOG.md` contiene una entrada `## [0.1.2]` en formato Keep a Changelog
- **And** el próximo push a `main` dispara `release.yml` y publica `0.1.2` sin error de versión duplicada

### Scenario 2: bin pre-normalizado sin warning de publish
- **Given** `package.json` declara `"bin": { "specboot": "./specboot.sh" }` y `npm publish` emite `"bin[specboot]" script name ... was invalid and removed`
- **When** se aplica el change
- **Then** `package.json` declara `"bin": { "specboot": "specboot.sh" }` (sin prefijo `./`)
- **And** `npm publish --dry-run` NO emite ningún warning de normalización de bin
- **And** el campo `bin` sigue apuntando al script `specboot.sh` publicado en el tarball

### Scenario 3: Spec npm-distribution consistente con package.json
- **Given** `openspec/specs/npm-distribution/spec.md` Requirement "Package configuration" dice `bin.specboot` entry pointing to `./specboot.sh` y versión inicial `0.1.1`
- **When** se aplica el change
- **Then** el requirement dice bin entry pointing to `specboot.sh` (sin `./`)
- **And** el requirement referencia la versión `0.1.2`
- **And** `openspec validate` sobre el change pasa (delta MODIFIED válido)

### Scenario 4: Sin regresión en validaciones del framework
- **Given** el change aplicado al repositorio Specboot
- **When** se ejecutan `npm publish --dry-run`, `bash check-refs.sh`, `bash specboot.sh --ci`, `make ci` y todos los `tests/*-test.sh`
- **Then** `npm publish --dry-run` no emite warnings de bin
- **And** `check-refs.sh` y `specboot.sh --ci` reportan 0 errores
- **And** `make ci` termina en 0 y todos los tests pasan
