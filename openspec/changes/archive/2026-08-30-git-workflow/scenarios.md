# Scenarios: Git workflow guidelines

## Scenario 1: Standards document exists and is discoverable (Happy Path)
**Given** the team voted "one PR per phase" (rule A) and the git workflow is a cross-phase P0 policy
**When** the change is applied
**Then** `docs/git-workflow-standards.md` exists and is the source of truth for the git workflow
**And** it explicitly states it **extends** the basic rules in `AGENTS.md` without replacing them or modifying any intocable framework file

## Scenario 2: Branch per ticket, created from current HEAD (Happy Path)
**Given** a developer (or OpenCode) starts a new ticket `TICKET-X.Y` via `/plan-change`
**When** the feature branch is created
**Then** it is named `feature/ticket-X.Y-nombre-corto` (kebab-case, short description)
**And** it is created from the current HEAD, which already carries the previous tickets' commits not yet merged to `main`

## Scenario 3: Commits are local-first with conventional headers (Happy Path)
**Given** work is happening on the feature branch of a ticket
**When** a developer commits
**Then** the commit uses a Conventional Commit header (`feat:` / `fix:` / `docs:` / `refactor:` / `test:` / `chore:`), one logical change per commit
**And** the body/reference includes `Closes TICKET-X.Y`
**And** pushing is optional — commits may stay local without the system requiring a push

## Scenario 4: Phase closure — accumulate, review locally, rebase ONCE (Happy Path)
**Given** a Phase groups multiple tickets (e.g. 1.1, 1.2, 2.1) all committed on the accumulated feature branch
**When** the Phase is finished and reviewed locally by the user
**Then** the developer decides whether to push/PR
**And** if pushing, a **single** `git rebase main` (conflict resolution once) precedes `git push` and the creation of **one PR per Phase** (squash/merge of all Phase commits)
**And** the resulting branch carries the accumulated history into the next Phase

## Scenario 5: Push/PR decision matrix is documented and applied (Edge case)
**Given** `gh` may or may not be authenticated, and a Phase may or may not be "ready for review"
**When** the developer faces the push/PR decision
**Then** the document contains a 2×2 decision matrix covering all four combinations:
- `gh` yes + Phase ready → rebase to main, push, create PR
- `gh` yes + not ready → local commit, no push, ticket marked "en local"
- `gh` no + Phase ready → manual PR on GitHub.com, no forced rebase
- `gh` no + not ready → local commit, keep state, review later

## Scenario 6: Local-only mode is always available (Edge case)
**Given** a user does not want to push/PR for a Phase or ticket
**When** the Phase closes
**Then** the ticket is marked "completa en local" with commits left on the feature branch
**And** the system does not force push/PR, and no commits are lost or "ghosted" for lack of rebase

## Scenario 7: Framework intocable files remain untouched (Acceptance)
**Given** the git workflow policy is being documented
**When** the change is applied
**Then** `AGENTS.md` is not modified
**And** none of the intocable framework docs (`docs/base-standards.md`, `docs/framework-contract.md`, `docs/docs-standard.md`, `docs/versioning-standard.md`, `docs/specboot-json-standard.md`) are modified
**And** `docs/documentation-standards.md` (section "Commits y PRs") remains authoritative for Conventional Commits and PR description rules — the new document deepens, does not contradict

## Scenario 8: Validation passes (Acceptance)
**Given** the new standards document is applied
**When** running `bash check-refs.sh`
**Then** the script exits 0 (no broken `{file:...}` refs or unregistered skills)
**And** when running `bash specboot.sh --ci`
**Then** the script exits 0 (file structure, JSON, skills, refs all valid)