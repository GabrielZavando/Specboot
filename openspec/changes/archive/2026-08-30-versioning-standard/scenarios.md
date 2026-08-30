# Scenarios: Estándar SemVer + matriz de ruptura de compatibilidad

Todos los escenarios usan lenguaje Gherkin (Given/When/Then) y entidades reales del repo:
el paquete `@gabrielzavando/specboot`, el archivo `.specboot.json` (campo `frameworkVersion`),
el comando `specboot update` (opción A del contrato), y los docs inyectados (`base-standards.md`,
`framework-contract.md`, `docs-standard.md`, `versioning-standard.md`).

## Scenario 1: El estándar SemVer se define y se refleja en frameworkVersion (happy path)

Given el paquete `@gabrielzavando/specboot` con `version` en `package.json`
When se corta un release del framework
Then la versión sigue el formato `MAJOR.MINOR.PATCH` (ej. `0.1.1`)
And tras `specboot update`, el `frameworkVersion` de `.specboot.json` del proyecto coincide con la versión instalada
And durante `0.x` se documenta que un cambio minor puede romper, pero se registra igual según la matriz

## Scenario 2: Un cambio del framework se clasifica por la matriz de ruptura (happy path)

Given la matriz de ruptura canónica en `docs/versioning-standard.md`
When se evalúa un cambio concreto del framework
Then el cambio recibe un nivel `patch`, `minor` o `major` según la tabla
And los cambios de los tickets 0.1–0.3 se clasifican correctamente:
  - corrección de rutas `.openspec/`→`openspec/` en skills = `patch`
  - corrección de typo/placeholder en `base-standards.md` = `patch`
  - nuevo campo opcional `layers` en `.specboot.json` (0.3) = `minor`
  - reestructuración del árbol `docs/` (0.2) = `major`

## Scenario 3: El proyecto entiende el significado de cada nivel (happy path)

Given un proyecto consumidor con `.specboot.json`
When recibe una actualización del framework de cierto nivel
Then si es `patch`: cambios internos sin alterar interfaz ni archivos inyectados → el proyecto actualiza sin acción
And si es `minor`: se añade funcionalidad sin romper lo existente → el proyecto actualiza; sus archivos no se rompen, puede aprovechar lo nuevo
And si es `major`: altera interfaz o archivos inyectados → el proyecto debe leer release notes y posiblemente migrar `.specboot.json` / `docs/`

## Scenario 4: specboot update detecta un salto major y avisa (error/warning path)

Given un proyecto con `frameworkVersion` menor que la versión instalada del paquete (salto major)
When el dev ejecuta `specboot update`
Then `update` imprime `⚠️ Breaking change. Lee CHANGELOG/release notes de vX.Y.Z`
And procede a reemplazar los archivos inyectados (opción A)
And no toca `docs/` del proyecto ni el código del proyecto

## Scenario 5: specboot update ante minor/patch es silencioso (edge case)

Given un proyecto con `frameworkVersion` menor que la instalada solo en minor o patch
When el dev ejecuta `specboot update`
Then `update` reemplaza los archivos inyectados sin advertencia de ruptura
And el proyecto no necesita acción de migración

## Scenario 6: Se declara la ruptura en el release (happy path)

Given un release major del framework
When se publica el CHANGELOG
Then incluye una sección `### Breaking changes` con la lista de cambios que rompen
And (si aplica) una sección de migración indicando qué revisar en `.specboot.json` / `docs/` / env
And el formato sigue Keep a Changelog + Semantic Versioning

## Scenario 7: CHANGELOG mantiene el formato estándar y la plantilla (edge case)

Given el `CHANGELOG.md` del repo Specboot
When se añade la entrada de la versión actual
Then la entrada `0.1.1` sirve de ejemplo del formato con subsección `### Breaking changes: None`
And queda una sección `## [Unreleased]` vacía para futuras versiones
And hay una plantilla reutilizable de "Breaking changes" para releases mayores

## Scenario 8: versioning-standard.md queda enlazado y marcado intocable (happy path)

Given `docs/versioning-standard.md` creado
When un dev lee `docs/framework-contract.md`
Then encuentra un enlace relativo a `versioning-standard.md`
And `versioning-standard.md` aparece en la columna Intocable de la frontera del framework
and `docs/docs-standard.md` lo nota como doc del framework (intocable)

## Scenario 9: check-refs.sh y specboot.sh --ci siguen en 0 errores (edge case)

Given los archivos nuevos y modificados del change
When se ejecuta `bash check-refs.sh`
Then termina con 0 errores (el enlace usa markdown relativo, no `{file:...}`)
When se ejecuta `bash specboot.sh --ci`
Then no regresa nuevos errores/warnings respecto al baseline de 0.3
