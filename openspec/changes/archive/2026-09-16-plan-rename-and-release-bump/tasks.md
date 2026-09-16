# Tasks: plan-rename-and-release-bump (TICKET-AUDIT-3)

> Implements REQ-001…REQ-005 covering SC-001…SC-008.
> TDD: guards extended/created and observed failing (RED) before implementation.

---

## Mandatory Steps

> Injected by `plan-change` from `docs/openspec-tasks-mandatory-steps.md`
> (single source of truth, read at generation time).

**Pre-implementation**

- [x] Active branch: `feature/ticket-audit-3-plan-rename-and-release-bump` (created via Step 1½)
- [x] Clean git state at start (spec artifacts uncommitted per flow)

**During implementation**

- [x] New test fails before implementing (RED observado: 8 asserts de rename + 1 de script + 1 de distribución)
- [x] Guards re-run while iterating (RED-GREEN por tarea)

**Post-implementation**

- [x] Run `verify`: produces `openspec/state/verify-results.json` (PASS, executable)
- [x] Run `adversarial-review`: produces `openspec/state/adversarial-result.json` (SHIP, 0.82 — 2 WARNINGs registrados como follow-up de release-bump.sh)

---

## Phase 1 — Guards first (RED)

### Task 1: Guards for the agent rename ✅ COMPLETED (RED: 8 failing asserts; fixed subshell-env bug in new assert)

- [x] `tests/agent-permissions-test.sh`: asserts para `sdd-plan.md` existente con contrato preservado, ningún comando con `agent: plan`, y los 3 comandos apuntando a `sdd-plan`
- [x] Run → RED
- Priority: High
- Layer: Framework infra (guards)
- Suggested Path: tests/agent-permissions-test.sh
- Test Path: same
- Estimated: 0.5h

### Task 2: New guard for release-bump ✅ COMPLETED (RED: exit 1, "script does not exist")

- [x] Creado `tests/release-bump-test.sh` con fixtures en temp: happy path (sync ambos archivos), semver inválido aborta sin tocar nada, sección CHANGELOG ausente aborta sin tocar nada, sin git tag (fixture sin repo git)
- [x] Run → RED confirmado
- Priority: High
- Layer: Framework infra (guards)
- Suggested Path: tests/release-bump-test.sh
- Test Path: same
- Estimated: 1h

## Phase 2 — Implementation (GREEN)

### Task 3: Rename the agent and rewire commands ✅ COMPLETED (GREEN: 47/47 agent-permissions, check-refs 0 errores, --ci OK)

- [x] `git mv .opencode/agents/plan.md .opencode/agents/sdd-plan.md`
- [x] `agent: sdd-plan` en plan-change.md, enrich-us.md, explain.md
- [x] Actualizado ai-specs/README.md (registro del rename); AGENTS.md sin referencias al file path (solo a roles/comandos, intactos); sweep rg sin residuales
- Priority: High
- Layer: Framework infra
- Suggested Path: .opencode/agents/plan.md, .opencode/agents/sdd-plan.md, .opencode/commands/{plan-change,enrich-us,explain}.md, AGENTS.md, ai-specs/README.md
- Test Path: tests/agent-permissions-test.sh
- Estimated: 1h

### Task 4: release-bump.sh + distribution ✅ COMPLETED (GREEN: 10/10 + allowlist + init/update verdes)

- [x] Creado `release-bump.sh` en raíz (semver validation, atomic JSON writes vía node, CHANGELOG precondition, sin git)
- [x] Registrado en `package.json → files`, `FRAMEWORK_ITEMS` y `UPDATE_ITEMS`
- [x] `tests/package-files-test.sh` requiredExact incluye `release-bump.sh` (RED observado antes de registrar, GREEN después)
- Priority: High
- Layer: Framework tooling
- Suggested Path: release-bump.sh, package.json, specboot.sh, tests/package-files-test.sh
- Test Path: tests/release-bump-test.sh, tests/package-files-test.sh
- Estimated: 1.5h

### Task 5: Spec deltas ✅ COMPLETED

- [x] `agent-permissions/spec.md`: MODIFIED "Plan agent can create the ticket branch via git" → sdd-plan, título exacto verificado
- [x] `npm-distribution/spec.md`: MODIFIED "Package configuration" (release-bump.sh) ✅
- [x] `specboot-update/spec.md`: MODIFIED "Replaces intocable files..." (UPDATE_ITEMS + wipe de plan.md) ✅
- [x] `openspec validate plan-rename-and-release-bump` ✅ válido
- Priority: High
- Layer: Framework docs
- Suggested Path: openspec/specs/agent-permissions/spec.md, openspec/specs/npm-distribution/spec.md, openspec/specs/specboot-update/spec.md
- Test Path: openspec validate
- Estimated: 0.5h

### Task 7: Fix adversarial warnings in release-bump.sh (post-review hardening) ✅ COMPLETED

- [x] Guard extendido: SC-009 (parse-before-write ante peer corrupto) + SC-010 (anti-downgrade) → RED (4 fallos)
- [x] `release-bump.sh` reescrito: ambos JSON parseados y semver comparado ANTES de escribir; `grep -F` en precondición CHANGELOG
- [x] GREEN: 15/15 release-bump + suite completa 19/19; openspec validate ✅
- Priority: High
- Layer: Framework tooling
- Suggested Path: release-bump.sh
- Test Path: tests/release-bump-test.sh
- Estimated: 0.5h

### Task 6: Versioning-standard rule + CHANGELOG + bump ✅ COMPLETED

- [x] `docs/versioning-standard.md` §6.1: bumps solo vía `release-bump.sh` (nunca manual ni `npm version`)
- [x] CHANGELOG 0.9.0 con `### Breaking changes` (rename) + `### Added` (script + guards)
- [x] Dogfooding: `bash release-bump.sh 0.9.0` ejecutó este bump (ambos archivos sincronizados)
- [x] Full suite 19/19 + check-refs 0 errores + specboot --ci OK (SC-008)
- Priority: High
- Layer: Framework docs/infra
- Suggested Path: docs/versioning-standard.md, CHANGELOG.md, package.json, .specboot.json
- Test Path: tests/mandatory-steps-test.sh (version consistency)
- Estimated: 0.5h
