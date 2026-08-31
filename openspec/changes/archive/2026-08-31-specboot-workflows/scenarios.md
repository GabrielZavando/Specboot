# Scenarios: Workflows de CI/CD del framework parametrizados por env

## Acceptance Criteria

### Scenario 1: `project-ci` corre el gate del proyecto consumidor
- Given a project (or the framework repo) with `.specboot.json` declaring `stack: "framework"` or a real stack
- When the `project-ci` job runs
- Then it executes `make ci` (which runs `refs` + `solid-lint` + `lint` + `test` + `audit`) and does not invoke `specboot.sh --ci`

### Scenario 2: `validate` corre el framework self-check + self-tests condicionales
- Given the Specboot framework repo (tiene `tests/check-refs-test.sh`, `tests/solid-templates-test.sh`, `tests/update-test.sh`)
- When the `validate` job runs
- Then it runs `bash check-refs.sh`, `bash specboot.sh --ci`, and the framework self-tests (the three `tests/*-test.sh` scripts)
- And in a consumer repo (sin `tests/`) those self-test steps are skipped via step-level `hashFiles` and the job stays green

### Scenario 3: `ci.yml` no usa `hashFiles` en job-level `if`
- Given the change applied
- When `grep -nE '^\s*if:.*hashFiles' .github/workflows/ci.yml` runs
- Then it matches zero job-level `if` lines (any `hashFiles` appears only inside a `steps:` block, i.e. step-level `if`)

### Scenario 4: `deploy.yml` no corre si `vars.DEPLOY_ENABLED` != 'true'
- Given a repo where `vars.DEPLOY_ENABLED` is unset or `'false'`
- When a tag `v*` is pushed (or `workflow_dispatch`)
- Then no job in `deploy.yml` executes (all jobs are gated by `if: vars.DEPLOY_ENABLED == 'true'`)

### Scenario 5: `deploy.yml` build + deploy cuando está habilitado y hay Dockerfile
- Given a repo where `vars.DEPLOY_ENABLED == 'true'`, `vars.DOCKER_REPO`/`DEPLOY_HOST`/`DEPLOY_USER` set, `secrets.DEPLOY_SSH_KEY` set, and a `Dockerfile` exists
- When a tag `v*` is pushed
- Then `deploy-staging` (and `deploy-production` on a `v*` tag) build the image and run it on the remote host via SSH

### Scenario 6: `deploy.yml` salta steps Docker si no hay Dockerfile
- Given `vars.DEPLOY_ENABLED == 'true'` but no `Dockerfile` in the repo
- When `deploy.yml` runs
- Then the `Check Dockerfile exists` step sets `dockerfile-present` empty and the build/SSH steps are skipped (step-level `hashFiles('Dockerfile')`)

### Scenario 7: Sin regresión en validaciones del framework
- Given the change applied to the framework repo
- When `python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml')); yaml.safe_load(open('.github/workflows/deploy.yml'))"`, `bash check-refs.sh`, and `bash specboot.sh --ci` run
- Then the YAML parses, `check-refs.sh` reports 0 errors, and `specboot.sh --ci` reports no new errors

### Scenario 8: Documentación refleja intocable + parametrizable sin refs rotas
- Given the change applied
- When `docs/framework-contract.md` and `README.md` are inspected
- Then they describe the workflows as intocable/parametrizable and `bash check-refs.sh` reports 0 errors (no new `{file:...}` references introduced)
