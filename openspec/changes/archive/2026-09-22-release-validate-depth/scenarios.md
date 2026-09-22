# Scenarios — SPECBOOT-HARDEN-03: release-validate-depth

> Mapeo 1:1 de los escenarios de aceptación del ticket (SC-001..SC-004),
> preservando sus IDs. Change de tooling/CI del framework: no hay entidades de
> dominio ni endpoints API que verificar (Step 4½: "none", sin conflictos).

### SC-001: El self-check de release recibe historial completo

- **GIVEN** un push a `main` que ejecuta `.github/workflows/release.yml`
- **WHEN** se ejecuta el job `validate` ("Framework self-check + tests")
- **THEN** su paso `actions/checkout` declara `fetch-depth: 0`
- **AND** `tests/specboot-update-test.sh` (que consulta variantes históricas de
  `.github/workflows/release.yml` vía `git show`/`git log`) pasa al tener historial
  completo

### SC-002: El job publish permanece intacto y dependiente de validate

- **GIVEN** el workflow de release con `fetch-depth: 0` en el job `validate`
- **WHEN** se inspecciona el job `publish`
- **THEN** su checkout `actions/checkout` NO declara `fetch-depth: 0` (sigue sin
  cambios)
- **AND** el job `publish` conserva `needs: validate`

### SC-003: validate bloquea publish

- **GIVEN** el job `publish` con `needs: validate`
- **WHEN** el job `validate` falla
- **THEN** el job `publish` no se ejecuta

### SC-004: El contrato detecta un fetch-depth mal ubicado

- **GIVEN** `tests/release-workflow-test.sh` verificando que `fetch-depth: 0`
  pertenece exclusivamente al job `validate`
- **WHEN** `fetch-depth: 0` desaparece del job `validate` o se agrega
  accidentalmente al job `publish`
- **THEN** el test de contrato falla (exit ≠ 0)