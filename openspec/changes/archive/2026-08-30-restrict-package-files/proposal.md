# Proposal: Restrict package.json to framework-only distribution

**Ticket ID**: TICKET-1.1
**Original title**: Reestructuración de `package.json` para distribución solo-framework
**Tag**: [docs] (inferred — packaging/contract change; governing context: docs/framework-contract.md, docs/docs-standard.md, docs/versioning-standard.md; no backend/frontend/api standards apply)
**Derived change name**: restrict-package-files

## Why

The current `package.json` ships the entire `docs/` tree (project docs), `update.sh`, and the whole `templates/` dir, while NOT shipping the intocable framework assets `.opencode/commands`, `.opencode/agents`, and `.github/workflows`. This violates the framework contract (TICKET-0.1): the npm package is the ONLY distribution channel and must carry ONLY intocable framework files. Shipping project docs leaks consumer-customizable content; omitting `.opencode/*` and `.github/workflows` breaks the "specboot installs framework tooling" promise.

## What Changes

- Rewrite `package.json` `files` allowlist to ship exclusively intocable framework assets (commands, agents, ai-specs, validation scripts, templates/ci, the 5 intocable docs, opencode.json, AGENTS.md, Makefile, .github/workflows, LICENSE, README.md).
- Drop `update.sh` from `files` (retired as a standalone shipped script; init/update becomes specboot.sh's responsibility in Fase 3/4).
- Add `bin.specboot` -> ./specboot.sh, `scripts` (check/validate/ci), corrected `description` (no "template"), framework `keywords`.
- Reconcile `.npmignore` with `files`: remove blanket `.github/` and `.opencode/` exclusions so the now-allowlisted subpaths ship; keep excluding internal state (openspec/, tests/, node_modules/, .git/, .env*, CHANGELOG.md, logs). Add `.openspec/` for safety.
- Remove `update.sh` from `specboot.sh` REQUIRED_FILES (coherence edit) so the shipped `--ci`/`--init` does not fail on a file no longer shipped.
- Update the `npm-distribution` capability spec to reflect the new allowlist/exclusions.

## Summary and Motivation

Materializes the TICKET-0.1 contract: `@gabrielzavando/specboot` distributes only the intocable framework. Keeps the published tarball lean and correct, and keeps the framework's own `specboot.sh --ci` green for consumers.

## Acceptance Criteria (from ticket)

1. `package.json` `files` lists only framework (intocable) files.
2. `npm pack --dry-run` excludes project docs (except the 5 intocable standards), openspec/, node_modules/, tests/.
3. `bin.specboot` -> ./specboot.sh.
4. `description` no longer says "template".
5. `check-refs.sh` and `specboot.sh --ci` exit 0.
6. `.npmignore` coherent with `files`.

## Rollback Plan

- Revert package.json, .npmignore, specboot.sh REQUIRED_FILES via git. The published artifact is immutable per GitHub Packages; if a bad version shipped, `npm deprecate` it and cut a patch.
