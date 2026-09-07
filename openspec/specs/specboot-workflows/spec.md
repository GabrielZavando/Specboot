# specboot-workflows Specification

## Purpose
TBD - created by archiving change specboot-workflows. Update Purpose after archive.
## Requirements
### Requirement: `ci.yml` has a `validate` job (framework dogfooding) with conditional self-tests
`ci.yml` SHALL include a `validate` job running `bash check-refs.sh`,
`bash specboot.sh --ci`, and the framework's own self-tests
(`tests/check-refs-test.sh`, `tests/solid-templates-test.sh`, `tests/update-test.sh`).
The self-test step SHALL be gated by step-level `hashFiles` so it is skipped in a
consumer repo (where `tests/` is not published) and the job stays green.

#### Scenario: validate runs self-check plus framework self-tests in the framework repo
- **GIVEN** the Specboot framework repo (has `tests/check-refs-test.sh`, `tests/solid-templates-test.sh`, `tests/update-test.sh`)
- **WHEN** the `validate` job runs
- **THEN** it runs `bash check-refs.sh`, `bash specboot.sh --ci`, and the three `tests/*-test.sh` scripts

#### Scenario: validate self-tests are skipped in a consumer repo
- **GIVEN** a consumer project without `tests/`
- **WHEN** the `validate` job runs
- **THEN** the self-test step is skipped via step-level `hashFiles` and the job stays green

### Requirement: `ci.yml` has a `project-ci` job running `make ci`
`ci.yml` SHALL include a `project-ci` job that runs `make ci` (the project's CI gate:
`refs` + `solid-lint` + `lint` + `test` + `audit`). It SHALL NOT invoke
`specboot.sh --ci`.

#### Scenario: project-ci runs the project gate
- **GIVEN** any project
- **WHEN** the `project-ci` job runs
- **THEN** it executes `make ci` and does not call `specboot.sh --ci`

### Requirement: No `hashFiles()` in job-level `if`
Neither `ci.yml` nor `deploy.yml` SHALL use `hashFiles()` in a job-level `if` (invalid
job context). `hashFiles()` is allowed only in `steps[*].if`.

#### Scenario: no job-level hashFiles in ci.yml
- **GIVEN** the change applied
- **WHEN** `grep -nE '^\s*if:.*hashFiles' .github/workflows/ci.yml` runs
- **THEN** it matches zero job-level lines (any match is inside a `steps:` block)

#### Scenario: hashFiles used only at step level in deploy.yml
- **GIVEN** the change applied
- **WHEN** `deploy.yml` is inspected
- **THEN** `hashFiles('Dockerfile')` appears only in `steps[*].if`, never in a job `if`

### Requirement: `deploy.yml` gated by `vars.DEPLOY_ENABLED` at job level
`deploy.yml` SHALL gate every deploy job with `if: vars.DEPLOY_ENABLED == 'true'`
(job level). Build/SSH steps SHALL additionally be gated on Dockerfile presence via
step-level `hashFiles('Dockerfile')`.

#### Scenario: deploy skipped when DEPLOY_ENABLED is not 'true'
- **GIVEN** a repo where `vars.DEPLOY_ENABLED` is unset or `'false'`
- **WHEN** a `v*` tag is pushed
- **THEN** no job in `deploy.yml` executes

#### Scenario: deploy builds and deploys when enabled with a Dockerfile
- **GIVEN** `vars.DEPLOY_ENABLED == 'true'`, `vars.DOCKER_REPO`/`DEPLOY_HOST`/`DEPLOY_USER` set, `secrets.DEPLOY_SSH_KEY` set, and a `Dockerfile` exists
- **WHEN** a `v*` tag is pushed
- **THEN** `deploy-staging` (and `deploy-production` on a tag) build the image and run it on the remote host via SSH

#### Scenario: deploy skips Docker steps when no Dockerfile
- **GIVEN** `vars.DEPLOY_ENABLED == 'true'` but no `Dockerfile`
- **WHEN** `deploy.yml` runs
- **THEN** the Docker build/SSH steps are skipped (step-level `hashFiles('Dockerfile')`)

### Requirement: `deploy.yml` uses only `vars.DEPLOY_*` / `secrets.DEPLOY_*`
`deploy.yml` SHALL be parametrized exclusively via GitHub repo `vars`
(`DOCKER_REPO`, `DEPLOY_HOST`, `DEPLOY_USER`) and `secrets` (`DEPLOY_SSH_KEY`).
No framework-specific infrastructure (ghcr.io, GitHub Release, Slack) is hardcoded.

#### Scenario: deploy has no hardcoded framework infrastructure
- **GIVEN** the change applied
- **WHEN** `deploy.yml` is inspected
- **THEN** it references `${{ vars.DOCKER_REPO }}`, `${{ vars.DEPLOY_HOST }}`, `${{ vars.DEPLOY_USER }}`, `${{ secrets.DEPLOY_SSH_KEY }}` and contains no `ghcr.io`, `github.repository`, Slack, or `softprops/action-gh-release`

### Requirement: `ci.yml` uses `node-version: 20`
`ci.yml` SHALL set `node-version: '24'` in both jobs (`validate` and `project-ci`), superseding the previous Node 20 requirement in line with the `workflow-node-upgrade` capability (`actions/checkout@v5` + `actions/setup-node@v5` + Node 24). The requirement name is kept unchanged so the delta matches; its content reflects the shipped workflow.

#### Scenario: ci.yml pins Node 24
- **GIVEN** the change applied
- **WHEN** `ci.yml` is inspected
- **THEN** both `validate` and `project-ci` use `node-version: '24'`

### Requirement: Documentation describes intocable + parametrizable workflows
`docs/framework-contract.md` and `README.md` SHALL document the workflows as
intocable (replaced by `specboot update`) and parametrizable via GitHub
vars/secrets. No edit introduces a broken `{file:...}` reference.

#### Scenario: docs reflect behavior without broken refs
- **GIVEN** the change applied
- **WHEN** `bash check-refs.sh` runs
- **THEN** it reports 0 errors

### Requirement: No regression in framework checks or YAML validity
After the change, the YAML of both workflows SHALL parse, `check-refs.sh` SHALL stay
green, and `specboot.sh --ci` SHALL report no new errors.

#### Scenario: framework self-check stays green
- **GIVEN** the change applied to the framework repo
- **WHEN** `python -c "import yaml; yaml.safe_load(...)"` for both files, `bash check-refs.sh`, and `bash specboot.sh --ci` run
- **THEN** YAML parses and both checks pass with no new errors

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

