# Requirements — SPECBOOT-HARDEN-03: release-validate-depth

> Rastro: cada REQ traza a sus escenarios en `scenarios.md` (SC-001..SC-004).

## REQ-001 — Historial completo en el self-check de release

El paso `actions/checkout` del job `validate` de `.github/workflows/release.yml`
debe declarar `fetch-depth: 0`, de modo que el self-check y las pruebas de
proveniencia histórica (`tests/specboot-update-test.sh`) dispongan del historial
git completo y no falle en el push a `main`.

**Traza**: SC-001.

## REQ-002 — publish intacto y dependiente de validate

El paso `actions/checkout` del job `publish` de `.github/workflows/release.yml`
debe permanecer sin cambios (sin `fetch-depth: 0`). El job `publish` debe seguir
declarando `needs: validate` para que la publicación nunca se ejecute sin que el
self-check haya pasado.

**Traza**: SC-002, SC-003.

## REQ-003 — Contrato por job en el test de release

`tests/release-workflow-test.sh` debe verificar que `fetch-depth: 0` se declara
exclusivamente en el job `validate` y que NO aparece en el job `publish`, de modo
que cualquier regresión (pérdida en `validate` o intrusión en `publish`) se
detecte como fallo del test de contrato.

**Traza**: SC-004.

## REQ-004 — Regresión verde

La corrección debe mantener verdes `tests/release-workflow-test.sh`,
`tests/specboot-update-test.sh`, `tests/run-all.sh`, `specboot.sh --ci` y
`check-refs.sh`. Como REQ-001 evoluciona el `release.yml` interno (su
fingerprint deja de coincidir con los variantes legacy distribuidos), el fixture
del test de reparación legacy (`tests/specboot-update-test.sh`, Test 12) debe
derivar de un variante legacy real del historial git (v3) en lugar de copiar el
archivo interno vivo — sin alterar la allowlist de fingerprints históricos.

**Traza**: SC-001, SC-004.