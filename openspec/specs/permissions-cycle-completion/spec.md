# permissions-cycle-completion Specification

## Purpose
TBD - created by archiving change permissions-cycle-completion. Update Purpose after archive.
## Requirements
### Requirement: The archive agent covers directory creation

The `archive` agent SHALL include `"mkdir -p openspec/*": allow` in its bash permission block, consistent with the `verify` and `commit` agents, so the manifest directory creation (Step 5 of the archive skill) never falls into `deny` or requires delegation.

#### Scenario: archive creates the state directory without friction
- **GIVEN** the `archive` agent
- **WHEN** archive needs to create `openspec/state/` (manifest absent)
- **THEN** `mkdir -p openspec/*` runs without confirmation or delegation

### Requirement: A canonical runner covers the full verification without for-loops

The framework SHALL ship a canonical runner script `tests/run-all.sh` that executes every `tests/*-test.sh`. Agents SHALL invoke the full verification as `bash tests/run-all.sh`, which is covered by the `"bash tests/*"` allowlist entry, so the recurring `for t in tests/*-test.sh; do bash "$t"; done` pattern (which starts with `for` and falls into `ask`) is no longer needed.

#### Scenario: Full verification runs without prompts
- **GIVEN** the framework with `tests/run-all.sh`
- **WHEN** an agent runs `bash tests/run-all.sh`
- **THEN** every `tests/*-test.sh` executes and the command requires no user confirmation

### Requirement: The staleness code-path list is configurable

`.specboot.json` SHALL accept an optional `"stalenessPaths"` array of strings, documented in `docs/specboot-json-standard.md` and validated by `validate-specboot.sh` (array of strings when present). The `commit` skill SHALL read it token-light via `node -e` with fallback to the default list (`src`, `app`, `tests`, `ai-specs`, `.opencode`), and SHALL document the canonical git computation command (`git log --format="%H %ad" --date=iso -5 -- <stalenessPaths>`). Consumer projects with other code layouts (e.g. `lib/`, `server/`) therefore receive staleness detection.

#### Scenario: Configured staleness paths are honored
- **GIVEN** a consumer project with `"stalenessPaths": ["lib", "server"]` in `.specboot.json`
- **WHEN** `/commit` computes evidence staleness
- **THEN** the commit skill reads the configured paths token-light and a commit touching `lib/` or `server/` marks the evidence stale

#### Scenario: Absent field falls back to the default
- **GIVEN** a project without `stalenessPaths` in `.specboot.json`
- **WHEN** `/commit` computes evidence staleness
- **THEN** the default list (`src`, `app`, `tests`, `ai-specs`, `.opencode`) applies — behavior identical to the current one

#### Scenario: The canonical computation command is documented
- **GIVEN** the `commit` skill
- **WHEN** the guard inspects how staleness is computed
- **THEN** the canonical git command (`git log --format="%H %ad" --date=iso -5 -- <stalenessPaths>`) is documented and asserted by the guard

### Requirement: The bash trust model is documented

`docs/framework-contract.md` SHALL document the primary agent bash trust model: `node *` and `python3 *` allow arbitrary code execution and are consistent with the existing `npm *`/`npx *` trust (maintainer decision: accept and document). `opencode.json` SHALL include `"bash check-refs.sh *"` as an allowed variant.

#### Scenario: Trust model and check-refs variant documented
- **GIVEN** the framework contract
- **WHEN** the trust model of the primary bash allowlist is consulted
- **THEN** `framework-contract.md` documents the `node *`/`python3 *` decision and `opencode.json` includes `"bash check-refs.sh *"`

