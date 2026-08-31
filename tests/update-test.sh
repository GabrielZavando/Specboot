#!/usr/bin/env bash
# TDD test for update.sh — version bump tooling (maintainer-only mode).
#
# The sync mode of update.sh is DEPRECATED: the canonical update path for
# consumer projects is `specboot update` (see specboot.sh). Per
# cleanup-publish-and-junk (TICKET-CLEANUP, Fase G) this test therefore:
#   1. Tests the current `--bump` mode as the primary behavior
#      (maintainer release flow: tag + CHANGELOG entry).
#   2. Keeps a light assertion that the deprecated sync mode prints its
#      deprecation warning (no full sync behavior assertions — deprecated).
#
# Run: bash tests/update-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/update.sh"

PASS=0
FAIL=0

assert_exit() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" -eq 0 ] && [ "$actual" -eq 0 ]; then
    echo "  ✓ $desc"; PASS=$((PASS + 1))
  elif [ "$expected" -ne 0 ] && [ "$actual" -ne 0 ]; then
    echo "  ✓ $desc"; PASS=$((PASS + 1))
  else
    echo "  ✗ $desc (expected exit $expected, got $actual)"; FAIL=$((FAIL + 1))
  fi
}

assert_contains() {
  local desc="$1" file="$2" needle="$3"
  if grep -q "$needle" "$file" 2>/dev/null; then
    echo "  ✓ $desc"; PASS=$((PASS + 1))
  else
    echo "  ✗ $desc (missing '$needle' in $file)"; FAIL=$((FAIL + 1))
  fi
}

if [ ! -f "$SCRIPT" ]; then
  echo "  ✗ update.sh does not exist yet (RED)"; exit 1
fi

# ---------- Bump test (modo vigente) ----------
REPO="$(mktemp -d)"
( cd "$REPO" && git init -q && git config user.email t@t.t && git config user.name t \
  && printf '# Changelog\n' > CHANGELOG.md \
  && printf '## [Unreleased]\n\n## [0.0.0] - 2000-01-01\n' >> CHANGELOG.md \
  && git add -A && git commit -qm init ) >/dev/null 2>&1

# --template "$REPO" keeps the trailing sync a no-op (target == template),
# so the bump behavior is tested hermetically.
( cd "$REPO" && bash "$SCRIPT" --template "$REPO" --bump minor ) >/tmp/up-bump.out 2>&1
assert_exit "bump exits 0" 0 $?
if git -C "$REPO" tag | grep -q "v0.1.0"; then
  echo "  ✓ tag v0.1.0 created"; PASS=$((PASS + 1))
else
  echo "  ✗ tag v0.1.0 created"; FAIL=$((FAIL + 1))
fi
if grep -q "## \[0.1.0\]" "$REPO/CHANGELOG.md"; then
  echo "  ✓ CHANGELOG has 0.1.0"; PASS=$((PASS + 1))
else
  echo "  ✗ CHANGELOG has 0.1.0"; FAIL=$((FAIL + 1))
fi

# ---------- Deprecated sync mode: deprecation warning assertion ----------
# Sync mode must announce it is deprecated (canonical path is `specboot update`).
# --dry-run keeps the check read-only; empty temp target is enough because
# sync_item under --dry-run only prints "would sync".
PROJECT="$(mktemp -d)"
( cd "$PROJECT" && bash "$SCRIPT" --template "$ROOT" --dry-run ) >/tmp/up-sync-deprecated.out 2>&1
assert_exit "deprecated sync mode exits 0" 0 $?
assert_contains "deprecated sync mode prints deprecation warning" \
  /tmp/up-sync-deprecated.out "deprecado"

rm -rf "$REPO" "$PROJECT"

echo ""
echo "TDD tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
