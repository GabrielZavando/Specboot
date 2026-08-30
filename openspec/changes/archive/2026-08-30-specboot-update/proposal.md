# Change: specboot-update

## Origin

- **Ticket ID:** TICKET-3.2
- **Original title:** Implementar `specboot update` (actualización de proyecto)
- **Tag:** `[docs]` + framework docs (inferred + confirmed)
- **Derived change name:** `specboot-update`

## Summary

`specboot init` (entregado en TICKET-3.1 / archivado como `specboot-init`) crea un proyecto
nuevo desde cero, pero hasta ahora **no existe una ruta de actualización soportada** para un
proyecto ya inicializado. El modelo de actualización "opción A" declarado en
`docs/framework-contract.md` (§"Modelo de actualización") y la semántica de versión congelada en
`docs/versioning-standard.md` §5 exigen un comando `specboot update` que:

- reemplace **sin piedad** los archivos intocables del framework,
- **nunca** toque `docs/` del desarrollador ni el código del proyecto,
- avise de breaking change en saltos major (según la matriz de `versioning-standard.md`),
- reescriba `frameworkVersion` en `.specboot.json`.

## Motivation

1. **Cierre del ciclo de vida del framework.** Sin `update`, un proyecto queda atado a la
   versión con la que nació; las mejoras del framework (nuevos agentes, skills, correcciones de
   estándares) nunca llegan al consumidor.
2. **El comando documentado hoy no existe en el consumidor.** `README.md:102` instruye
   `bash node_modules/@gabrielzavando/specboot/update.sh`, pero `update.sh` **no está en la
   allowlist `files` de `package.json`**, así que el tarball npm nunca lo incluye. El `specboot.sh`
   sí se publica, por lo que `specboot update` (dentro de `specboot.sh`) es la ruta canónica.
3. **Reparación de intocables.** `docs/docs-standard.md` (filas B/C/D) prescribe "ejecutar
   `specboot update`" como remedio cuando `AGENTS.md`, `base-standards.md` u `opencode.json` se
   corrompen. `update` debe funcionar aunque la versión instalada sea igual a la del proyecto
   (modo reparación).

## Scope

### Incluye (IN)
- Subcomando `update` en `specboot.sh` con lógica completa (guard, lectura/comparación de
  versiones, advertencia major, backup, reemplazo, reescritura de `.specboot.json`, post-checks).
- Lista `UPDATE_ITEMS[]` propia (excluye `README.md` y `LICENSE`; `.github` archivo por archivo).
- Flags: `--dry-run`, `--yes`, `--template DIR`, `--no-backup`.
- Aviso de deprecación en el sync de `update.sh`.
- Documentación: sección en `docs/framework-contract.md` y ejemplo en `README.md`.

### Excluye (OUT)
- `specboot init` (ya en TICKET-3.1).
- Modificaciones al Makefile del proyecto (se reemplaza como intocable, sin lógica nueva).
- Modificaciones a workflows del proyecto (se reemplazan sólo los del framework, archivo por archivo).
- Arreglar la desviación del spec `specboot-init` sobre resolución desde `node_modules` (se propone
  como ticket de seguimiento; no afecta a `update`, que resuelve a `$SCRIPT_DIR` correctamente).
- Quitar `update.sh` del repo (se mantiene `--bump` para maintainers).

## Consumo previo / dependencias
- `validate-specboot.sh` (`semver_cmp`) es la referencia para la comparación de versiones.
- `package.json` `files` es la fuente de verdad de los archivos intocables publicados.
- `openspec/specs/specboot-init/spec.md` define el contrato de los archivos intocables inyectados.
