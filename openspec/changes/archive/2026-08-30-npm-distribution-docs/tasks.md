# Tasks: Document npm distribution boundary

## Phase 1: README boundary sections
- [x] Add `## Qué incluye el paquete` section after the "Instalación como paquete NPM" block, listing each `files` allowlist asset in a table (High | Docs | 0.5h)
    - Suggested Path: `README.md`
    - Test Path: `bash check-refs.sh`, `bash specboot.sh --ci`
- [x] Add `## Qué es del proyecto (NO se publica)` section listing app code, project `docs/` (minus 5 standards), `.specboot.json`, project MCP, env/GitHub vars; include the dogfooding callout that the dev repo's `docs/` are NOT published (High | Docs | 0.5h)
    - Suggested Path: `README.md`

## Phase 2: framework-contract subsection
- [x] Add `### Distribución vía npm` subsection under "Arquitectura de distribución" in `docs/framework-contract.md`, reaffirming intocable-only publishing and `docs/` filtering by `files` (High | Docs | 0.25h)
    - Suggested Path: `docs/framework-contract.md`

## Phase 3: Verification
- [x] `bash check-refs.sh` exits 0 (High | Docs | 0.25h)
- [x] `bash specboot.sh --ci` exits 0 (High | Docs | 0.25h)
- [x] `openspec validate npm-distribution-docs` passes (High | Docs | 0.25h)
