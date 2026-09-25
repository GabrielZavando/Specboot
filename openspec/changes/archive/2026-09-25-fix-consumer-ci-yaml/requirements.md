# Requirements — fix-consumer-ci-yaml

Cada requisito es trazable a al menos un escenario (`scenarios.md`, SC-001..SC-004).

1. **REQ-001** — La plantilla `templates/github/workflows/consumer-ci.yml` MUST
   ser YAML válido para GitHub Actions (parseo limpio; job `ci` creable sin
   error de sintaxis). → SC-001

2. **REQ-002** — El valor `name` del step "Project gate" MUST quedar
   correctamente entrecomillado o reformulado para no contener `: ` ambiguo.
   Precedente de casa: el workflow interno `.github/workflows/ci.yml` (línea
   58) formula el mismo gate sin `: `: `make ci (refs + solid-lint + lint +
   test + audit)`. → SC-001, SC-002

3. **REQ-003** — MUST existir una prueba de regresión
   (`tests/consumer-ci-yaml-test.sh`, auto-descubierta por `tests/run-all.sh`
   vía glob `tests/*-test.sh`) que falle (exit non-zero) si la plantilla deja
   de ser YAML válida o si un valor `name` vuelve a incluir `: ` sin comillas. → SC-002

4. **REQ-004** — MUST publicarse el patch release 0.11.1 vía el mecanismo
   canónico `bash release-bump.sh 0.11.1` (nunca a mano ni con `npm version`;
   bump atómico de `package.json`, `package-lock.json` y `.specboot.json`; sin
   tags, sin commit — `docs/versioning-standard.md` §6.1) y con entrada
   `## [0.11.1] - YYYY-MM-DD` en `CHANGELOG.md` (Keep a Changelog, sección
   `### Fixed` y `### Breaking changes: None` según la matriz §3: fix de bug
   sin cambio de interfaz → patch). → SC-003

5. **REQ-005** — Los workflows internos (`.github/workflows/*`) y el código de
   negocio MUST NOT modificarse: el fix se limita a la plantilla consumer-ci,
   el test de regresión, los archivos de versión y el CHANGELOG. Restricción
   TRANSITORIA de este change (no contrato permanente para cambios futuros):
   su verificación es la revisión del diff actual, documentada por `/verify`. → SC-004
