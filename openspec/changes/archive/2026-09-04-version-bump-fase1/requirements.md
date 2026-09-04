# Change Requirements: version-bump-fase1

## REQ-001: package.json version bumped to 0.2.0
- **Descripción**: El campo `version` de `package.json` SHALL ser `"0.2.0"` y coincidir con el git tag `v0.2.0` (sin prefijo), conforme a la spec `version-bump`.
- **Trazabilidad**: SC-001

## REQ-002: CHANGELOG entry for 0.2.0
- **Descripción**: `CHANGELOG.md` SHALL contener una entrada `## [0.2.0]` siguiendo Keep a Changelog + SemVer, con una sección `### Added`/`### Changed` que documente la Fase 1 (M-101, M-102).
- **Trazabilidad**: SC-002

## REQ-003: Publish to GH Packages succeeds
- **Descripción**: El workflow `release.yml` SHALL poder publicar `@gabrielzavando/specboot@0.2.0` con exit code 0 tras el bump.
- **Trazabilidad**: SC-003
