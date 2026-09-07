# Change Proposal: enforce-commit-gates

- **Ticket ID**: M-901-903
- **Original Title**: [docs] Gate duro de commit con evidencia, evaluación CI y checklist de deploy
- **Tag (source)**: [docs] (explicit)
- **Derived change name**: `enforce-commit-gates`
- **Change folder**: `openspec/changes/enforce-commit-gates/`
- **Enriched artifact used**: no (ticket de PLAN_MEJORAS_SPECBOOT.md §Fase 9 + decisiones validadas en sesión)
- **SemVer Impact**: minor (`0.4.0` → `0.5.0`) con sección `### Breaking changes` — regla §2 de `docs/versioning-standard.md`: durante 0.x un minor puede romper registrando la ruptura según la matriz

## Summary

Este cambio implementa la **Fase 9** del plan de mejoras de Specboot
(`PLAN_MEJORAS_SPECBOOT.md`), abordando los tickets **M-901**, **M-902** y
**M-903** en un solo change (convención de batch por fase del repo):

1. **M-901 (Gate duro de commit basado en evidencia)**: `/commit` deja de
   depender de la honestidad del usuario. El Step 2 del skill `commit` pasa de
   gates informados suaves a **gates duros**: exige `verify-results.json` con
   `status: PASS` y `adversarial-result.json` con `verdict: SHIP`, ambos con
   campo `change` coincidente con el change activo. Ante evidencia negativa
   (`PARTIAL`/`FAIL`/`NO-SHIP`), ausente, inválida o ajena → bloquea y ofrece
   ejecutar la herramienta faltante, abortar, o usar `--force`. El flag
   `--force` es el escape hatch de emergencia y **queda registrado** en el
   commit message mediante el trailer `Gate-Bypass: ...`.

2. **M-902 (Evaluación de arquitectura CI)**: ticket de evaluación frente a
   `openspec/specs/specboot-workflows/spec.md`. Sin evidencia reportada de
   fricción de consumidores con el modelo "2 jobs, 1 archivo" (decisión del
   mantenedor, 2026-09-05), se concluye **mantener el diseño actual** y se
   cierra como "evaluado, sin acción": no se toca `ci.yml` ni la spec de
   workflows; la decisión queda documentada en este change y en el historial
   del plan.

3. **M-903 (Checklist de deploy)**: el skill `deploy` incorpora un checklist
   mínimo obligatorio, independiente del proyecto (tests verdes, lint sin
   errores críticos, build exitoso, auditoría de seguridad sin críticos,
   rollback definido, change archivado) y la plantilla
   `docs/deploy-standards.md` incluye rollback y change archivado en su
   Pre-deploy Checklist.

## Motivation

- Hoy `/commit` usa gates suaves (Step 2 de su skill): con `PARTIAL`/`FAIL`
  advierte y pregunta; con evidencia adversarial ausente ni siquiera pregunta
  ("la auditoría es opcional"). El gate depende de la honestidad del usuario —
  exactamente el problema que M-901 declara.
- La evidencia persistente que M-401 (`verify-results.json`) y M-502
  (`adversarial-result.json`) dejaron en marcha ya es consumible; ambas specs
  declaran "The hard gate remains M-901 (out of scope)". Este change consume
  esa evidencia y la vuelve obligatoria.
- M-902 protege el contrato ya probado de `specboot-workflows`: ninguna
  migración de CI sin evidencia real de consumidores.
- El skill `deploy` delega todo en `deploy-standards.md` sin validaciones
  mínimas propias; el checklist mínimo cierra el ciclo de calidad
  (verify → adversarial → commit → deploy).

## What Changes

- **M-901**:
  - `ai-specs/skills/commit/SKILL.md` (Step 2): matriz de decisión del gate
    duro sobre ambos archivos de estado (enums reales `PASS|PARTIAL|FAIL` y
    `SHIP|NO-SHIP` de `schema_version: 1`), match por campo `change`, lectura
    token-light (`node -e`, nunca `jq`), staleness warn-only.
  - Flag `--force`: procede con gates fallidos/ausentes pero añade al commit
    message el trailer `Gate-Bypass: --force (verify=<estado|missing>;
    adversarial=<veredicto|missing>)`.
  - Deltas de spec: capability nueva `commit-gates` (matriz del gate duro,
    `--force` registrado, sincronía de descripciones) y REMOVED+ADDED de los
    dos requisitos "informed soft gate" de `verification-state` y
    `adversarial-state` (endurecidos; referencian `commit-gates`).
  - Sincronía de descripciones (lección M-403): `AGENTS.md` (§5.2), nota de
    consumidor en `verify/SKILL.md`, wording "M-901 futuro" en
    `archive/SKILL.md` y `code-auditing/SKILL.md`,
    `.opencode/commands/commit.md`.
  - Self-test ejecutable: `tests/commit-gate-test.sh` con asserts `[SC-NNN]`
    (contrato del gate + fixtures de la matriz de estados).
- **M-902**:
  - Decisión documentada "mantener" con justificación (este proposal +
    historial v3.5 del plan); `ci.yml` y `specboot-workflows/spec.md` sin
    modificaciones.
  - `tests/ci-evaluation-test.sh`: aserta que la decisión está registrada y
    que el contrato de `ci.yml` (jobs `validate` + `project-ci`) permanece
    intacto.
- **M-903**:
  - `ai-specs/skills/deploy/SKILL.md`: checklist mínimo obligatorio (6 ítems)
    que `/deploy` debe pasar antes de proceder.
  - `docs/deploy-standards.md`: Pre-deploy Checklist incluye "rollback
    definido" y "OpenSpec change archivado".
  - `tests/deploy-checklist-test.sh` con asserts `[SC-NNN]`; sync de
    descripción en `.opencode/commands/deploy.md`.
- **Cierre**:
  - Bump `0.4.0` → `0.5.0` + entrada CHANGELOG `## [0.5.0]` con
    `### Breaking changes` (contrato de `/commit`) y `### Migration`
    (spec `version-bump`: el mantenedor bumpa antes del merge para no
    bloquear `release.yml`).
  - `PLAN_MEJORAS_SPECBOOT.md`: marcar `[x]` M-901/M-902/M-903 + fila de
    historial v3.5.

## Decisions

- **Batch M-901+M-902+M-903 en un change** (convención por fase;
  `ticket_id: M-901-903`), con M-902 acotado a evaluación documental: si
  apareciera evidencia real de fricción, la migración se trataría en un
  change independiente sobre `specboot-workflows`, fuera de este alcance.
- **Gate duro estricto (decisión del mantenedor, 2026-09-05)**: solo
  `PASS` + `SHIP` con `change` coincidente permiten commit. `PARTIAL`
  bloquea (no solo advierte): el wording "passed" del ticket se materializa
  con el enum real `PASS` de `schema_version: 1`. Sin evidencia no hay
  pregunta a ciegas: se ofrece ejecutar la herramienta faltante o `--force`.
- **La ausencia de auditoría adversarial deja de ser opcional en `/commit`**
  (hoy "el gate duro es M-901" la eximía): es la breaking change del release
  0.5.0.
- **Sin excepción para commits sin change activo**: si no hay change activo,
  la evidencia es "ajena" por definición (el match de `change` falla) → el
  gate bloquea → `--force` registrado. Evita ventanas de bypass silencioso.
- **Trailer git estándar** para auditar `--force`: al final del mensaje,
  formato `Gate-Bypass: --force (verify=<PASS|PARTIAL|FAIL|missing>;
  adversarial=<SHIP|NO-SHIP|missing>)`. Con gates verdes el trailer no se
  emite.
- **Dogfooding del gate**: el propio commit de este change pasará por el
  gate duro; para ello todos los escenarios tienen Test Path ejecutable con
  asserts `[SC-NNN]` → `/verify` debe alcanzar `status: PASS` (sin
  `--force`). Si algún escenario quedara UNTESTED, se vuelve a `/apply`;
  `--force` no es el camino por defecto.
- **Staleness sigue warn-only** (semántica M-401/M-502 preservada): la
  vigencia temporal no bloquea por sí sola; lo que bloquea es la
  falta/negatividad de la evidencia.

## Acceptance Criteria

- [ ] `/commit` procede sin preguntas solo con verify `PASS` + adversarial
      `SHIP` vigentes para el change activo (reporta ambas evidencias)
- [ ] `/commit` bloquea con `PARTIAL`, `FAIL`, `NO-SHIP`, evidencia ausente,
      inválida o ajena; ofrece ejecutar la herramienta faltante, abortar o
      `--force`; no continúa sin decisión explícita
- [ ] Con `--force` el commit se realiza pero registra el trailer
      `Gate-Bypass` con el estado real de ambos gates; con gates verdes el
      trailer no se emite
- [ ] El staleness es warn-only y no bloquea por sí solo
- [ ] La decisión M-902 ("mantener 2 jobs/1 archivo") está documentada y
      justificada; `ci.yml` y `specboot-workflows/spec.md` sin cambios
- [ ] `/deploy` exige el checklist mínimo (6 ítems) y no procede si alguno
      falla; `deploy-standards.md` incluye rollback y change archivado en su
      checklist
- [ ] `tests/commit-gate-test.sh`, `tests/ci-evaluation-test.sh` y
      `tests/deploy-checklist-test.sh` pasan con asserts `[SC-NNN]`
      (evidencia ejecutable para todos los escenarios)
- [ ] `AGENTS.md` §5.2, `verify/SKILL.md`, `archive/SKILL.md`,
      `code-auditing/SKILL.md` y `.opencode/commands/commit.md` sin wording
      "M-901 futuro"; las descripciones declaran el gate duro
- [ ] `bash check-refs.sh` y `bash specboot.sh --ci` reportan 0 errores
