# Requirements: fix-agent-permissions

1. **REQ-001**: The primary agent bash allowlist in `opencode.json` SHALL include
   the framework's routine SDD-cycle commands: `bash tests/*`, `bash scripts/*`,
   `bash check-refs.sh`, `bash specboot.sh *`, `bash validate-specboot.sh`,
   `node *`, `mkdir *`, `date *`, `python3 *`. `gh *` SHALL NOT be in the
   primary allowlist (the maintainer flow does not use gh; PR creation lives in
   the commit agent, which keeps its own `gh *` allow).
   (traces: SC-001)

2. **REQ-002**: The primary agent bash allowlist SHALL keep destructive or
   edit-bypassing commands gated as `ask`: `rm -rf *`, `find *`, `sed -i *`, and
   every unlisted command via the `"*": "ask"` fallback. File edits go through
   the edit tool, which remains allowed.
   (traces: SC-002)

3. **REQ-003**: `.opencode/commands/sync-specs.md` SHALL declare `agent:
   sync-specs` in its frontmatter, and `.opencode/agents/sync-specs.md` SHALL
   exist as a primary agent with scoped permissions: `edit` limited to
   `openspec/**`, bash limited to `openspec *`, `git status`/`git diff` (and
   variants), `ls *`, `cat *`, with `"*": deny` fallback.
   (traces: SC-003)

4. **REQ-004**: The `verify` agent SHALL allow `bash tests/*`, `bash scripts/*`,
   `node -e *`, and `date *`, and `ai-specs/agents/verify-agent.md` SHALL
   document these capabilities in its "Bash permitido" section (role↔permission
   sync, M-403 pattern), covering the framework's own bash guards (dogfooding).
   (traces: SC-004)

5. **REQ-005**: The `archive` agent SHALL allow `rm -f openspec/tickets/*`
   (silent cleanup when the enriched ticket does not exist), and the `archive`
   skill SHALL instruct Mandatory Steps checkbox ticking via the edit tool
   (scoped to `openspec/**`) instead of `sed -i`, which remains gated.
   (traces: SC-005)

6. **REQ-006**: The guard `tests/agent-permissions-test.sh` SHALL be extended
   with asserts for the new requirements, and `bash check-refs.sh`,
   `bash specboot.sh --ci`, `bash validate-specboot.sh` and all
   `tests/*-test.sh` SHALL pass after the change (no regression).
   (traces: SC-006)
