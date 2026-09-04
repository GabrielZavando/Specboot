# Proposal: Fase 0 — Reconciliación del plan y documentación de auth

## Ticket
- **IDs:** M-001 + M-002 (plan `PLAN_MEJORAS_SPECBOOT.md`, Fase 0)
- **Tag:** `[docs]`
- **Título:** Reconciliación del plan y documentación de autenticación GitHub Packages
- **Nivel SemVer estimado:** `patch` (solo documentación y registro; no cambia contratos del framework)
- **Dependencias:** ninguna (es el punto de partida del roadmap)

## Summary
Este change cubre las dos primeras tareas de la **Fase 0 (Reconciliación)** del plan de
mejoras de Specboot:

### M-001 — Auditoría de funcionalidades ya implementadas
Tarea de **registro y verificación**, sin cambios de código. El plan original se escribió
sobre una foto desactualizada del repositorio, y varios tickets proponían "crear"
funcionalidad que ya existe. Se deja registrada la verificación real para que ningún
ticket posterior (M-301, M-302, M-501, M-801, M-902, …) reabra trabajo ya hecho.

La tabla de verificación está documentada en `PLAN_MEJORAS_SPECBOOT.md` (sección M-001).
Este change la **confirma y registra como verificada**, y **marca M-001 como completado**.

### M-002 — Documentar autenticación GitHub Packages para consumidores
La autenticación del framework hacia GitHub Packages (publicación) ya está resuelta
(`release.yml`, spec `npm-distribution`). Lo que falta es una guía para **consumidores**
(ej. WebAppRiff) sobre cómo autenticar su propio CI al instalar `@gabrielzavando/specboot`.
El plan original (`TICKET-0.1`) asumía incorrectamente que Specboot inyecta un `ci.yml` a
los consumidores — no existe tal inyección.

Este change agrega la sección **"Autenticación para consumidores (CI)"** en `README.md`.

## Motivation
- **Evitar duplicación:** registrar qué existe ya para no re-planificar funcionalidad
  implementada.
- **Adopción sin fricción:** un consumidor nuevo debe poder configurar `npm install` en su
  CI sin preguntar, siguiendo solo el README.
- **Corregir premisa errónea:** reemplazar el supuesto incorrecto de `TICKET-0.1` por una
  guía basada en el mecanismo real de GitHub Packages (`secrets.GITHUB_TOKEN` / PAT con
  `read:packages`).

## Scope
- `PLAN_MEJORAS_SPECBOOT.md`: marcar M-001 y M-002 como completados y registrar la
  verificación de la Fase 0.
- `README.md`: nueva sección "Autenticación para consumidores (CI)".
- Verificación real del snippet YAML en un repositorio de prueba del mismo org.

## Out of Scope
- Cambios a `release.yml` o al mecanismo de publicación (ya resuelto).
- Tickets posteriores del roadmap (Fases 1–9).
- Cambios a los estándares intocables (`docs/base-standards.md`, `AGENTS.md`, etc.).
- Migración/CI (M-902 es un ticket de evaluación independiente).

## Success Criteria
- M-001 y M-002 marcados como completados en `PLAN_MEJORAS_SPECBOOT.md`.
- Un consumidor nuevo puede configurar `npm install` en su CI sin preguntar, siguiendo
  solo el README.
- El snippet YAML de autenticación se verifica en un repo de prueba del mismo org.
- `bash check-refs.sh` → 0 errores.
- `bash specboot.sh --ci` → sin errores.

## Context loaded
- `docs/documentation-standards.md` (tag `[docs]`)
- `PLAN_MEJORAS_SPECBOOT.md` (M-001, M-002)
- `README.md` (estructura de instalación/autenticación existente)
- `openspec/changes/archive/2026-08-31-specboot-workflows/` (formato de artefactos)
