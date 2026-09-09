# Implementation Tasks: plan-agent-git-permissions

> ⚠️ **Origen**: el código de este change ya estaba implementado al generar estos
> artefactos (auditoría del mantenedor, 2026-09-09). La norma "specs-antes-código"
> (AGENTS.md §6.5) se incumplió en el orden; este tasks.md documenta y reconcilia el
> alcance ya entregado para /verify y /commit, marcando como `[x]` las tareas que ya
> tienen evidencia en el árbol de trabajo.

## 1. Permisos git del agente plan

- [x] 1.1 Ampliar el permission block de `.opencode/agents/plan.md` con patrones bash
      allow de branch-create/read git: `"git checkout *"`, `"git checkout"`,
      `"git switch *"`, `"git switch"`, `"git branch *"`, `"git branch"`,
      `"git status"`, `"git status *"`, `"git log *"`, `"git merge-base *"`.
      (GREEN SC-001, SC-002.)
  - **Priority**: High
  - **Layer**: tests
  - **Estimate**: S
  - **Suggested Path**: .opencode/agents/plan.md
  - **Test Path**: tests/agent-permissions-test.sh

- [x] 1.2 Denegar explícitamente `"git commit": deny` y `"git push": deny` en el block
      de `.opencode/agents/plan.md`, antes del `"*": deny`. (GREEN SC-003.)
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: .opencode/agents/plan.md
  - **Test Path**: tests/agent-permissions-test.sh

- [x] 1.3 Actualizar `ai-specs/agents/plan-agent.md` para documentar el nuevo contrato
      bash (openspec + git acotado para la rama; prohibido commit/push). (GREEN
      SC-004.)
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/agents/plan-agent.md
  - **Test Path**: tests/agent-permissions-test.sh

## 2. Guard de sincronización

- [x] 2.1 Ampliar SC-007 de `tests/agent-permissions-test.sh` con asserts que verifiquen
      que `plan` permite el branch-create git (`git checkout *`, `git switch *`,
      `git branch *`, `git status`), que el rol documenta el contrato git, y que `plan`
      NO permite `git commit` ni `git push` (GREEN SC-006). Verificado: 28/28 PASS.
  - **Priority**: High
  - **Layer**: tests
  - **Estimate**: S
  - **Suggested Path**: tests/agent-permissions-test.sh
  - **Test Path**: tests/agent-permissions-test.sh

## 3. Cierre del change

- [x] 3.1 Bump de versión `0.6.4` → `0.7.0` en `package.json`, `.specboot.json` y
      entrada `## [0.7.0]` en `CHANGELOG.md` (minor: el agente plan gana capacidad de
      branch-create git; sin breaking changes). Racional: matriz de ruptura
      `docs/versioning-standard.md` §3 — se añade funcionalidad del framework sin
      romper nada → minor.
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: package.json
  - **Test Path**: no aplica

- [x] 3.2 Registrar el change en el flujo `/verify`, `/archive` y `/commit` (este
      tasks.md es el artefacto previo; los gates de /commit exigen verify PASS +
      adversarial SHIP vigentes). (/verify → PASS; /adversarial-review → SHIP;
      /archive → archivado 2026-09-09.)
  - **Priority**: Medium
  - **Layer**: framework
  - **Estimate**: M
  - **Suggested Path**: openspec/changes/plan-agent-git-permissions/
  - **Test Path**: no aplica

## Mandatory Steps

> Inyectado por `plan-change` desde `docs/openspec-tasks-mandatory-steps.md`
> (fuente única de verdad, leído en el momento de generación). Checklist
> **obligatoria, no sugerida**.

### Pre-implementación

Antes de escribir la primera línea de la tarea actual:

- [x] La **rama activa** sigue la convención vigente del proyecto (ej.
  `feature/*`, `fix/*`); trabajar sobre ella, nunca directamente sobre la rama
  principal. (Rama creada: `feature/plan-agent-git-permissions`.)
- [x] Estado **git limpio**: sin cambios sin commitear (ni staged) antes de
  empezar; si hay trabajo en curso, resolverlo primero.

### Durante la implementación

- [ ] **Test nuevo que falla antes de implementar (RED)**: escribir el test del
  escenario (`SC-NNN`) y verificar que falla antes de escribir código de
  producción. *(Este change se entregó sin seguir RED — ver nota ⚠️ del header.)*
- [x] Ejecutar los **tests unitarios del módulo** tocado mientras se itera
  (ciclo RED-GREEN-REFACTOR), no solo al final. (`bash tests/agent-permissions-test.sh`
  → 28/28 PASS.)

### Post-implementación

Antes de dar la tarea por cerrada:

- [x] **Ejecutar `verify`**: la verificación del change corre y produce
  evidencia persistente (`openspec/state/verify-results.json`). (Hecho → PASS.)
- [x] **Ejecutar `adversarial-review`**: la auditoría adversarial corre y
  produce veredicto persistente (`openspec/state/adversarial-result.json`). (Hecho → SHIP.)

> Ambos pasos post alimentan los gates duros de `/commit` (M-901): sin
> `PASS` + `SHIP` vigentes para el change activo, el commit bloquea.