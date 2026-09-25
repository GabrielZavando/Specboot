#!/usr/bin/env bash
# Transient [SC-004] scope verification for change fix-consumer-ci-yaml
# (SPECBOOT-HOTFIX-01, REQ-005) — the change's OWN executable evidence.
#
# Lives INSIDE the change folder (openspec/changes/fix-consumer-ci-yaml/),
# NOT in tests/ — so `tests/run-all.sh` (glob `tests/*-test.sh`) never runs it.
# The scope constraint stays TRANSIENT (archived together with the change)
# instead of becoming a permanent contract that would false-fail future
# changes touching files outside this hotfix's allowlist or the internal
# workflows against v0.11.0 (adversarial-review WARNING, 2026-09-24).
#
# Produces strong [SC-004] evidence:
#   1. Fail if the working tree (git status --porcelain: staged, unstaged and
#      untracked) contains modified or new files OUTSIDE the change's allowed
#      scope, listing every unexpected path.
#   2. Verify .github/workflows/ has no changes vs v0.11.0 — the committed
#      diff (v0.11.0 vs HEAD) PLUS staged/unstaged/untracked working-tree
#      changes in that path.
#   3. Exit 0 with explicit [SC-004] output when both checks pass.
#
# Run: bash openspec/changes/fix-consumer-ci-yaml/verification/sc-004-scope-test.sh
# Exits 0 when both checks pass, 1 otherwise.

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"
cd "$ROOT"

PASS=0
FAIL=0

pass() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

echo "🔍 [SC-004] scope verification (fix-consumer-ci-yaml / SPECBOOT-HOTFIX-01, REQ-005)..."

# --- 1. Working-tree scope: every path in git status --porcelain (staged,
#        unstaged and untracked) must be within the change's allowed scope.
#        Any other path is a scope violation of REQ-005. ---
SC4_OFFENDERS="$(
  git status --porcelain | while read -r status path; do
    [ -z "$path" ] && continue
    case "$path" in
      templates/github/workflows/consumer-ci.yml|tests/consumer-ci-yaml-test.sh|package.json|package-lock.json|.specboot.json|CHANGELOG.md|openspec/*) ;;
      *) printf '%s\n' "$path" ;;
    esac
  done
)"
if [ -z "$SC4_OFFENDERS" ]; then
  pass "[SC-004] working tree limited to the change's allowed scope (fix + test + version files + CHANGELOG + openspec); no unexpected paths"
else
  fail "[SC-004] scope violation — files outside the change's allowed scope are modified or new: $SC4_OFFENDERS"
fi

# --- 2. .github/workflows/ unchanged vs v0.11.0 — including staged and
#        unstaged (and untracked) working-tree changes in that path ---
if git diff --quiet v0.11.0 HEAD -- .github/workflows/ \
  && [ -z "$(git status --porcelain -- .github/workflows/)" ]; then
  pass "[SC-004] .github/workflows/ unchanged vs v0.11.0 (committed diff clean + no staged/unstaged/untracked changes)"
else
  fail "[SC-004] .github/workflows/ modified vs v0.11.0 (committed, staged, unstaged or untracked) — scope violation (REQ-005)"
fi

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "[SC-004] PASS: scope verification complete ($PASS assertions, 0 failed)"
  exit 0
fi
echo "[SC-004] FAIL: scope verification found $FAIL violation(s)"
exit 1
