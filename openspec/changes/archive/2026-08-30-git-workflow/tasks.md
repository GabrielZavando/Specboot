# Tasks: Git workflow guidelines

## Phase 1: Document creation basics
- [x] Add intro to `docs/git-workflow-standards.md`: cross-phase P0 policy, scope (applies to all future tickets), note that it EXTENDS `AGENTS.md` basic rules and does NOT modify intocable framework files (High | Docs | 0.25h)
    - Suggested Path: `docs/git-workflow-standards.md`
    - Test Path: `bash check-refs.sh`
- [x] Add "Rama por ticket (siempre)" section: naming `feature/ticket-X.Y-nombre-corto`, branch created from current HEAD (carries previous unmerged commits), no reuse of old branches unless accumulating a Phase (High | Docs | 0.25h)
    - Suggested Path: `docs/git-workflow-standards.md`
- [x] Add "Commits local-first" section: Conventional Commit headers, one commit = one logical change, `Closes TICKET-X.Y` reference, push optional (High | Docs | 0.25h)
    - Suggested Path: `docs/git-workflow-standards.md`

## Phase 2: Phase closure and decision matrix
- [x] Add "Cierre de fase" section: accumulate tickets → review locally → decide push/PR → single `git rebase main` (resolve conflicts ONCE) → push → one PR per Phase (squash/merge) → resulting branch carries history into next Phase (High | Docs | 0.5h)
    - Suggested Path: `docs/git-workflow-standards.md`
- [x] Add "Matriz de decisión push/PR" 2×2 table: `gh` authenticated × Phase ready for review (4 quadrants: rebase+push+PR / local commit "en local" / manual PR no rebase / local commit review later) (High | Docs | 0.25h)
    - Suggested Path: `docs/git-workflow-standards.md`
- [x] Add "Modo solo local" note: user may close Phase/ticket as "completa en local", no push/PR forced, no ghost branches (commits never lost for lack of rebase) (Medium | Docs | 0.25h)
    - Suggested Path: `docs/git-workflow-standards.md`
- [x] Add "Flujo resumido para OpenCode" reference (plan-change → apply → verify → archive → commit; Phase end: push/PR decision) (Medium | Docs | 0.25h)
    - Suggested Path: `docs/git-workflow-standards.md`

## Phase 3: Verification
- [x] `bash check-refs.sh` exits 0 (High | Docs | 0.25h)
    - Test Path: `bash check-refs.sh`
- [x] `bash specboot.sh --ci` exits 0 (High | Docs | 0.25h)
    - Test Path: `bash specboot.sh --ci`
- [x] `openspec validate git-workflow` passes (High | Docs | 0.25h)
    - Test Path: `openspec validate git-workflow`