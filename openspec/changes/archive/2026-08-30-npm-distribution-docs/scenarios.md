# Scenarios: Document npm distribution boundary

## Scenario 1: README documents published assets (Happy Path)
**Given** `package.json` declares a `files` allowlist that ships only intocable framework assets (from TICKET-1.1)
**When** a reader opens `README.md`
**Then** there is a "Qué incluye el paquete" section listing each allowlisted asset (commands `.opencode/commands/`, agents `.opencode/agents/`, `ai-specs/`, scripts `check-refs.sh`/`specboot.sh`/`validate-specboot.sh`, `templates/ci/`, the 5 intocable docs `base-standards`/`framework-contract`/`docs-standard`/`specboot-json-standard`/`versioning-standard`, `opencode.json`, `AGENTS.md`, `Makefile`, `.github/workflows/`, `LICENSE`, `README.md`)
**And** there is a "Qué es del proyecto" section listing app code, project `docs/` (except the 5 standards), `.specboot.json`, project MCP, and env/GitHub vars as NOT shipped

## Scenario 2: framework-contract subsection reaffirms intocable-only (Happy Path)
**Given** `docs/framework-contract.md` already describes the distribution architecture
**When** a reader opens the document
**Then** it contains a "Distribución vía npm" subsection stating that `files` is the source of truth, that only intocable assets publish, and that project `docs/` is filtered out by the allowlist

## Scenario 3: Dogfooding clarity — dev repo docs not published (Edge case)
**Given** the Specboot development repository contains its own `docs/` (backend/frontend/documentation/deploy standards, `api/`, `data-model/`, `ci-standards.md`, `project/`) that are NOT in `files`
**When** a dogfooding developer reads `README.md` / `docs/framework-contract.md`
**Then** a note clarifies those `docs/` are NOT published (filtered by `files`), so the dev repo content differs from what `npm install` provides

## Scenario 4: Validation passes (Acceptance)
**Given** the README and framework-contract edits are applied
**When** running `bash check-refs.sh`
**Then** the script exits 0 (no broken `{file:...}` refs or unregistered skills)
**And** when running `bash specboot.sh --ci`
**Then** the script exits 0 (file structure, JSON, skills, refs all valid)
