# Requirements: Document npm distribution boundary

1. `README.md` MUST contain a "Qué incluye el paquete" section that lists exactly the assets in the `package.json` `files` allowlist: commands (`.opencode/commands/`), agents (`.opencode/agents/`), `ai-specs/`, validation scripts (`check-refs.sh`, `specboot.sh`, `validate-specboot.sh`), `templates/ci/`, the 5 intocable docs (`base-standards`, `framework-contract`, `docs-standard`, `specboot-json-standard`, `versioning-standard`), `opencode.json`, `AGENTS.md`, `Makefile`, `.github/workflows/`, `LICENSE`, `README.md` (REQ-1) -> Scenario 1

2. `README.md` MUST contain a "Qué es del proyecto" section listing the assets that are NOT shipped: application code (`backend/`, `frontend/`, …), project `docs/` except the 5 standards, `.specboot.json`, project MCP servers, and project env/GitHub vars (REQ-2) -> Scenario 1

3. `docs/framework-contract.md` MUST contain a "Distribución vía npm" subsection reaffirming that `files` is the source of truth, that only intocable framework assets are published, and that the project `docs/` tree is filtered out by the allowlist (REQ-3) -> Scenario 2

4. Both `README.md` and `docs/framework-contract.md` MUST note that the Specboot development repository's own `docs/` are NOT published (filtered by `files`), to avoid dogfooding confusion (REQ-4) -> Scenario 3

5. After the edits, `bash check-refs.sh` and `bash specboot.sh --ci` MUST both exit 0 (REQ-5) -> Scenario 4
