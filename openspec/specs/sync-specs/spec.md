# sync-specs Specification

## Purpose
TBD - created by archiving change sync-specs. Update Purpose after archive.
## Requirements
### Requirement: Sync applies deltas without archiving

The `/sync-specs` command SHALL apply the active change's spec deltas (`## ADDED` / `## MODIFIED` / `## REMOVED` / `## RENAMED`) from `openspec/changes/<change>/specs/` into `openspec/specs/` WITHOUT archiving the change and WITHOUT touching `openspec/state/manifest.json`. The environment premise is a single active change: the command SHALL NOT implement multi-change selection nor a TICKET-ID argument. A `## MODIFIED` delta targeting a spec absent from `openspec/specs/` SHALL be treated as `## ADDED`. Malformed deltas (unrecognized headers) SHALL abort the sync with an explicit report; partially-applied or corrupted specs are forbidden.

#### Scenario: Sync applies deltas of the active change without archiving
- **GIVEN** an active change in `openspec/changes/<change>/` with deltas in `specs/` and existing specs in `openspec/specs/`
- **WHEN** the user runs `/sync-specs`
- **THEN** the deltas (Added/Modified/Removed/Renamed) are applied to `openspec/specs/` and the change remains active (not archived, `openspec/state/manifest.json` untouched)

#### Scenario: MODIFIED delta on missing spec is treated as ADDED
- **GIVEN** an active change whose delta declares `## MODIFIED` for a spec that does not exist in `openspec/specs/`
- **WHEN** the user runs `/sync-specs`
- **THEN** the delta content is added to `openspec/specs/` as if it were `## ADDED`

#### Scenario: Malformed delta aborts without partial application
- **GIVEN** an active change whose deltas contain unrecognized section headers
- **WHEN** the user runs `/sync-specs`
- **THEN** the sync aborts with an explicit report and no spec file is partially modified

### Requirement: Token-light operation and idempotency

The sync SHALL be token-light: deltas are applied via deterministic file operations, never by reading full specs into the LLM context, and the final report SHALL be a quantitative summary only (counts of added/modified/removed/renamed requirements), never the full spec content. The operation SHALL be idempotent: re-running after a successful sync SHALL report "sin diferencias" and modify nothing.

#### Scenario: Quantitative report only
- **GIVEN** an active change with deltas across several specs
- **WHEN** `/sync-specs` completes the synchronization
- **THEN** the report shows a quantitative summary (N added, M modified, ...) without dumping full spec content into the context

#### Scenario: Idempotent re-run reports no differences
- **GIVEN** an active change whose deltas are already applied in `openspec/specs/`
- **WHEN** the user runs `/sync-specs`
- **THEN** the command reports "sin diferencias" and modifies no files

### Requirement: No active change is a clean no-op

When no active change exists in `openspec/changes/`, the command SHALL report "no hay change activo" and exit without modifying any file.

#### Scenario: No active change
- **GIVEN** `openspec/changes/` does not exist or contains no active change
- **WHEN** the user runs `/sync-specs`
- **THEN** the command reports "no hay change activo" and exits without modifying any file

### Requirement: Registration and integrity checks

The command SHALL exist as `.opencode/commands/sync-specs.md` (auto-discovered), SHALL be documented in the `AGENTS.md` §5.3 optional-tools table, and `bash check-refs.sh` SHALL pass with 0 errors after the registration.

#### Scenario: Command registered and invocable
- **GIVEN** the installed framework
- **WHEN** listing `.opencode/commands/` and `AGENTS.md` and running `bash check-refs.sh`
- **THEN** `.opencode/commands/sync-specs.md` exists, the `sync-specs` skill appears in the AGENTS.md skills table, and `check-refs.sh` exits with 0 errors

