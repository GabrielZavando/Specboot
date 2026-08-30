# Proposal: Estándar SemVer + matriz de ruptura de compatibilidad

## Change created from ticket

**Ticket ID**: TICKET-0.4
**Original title**: Estándar SemVer + matriz de ruptura de compatibilidad
**Tag (source)**: [docs] (explicit)
**Derived change name**: versioning-standard
**Change folder**: openspec/changes/versioning-standard/
**Enriched artifact used**: no (ticket well-formed; title used as source)

### Naming rationale
- Verb: define/establish (el entregable es un estándar documentado)
- Noun/entity: versioning standard (SemVer + breaking-change matrix)
- Domain prefix: none (single domain: the framework itself)

### Context loaded
- `docs/base-standards.md` (always via instructions[])
- `docs/documentation-standards.md` (tag [docs])
- `docs/framework-contract.md` (depends-on 0.1, update model "option A")
- `docs/specboot-json-standard.md` (depends-on 0.3, `frameworkVersion` SemVer)

## Why

Specboot inyecta archivos en el proyecto y `specboot update` los reemplaza sin piedad (opción A del contrato, TICKET-0.1). Sin un estándar de versionado y una matriz de ruptura explícita, un salto de versión del framework no comunica al proyecto consumidor cuándo debe revisar su `.specboot.json` / `docs/` / env. Esto es crítico para la confianza del dogfooding: el dev debe poder leer `frameworkVersion` y saber si una actualización es transparente (patch/minor) o requiere migración (major). TICKET-0.1 (contrato) y TICKET-0.3 (`frameworkVersion` + `validate-specboot.sh`) ya sentaron las bases; este ticket las cierra definiendo la semántica.

## What Changes

- **Adds** `docs/versioning-standard.md` — el estándar SemVer del framework + la matriz de ruptura canónica + el significado de cada nivel para el consumidor + el formato de CHANGELOG/release notes + el comportamiento definido de `specboot update` ante major/minor/patch (texto para Fase 4).
- **Updates** `CHANGELOG.md` — mueve el contenido de `[Unreleased]` a `## [0.1.1] - 2026-08-29`, añade la subsección `### Breaking changes` como plantilla canónica (`None` para 0.1.1) y deja `## [Unreleased]` vacío.
- **Updates** `docs/framework-contract.md` — añade `docs/versioning-standard.md` a la columna Intocable de la frontera y un enlace relativo al nuevo doc.
- **Updates** `docs/docs-standard.md` — nota `versioning-standard.md` como doc del framework (intocable) en su nota de alcance.
- **Does NOT** implementar `specboot update` (Fase 4), el release workflow (Fase 7), ni cambiar `package.json` (eso lo dispara el release).

## Goals

- **Fijar** el estándar SemVer para `@gabrielzavando/specboot` (cuándo sube major/minor/patch, incl. salvedad `0.x`).
- **Definir** la matriz de ruptura que clasifica cada tipo de cambio del framework y qué nivel dispara.
- **Documentar** el significado de cada nivel para el proyecto consumidor (patch: sin acción; minor: puede aprovechar; major: debe revisar/migrar).
- **Declarar** cómo se avisa la ruptura en el release (CHANGELOG + sección de migración) y cómo `specboot update` debe comportarse.
- **Enlazar** el estándar desde `framework-contract.md` y marcarlo intocable.

## Non-Goals

- Implementación de `specboot update` (Fase 4).
- Implementación del release workflow / bump de `package.json` (Fase 7).
- Cualquier cambio de versión real del paquete.

## Enriched User Story

**As a** framework maintainer (Gabriel / Agencia Zavando)
**I want** a single authoritative SemVer + breaking-change matrix document for Specboot
**So that** every `specboot update` communicates unambiguously whether the project must act (major) or can update transparently (minor/patch).

### Context

The framework version lives in `package.json` and is reflected in `frameworkVersion` of each project's `.specboot.json` (TICKET-0.3). `validate-specboot.sh` already compares `frameworkVersion` against the installed package and warns when the framework is outdated. What is missing is the *meaning* of that comparison: what concrete framework changes constitute a breaking change. This document closes that gap and becomes the reference that Fase 4 (`specboot update`) and Fase 7 (release) will implement against.
