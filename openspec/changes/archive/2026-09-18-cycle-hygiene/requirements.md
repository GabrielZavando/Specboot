# Requirements: cycle-hygiene

1. **REQ-001**: The build agent (`ai-specs/agents/build-agent.md`) SHALL tick each
   Mandatory Steps checkbox in `tasks.md` via the edit tool at the moment the
   step is satisfied, so `/apply` finishes with zero open Mandatory Steps
   checkboxes.
   (traces: SC-001)

2. **REQ-002**: The `archive` skill SHALL treat `/apply` as the canonical owner
   of the Mandatory Steps tick; archive only defensively ticks satisfied
   leftovers via the edit tool (never `sed -i`) and aborts on genuinely pending
   implementation tasks. The `--yes` flag SHALL no longer be required for
   Mandatory Steps checkboxes in the standard cycle.
   (traces: SC-002)

3. **REQ-003**: `PLAN_MEJORAS_SPECBOOT.md` SHALL mark M-701 as `## [x]`,
   register M-908 as a completed ticket (`## [x] M-908`, M-403 pattern with
   SemVer/dependencies declared), and add a history row covering the
   M-701 + M-908 + M-909 cycle.
   (traces: SC-003)

4. **REQ-004**: The `plan-change` skill proposal template SHALL include
   `## Why` and `## What Changes` sections, and its Step 6 checklist SHALL
   validate their presence, eliminating the `openspec archive` proposal warning
   for future changes.
   (traces: SC-004)

5. **REQ-005**: `tests/mandatory-steps-test.sh` SHALL be extended with asserts
   for REQ-001/REQ-002/REQ-003, and a new guard `tests/plan-proposal-test.sh`
   SHALL validate the proposal template contract (REQ-004).
   (traces: SC-005)

6. **REQ-006**: No regression — `bash check-refs.sh`, `bash specboot.sh --ci`,
   `bash validate-specboot.sh` and all `tests/*-test.sh` SHALL pass after the
   change.
   (traces: SC-006)
