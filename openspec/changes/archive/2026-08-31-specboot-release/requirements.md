# Requirements: Workflow de release que publica a npm tras merge a main

Cada requisito es trazable a uno o más escenarios de `scenarios.md`.

## REQ-001 — Workflow de release con triggers correctos
El workflow `release.yml` SHALL trigger on `push: branches: [main]` AND on
`release: types: [published]`.
- Trazable a: Scenario 1, Scenario 2.

## REQ-002 — Job de validación de framework completo
El job `validate` SHALL ejecutar `bash check-refs.sh`, `bash specboot.sh --ci`,
`make ci`, y todos los scripts en `tests/*-test.sh`. Si cualquiera falla, el job
falla y el workflow se detiene.
- Trazable a: Scenario 3.

## REQ-003 — Job de publicación dependiente de validación
El job `publish` SHALL tener `needs: validate` y correr sólo si `validate` pasó.
El `publish` SHALL ejecutarse si el evento es push-to-`main` O release (usando
paréntesis explícitos en la expresión `${{ }}` para evitar ambigüedad de
precedencia).
- Trazable a: Scenario 4, Scenario 9.

## REQ-004 — Publicación a GitHub Packages con GITHUB_TOKEN
El job `publish` SHALL correr `npm pack --dry-run` luego `npm publish` a
`https://npm.pkg.github.com` (via `publishConfig` in `package.json`), usando
`NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}` con `permissions: packages: write`.
- Trazable a: Scenario 5.

## REQ-005 — YAML válido y sin hashFiles en job-level `if`
`release.yml` SHALL parsear con `yaml.safe_load` sin error. SHALL NOT usar
`hashFiles()` en job-level `if` (válido sólo en `steps[*].if`).
- Trazable a: Scenario 6.

## REQ-006 — Documentación de release automático
`docs/versioning-standard.md` SHALL tener sección "Release automático"
documentando triggers, validation gate, y responsabilidad de bump de versión del
mantenedor. `README.md` SHALL tener sección "Publicación (release automático)"
con snippet YAML y descripción actualizada de `update.sh --bump` (convenience de
mantenedor, no dispara el workflow directamente).
- Trazable a: Scenario 7.

## REQ-007 — Intocabilidad
El workflow `release.yml` es un archivo intocable del framework: se reemplaza por
`specboot update`, no debe ser editado por proyectos consumidores. `update.sh
--bump` NO es invocado por el workflow (es herramienta local de mantenedor).
- Trazable a: Scenario 3, Scenario 7.

## REQ-008 — Sin regresión en validaciones del framework
Después del cambio: YAML parsea, `check-refs.sh` → 0, `specboot.sh --ci` → 0,
`make ci` → 0, `tests/*-test.sh` → todos pasan.
- Trazable a: Scenario 8.
