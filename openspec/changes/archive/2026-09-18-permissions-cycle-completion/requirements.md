# Requirements: permissions-cycle-completion

1. **REQ-001**: The `archive` agent SHALL include `"mkdir -p openspec/*": allow`
   in its bash permission block, consistent with the `verify` and `commit`
   agents.
   (traces: SC-001)

2. **REQ-002**: A canonical runner script `tests/run-all.sh` SHALL exist that
   executes every `tests/*-test.sh`; agents SHALL invoke the full verification
   as `bash tests/run-all.sh` (covered by the `"bash tests/*"` allowlist entry),
   eliminating the `for`-loop pattern that requires user confirmation.
   (traces: SC-002)

3. **REQ-003 (W5)**: `.specboot.json` SHALL accept an optional
   `"stalenessPaths"` array of strings; `docs/specboot-json-standard.md` SHALL
   document it; `validate-specboot.sh` SHALL validate it (array of strings when
   present); the `commit` skill SHALL read it token-light via `node -e` with
   fallback to the default list (`src`, `app`, `tests`, `ai-specs`,
   `.opencode`).
   (traces: SC-003, SC-004)

4. **REQ-004**: The `commit` skill SHALL document the canonical git command for
   staleness computation (`git log --format="%H %ad" --date=iso -5 --
   <stalenessPaths>`), and the guard SHALL assert its presence.
   (traces: SC-005)

5. **REQ-005**: `docs/framework-contract.md` SHALL document the trust model:
   `node *`/`python3 *` in the primary allowlist execute arbitrary code and are
   consistent with the existing `npm *`/`npx *` trust (maintainer decision:
   accept and document).
   (traces: SC-006)

6. **REQ-006**: `opencode.json` SHALL include `"bash check-refs.sh *"` as an
   allowed variant (invocations with arguments do not prompt).
   (traces: SC-006)

7. **REQ-007**: Guards extended (`tests/agent-permissions-test.sh` for
   REQ-001/002/006; `tests/commit-gate-test.sh` for REQ-003/004 with fixture
   update), and `bash check-refs.sh`, `bash specboot.sh --ci`,
   `bash validate-specboot.sh`, `bash tests/run-all.sh` and all
   `tests/*-test.sh` SHALL pass after the change (no regression).
   (traces: SC-007)
