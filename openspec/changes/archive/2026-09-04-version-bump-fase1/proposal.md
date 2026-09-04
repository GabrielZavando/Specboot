# Change Proposal: version-bump-fase1

- **Ticket ID**: FIX-M101-102
- **Original Title**: Bump version to unblock publish of Fase 1 (M-101/M-102)
- **Tag**: [docs]
- **SemVer Impact**: minor

## Why

La Fase 1 (`plan-traceability`, tickets M-101 y M-102) se mergeó a `main` sin bump de versión de `package.json`. El workflow `release.yml` se dispara en cada push a `main` y ejecuta `npm publish` incondicionalmente. Como la versión `0.1.3` ya está publicada en GitHub Packages, el publish falló con:

```
npm error You cannot publish over the previously published versions: 0.1.3.
```

El cambio M-101/M-102 es de nivel **minor** (nueva capacidad, no rompe contratos). Según la matriz SemVer de `docs/versioning-standard.md`, corresponde subir de `0.1.3` a `0.2.0`.

## What Changes

- Bump `version` en `package.json` de `"0.1.3"` a `"0.2.0"`.
- Añadir entrada `## [0.2.0]` en `CHANGELOG.md` con los cambios de la Fase 1.

## Summary and Motivation

El merge de la Fase 1 no llevó bump de versión, lo que rompió la publicación automática de GitHub Packages (no se puede republicar `0.1.3`, ya existente). Este es un fix de una línea de versión + registro en changelog para restaurar la semántica de release correcta.

## Acceptance Criteria

1. `package.json` declara `version: "0.2.0"`.
2. Tag `v0.2.0` publica exitosamente en GH Packages.
3. Package `@gabrielzavando/specboot@0.2.0` aparece listado en el tab Packages.
4. `CHANGELOG.md` incluye la entrada `## [0.2.0]`.

## Rollback Plan

- Si el publish falla por otra razón, revertir `package.json` a `"0.1.3"`. El impacto del rollback es solo la cadena de versión.
