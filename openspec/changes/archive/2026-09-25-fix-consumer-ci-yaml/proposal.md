# fix-consumer-ci-yaml

**Ticket ID**: SPECBOOT-HOTFIX-01
**Title**: [ci] Corregir sintaxis YAML de la plantilla consumer CI y publicar 0.11.1
**Tag**: [ci]
**Branch**: feature/specboot-hotfix-01-ci-yaml-fix
**Status**: proposed

## Why

Specboot 0.11.0 distribuye `templates/github/workflows/consumer-ci.yml` con un valor `name` no entrecomillado que contiene `: ` (línea 42: `Project gate (make ci: refs + solid-lint + lint + test + audit)`). YAML no admite `: ` en un escalar plano, así que GitHub Actions rechaza el workflow con "Invalid workflow file: yaml syntax on line 42" — regresión confirmada en WebAppRiff PR #28: todo consumidor con 0.11.0 tiene el CI roto.

El hueco de guard: los tests existentes validan como YAML los workflows internos del repo (`.github/workflows/ci.yml`, `release.yml`) pero nunca la plantilla distribuible — el workflow interno formula el mismo step sin `: ` (`make ci (refs + ...)`, línea 58), por lo que la suite estaba verde mientras la plantilla rota llegó a 0.11.0.

## What Changes

- **Fix YAML (REQ-001, REQ-002)** — reformular el valor `name` del step "Project gate" de `templates/github/workflows/consumer-ci.yml` para eliminar el `: ` ambiguo (precedente de casa: el workflow interno usa `make ci (refs + solid-lint + lint + test + audit)` sin `: `), o entrecomillar el valor completo. Ningún otro cambio en el workflow: job `ci`, wiring de consumidor (auth GitHub Packages, Node 24, actions v5, `hashFiles` a nivel de step) intactos (REQ-005).
- **Guard de regresión (REQ-003)** — nuevo `tests/consumer-ci-yaml-test.sh` (patrón de casa de `tests/consumer-ci-auth-test.sh`: `python3 yaml.safe_load` + check dedicado anti-`: ` sin comillas en valores `name`), auto-descubierto por `tests/run-all.sh`. Delta de spec `## ADDED` sobre la capability `specboot-workflows`.
- **Patch release 0.11.1 (REQ-004)** — entrada `## [0.11.1]` en `CHANGELOG.md` (Keep a Changelog, `### Fixed` + `### Breaking changes: None`) y bump canónico `bash release-bump.sh 0.11.1` (atómico sobre `package.json`, `package-lock.json`, `.specboot.json`; nunca a mano ni con `npm version`; sin tags, sin commit).

### Out of scope

- Cambios funcionales del job `ci` (más allá del `name` del step).
- Modificaciones a WebAppRiff distintas de consumir 0.11.1.
- Workflows internos (`.github/workflows/*`) y código de negocio (REQ-005).
- Cambios en la política de `specboot update` (SPECBOOT-HARDEN-04 vigente, `docs/versioning-standard.md` §5.1).
