# Scenarios: Restrict package.json to framework-only distribution

## Scenario 1: Package allowlist ships only framework assets (Happy Path)
**Given** `package.json` defines `files` with the framework-only allowlist
**When** running `npm pack --dry-run`
**Then** the tarball contains `.opencode/commands`, `.opencode/agents`, `ai-specs`, `check-refs.sh`, `specboot.sh`, `validate-specboot.sh`, `templates/ci`, the 5 intocable docs (base-standards, framework-contract, docs-standard, specboot-json-standard, versioning-standard), `opencode.json`, `AGENTS.md`, `Makefile`, `.github/workflows`, `LICENSE`, `README.md`
**And** the tarball does NOT contain `update.sh`, the project `docs/` tree, `openspec/`, `node_modules/`, `tests/`, `.git/`

## Scenario 2: .npmignore does not block allowlisted paths (Edge case)
**Given** `files` allowlists `.opencode/commands`, `.opencode/agents`, `.github/workflows`
**When** `.npmignore` is reconciled (blanket `.github/` and `.opencode/` exclusions removed)
**Then** `npm pack --dry-run` still includes those three paths
**And** `npm pack --dry-run` excludes `openspec/`, `tests/`, `node_modules/`, `.git/`, `.env*`, `CHANGELOG.md`

## Scenario 3: Shipped CLI stays self-consistent (Edge case)
**Given** `update.sh` is removed from `files`
**When** `update.sh` is also removed from `specboot.sh` REQUIRED_FILES
**Then** `bash specboot.sh --ci` exits 0 (no missing-required-file failure)
**And** `bash check-refs.sh` exits 0 (it never referenced update.sh)

## Scenario 4: Internal repo state excluded (Negative case)
**Given** the repository contains `openspec/`, `tests/`, `node_modules/`, `.git/`, project `docs/`
**When** running `npm pack --dry-run`
**Then** none of those paths appear in the tarball listing
