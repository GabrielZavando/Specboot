# Acceptance Scenarios: version-bump-fase1

### SC-001: package.json declara la versión minor actualizada

**Given** el repositorio Specboot con la Fase 1 (M-101/M-102) ya mergeada a main
**When** se inspecciona el campo `version` en `package.json`
**Then** el campo es `"0.2.0"` (minor bump desde `0.1.3`)
**And** coincide con el git tag `v0.2.0` sin el prefijo `v`

---

### SC-002: Cambio de Fase 1 minor se refleja en CHANGELOG

**Given** la Fase 1 introduce nuevas capacidades de nivel minor
**When** se revisiona `CHANGELOG.md`
**Then** existe una entrada `## [0.2.0]` que documenta los cambios de M-101 y M-102

---

### SC-003: Publicación a GitHub Packages en 0.2.0 tiene éxito

**Given** la versión `0.2.0` no está publicada en GitHub Packages y `package.json` la declara
**When** el workflow `release.yml` ejecuta `npm publish` en un push a main (o tag `v0.2.0`)
**Then** la publicación termina con exit code 0
**And** `@gabrielzavando/specboot@0.2.0` aparece en el tab Packages
