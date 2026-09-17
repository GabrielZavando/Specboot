# Requirements: sync-specs

1. **REQ-001**: `/sync-specs` SHALL apply the active change's spec deltas
   (`## ADDED` / `## MODIFIED` / `## REMOVED` / `## RENAMED`) from
   `openspec/changes/<change>/specs/` into `openspec/specs/` WITHOUT archiving
   the change and WITHOUT touching `openspec/state/manifest.json`.
   (traces: SC-001)

2. **REQ-002**: The sync SHALL be token-light: deltas are applied via
   deterministic file operations, never by reading full specs into the LLM
   context; the final report SHALL be a quantitative summary only.
   (traces: SC-002)

3. **REQ-003**: When no active change exists, the command SHALL report it and
   exit without modifying any file.
   (traces: SC-003)

4. **REQ-004**: The operation SHALL be idempotent: re-running after a
   successful sync SHALL report "sin diferencias" and modify nothing.
   (traces: SC-004)

5. **REQ-005**: A `## MODIFIED` delta targeting a spec absent from
   `openspec/specs/` SHALL be treated as `## ADDED` (maintainer decision).
   (traces: SC-001)

6. **REQ-006**: The environment premise SHALL be a single active change; the
   command SHALL NOT implement multi-change selection nor a TICKET-ID argument.
   (traces: SC-003)

7. **REQ-007**: Malformed deltas (unrecognized headers) SHALL abort the sync
   with an explicit report; partially-applied or corrupted specs are forbidden.
   (traces: SC-001)

8. **REQ-008**: The command SHALL be registered as
   `.opencode/commands/sync-specs.md` (auto-discovered), documented in
   `AGENTS.md` §5.3, and `bash check-refs.sh` SHALL pass with 0 errors.
   (traces: SC-005)
