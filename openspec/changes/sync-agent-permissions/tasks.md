# Implementation Tasks: sync-agent-permissions

## 1. Guard de sincronización (TDD primero)

- [x] 1.1 Crear `tests/agent-permissions-test.sh` (RED): asserts con prefijo
      `[SC-NNN]` que validen el contrato de sincronía rol↔block —
      `[SC-001]` `"pytest *": allow` presente en `.opencode/agents/verify.md`,
      `[SC-002]` `npm run test` documentado en `ai-specs/agents/verify-agent.md`,
      `[SC-003]` patrones `git status *` / `git diff` / `git diff *` / `git log` /
      `git log *` / `node -e *` presentes en `.opencode/agents/archive.md`,
      `[SC-004]` `rm openspec/tickets/*` presente y `rm -rf openspec/changes/*`
      ausente en el block de archive,
      `[SC-005]` `git commit` ausente de "Bash permitido" en
      `ai-specs/agents/archive-agent.md` y `node -e` presente,
      `[SC-006]` pares de sincronía reviewer (npm audit, npx eslint,
      npx dependency-cruiser, git diff/status, ls, cat, mkdir -p openspec/*),
      `[SC-007]` sincronía plan (`openspec *` en block y rol; edit acotado a
      `openspec/**`),
      `[SC-008]` `"*": deny` preservado en los bloques bash de verify, reviewer,
      archive y plan,
      `[SC-010]` M-403 marcado `[x]` en `PLAN_MEJORAS_SPECBOOT.md` (fila v3.7).
      Debe fallar (RED) antes de implementar 2.x/3.x. Estilo: greps explícitos
      por archivo (precedente `tests/mandatory-steps-test.sh`), salida compacta
      y exit no-cero al primer fallo de contrato.
  - **Priority**: High
  - **Layer**: tests
  - **Estimate**: M
  - **Suggested Path**: .opencode/agents/verify.md
  - **Test Path**: tests/agent-permissions-test.sh

## 2. Fix verify (core de M-403)

- [x] 2.1 Añadir `"pytest *": allow` al permission block de
      `.opencode/agents/verify.md`, antes de la línea `"*": deny` (GREEN
      `[SC-001]`).
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: .opencode/agents/verify.md
  - **Test Path**: tests/agent-permissions-test.sh

- [ ] 2.2 Documentar `npm run test` en la lista "Bash permitido" de
      `ai-specs/agents/verify-agent.md`, junto a `npm test` (GREEN `[SC-002]`).
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/agents/verify-agent.md
  - **Test Path**: tests/agent-permissions-test.sh

## 3. Fix archive (brechas de la auditoría de planificación)

- [ ] 3.1 Corregir el permission block de `.opencode/agents/archive.md`
      (GREEN `[SC-003]`, `[SC-004]`): añadir `"git status *": allow`,
      `"git diff": allow`, `"git diff *": allow`, `"git log": allow`,
      `"git log *": allow` y `"node -e *": allow`; reemplazar
      `"rm -rf openspec/changes/*": allow` por `"rm openspec/tickets/*": allow`.
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: .opencode/agents/archive.md
  - **Test Path**: tests/agent-permissions-test.sh

- [ ] 3.2 Corregir `ai-specs/agents/archive-agent.md` (GREEN `[SC-005]`):
      eliminar `git commit` de la lista "Bash permitido" (la regla "Commit
      ownership" y el Step 6 del skill lo prohíben), documentar `node -e`
      (lecturas token-light de la evidencia del Step 5).
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/agents/archive-agent.md
  - **Test Path**: tests/agent-permissions-test.sh

## 4. Auditoría de sincronía reviewer/plan

- [ ] 4.1 Verificar vía guard que `.opencode/agents/reviewer.md` ↔
      `ai-specs/skills/code-auditing/SKILL.md` y `.opencode/agents/plan.md` ↔
      `ai-specs/agents/plan-agent.md` están sincronizados (GREEN `[SC-006]`,
      `[SC-007]`, `[SC-008]`). Estado esperado: ya sincronizados (solo asserts).
      Si `/apply` encontrara una brecha nueva, actualizar primero estos
      artefactos OpenSpec (base-standards §7) antes de corregir el archivo.
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: .opencode/agents/reviewer.md
  - **Test Path**: tests/agent-permissions-test.sh

## 5. Cierre del change

- [ ] 5.1 Bump de versión `0.6.0` → `0.6.1` y entrada `## [0.6.1]` en
      CHANGELOG (patch: sincronización de permisos/documentación de agentes,
      sin breaking changes).
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: package.json
  - **Test Path**: no aplica

- [ ] 5.2 Marcar `[x]` M-403 en `PLAN_MEJORAS_SPECBOOT.md` y completar la fila
      de historial v3.7 con lo entregado por este change (GREEN `[SC-010]`).
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: PLAN_MEJORAS_SPECBOOT.md
  - **Test Path**: tests/agent-permissions-test.sh

## Mandatory Steps

> Inyectado por `plan-change` desde `docs/openspec-tasks-mandatory-steps.md`
> (fuente única de verdad, leído en el momento de generación). Checklist
> **obligatoria, no sugerida**.

### Pre-implementación

Antes de escribir la primera línea de la tarea actual:

- [ ] La **rama activa** sigue la convención vigente del proyecto (ej.
  `feature/*`, `fix/*`); trabajar sobre ella, nunca directamente sobre la rama
  principal.
- [ ] Estado **git limpio**: sin cambios sin commitear (ni staged) antes de
  empezar; si hay trabajo en curso, resolverlo primero.

### Durante la implementación

- [ ] **Test nuevo que falla antes de implementar (RED)**: escribir el test del
  escenario (`SC-NNN`) y verificar que falla antes de escribir código de
  producción.
- [ ] Ejecutar los **tests unitarios del módulo** tocado mientras se itera
  (ciclo RED-GREEN-REFACTOR), no solo al final.

### Post-implementación

Antes de dar la tarea por cerrada:

- [ ] **Ejecutar `verify`**: la verificación del change corre y produce
  evidencia persistente (`openspec/state/verify-results.json`).
- [ ] **Ejecutar `adversarial-review`**: la auditoría adversarial corre y
  produce veredicto persistente (`openspec/state/adversarial-result.json`).

> Ambos pasos post alimentan los gates duros de `/commit` (M-901): sin
> `PASS` + `SHIP` vigentes para el change activo, el commit bloquea.
