# git-workflow Specification

## Purpose
TBD - created by archiving change git-workflow. Update Purpose after archive.
## Requirements
### Requirement: New git workflow standards document exists as source of truth

`docs/git-workflow-standards.md` MUST exist and be the source of truth for the
git workflow policy (branch per ticket, local-first commits, phase closure,
push/PR decision matrix, local-only mode). The document MUST state that it
**extends** the basic git rules in `AGENTS.md` (Conventional Commits, branch
per ticket) and does NOT replace or modify them, nor any intocable framework
file.

#### Scenario: Standards document exists and is discoverable

- **Given** the team voted "one PR per phase" (rule A) and the git workflow is a cross-phase P0 policy
- **When** the change is applied
- **Then** `docs/git-workflow-standards.md` exists and is the source of truth for the git workflow
- **And** it explicitly states it extends the basic rules in `AGENTS.md` without replacing them or modifying any intocable framework file

### Requirement: Branch per ticket created from current HEAD

The document MUST define the branch-per-ticket rule: every new ticket creates
a branch `feature/ticket-X.Y-nombre-corto` from the current HEAD (which
already carries the previous tickets' commits not yet merged to `main`), and
previous tickets' branches MUST NOT be reused unless the intention is Phase
accumulation.

#### Scenario: Branch per ticket, created from current HEAD

- **Given** a developer (or OpenCode) starts a new ticket `TICKET-X.Y` via `/plan-change`
- **When** the feature branch is created
- **Then** it is named `feature/ticket-X.Y-nombre-corto` (kebab-case, short description)
- **And** it is created from the current HEAD, which already carries the previous tickets' commits not yet merged to `main`

### Requirement: Commits are local-first with conventional headers

The document MUST define the commits local-first rule: Conventional Commit
headers (`feat:` / `fix:` / `docs:` / `refactor:` / `test:` / `chore:`), one
logical change per commit, a `Closes TICKET-X.Y` reference, and no mandatory
push — commits MAY remain local without the system requiring a push.

#### Scenario: Commits are local-first with conventional headers

- **Given** work is happening on the feature branch of a ticket
- **When** a developer commits
- **Then** the commit uses a Conventional Commit header, one logical change per commit
- **And** the body/reference includes `Closes TICKET-X.Y`
- **And** pushing is optional — commits may stay local without the system requiring a push

### Requirement: Phase closure — accumulate, review locally, rebase ONCE

The document MUST define the phase closure procedure: a Phase groups multiple
tickets committed on the accumulated feature branch; when the Phase is
reviewed locally by the user, the developer decides whether to push/PR. If
pushing, a **single** `git rebase main` (conflict resolution once) MUST
precede `git push` and the creation of **one PR per Phase** (squash/merge of
all Phase commits). The resulting branch carries the accumulated history into
the next Phase.

#### Scenario: Phase closure — accumulate, review locally, rebase ONCE

- **Given** a Phase groups multiple tickets (e.g. 1.1, 1.2, 2.1) all committed on the accumulated feature branch
- **When** the Phase is finished and reviewed locally by the user
- **Then** the developer decides whether to push/PR
- **And** if pushing, a single `git rebase main` (conflict resolution once) precedes `git push` and the creation of one PR per Phase (squash/merge of all Phase commits)
- **And** the resulting branch carries the accumulated history into the next Phase

### Requirement: Push/PR decision matrix is documented and applied

The document MUST contain a 2x2 push/PR decision matrix (`gh` authenticated x
Phase ready for review) covering all four combinations and their actions:
`gh` yes + Phase ready → rebase to main, push, create PR; `gh` yes + not
ready → local commit, no push, ticket marked "en local"; `gh` no + Phase
ready → manual PR on GitHub.com, no forced rebase; `gh` no + not ready →
local commit, keep state, review later.

#### Scenario: Push/PR decision matrix is documented and applied

- **Given** `gh` may or may not be authenticated, and a Phase may or may not be "ready for review"
- **When** the developer faces the push/PR decision
- **Then** the document contains a 2x2 decision matrix covering all four combinations
- **And** each combination maps to its action (rebase+push+PR / local commit "en local" / manual PR / local commit review later)

### Requirement: Local-only mode is always available (no ghost branches)

The document MUST guarantee the local-only mode: the user MAY close a
Phase/ticket as "completa en local" with commits left on the feature branch,
the system MUST NOT force push/PR, and no commits MUST be lost or "ghosted"
for lack of rebase.

#### Scenario: Local-only mode is always available

- **Given** a user does not want to push/PR for a Phase or ticket
- **When** the Phase closes
- **Then** the ticket is marked "completa en local" with commits left on the feature branch
- **And** the system does not force push/PR, and no commits are lost or "ghosted" for lack of rebase

### Requirement: Framework intocable files remain untouched

The change MUST NOT modify intocable framework files: `AGENTS.md`,
`docs/base-standards.md`, `docs/framework-contract.md`, `docs/docs-standard.md`,
`docs/versioning-standard.md`, `docs/specboot-json-standard.md`. It MUST NOT
contradict `docs/documentation-standards.md`'s "Commits y PRs" rules; that
section remains authoritative for Conventional Commits and PR description
rules, and the new document deepens without contradicting.

#### Scenario: Framework intocable files remain untouched

- **Given** the git workflow policy is being documented
- **When** the change is applied
- **Then** `AGENTS.md` is not modified
- **And** none of the intocable framework docs (`docs/base-standards.md`, `docs/framework-contract.md`, `docs/docs-standard.md`, `docs/versioning-standard.md`, `docs/specboot-json-standard.md`) are modified
- **And** `docs/documentation-standards.md` (section "Commits y PRs") remains authoritative for Conventional Commits and PR description rules — the new document deepens, does not contradict

### Requirement: Validation scripts pass

`bash check-refs.sh` and `bash specboot.sh --ci` MUST both exit 0 from the
project root after the document is created. The change MUST NOT alter the list
of files returned by `check-refs.sh` Step 3 (every skill name in
`ai-specs/skills/*/` MUST still appear in `AGENTS.md`) and MUST NOT alter
`specboot.sh`'s `REQUIRED_FILES` or `PLACEHOLDER_PATTERNS` arrays. The
validation scripts MUST remain green after the change.

#### Scenario: check-refs.sh and specboot.sh --ci report 0 errors

- **Given** the new standards document is applied
- **When** `bash check-refs.sh` is executed from the project root
- **Then** it reports 0 errors
- **And** when running `bash specboot.sh --ci`, it also reports 0 errors
- **And** no `PLACEHOLDER_PATTERNS` are detected in `docs/`
- **And** the `REQUIRED_FILES` list is not modified by this change

