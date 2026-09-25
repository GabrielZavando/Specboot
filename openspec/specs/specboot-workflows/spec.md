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

`docs/framework-contract.md` and `README.md` SHALL document the workflows
distinguishing the Specboot repository's internal workflows (`release.yml`,
repo-only) from the consumer templates (`templates/github/`), stating that only
the consumer CI workflow is installed by default and that `init`/`update` use
explicit file lists. No edit introduces a broken `{file:...}` reference.

#### Scenario: docs distinguish internal workflows from consumer templates

- **GIVEN** the change applied
- **WHEN** `README.md` and `docs/framework-contract.md` are inspected
- **THEN** they distinguish internal workflows from consumer templates and
  state the default install set (consumer CI + PR template)

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

### Requirement: The internal release workflow stays repo-internal

`.github/workflows/release.yml` MUST exist only in the Specboot development
repository. It MUST NOT be included in the npm `files` allowlist, MUST NOT be
copied by `specboot init` or `specboot update`, and MUST NOT exist in any
template directory distributed to consumers. A consumer project MUST NOT receive
any workflow that executes `npm publish` of the Specboot package.

#### Scenario: Fresh init does not install the release workflow

- **GIVEN** the Specboot framework with `templates/github/workflows/`
- **WHEN** a new project runs `specboot init`
- **THEN** `.github/workflows/release.yml` does not exist in the project
- **AND** no installed file publishes the Specboot package

#### Scenario: update never copies the release workflow

- **GIVEN** a consumer project running `specboot update`
- **WHEN** the update copies framework workflow files
- **THEN** `release.yml` is never among them

### Requirement: Consumer workflow templates live in an explicit template location

The framework MUST ship consumer workflow artifacts under
`templates/github/`: `templates/github/workflows/consumer-ci.yml` (the only CI
workflow installed by default), `templates/github/workflows/deploy.example.yml`
(optional deploy template, never installed automatically) and
`templates/github/pull_request_template.md` (source of the PR template that
`init` installs into `.github/pull_request_template.md`).

#### Scenario: Templates exist and deploy template is not installed

- **GIVEN** the Specboot framework repository
- **WHEN** the template directory is inspected after a `specboot init` in a
  fresh project
- **THEN** `templates/github/workflows/consumer-ci.yml`,
  `templates/github/workflows/deploy.example.yml` and
  `templates/github/pull_request_template.md` exist
- **AND** the fresh project received `.github/workflows/ci.yml` (from the
  consumer template) and `.github/pull_request_template.md`
- **AND** `deploy.example.yml` was not installed as an active workflow

### Requirement: `specboot update` repairs a contaminated consumer safely

`specboot update` MUST detect a legacy framework-owned `release.yml` in the
consumer's `.github/workflows/`, back it up (`.specboot-backup-*/`) before
removing it when it matches the known framework-owned signature, warn and
require explicit resolution when the file was modified (never removing it
automatically), and MUST never delete or overwrite custom workflows unrelated
to the framework.

#### Scenario: Intact legacy release is backed up and removed

- **GIVEN** a consumer with the legacy framework-owned `release.yml` unmodified
- **WHEN** `specboot update` runs
- **THEN** the file is copied to the backup directory and then removed
- **AND** the removal and backup path are reported

#### Scenario: Modified legacy release requires explicit resolution

- **GIVEN** a consumer whose `release.yml` no longer matches the framework
  signature
- **WHEN** `specboot update` runs
- **THEN** the update warns and requires explicit resolution without deleting
  the file automatically

#### Scenario: Custom workflows survive the update

- **GIVEN** a consumer with a custom workflow unrelated to the framework
- **WHEN** `specboot update` runs
- **THEN** the custom workflow remains intact

### Requirement: init/update distribute workflows via explicit file lists

`specboot init` and `specboot update` MUST use explicit file lists for
GitHub-related artifacts and MUST NOT copy the `.github` tree as a whole. Only
the consumer CI workflow (from `templates/github/workflows/consumer-ci.yml`)
and the PR template are installed by default; the framework's internal
`release.yml` and `deploy.yml` are never copied.

#### Scenario: init installs CI and PR template only

- **GIVEN** a fresh project
- **WHEN** `specboot init` runs
- **THEN** the project receives `.github/workflows/ci.yml` and
  `.github/pull_request_template.md`
- **AND** no other `.github/workflows/*` file is created and the `.github` tree
  was never copied as a whole

### Requirement: The consumer CI template MUST be valid YAML for GitHub Actions (REQ-001)

`templates/github/workflows/consumer-ci.yml` SHALL parse as valid YAML for
GitHub Actions: no step `name` value SHALL contain ambiguous YAML syntax
(`: ` inside an unquoted plain scalar, which the Actions YAML parser rejects
with "Invalid workflow file"). The fix SHALL be limited to quoting or
rephrasing the offending `name` value — the job `ci`, its steps and the
standing consumer wiring (GitHub Packages auth, `node-version: '24'`, actions
v5, step-level `hashFiles`) MUST be preserved (REQ-005).

#### Scenario: GitHub Actions processes the template without a syntax error

- **GIVEN** the corrected `templates/github/workflows/consumer-ci.yml`
- **WHEN** a YAML parser (`python3 -c "import yaml; yaml.safe_load(...)"`)
  processes it and GitHub Actions loads it as a workflow
- **THEN** the YAML parses cleanly and the job `ci` is created without syntax
  errors

### Requirement: A regression test guards the consumer CI template YAML validity (REQ-003)

`tests/consumer-ci-yaml-test.sh` SHALL validate that
`templates/github/workflows/consumer-ci.yml` parses as valid YAML, and SHALL
fail (exit non-zero) if a step `name` value again contains an unquoted `: `.
The test SHALL follow the house test pattern (`tests/consumer-ci-auth-test.sh`)
and SHALL be auto-discovered by `tests/run-all.sh` (glob `tests/*-test.sh`).

#### Scenario: regression test fails on an ambiguous unquoted name

- **GIVEN** the template with an unquoted `name` value containing `: ` (e.g.
  the 0.11.0 line 42: `Project gate (make ci: refs + solid-lint + lint + test
  + audit)`)
- **WHEN** `bash tests/consumer-ci-yaml-test.sh` runs
- **THEN** it fails (exit non-zero) reporting the ambiguous `name` and its line

#### Scenario: regression test passes on the corrected template

- **GIVEN** the corrected `templates/github/workflows/consumer-ci.yml`
- **WHEN** `bash tests/consumer-ci-yaml-test.sh` and `bash tests/run-all.sh` run
- **THEN** the regression test passes (exit 0) and the full suite stays green

#### Scenario: consumer gets a valid ci.yml after updating to 0.11.1

- **GIVEN** a consumer project with Specboot 0.11.0 (broken ci.yml) and
  version 0.11.1 published
- **WHEN** the consumer runs `specboot update`
- **THEN** the standing tri-state policy (SPECBOOT-HARDEN-04,
  `docs/versioning-standard.md` §5.1) backs up the known historical variant
  and installs the corrected 0.11.1 template as `.github/workflows/ci.yml`,
  which is valid YAML for GitHub Actions

