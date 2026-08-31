# Proposal: Workflow de release que publica a npm tras merge a main

## Change created from ticket

**Ticket ID**: TICKET-6.1
**Original title**: Workflow de release que publica a npm tras merge a main
**Tag (source)**: [docs] (explicit)
**Derived change name**: specboot-release
**Change folder**: openspec/changes/specboot-release/
**Enriched artifact used**: no (ticket is well-formed; title used as source)

### Naming rationale
- **Verb**: `release` — the workflow publishes the framework package to npm/GitHub Packages upon release
- **Noun/entity**: `release` workflow — the GitHub Actions workflow that orchestrates validation + publication
- **Domain prefix**: `specboot-` — this is the framework's *own* release workflow, consistent with sibling names `specboot-workflows`, `specboot-makefile`, `specboot-update`

### Context loaded
- `docs/documentation-standards.md` (tag `[docs]`)
- `docs/framework-contract.md` (sección "Workflows del framework" + frontera intocable — confirma que los workflows son intocables, `update.sh` no toca workflows, `specboot update` sí los reemplaza)
- `docs/versioning-standard.md` (sec. 5 "Comportamiento de specboot update" + sec. 6 "Formato CHANGELOG / Release notes")
- `docs/docs-standard.md` (frontera intocable/docs — confirma `versioning-standard.md` es intocable)
- `package.json` (allowlist `files` incluye `.github/workflows`; `publishConfig` = GitHub Packages; versión `0.1.1`)
- `Makefile` (`ci: refs solid-lint lint test audit`)
- `specboot.sh` (`--ci`), `check-refs.sh`, `validate-specboot.sh`
- `tests/*-test.sh` (8 self-tests existentes: check-refs-test, update-test, specboot-update-test, solid-templates-test, package-files-test, dogfood-check-test, specboot-init-test, makefile-test)
- `openspec/specs/npm-distribution/spec.md`, `specboot-workflows/spec.md`, `versioning-standard/spec.md` (archived patterns)

## Why

Phase 0 declared: "publicación automática por release: rama por cambio → merge a main → release cuando la versión está lista." The npm-distribution spec (TICKET-1.1) defined a `publish.yml` triggered on tag push `v*.*.*`, but that trigger model is superseded: the release workflow should fire on **push to `main`** (merge of a completed change) **or** on **GitHub Release published**, with the maintainer bumping `version` in `package.json` (SemVer) before merge.

Without this workflow, there is no CI/CD path that validates the framework end-to-end and publishes the npm tarball to GitHub Packages automatically. The existing `update.sh --bump` creates a git tag but there is no workflow consuming that trigger — the release automation must be explicit and gate on full framework self-check before publishing.

## What Changes

- **Creates** `.github/workflows/release.yml` — new workflow with two jobs: `validate` (full framework self-check: `check-refs.sh` + `specboot.sh --ci` + `make ci` + `tests/*-test.sh`) and `publish` (`npm pack --dry-run` + `npm publish` to GitHub Packages), triggered on `push: branches: [main]` and `release: types: [published]`.
- **Updates** `docs/versioning-standard.md` — adds a "Release automático" section documenting the workflow's validation gate, triggers, and the maintainer's manual version-bump responsibility (SemVer bump before merge; workflow does NOT auto-bump).
- **Updates** `README.md` — adds a "Publicación (release automático)" section with YAML snippet of triggers and clarifies the `update.sh --bump` description (line 121): it is maintainer convenience for the version bump, not a direct workflow trigger; the `publish.yml`-on-tag model from TICKET-1.1 is superseded by `release.yml`.

## Goals

- Implement a release workflow that validates the entire framework before publishing to GitHub Packages.
- Document the release model (triggers, validation gate, version-bump responsibility) in `versioning-standard.md` and `README.md`.
- Replace the obsolete `publish.yml`-on-tag concept from TICKET-1.1 with a robust `release.yml`.

## Non-Goals

- **No version bump automation** in the workflow. The maintainer increments `version` in `package.json` (SemVer) before merge (TICKET-0.4). `update.sh --bump` remains as a maintainer convenience tool, but the release workflow does NOT invoke it.
- Does NOT modify `Makefile`, `ci.yml`, `deploy.yml`, `specboot.sh`, `update.sh`, `package.json` `files`, or `AGENTS.md` (all intocables — per ticket §7 "No se modifica").
- Does NOT create `publish.yml` from TICKET-1.1 — `release.yml` replaces that concept.
- Does NOT implement automatic version bump or git tagging in the workflow.
