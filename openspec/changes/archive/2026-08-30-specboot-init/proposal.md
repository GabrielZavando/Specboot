Ticket ID: TICKET-3.1

## Why

Every new consumer project currently has to manually clone the Specboot repo, run `specboot.sh --init` to merely *verify* structure, and hand-write `.specboot.json` plus the project-owned `docs/` skeleton. There is no single command that *initializes* a project from scratch by injecting the framework's intocable files, generating `.specboot.json`, and scaffolding `docs/`. TICKET-3.1 fills this gap: `specboot init` becomes the canonical "bootstrap a new project" command, complementing the existing `--init` (verification) and the future `update` (TICKET-3.2).

## What Changes

Adds a new `init` subcommand to `specboot.sh` (distinct from the existing `--init` flag, which only verifies). The `init` subcommand:

1. Aborts if `.specboot.json` already exists, advising `specboot update` instead.
2. Resolves the framework source directory: prefers `node_modules/@gabrielzavando/specboot` when present, otherwise the script's own directory (repo/dogfooding).
3. Copies the framework's intocable files (the `package.json` `files` allowlist: `.opencode/`, `ai-specs/`, scripts, `templates/ci/`, the 5 framework docs, `opencode.json`, `AGENTS.md`, `Makefile`, `.github/`, `LICENSE`, `README.md`).
4. Creates `.specboot.json` with defaults (`frameworkVersion` from the framework, `services: ["."]`, `stack: "framework"`) or interactive values when `--interactive` is passed.
5. Creates the project-owned `docs/` skeleton (placeholder templates for `backend-standards.md`, `frontend-standards.md`, `ci-standards.md`, `deploy-standards.md`, `documentation-standards.md`, `project/{domain,stack,client}.md`, `api/api-spec.yml`, `data-model/data-model.md`) when `docs/` is missing.
6. Never overwrites existing project files (files already present are skipped with a warning), except framework intocables on first install.

Also updates `docs/framework-contract.md` (new "Inicialización con `specboot init`" section) and `README.md` (usage example).

## Capabilities

### New Capabilities
- `specboot-init`: the `specboot init` subcommand — bootstraps a new project by injecting framework files, creating `.specboot.json`, and scaffolding the `docs/` skeleton.

### Modified Capabilities
<!-- none -->

## Impact

- `specboot.sh`: new `init` case + helper functions (`determine_framework_dir`, `copy_framework_files`, `create_initial_specboot_json`, `create_docs_skeleton_if_missing`).
- New test file `tests/specboot-init-test.sh` (TDD).
- `docs/framework-contract.md`, `README.md`: documentation only.
- No intocable framework file is *removed*; `AGENTS.md`, `base-standards.md` and other intocables are copied *to the target project*, not modified in the framework repo.
