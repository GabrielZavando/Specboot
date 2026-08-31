# Tasks: `Workflows de CI/CD del framework parametrizados por env`

## Task 1: Reescribir `.github/workflows/ci.yml` (validate + project-ci)
**Status**: [x]
**Domain**: Tooling / CI
**Layer**: N/A
**Priority**: High
**Estimate**: M
**Suggested Path**: .github/workflows/ci.yml
**Test Path**: `python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"` + `grep` de `hashFiles` job-level

**Steps**:
1. Reescribir `ci.yml` con dos jobs: `validate` (dogfooding) y `project-ci` (gate del proyecto).
2. `validate`: `actions/checkout@v4`, `actions/setup-node@v4` con `node-version: 20`, `npm install`, `bash check-refs.sh`, `bash specboot.sh --ci`, y un step condicional de self-tests (`if: ${{ hashFiles('tests/check-refs-test.sh', 'tests/solid-templates-test.sh', 'tests/update-test.sh') != '' }}` que corre los tres scripts).
3. `project-ci`: mismo checkout/setup/node20/install, luego `make ci`.
4. `permissions: contents: read`; `on: push/pull_request` sobre `main`.

**Acceptance Criteria**:
- Ambos jobs presentes; `validate` corre self-check + self-tests condicionales.
- `project-ci` corre `make ci`, no `specboot.sh --ci`.
- `node-version: 20` en ambos.
- 0 coincidencias job-level de `hashFiles` (REQ-003.1).

---

## Task 2: Reescribir `.github/workflows/deploy.yml` (SSH+Docker genérico)
**Status**: [x]
**Domain**: Tooling / Deploy
**Layer**: N/A
**Priority**: High
**Estimate**: M
**Suggested Path**: .github/workflows/deploy.yml
**Test Path**: `python -c "import yaml; yaml.safe_load(open('.github/workflows/deploy.yml'))"` + `grep` `hashFiles`/`vars.DEPLOY`

**Steps**:
1. Reescribir `deploy.yml` con `on: push: tags: ['v*']` + `workflow_dispatch`.
2. Jobs `deploy-staging`, `deploy-production`, `rollback` gated por `if: vars.DEPLOY_ENABLED == 'true'` (production/rollback además `startsWith(github.ref, 'refs/tags/v')`).
3. Cada job: step `Check Dockerfile exists` con `id: dockerfile` y `if: ${{ hashFiles('Dockerfile') != '' }}` que setea `dockerfile-present=true`; steps build/SSH con `if: steps.dockerfile.outputs.dockerfile-present == 'true'`.
4. Build con `docker build -t ${{ vars.DOCKER_REPO }}:<env> .`; deploy vía `appleboy/ssh-action@v1` con `host: ${{ vars.DEPLOY_HOST }}`, `username: ${{ vars.DEPLOY_USER }}`, `key: ${{ secrets.DEPLOY_SSH_KEY }}`, script de pull/stop/rm/run.
5. Eliminar cualquier referencia a `ghcr.io`, `github.repository`, Slack o `softprops/action-gh-release`.

**Acceptance Criteria**:
- Gating por `vars.DEPLOY_ENABLED` a nivel de job.
- `hashFiles('Dockerfile')` solo en step `if`; `vars.DOCKER_REPO`/`DEPLOY_HOST`/`DEPLOY_USER` + `secrets.DEPLOY_SSH_KEY` usados.
- Sin infra hardcodeada del framework (REQ-005.3).

---

## Task 3: Documentación (framework-contract.md + README.md)
**Status**: [x]
**Domain**: Documentation
**Layer**: N/A
**Priority**: Medium
**Estimate**: S
**Suggested Path**: docs/framework-contract.md, README.md
**Test Path**: bash check-refs.sh

**Steps**:
1. En `docs/framework-contract.md` añadir sección "Workflows del framework" (intocables; `ci.yml` = `validate`+`project-ci`; `deploy.yml` gated por `vars.DEPLOY_ENABLED`; parametrización vía GitHub vars/secrets; `update.sh` no toca workflows, `specboot update` sí).
2. En `README.md` añadir sección "Workflows del framework" con ejemplo de parametrización (bloque YAML + Settings→Secrets and variables) y actualizar el bullet "CI/CD Incluido" para reflejar `validate`+`project-ci` y el deploy SSH+Docker gated.
3. No introducir referencias `{file:...}` rotas.

**Acceptance Criteria**:
- Doc refleja comportamiento (REQ-007.1/007.2).
- `check-refs.sh` → 0 errores (REQ-007.3).

---

## Task 4: Validación final (sin regresión)
**Status**: [x]
**Domain**: QA
**Layer**: N/A
**Priority**: High
**Estimate**: M
**Suggested Path**: repo root
**Test Path**: comandos de validación §6 del ticket

**Steps**:
1. `python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml')); yaml.safe_load(open('.github/workflows/deploy.yml'))"` → sin error.
2. `grep -nE '^\s*if:.*hashFiles' .github/workflows/*.yml` → solo líneas de step (indentadas bajo `steps:`), 0 job-level.
3. `bash check-refs.sh` → 0.
4. `bash specboot.sh --ci` → sin nuevos errores.
5. Simulación manual: `vars.DEPLOY_ENABLED='false'` → `deploy.yml` no corre jobs; `'true'` + `Dockerfile` → build+deploy.

**Acceptance Criteria**:
- YAML válido, sin `hashFiles` job-level, `check-refs.sh` y `specboot.sh --ci` en verde (REQ-008).
- Self-tests del framework corren en `validate` y se saltan en consumidor (REQ-009).

---

## Traceability to Requirements
| Task | Requirements |
|------|--------------|
| T1 | REQ-001, REQ-002, REQ-003, REQ-006, REQ-009 |
| T2 | REQ-004, REQ-005 |
| T3 | REQ-007 |
| T4 | REQ-003, REQ-008, REQ-009 |
