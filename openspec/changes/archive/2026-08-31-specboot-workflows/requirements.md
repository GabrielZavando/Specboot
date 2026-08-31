# Requirements: Workflows de CI/CD del framework parametrizados por env

## REQ-001: `ci.yml` tiene job `validate` (framework dogfooding) con self-tests condicionales
### Description
`ci.yml` MUST incluir un job `validate` que ejecute el self-check del framework:
`bash check-refs.sh`, `bash specboot.sh --ci`, y los self-tests internos del
framework (`tests/check-refs-test.sh`, `tests/solid-templates-test.sh`,
`tests/update-test.sh`). Estos self-tests se ejecutan solo si los archivos existen
(step-level `hashFiles`), de modo que el job sea consumer-safe.
### Requirements
- **REQ-001.1:** `validate` corre `bash check-refs.sh` y `bash specboot.sh --ci`.
- **REQ-001.2:** `validate` incluye un step que corre los tres `tests/*-test.sh` con `if: ${{ hashFiles('tests/check-refs-test.sh', 'tests/solid-templates-test.sh', 'tests/update-test.sh') != '' }}`.
- **REQ-001.3:** En un consumidor (sin `tests/`) el step de self-tests se salta y el job queda en verde.
### Acceptance Criteria
- [ ] `validate` cubre self-check + self-tests del framework.
- [ ] Self-tests condicionales a presencia de `tests/`.
- [ ] Consumer-safe.

---

## REQ-002: `ci.yml` tiene job `project-ci` que corre `make ci`
### Description
`ci.yml` MUST incluir un job `project-ci` que ejecute `make ci` (el CI gate del
proyecto consumidor: `refs` + `solid-lint` + `lint` + `test` + `audit`).
### Requirements
- **REQ-002.1:** `project-ci` corre `make ci`.
- **REQ-002.2:** `project-ci` NO invoca `specboot.sh --ci`.
### Acceptance Criteria
- [ ] `make ci` es el gate del proyecto.
- [ ] `specboot.sh --ci` queda fuera de `project-ci`.

---

## REQ-003: Sin `hashFiles()` en job-level `if`
### Description
Ningún job en `ci.yml` ni `deploy.yml` puede usar `hashFiles()` en su `if` (contexto
de job inválido). `hashFiles()` solo se permite en `steps[*].if`.
### Requirements
- **REQ-003.1:** `grep -nE '^\s*if:.*hashFiles'` sobre ambos YAML no coincide con ninguna línea a nivel de job.
- **REQ-003.2:** Las condiciones sobre Dockerfile usan `hashFiles` solo en `steps[*].if`.
### Acceptance Criteria
- [ ] 0 coincidencias job-level de `hashFiles`.
- [ ] `hashFiles('Dockerfile')` solo en step `if`.

---

## REQ-004: `deploy.yml` gated por `vars.DEPLOY_ENABLED` a nivel de job
### Description
`deploy.yml` MUST tener todos sus jobs de despliegue gated por
`if: vars.DEPLOY_ENABLED == 'true'` a nivel de job. El paso de build/SSH se
condiciona además a la existencia de `Dockerfile` vía step-level `hashFiles`.
### Requirements
- **REQ-004.1:** `deploy-staging`, `deploy-production` y `rollback` usan `if: vars.DEPLOY_ENABLED == 'true'` (combinado con `startsWith(github.ref, 'refs/tags/v')` donde aplique).
- **REQ-004.2:** Los steps de build/SSH usan `if: steps.dockerfile.outputs.dockerfile-present == 'true'`.
- **REQ-004.3:** `rollback` corre solo en `failure()` de un deploy por tag.
### Acceptance Criteria
- [ ] `DEPLOY_ENABLED != 'true'` → ningún job de deploy corre.
- [ ] Sin Dockerfile → steps Docker se saltan.

---

## REQ-005: `deploy.yml` usa solo `vars.DEPLOY_*` / `secrets.DEPLOY_*`
### Description
`deploy.yml` MUST parametrizarse exclusivamente vía GitHub repo `vars`
(`DOCKER_REPO`, `DEPLOY_HOST`, `DEPLOY_USER`) y `secrets` (`DEPLOY_SSH_KEY`). No
hardcodea infra del framework.
### Requirements
- **REQ-005.1:** Imágenes referencian `${{ vars.DOCKER_REPO }}`.
- **REQ-005.2:** SSH usa `${{ vars.DEPLOY_HOST }}`, `${{ vars.DEPLOY_USER }}`, `${{ secrets.DEPLOY_SSH_KEY }}`.
- **REQ-005.3:** No quedan referencias a `ghcr.io`, `github.repository`, Slack ni `softprops/action-gh-release`.
### Acceptance Criteria
- [ ] Deploy 100% parametrizado por env.
- [ ] Sin infra hardcodeada del framework.

---

## REQ-006: `ci.yml` usa `node-version: 20`
### Description
`ci.yml` MUST fijar `node-version: 20` en ambos jobs (alineado al mínimo del repo
y README: 20.19.0).
### Requirements
- **REQ-006.1:** `validate` y `project-ci` usan `node-version: 20` en `actions/setup-node`.
### Acceptance Criteria
- [ ] Node 20 en ambos jobs.

---

## REQ-007: Documentación describe workflows intocables + parametrizables
### Description
`docs/framework-contract.md` y `README.md` MUST documentar que los workflows son
intocables (reemplazados por `specboot update`) y parametrizables vía GitHub
vars/secrets. Ninguna edición introduce `{file:...}` rotas.
### Requirements
- **REQ-007.1:** `docs/framework-contract.md` incluye sección "Workflows del framework".
- **REQ-007.2:** `README.md` incluye sección "Workflows del framework" con ejemplo de parametrización y actualiza el bullet "CI/CD Incluido".
- **REQ-007.3:** `bash check-refs.sh` → 0 errores tras los cambios de doc.
### Acceptance Criteria
- [ ] Docs reflejan comportamiento.
- [ ] `check-refs.sh` → 0.

---

## REQ-008: Sin regresión en validaciones del framework
### Description
Tras el cambio, `check-refs.sh`, `specboot.sh --ci` y el parseo YAML de ambos
workflows MUST seguir en verde.
### Requirements
- **REQ-008.1:** `python -c "import yaml; yaml.safe_load(...)"` para ambos archivos sin error.
- **REQ-008.2:** `bash check-refs.sh` → 0 errores.
- **REQ-008.3:** `bash specboot.sh --ci` → sin nuevos errores/avisos.
### Acceptance Criteria
- [ ] YAML válido + checks verdes.

---

## REQ-009: Self-tests del framework corren en CI y son consumer-safe
### Description
Los self-tests internos del framework (`tests/*-test.sh`) MUST ejecutarse en CI del
repositorio del framework (vía job `validate`) y MUST omitirse limpiamente en un
proyecto consumidor donde `tests/` no se publica.
### Requirements
- **REQ-009.1:** En el repo framework, los tres self-tests corren en `validate`.
- **REQ-009.2:** En consumidor, el step se salta (`hashFiles` vacío) y el job queda verde.
### Acceptance Criteria
- [ ] Cobertura de self-tests preservada en framework.
- [ ] Sin rotura en consumidor.

---

## Technical Constraints
| Constraint | Description |
|------------|-------------|
| Archivos tocados | `.github/workflows/ci.yml`, `.github/workflows/deploy.yml` (intocables framework), `docs/framework-contract.md`, `README.md` |
| Parametrización | GitHub repo `vars` + `secrets` (no edición de YAML por el proyecto) |
| Node | 20 (alineado README mín 20.19.0) |
| Límite hashFiles | solo `steps[*].if`, nunca job-level `if` |
| Self-tests | `tests/check-refs-test.sh`, `tests/solid-templates-test.sh`, `tests/update-test.sh` (los mismos del job `template-integrity` previo) |

## Dependencies
- TICKET-4.1 (`make ci` como gate del proyecto, target `ci` existente).
- TICKET-3.2 (`specboot update` reemplaza `.github/workflows/*` vía `UPDATE_ITEMS`).
- TICKET-1.1 (allowlist `files` incluye `.github/workflows`).

## Out of Scope
- Editar `Makefile` (TICKET-4.1).
- Editar `update.sh` para tocar workflows.
- Cambiar `specboot.sh` ni `check-refs.sh`.
- Publicar a ghcr.io / GitHub Release / Slack en el template del framework.
