# Tasks: force-push-deny-and-doc-distribution (TICKET-AUDIT-2)

> Implements REQ-001…REQ-005 covering SC-001…SC-007.
> TDD: guards are extended and observed failing (RED) before any
> agent/package/script file is modified (GREEN).

---

## Mandatory Steps

> Injected by `plan-change` from `docs/openspec-tasks-mandatory-steps.md`
> (single source of truth, read at generation time). This checklist is
> **mandatory, not suggested**, and applies to every implementation task
> executed via `/apply`.

**Pre-implementation**

- [x] Active branch follows the project convention: `feature/ticket-audit-2-force-push-deny-and-doc-distribution` (creada desde origin/main)
- [x] Clean git state at start (spec artifacts uncommitted per flow)

**During implementation**

- [x] New guard asserts failed before implementation (RED observado en Tasks 1-2: 3 + 4 fallos)
- [x] Guards re-run while iterating (RED-GREEN por tarea)

**Post-implementation**

- [x] Run `verify`: produces `openspec/state/verify-results.json` (PASS, executable)
- [x] Run `adversarial-review`: produces `openspec/state/adversarial-result.json` (SHIP, 0.9)

---

## Phase 0 — Spike

### Task 0: Spike — mid-command wildcard support in permission engine ✅ COMPLETED

- [x] Verificado vía documentación oficial OpenCode (docs/permissions): los patterns son glob sobre el string completo del comando (`*` = cero o más caracteres cualesquiera) → **wildcards intermedios soportados**; regla "last matching rule wins" → denies después del allow genérico
- Resultado: deny set para Task 5 = `git push --force*`, `git push *--force*`, `git push -f*`, `git push * -f`
- Priority: High
- Layer: Framework infra
- Suggested Path: no aplica (spike documentado)
- Test Path: no aplica
- Estimated: 0.25 hours

## Phase 1 — Guards first (RED)

### Task 1: Extend distribution guards for the 7th intocable doc ✅ COMPLETED (RED: 3 failing asserts)

- [x] `tests/package-files-test.sh`: `allowedDocs` 6→7 (incluye `docs/tdd-failure-protocol.md`)
- [x] `tests/specboot-init-test.sh`: assert de que init copia `docs/tdd-failure-protocol.md` (+ base-standards como control)
- [x] `tests/specboot-update-test.sh`: fixture FW-tddproto + assert de UPDATE replacement
- [x] Run guards → failures observados (RED)
- Priority: High
- Layer: Framework infra (guards)
- Suggested Path: tests/package-files-test.sh, tests/specboot-init-test.sh, tests/specboot-update-test.sh
- Test Path: mismos archivos
- Estimated: 0.5 hours

### Task 2: Extend agent-permissions guard for force-push coverage ✅ COMPLETED (RED: 4 failing asserts)

- [x] Nuevos asserts [SC-005]: deny `"git push *--force*"`, `"git push -f*"`, `"git push * -f"`; [SC-006]: el rol documenta el deny set completo
- [x] Run guard → 4 fallos observados (RED), 0 regresiones en los 39 preexistentes
- Priority: High
- Layer: Framework infra (guards)
- Suggested Path: tests/agent-permissions-test.sh
- Test Path: tests/agent-permissions-test.sh
- Estimated: 0.25 hours

## Phase 2 — Distribution fix (GREEN)

### Task 3: Ship the canonical doc ✅ COMPLETED (GREEN: package-files ✅, init 29/0, update 43/0)

- [x] Añadido `docs/tdd-failure-protocol.md` a `package.json` `files`
- [x] Añadido a `FRAMEWORK_ITEMS` y `UPDATE_ITEMS` en `specboot.sh`
- [x] Actualizados árbol/tabla en `docs/docs-standard.md` y conteos 6→7 en `framework-contract.md`
- Priority: High
- Layer: Framework infra
- Suggested Path: package.json, specboot.sh, docs/docs-standard.md, docs/framework-contract.md
- Test Path: tests/package-files-test.sh, tests/specboot-init-test.sh, tests/specboot-update-test.sh
- Estimated: 0.75 hours

### Task 4: Spec deltas ✅ COMPLETED

- [x] `openspec/specs/npm-distribution/spec.md`: delta MODIFIED (files incluye el 7º doc) — escrito en plan-change, verificado vs implementación
- [x] `openspec/specs/specboot-update/spec.md`: delta MODIFIED (UPDATE_ITEMS con 7 docs) — verificado
- [x] `openspec validate force-push-deny-and-doc-distribution` ✅
- Priority: High
- Layer: Framework docs
- Suggested Path: openspec/specs/npm-distribution/spec.md, openspec/specs/specboot-update/spec.md
- Test Path: openspec validate
- Estimated: 0.5 hours

## Phase 3 — Force-push coverage (GREEN)

### Task 5: Harden commit agent push patterns ✅ COMPLETED (GREEN: 43/43)

- [x] Denies añadidos al permission block de `.opencode/agents/commit.md`: `git push *--force*`, `git push -f*`, `git push * -f` (además del existente `git push --force*`)
- [x] Rol del agente documenta el deny set completo (espejo M-403)
- [x] `agent-permissions-test.sh` → 43/43 GREEN
- Priority: High
- Layer: Framework infra
- Suggested Path: .opencode/agents/commit.md
- Test Path: tests/agent-permissions-test.sh
- Estimated: 0.5 hours

## Phase 4 — Closure

### Task 6: Full suite + patch bump ✅ COMPLETED

- [x] Todos los guards verdes (`ls tests/*.sh`, 0 fallos), `check-refs.sh` 0 errores, `specboot.sh --ci` OK (SC-007)
- [x] CHANGELOG entrada patch + bump 0.8.0 → 0.8.1 en package.json y .specboot.json sincronizados (lección: ambos archivos en la misma operación)
- Priority: High
- Layer: Framework infra
- Suggested Path: CHANGELOG.md, package.json, .specboot.json
- Test Path: tests/mandatory-steps-test.sh (version consistency)
- Estimated: 0.25 hours
