# Requirements: Cierre de Fase 6 — cleanup publish.yml, bump node 24, limpiar clutter, reconciliar docs

Cada requisito es trazable a uno o más escenarios de `scenarios.md`.

## REQ-001 — publish.yml eliminado; release.yml es el único workflow de publicación

`.github/workflows/publish.yml` SHALL NOT exist; `.github/workflows/release.yml` SHALL be the
only publication workflow, triggered by `push: branches: [main]` and
`release: types: [published]`.

- Trazable a: Scenario 1.

## REQ-002 — release.yml y ci.yml usan actions@v5 y node 24

`release.yml` and `ci.yml` SHALL use `actions/checkout@v5`,
`actions/setup-node@v5`, and `node-version: '24'` (eliminate Node 20 deprecation warning).

- Trazable a: Scenario 2.

## REQ-003 — El árbol de trabajo no contiene Digital/ ni .openspec/

The working tree SHALL NOT contain `Digital/` or `.openspec/`; `.npmignore`
SHALL retain the legacy `.openspec/` exclusion as a safety net (unchanged).

- Trazable a: Scenario 3.

## REQ-004 — Specs activas reconciliadas con el modelo release.yml

`openspec/specs/npm-distribution/spec.md` SHALL require `release.yml`
(not `publish.yml`); `openspec/specs/workflow-node-upgrade/spec.md` SHALL require
`release.yml` and `ci.yml` at `@v5`/node24; `openspec/specs/specboot-release/spec.md`
SHALL add a requirement consolidating `workflow-node-upgrade` (node 24).

- Trazable a: Scenario 4, Scenario 9.

## REQ-005 — README.md refleja el modelo npm + specboot init / specboot update

`README.md` SHALL lead the Quick Start with `npm install --save-dev
@gabrielzavando/specboot` + `specboot init`; the `git clone` flow SHALL be moved to a
secondary "Desarrollo del framework (maintainers)" note; `update.sh` SHALL be documented as
`--bump` maintainer-only and **not published** (consumer flow is `specboot update`).

- Trazable a: Scenario 5.

## REQ-006 — framework-contract.md lista los tres workflows del framework

`docs/framework-contract.md` §"Workflows del framework" SHALL list
`ci.yml`, `deploy.yml`, **and `release.yml`** with their triggers (push to `main` / Release
published), and SHALL state that `release.yml` does not invoke `update.sh --bump`.

- Trazable a: Scenario 6.

## REQ-007 — No regression en todas las validaciones del framework

No regression — `check-refs.sh`, `specboot.sh --ci`, `validate-specboot.sh`,
`make ci`, `bash scripts/dogfood-check.sh`, and all `tests/*-test.sh` SHALL pass after
the change. Additionally:
- `ci.yml` SHALL run the same 9 self-tests as `release.yml` (not a subset of 3).
- `tests/update-test.sh` SHALL test the `--bump` mode (not the deprecated sync mode).

- Trazable a: Scenario 7, Scenario 8, Scenario 10.
