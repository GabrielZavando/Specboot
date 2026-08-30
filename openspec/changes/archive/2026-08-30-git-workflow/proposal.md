# Proposal: Git workflow guidelines for commit, phase closure, and PR management

**Ticket ID**: TICKET-3.1
**Original title**: Git Workflow Guidelines: Commit, Phase Closure, and PR Management
**Tag**: [docs]
**Derived change name**: git-workflow
**Depends-on**: none (cross-phase working policy; applies to all future tickets)

## Why

Every ticket cycle faces the "stale branch" problem: commits accumulated on a feature
branch diverge from `main`, and the decision of *commit vs PR* is re-litigated ticket by
ticket. The team voted "one PR per phase" (rule A), but in practice some phases stay
local and some get pushed — without a written policy, OpenCode re-decides each time and
commits get lost in "ghost branches". TICKET-3.1 makes the git policy explicit and
mandatory so future tickets/agents follow the same flow instead of renegotiating it.

## What Changes

Creates a **new project-owned document** `docs/git-workflow-standards.md` that extends
the basic git rules already present in `AGENTS.md` (Conventional Commits, branch per
ticket) with the phase/rebase/PR decision workflow:

- **Rama por ticket (siempre)**: `feature/ticket-X.Y-nombre-corto` creada desde el HEAD
  actual (que ya trae tickets previos sin fusionar a main). No reutilizar ramas antiguas.
- **Commits local-first**: Conventional Commits con `Closes TICKET-X.Y`, sin push
  obligatorio.
- **Cierre de fase**: acumulación → revisión local → decisión push/PR → **un único**
  `git rebase main` al cerrar la fase (no por ticket).
- **Matriz de decisión push/PR**: 2×2 (¿`gh` autenticado? × ¿fase lista para revisar?).
- **Modo solo local**: el usuario puede mantener todo en local sin que se le exija push/PR.

**No toca archivos intocables del framework** (`AGENTS.md`, `docs/base-standards.md`,
`docs/framework-contract.md`, `docs/docs-standard.md`, `docs/versioning-standard.md`,
`docs/specboot-json-standard.md`): es una extensión, no un reemplazo. Tampoco modifica
`docs/documentation-standards.md` (que ya fija Conventional Commits y PR rules en
"Commits y PRs"); el nuevo documento las profundiza sin alterarlas.

## Summary and Motivation

Document a single, mandatory git policy in a discoverable standards file so the
"commit vs PR" decision stops being re-decided per ticket. The document is the source of
truth for agents and devs; it guarantees the "no ghost branch" invariant (commits never
get lost for lack of rebase) and lets the user choose local-only commits without the
system forcing push/PR. This is a cross-phase (Transversal) P0 working policy.

## Acceptance Criteria (from ticket)

1. El flujo "rebase por fase + decisión push/PR" está documentado en el ticket (y queda
   materializado en `docs/git-workflow-standards.md`).
2. OpenCode respeta la matriz de decisión al iniciar nuevos tickets.
3. No hay "rama fantasma" donde los commits se pierden por falta de actualización.
4. El usuario puede elegir "solo commits locales" sin que el sistema le exija push/PR.
5. `bash check-refs.sh` → 0 y `bash specboot.sh --ci` → 0.

## Rollback Plan

- Remove `docs/git-workflow-standards.md` via git revert of the change. No framework
  file is modified, so no `specboot update` or capability-spec change is required. The
  git policy falls back to the basic rules already in `AGENTS.md`.