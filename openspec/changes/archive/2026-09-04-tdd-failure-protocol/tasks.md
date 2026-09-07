# Implementation Tasks: tdd-failure-protocol

## 1. Protocolo explícito ante fallo TDD (M-301)
- [x] 1.1 Añadir sección "TDD Failure Protocol" en `.opencode/commands/apply.md` con protocolo de 4 pasos (Detectar → Intentar → Reportar → Detener)
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: .opencode/commands/apply.md
  - **Test Path**: tests/check-refs-test.sh

- [x] 1.2 Definir plantilla de `TDD Failure Report` con campos: Task, Attempt, Error, Suggested investigation
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: .opencode/commands/apply.md
  - **Test Path**: tests/check-refs-test.sh

- [x] 1.3 Integrar protocolo de fallo en `ai-specs/agents/build-agent.md` referenciando el ciclo TDD existente
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/agents/build-agent.md
  - **Test Path**: tests/check-refs-test.sh

## 2. Detención explícita tras completar tarea (M-302)
- [x] 2.1 Añadir paso "detener y reportar" al final del flujo de `ai-specs/agents/build-agent.md`
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/agents/build-agent.md
  - **Test Path**: tests/check-refs-test.sh

- [x] 2.2 Actualizar example en `ai-specs/examples/tasks.md` con ejemplo de TDD Failure Report
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/examples/tasks.md
  - **Test Path**: tests/check-refs-test.sh
