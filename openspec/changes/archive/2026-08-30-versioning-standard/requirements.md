# Requirements: Estándar SemVer + matriz de ruptura de compatibilidad

Cada requisito es trazable a uno o más escenarios de `scenarios.md`.

## REQ-001 — Estándar SemVer definido
El framework `@gabrielzavando/specboot` usa versionado `MAJOR.MINOR.PATCH`.
La versión vive en `package.json` del framework y se refleja en `frameworkVersion` de
`.specboot.json` del proyecto. Durante `0.x` se trata como API no estable (un minor puede
romper) pero se documenta igual; al llegar a `1.0.0` aplica SemVer estricto.
- Trazable a: Scenario 1.

## REQ-002 — Matriz de ruptura canónica
`docs/versioning-standard.md` contiene una tabla que clasifica cada tipo de cambio del
framework y qué nivel (patch/minor/major) dispara, incluyendo las filas de los tickets 0.1–0.3
(rutas `.openspec/`→`openspec/` = patch; placeholder en `base-standards.md` = patch; campo
`layers` opcional = minor; reestructuración `docs/` = major).
- Trazable a: Scenario 2.

## REQ-003 — Significado por nivel para el consumidor
El doc define, por nivel, qué debe hacer el proyecto:
- `patch`: cambios internos sin alterar interfaz ni archivos inyectados → actualiza sin acción.
- `minor`: añade funcionalidad sin romper → actualiza; sus archivos no se rompen, puede aprovechar lo nuevo.
- `major`: altera interfaz o archivos inyectados → debe leer release notes y posiblemente migrar `.specboot.json` / `docs/`.
- Trazable a: Scenario 3.

## REQ-004 — Comportamiento de `specboot update` ante versiones
Se define (texto para Fase 4) que `specboot update`:
- ante salto **major** (frameworkVersion del proyecto < instalada): imprime
  `⚠️ Breaking change. Lee CHANGELOG/release notes de vX.Y.Z` y reemplaza (opción A), pero avisa.
- ante **minor/patch**: reemplazo silencioso.
Nunca toca `docs/` del proyecto ni el código del proyecto.
- Trazable a: Scenario 4, Scenario 5.

## REQ-005 — Formato CHANGELOG y plantilla de ruptura
El CHANGELOG sigue Keep a Changelog + Semantic Versioning. Cada release mayor incluye
`### Breaking changes` y (si aplica) sección de migración. La entrada `0.1.1` ejemplifica el
formato con `### Breaking changes: None` y queda plantilla para futuras versiones.
- Trazable a: Scenario 6, Scenario 7.

## REQ-006 — `versioning-standard.md` creado y enlazado desde el contrato
El doc nuevo existe y `docs/framework-contract.md` enlaza a él con markdown relativo.
- Trazable a: Scenario 8.

## REQ-007 — `versioning-standard.md` marcado intocable
Aparece en la columna Intocable de la frontera en `framework-contract.md` y se nota en
`docs/docs-standard.md` como doc del framework.
- Trazable a: Scenario 8.

## REQ-008 — Validación de referencias y CI
`check-refs.sh` termina con 0 errores (sin `{file:...}` rotos) y `specboot.sh --ci` no regresa
nuevos errores/warnings respecto al baseline de 0.3.
- Trazable a: Scenario 9.
