# specboot-workflows Specification (delta — change fix-consumer-mode)

> Añade el wiring de autenticación de GitHub Packages que el `ci.yml` distribuido
> necesita en modo consumidor (E401 en `npm install`: sin `packages: read`, sin
> `NODE_AUTH_TOKEN`, sin `registry-url`) y corrige el requisito stale de Node 20
> (el archivo real usa `'24'` por la capability `workflow-node-upgrade`). Los
> requisitos de los jobs `validate` y `project-ci` NO se modifican (los guards
> `ci-evaluation-test.sh` y `solid-templates-test.sh` dependen de ellos).

## ADDED Requirements

### Requirement: ci.yml ships consumer authentication wiring for GitHub Packages
The distributed `ci.yml` MUST include, at workflow level, `permissions` declaring `contents: read` AND `packages: read`, and `env` declaring `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}`. Every job that runs `npm install` MUST use `actions/setup-node` with `registry-url: https://npm.pkg.github.com`. The wiring MUST be harmless in dogfooding (the framework repo's own `GITHUB_TOKEN` can read its own packages) and MUST survive every `specboot update` (the file is intocable-replaced, so each update reinstalls the correct wiring instead of reintroducing the E401 regression). The two-job design (`validate` + `project-ci`), the `make ci` project gate, actions v5, and step-level-only `hashFiles` MUST be preserved.

#### Scenario: permissions include packages read
- **WHEN** the distributed `ci.yml` is inspected
- **THEN** workflow-level `permissions` declares `contents: read` and `packages: read`

#### Scenario: NODE_AUTH_TOKEN is declared at workflow level
- **WHEN** the distributed `ci.yml` is inspected
- **THEN** workflow-level `env` declares `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}`

#### Scenario: every npm-install job authenticates the registry
- **GIVEN** both `validate` and `project-ci` jobs run `npm install`
- **WHEN** their `actions/setup-node` steps are inspected
- **THEN** each sets `registry-url: https://npm.pkg.github.com` (2 occurrences)

#### Scenario: dogfooding behavior is unchanged
- **GIVEN** the Specboot framework repo
- **WHEN** the `validate` job runs with the new wiring
- **THEN** `npm install`, `check-refs.sh`, `specboot.sh --ci`, and the self-tests behave exactly as before (the added auth is inert without GitHub Packages dependencies)

## MODIFIED Requirements

### Requirement: `ci.yml` uses `node-version: 20`
`ci.yml` SHALL set `node-version: '24'` in both jobs (`validate` and `project-ci`), superseding the previous Node 20 requirement in line with the `workflow-node-upgrade` capability (`actions/checkout@v5` + `actions/setup-node@v5` + Node 24). The requirement name is kept unchanged so the delta matches; its content reflects the shipped workflow.

#### Scenario: ci.yml pins Node 24
- **GIVEN** the change applied
- **WHEN** `ci.yml` is inspected
- **THEN** both `validate` and `project-ci` use `node-version: '24'`
