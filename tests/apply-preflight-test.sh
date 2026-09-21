#!/usr/bin/env bash
# TDD test for SPECBOOT-HARDEN-02 — resumable `/apply` pre-flight (REQ-004,
# SC-005/SC-006/SC-007). The pre-flight is agent-behavior prose in
# `.opencode/commands/apply.md`; this test locks the documented contract into a
# verifiable form so future regressions fail CI.
#
# Run: bash tests/apply-preflight-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APMD="$ROOT/.opencode/commands/apply.md"

PASS=0
FAIL=0
ok()  { echo "  ✓ $1"; PASS=$((PASS + 1)); }
bad() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }
has() { grep -q "$1" "$APMD"; }

echo "🔍 /apply pre-flight contract (SPECBOOT-HARDEN-02, REQ-004)..."

# SC-005: once per change; first-run allows plan artifacts without manual commit.
if has "once per change"; then
  ok  "[SC-005] pre-flight runs once per change (not per task)"
else
  bad "[SC-005] apply.md does NOT state run-once-per-change"
fi
if has "openspec/changes/{active-change}/\*\*" && has "no commit or stash"; then
  ok  "[SC-005] first-run dirt limited to plan artifacts requires no commit/stash"
else
  bad "[SC-005] apply.md not allowing plan-artifact dirt on first run"
fi

# SC-007: foreign changes still block.
if has "Any change outside" && has "block"; then
  ok  "[SC-007] foreign pre-existing changes still block /apply"
else
  bad "[SC-007] apply.md not blocking foreign changes"
fi

# SC-006: resumed /apply accepts prior-task changes, no intermediate commits,
# resumes from first pending task.
if has "MUST NOT require intermediate commits" && has "first pending task"; then
  ok  "[SC-006] resumed /apply accepts prior-task changes without commits, resumes from pending"
else
  bad "[SC-006] apply.md not covering resumed dirty-tree acceptance / resume"
fi

# /commit keeps exclusive git ownership.
if has "exclusive ownership" && has "git add" && has "git commit" && has "git push"; then
  ok  "[REQ-004] /commit keeps exclusive ownership of git add/commit/push"
else
  bad "[REQ-004] apply.md not stating /commit git ownership"
fi

# Per-change marker; never touches verify/adversarial evidence (fail-closed).
if has "apply-preflight" && has "fail-closed"; then
  ok  "[REQ-004] per-change marker without touching verify/adversarial evidence"
else
  bad "[REQ-004] apply.md missing per-change marker / evidence fail-closed note"
fi

# Interplay with Mandatory Steps checklist.
if has "Mandatory Steps" && has "Estado git limpio"; then
  ok  "[REQ-004] explicit interplay with the Mandatory Steps checklist"
else
  bad "[REQ-004] apply.md missing Mandatory Steps interplay"
fi

echo ""
echo "apply-preflight: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]