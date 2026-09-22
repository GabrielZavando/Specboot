# Proposal: Proveer historial completo al self-check del workflow de release

- **Ticket ID**: SPECBOOT-HARDEN-03
- **Título original**: Proveer historial completo al self-check del workflow de release
- **Prioridad**: Alta
- **Tag**: `[ci]` (explícito) — CI/tooling del framework; sin estándares de
  dominio que cargar (solo base standards + AGENTS, ya pre-cargados).
- **Change name**: `release-validate-depth`
- **Change type**: tooling/CI — hardening del workflow interno de release del
  propio framework; sin entidades de dominio ni endpoints API.

## Why

Tras fusionar SPECBOOT-HARDEN-02, los checks del PR pasan porque el job `validate`
de `.github/workflows/ci.yml` usa `fetch-depth: 0`. Sin embargo, el push a `main`
ejecuta `.github/workflows/release.yml`, cuyo job `validate` ("Framework
self-check + tests") conserva el checkout superficial predeterminado.
`tests/specboot-update-test.sh` consulta variantes históricas de
`.github/workflows/release.yml` mediante `git show`/`git log`, por lo que el
workflow de release falla con 10 errores y bloquea correctamente la publicación.

## What Changes

Incluido:

- **REQ-001 — Historial completo en validate**: el checkout del job `validate` de
  `.github/workflows/release.yml` debe declarar `fetch-depth: 0`.
- **REQ-002 — publish intacto y dependiente**: el checkout del job `publish` debe
  permanecer sin cambios y la publicación debe seguir dependiendo de `validate`
  (`needs: validate`).
- **REQ-003 — Contrato por job**: `tests/release-workflow-test.sh` debe verificar
  que `fetch-depth: 0` pertenece exclusivamente al job `validate` (no al `publish`).
- **REQ-004 — Regresión verde**: la corrección debe mantener verdes
  `tests/release-workflow-test.sh`, `tests/specboot-update-test.sh`,
  `tests/run-all.sh`, `specboot.sh --ci` y `check-refs.sh`.

Fuera de alcance (per ticket): cambiar fingerprints históricos, cambiar la versión
o lógica de publicación, modificar `.github/workflows/ci.yml`, reabrir o alterar el
change archivado `SPECBOOT-HARDEN-02`.