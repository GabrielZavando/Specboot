# Scenarios — fix-consumer-ci-yaml

Fuente: ticket SPECBOOT-HOTFIX-01 — escenarios SC-001..SC-003 mapeados 1:1 con IDs
preservados; SC-004 derivado de REQ-005 para trazabilidad y cobertura de edge cases.

### SC-001: GitHub Actions procesa la plantilla sin error de sintaxis
- **Given** la plantilla `templates/github/workflows/consumer-ci.yml` corregida
  (el valor `name` del step "Project gate" sin `: ` ambiguo o correctamente
  entrecomillado)
- **When** un parser YAML (`python3 -c "import yaml; yaml.safe_load(...)"`) la
  procesa y GitHub Actions la carga como workflow
- **Then** el parseo es válido, el job `ci` se crea sin error de sintaxis y la
  prueba de regresión `tests/consumer-ci-yaml-test.sh` pasa (exit 0)

### SC-002: El name del step con ": " sin comillas hace fallar la prueba de regresión
- **Given** la plantilla `consumer-ci.yml` con un valor `name` no entrecomillado
  que contiene `: ` (la línea 42 de 0.11.0: `Project gate (make ci: refs +
  solid-lint + lint + test + audit)`)
- **When** la prueba de regresión corre (`bash tests/consumer-ci-yaml-test.sh`)
- **Then** falla (exit 1) reportando el `name` ambiguo y su línea: la plantilla
  no parsea como YAML válido (YAML rechaza `: ` en un escalar plano)

### SC-003: El consumidor obtiene un ci.yml válido tras specboot update con 0.11.1
- **Given** un proyecto consumidor con Specboot 0.11.0 (ci.yml roto) y la
  versión 0.11.1 publicada
- **When** el consumidor ejecuta `specboot update`
- **Then** la política tri-estado vigente (SPECBOOT-HARDEN-04,
  `docs/versioning-standard.md` §5.1) respalda la variante histórica conocida
  (0.11.0 está en la allowlist de fingerprints) en `.specboot-backup-*/` e
  instala la plantilla 0.11.1 corregida como `.github/workflows/ci.yml`, que es
  YAML válido para GitHub Actions

### SC-004: Workflows internos y código de negocio permanecen intactos (restricción transitoria del change)
- **Given** el change aplicado
- **When** se inspecciona el diff del change
- **Then** solo cambian la plantilla `templates/github/workflows/consumer-ci.yml`,
  el test nuevo `tests/consumer-ci-yaml-test.sh`, los archivos de versión
  (`package.json`, `package-lock.json`, `.specboot.json`, `CHANGELOG.md`) y los
  artefactos OpenSpec; `.github/workflows/*` interno y el código de negocio no
  se modifican (REQ-005)
- **Naturaleza y verificación**: restricción TRANSITORIA de este change — su
  verificación es la revisión del diff actual (git status/diff), evidencia
  documentada por `/verify`; NO es un contrato permanente del test permanente
  (`tests/consumer-ci-yaml-test.sh`): los asserts `[SC-004]` se retiraron de él
  (WARNING de `/adversarial-review` — tras el archive, falsearían "scope
  violation" en cambios futuros que toquen archivos fuera del allowlist de
  este hotfix o los workflows internos contra v0.11.0)
