# Implementation Tasks: enforce-commit-gates

## 1. Gate duro de commit (M-901 — TDD primero)

- [x] 1.1 Crear self-test del contrato `tests/commit-gate-test.sh` (RED): valida la matriz de decisión del Step 2 del skill `commit` contra los fixtures (PASS+SHIP → procede; PARTIAL/FAIL → bloquea; ausente/inválido/ajeno → bloquea sin pregunta a ciegas; NO-SHIP → bloquea; adversarial ausente/ajeno → bloquea), el trailer `Gate-Bypass: --force (...)`, el staleness warn-only, la lectura token-light (`node -e`, nunca `jq`), el match por campo `change` y la sincronía de descripciones (AGENTS.md §5.2 declara gate duro + `--force`; sin wording "M-901 futuro" en `verify`/`archive`/`code-auditing`/`commit.md`). Debe fallar (RED) antes de implementar 1.3. Asserts con prefijo `[SC-NNN]`.
  - **Priority**: High
  - **Layer**: tests
  - **Estimate**: M
  - **Suggested Path**: ai-specs/skills/commit/SKILL.md
  - **Test Path**: tests/commit-gate-test.sh

- [x] 1.2 Crear fixtures de la matriz de estados `ai-specs/examples/commit-gate-fixtures/`: `verify-pass.json`, `verify-partial.json`, `verify-fail.json`, `verify-foreign.json`, `verify-invalid.json`, `adversarial-ship.json`, `adversarial-no-ship.json`, `adversarial-foreign.json` (los casos "missing" se ejercitan por ausencia de archivo). Los valida 1.1 (→ GREEN parcial).
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/examples/commit-gate-fixtures
  - **Test Path**: tests/commit-gate-test.sh

- [x] 1.3 Reescribir el Step 2 del SKILL `commit` (GREEN): gates duros con la matriz de decisión completa sobre ambos archivos, flag `--force` con trailer `Gate-Bypass` registrado en el commit message, staleness warn-only, lectura token-light, eliminación de la pregunta a ciegas y del wording "el gate duro con --force registrado es M-901, futuro"; actualizar el header "Use after".
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: L
  - **Suggested Path**: ai-specs/skills/commit/SKILL.md
  - **Test Path**: tests/commit-gate-test.sh

- [x] 1.4 Sincronizar descripciones con el nuevo contrato (lección M-403): `AGENTS.md` §5.2 (fila `/commit`: gates duros + `--force`), nota de consumidor en `ai-specs/skills/verify/SKILL.md` (Step 8, "Consumidores"), referencias al gate en `ai-specs/skills/archive/SKILL.md` y `ai-specs/skills/code-auditing/SKILL.md`, y description de `.opencode/commands/commit.md`.
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: AGENTS.md
  - **Test Path**: tests/commit-gate-test.sh

- [x] 1.5 Resolución del change de referencia post-archive (fix descubierto en dogfooding del propio gate, base-standards §7 — artefactos primero, luego código): actualizar `tests/commit-gate-test.sh` (RED) con el assert SC-012 y el token `coincide con el change de referencia`; reescribir el bullet de Step 1 y la regla 1 del Step 2 del SKILL `commit` (GREEN) para resolver el change de referencia (el change activo; si no hay, el change recién archivado por su nombre derivado, tolerando el prefijo de fecha `YYYY-MM-DD-` del CLI) y re-ejecutar `/verify`.
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/skills/commit/SKILL.md
  - **Test Path**: tests/commit-gate-test.sh

## 2. Evaluación CI (M-902)

- [x] 2.1 Crear `tests/ci-evaluation-test.sh` (RED): aserta que el historial de `PLAN_MEJORAS_SPECBOOT.md` registra el cierre M-902 ("evaluado, sin acción" / mantener), que `ci.yml` conserva los jobs `validate` y `project-ci`, y que `openspec/specs/specboot-workflows/spec.md` sigue declarando el contrato dos-jobs-un-archivo (sin migración). Debe fallar antes de 2.2. Asserts con prefijo `[SC-NNN]`.
  - **Priority**: Medium
  - **Layer**: tests
  - **Estimate**: S
  - **Suggested Path**: PLAN_MEJORAS_SPECBOOT.md
  - **Test Path**: tests/ci-evaluation-test.sh

- [x] 2.2 Documentar la decisión (GREEN): fila v3.5 en el historial de `PLAN_MEJORAS_SPECBOOT.md` con el cierre M-902 justificado (sin evidencia de fricción de consumidores; decisión del mantenedor 2026-09-05), sin tocar `ci.yml` ni `specboot-workflows/spec.md`.
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: PLAN_MEJORAS_SPECBOOT.md
  - **Test Path**: tests/ci-evaluation-test.sh

## 3. Checklist de deploy (M-903 — TDD)

- [x] 3.1 Crear `tests/deploy-checklist-test.sh` (RED): aserta que el SKILL `deploy` contiene la sección de checklist mínimo obligatorio con los 6 ítems (tests verdes, lint sin críticos, build ok, audit sin críticos, rollback definido, change archivado) y la regla de bloqueo; aserta que `docs/deploy-standards.md` incluye "rollback procedure defined" y "OpenSpec change archived" en su Pre-deploy Checklist. Debe fallar antes de 3.2/3.3. Asserts con prefijo `[SC-NNN]`.
  - **Priority**: Medium
  - **Layer**: tests
  - **Estimate**: S
  - **Suggested Path**: ai-specs/skills/deploy/SKILL.md
  - **Test Path**: tests/deploy-checklist-test.sh

- [x] 3.2 Añadir al SKILL `deploy` la sección "Mandatory pre-deploy checklist" (GREEN) con los 6 ítems y la regla: si alguno falla, no proceder (detener antes del version bump y reportar los ítems fallidos).
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/skills/deploy/SKILL.md
  - **Test Path**: tests/deploy-checklist-test.sh

- [x] 3.3 Actualizar la plantilla `docs/deploy-standards.md` (GREEN): Pre-deploy Checklist += "Rollback procedure defined" y "OpenSpec change archived".
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: docs/deploy-standards.md
  - **Test Path**: tests/deploy-checklist-test.sh

- [x] 3.4 Sincronizar la description de `.opencode/commands/deploy.md` con el checklist mínimo obligatorio.
  - **Priority**: Low
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: .opencode/commands/deploy.md
  - **Test Path**: tests/deploy-checklist-test.sh

## 4. Cierre del change

- [x] 4.1 Bump de versión `0.4.0` → `0.5.0` y entrada `## [0.5.0]` en CHANGELOG con `### Breaking changes` (contrato de `/commit`: gates duros; la auditoría adversarial deja de ser opcional) y `### Migration` (ejecutar `/verify` y `/adversarial-review` antes de `/commit`; `--force` como escape registrado).
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: package.json
  - **Test Path**: no aplica

- [x] 4.2 Completar el cierre en `PLAN_MEJORAS_SPECBOOT.md`: marcar `[x]` M-901, M-902 y M-903 y completar la fila v3.5 con lo entregado por el change (fila creada en 2.2).
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: PLAN_MEJORAS_SPECBOOT.md
  - **Test Path**: tests/ci-evaluation-test.sh
