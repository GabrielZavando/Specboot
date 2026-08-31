# Requirements: Fix npm publish — bump to 0.1.2 and normalize bin path

Cada requisito es trazable a uno o más escenarios de `scenarios.md`.

## REQ-001 — Versión 0.1.2 lista para publicar

`package.json` SHALL declare `"version": "0.1.2"` (patch bump from the already-published
`0.1.1`), so that the next push to `main` publishes a NEW version via `release.yml`
without the `You cannot publish over the previously published versions` error.

- Trazable a: Scenario 1.

## REQ-002 — Entrada CHANGELOG 0.1.2

`CHANGELOG.md` SHALL contain a `## [0.1.2] - <date>` entry (Keep a Changelog format)
documenting the publish fix and the bin path normalization.

- Trazable a: Scenario 1.

## REQ-003 — Bin path pre-normalizado

`package.json` SHALL declare `"bin": { "specboot": "specboot.sh" }` (no `./` prefix),
matching the value npm normalizes to, so `npm publish` emits no
`"bin[specboot]" script name ... was invalid and removed` warning. The `bin.specboot`
entry SHALL still point to the shipped `specboot.sh` script.

- Trazable a: Scenario 2.

## REQ-004 — Spec npm-distribution reconciliada

`openspec/specs/npm-distribution/spec.md` Requirement "Package configuration" SHALL
state the bin entry points to `specboot.sh` (without the `./` prefix) and SHALL
reference version `0.1.2`, staying consistent with `package.json`.

- Trazable a: Scenario 3.

## REQ-005 — Sin regresión

After the change: `npm publish --dry-run` SHALL emit no bin normalization warning,
`bash check-refs.sh` SHALL report 0 errors, `bash specboot.sh --ci` SHALL report
0 errors, `make ci` SHALL exit 0, and all `tests/*-test.sh` SHALL pass.

- Trazable a: Scenario 4.
