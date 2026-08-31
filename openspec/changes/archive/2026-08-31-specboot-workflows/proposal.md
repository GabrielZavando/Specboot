# Proposal: Workflows de CI/CD del framework parametrizados por env

## Ticket
Ticket ID: TICKET-4.2
- **ID:** TICKET-4.2
- **Tag:** `[docs]`
- **Título:** Workflows de CI/CD del framework parametrizados por env
- **Fase:** 4 (Makefile y workflows parametrizables) · Tipo: code + docs · Prioridad: P0
- **Depends-on:** TICKET-4.1 (Makefile del framework parametrizado), TICKET-3.2 (`specboot update` implementado), TICKET-1.1 (empaquetado, `files` incluye `.github/workflows`)

## Summary
Los workflows de GitHub Actions del **framework** (`.github/workflows/ci.yml` y
`.github/workflows/deploy.yml`) deben ser **intocables** (reemplazados sin piedad
por `specboot update`) pero **parametrizables por variables de entorno** de GitHub
(repo `vars` + `secrets`). El proyecto consumidor adapta el despliegue a su
infraestructura (VPS, Docker, repo distinto) sin editar el YAML, usando
`vars.DEPLOY_*` y `secrets.DEPLOY_*`.

`ci.yml` se consolida en dos jobs: `validate` (dogfooding del framework:
`check-refs.sh` + `specboot.sh --ci` + self-tests del framework condicionales) y
`project-ci` (gate real del consumidor: `make ci`). `deploy.yml` se reescribe como
deploy genérico SSH+Docker gated por `vars.DEPLOY_ENABLED`.

## Motivation
- El workflow actual (`ci.yml`) corre jobs sueltos (`lint`, `test`, `build`,
  `audit`, `solid-lint`, `commitlint`, `template-integrity`) y además un job
  `template-integrity` que ejecuta `tests/*.sh` del framework — scripts que **no**
  se publican en el paquete npm, por lo que el workflow actual rompe en un proyecto
  consumidor. Hay que hacerlo consumer-safe.
- `deploy.yml` actual publica a ghcr.io, crea GitHub Release y notifica a Slack con
  valores hardcodeados al repositorio del framework, lo que no es parametrizable.
- Objetivo: workflows que el consumidor sólo configura vía GitHub vars/secrets, sin
  editar YAML, coherentes con el principio rector 9 del contrato (Makefile y
  workflows intocables, adaptados vía `.specboot.json` + env vars).

## Resoluciones aplicadas (gap analysis del ticket)
- **D1 — Self-tests del framework:** se pliegan en el job `validate` como step
  condicional (`if: hashFiles('tests/...') != ''`), preservando la cobertura del
  framework y siendo consumer-safe.
- **D2 — deploy.yml:** se adopta el deploy genérico SSH+Docker de §4.2 (sin
  ghcr.io / Release / Slack).
- **D3 — Node version:** `node-version: 20` en `ci.yml` (alineado a README min
  20.19.0), no 18.
- **D4 — hashFiles:** prohibido en job-level `if`; permitido solo en `steps[*].if`.
- **D5 — Intocabilidad:** los workflows se reescriben íntegros; el proyecto no los
  edita.

## Context loaded
- `docs/documentation-standards.md` (tag `[docs]`)
- `docs/framework-contract.md` (sección "Makefile del framework" + frontera intocable)
- `docs/versioning-standard.md`, `docs/docs-standard.md` (frontera intocable/docs)
- `Makefile` (target `ci: refs solid-lint lint test audit`), `specboot.sh` (`--ci`),
  `check-refs.sh` (validación de `{file:...}`)
