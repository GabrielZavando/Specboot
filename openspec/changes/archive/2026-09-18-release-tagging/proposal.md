# Proposal: release-tagging

**Ticket ID**: M-912
**Título original**: [docs] Alinear tags, Releases y tooling de release
**Tag**: docs (framework tooling)
**Origen**: Plan integral aprobado por el mantenedor (Change 2)

## Why

Hoy, las versiones del framework publicadas a GitHub Packages son el pasado domingo de `git tag` (solo hasta `v0.6.3`), pero `package.json` se actualizó por merges del sUSBanner y  `"0.9.0"` ⇒ la página de Releases muestra v0.6.3 mientras el paquete real está en 0.9.0. Además: el `update.sh --bump` depende still de `git describe --tags` (hereda el último tag que no existe) — con la rotura de los tags intermedios paila mal. Falta el landgüok canonico para que los tags acompañen al bump y no se perdan otra vez.

## What Changes

1. `release-bump.sh` ahora **crea el tag local** `v{version}` al finalizar el bump (como lo hace `update.sh --bump`), y el mensaje explícito recuerda hacer push del tag tras mergear.
2. `update.sh --bump` computa la versión actual desde `package.json` (fuente de verdad) en vez de `git describe --tags` (que estoque en tags no actualizados rompía la cadena).
3. `docs/versioning-standard.md` sección RELEASE documnta la política única: tag por bump, push del tag tras el merge, GitHub Release manual desde la UI con el texto del CHANGELOG.
4. `tests/release-bump-test.sh` extendido (aserta creación del tag local).
5. **Backfill retroactivo** de los tags faltantes: `v0.6.4`, `v0.7.0`, `v0.8.0`, `v0.8.1`, `v0.9.0` apuntando a sus commits de bump y `git push origin --tags` (no dispara `release.yml`).

## Fuera de alcance

- GitHub Releases los creas tú desde la UI (no hay `gh` en tu flujo; link te lo doy).
- Reforma de `update.sh` completa o unificación del **SCOPE / update**: fuera de alcance (documentación y tags).
- F-harness: ya registrado, sin acción.

## Nivel SemVer

`patch` (tools/documentación de tooling; no cambia el contrato de ningún IA-agente ni runtime del framework).
