# Scenarios: specboot init

## Scenario 1: Init in empty directory (Happy Path)
**Given** an empty directory
**When** `specboot init` runs
**Then** `.specboot.json` is created with defaults (`frameworkVersion`, `services: ["."]`, `stack: "framework"`)
**And** the framework intocable files are copied into the directory
**And** a `docs/` skeleton with project-owned placeholder templates is created

## Scenario 2: Guard — .specboot.json already exists
**Given** a directory that already contains `.specboot.json`
**When** `specboot init` runs
**Then** it prints a warning "already exists, use specboot update" and exits 0 without overwriting

## Scenario 3: Interactive mode
**Given** a user runs `specboot init --interactive`
**When** prompted for project name, stack and services
**Then** the resulting `.specboot.json` reflects the entered values

## Scenario 4: Custom template source
**Given** a `--template /path/to/framework` flag
**When** `specboot init --template /path/to/framework` runs
**Then** framework files are copied from that directory instead of the default resolution

## Scenario 5: No overwrite of existing project files
**Given** a directory that already has a project-owned file (e.g. a custom `AGENTS.md` or `docs/base-standards.md`)
**When** `specboot init` runs
**Then** the existing file is preserved (skipped with a warning), not overwritten

## Scenario 6: Docs skeleton generation
**Given** a directory without a `docs/` folder
**When** `specboot init` runs
**Then** `docs/` is created with placeholder templates for all project-owned standards (backend/frontend/ci/deploy/documentation, project/*, api, data-model)

## Scenario 7: Existing --init verification remains functional
**Given** the `init` subcommand is added
**When** `specboot.sh --init` (verification) runs on a fully-initialized project
**Then** it still exits 0 reporting the structure is valid

## Scenario 8: Validation passes (Acceptance)
**Given** the change is applied to the framework repo
**When** `bash check-refs.sh` runs
**Then** it exits 0
**And** when `bash specboot.sh --ci` runs it also exits 0
**And** `openspec validate specboot-init` passes
