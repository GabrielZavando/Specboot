#!/usr/bin/env bash
# TDD test for TICKET-AUDIT-3 — release-bump.sh: atomic version bump.
#
# Contract:
#   - SC-004: `bash release-bump.sh <semver>` updates package.json → version
#     and .specboot.json → frameworkVersion in ONE operation
#   - SC-005: aborts (exit != 0, no writes) on invalid semver or when the
#     CHANGELOG lacks the `## [X.Y.Z]` section
#   - No git tag/commit is created by the script (fixture dirs are NOT git
#     repos: if the script used git, the happy path would fail)
#
# The script lives at the repo root and acts on the CURRENT WORKING
# DIRECTORY, so tests run it inside temp fixtures with the three files
# pre-populated.
#
# Run: bash tests/release-bump-test.sh (RED until Task 4 lands)

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/release-bump.sh"

PASS=0
FAIL=0

ok()  { echo "  ✓ $1"; PASS=$((PASS + 1)); }
bad() { echo "  ✗ $1: $2"; FAIL=$((FAIL + 1)); }

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then ok "$desc"; else bad "$desc" "expected '$expected', got '$actual'"; fi
}

make_fixture() {
  local dir="$1" ver="$2" changelog="$3"
  mkdir -p "$dir"
  printf '{\n  "name": "fw",\n  "version": "%s"\n}\n' "$ver" > "$dir/package.json"
  printf '{\n  "frameworkVersion": "%s",\n  "name": "proj"\n}\n' "$ver" > "$dir/.specboot.json"
  printf '%s\n' "$changelog" > "$dir/CHANGELOG.md"
}

# --- Precondition: script exists (RED until Task 4) ---
if [ ! -f "$SCRIPT" ]; then
  echo "  ✗ [SC-004] release-bump.sh does not exist at repo root (RED)"
  echo ""
  echo "TDD tests: 0 passed, 1 failed"
  exit 1
fi

# --- SC-004: happy path syncs both files atomically ---
F1="$(mktemp -d)"
make_fixture "$F1" "0.8.1" '# Changelog

## [0.9.0] - 2026-09-16

- stuff'
( cd "$F1" && bash "$SCRIPT" 0.9.0 ) >/tmp/rb-happy.out 2>&1
rc=$?
assert_eq "[SC-004] happy path exits 0" "0" "$rc"
assert_eq "[SC-004] package.json bumped" "0.9.0" "$(node -e "console.log(require('$F1/package.json').version)")"
assert_eq "[SC-004] .specboot.json bumped" "0.9.0" "$(node -e "console.log(require('$F1/.specboot.json').frameworkVersion)")"
# No git repo here: success itself proves the script never touches git.
if grep -qi "git tag" /tmp/rb-happy.out; then
  bad "[SC-004] script output mentions git tag" "output mentions git tag"
else
  ok "[SC-004] no git tag mentioned"
fi

# --- SC-005: invalid semver aborts without writes ---
F2="$(mktemp -d)"
make_fixture "$F2" "0.8.1" '## [0.9.0]'
( cd "$F2" && bash "$SCRIPT" notsemver ) >/tmp/rb-badver.out 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then ok "[SC-005] invalid semver exits non-zero"; else bad "[SC-005] invalid semver exits non-zero" "exit was 0"; fi
assert_eq "[SC-005] package.json untouched on invalid semver" "0.8.1" "$(node -e "console.log(require('$F2/package.json').version)")"
assert_eq "[SC-005] .specboot.json untouched on invalid semver" "0.8.1" "$(node -e "console.log(require('$F2/.specboot.json').frameworkVersion)")"

# --- SC-005: missing CHANGELOG section aborts without writes ---
F3="$(mktemp -d)"
make_fixture "$F3" "0.8.1" '# Changelog

## [0.8.0] - 2026-09-01'
( cd "$F3" && bash "$SCRIPT" 0.9.0 ) >/tmp/rb-nochangelog.out 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then ok "[SC-005] missing CHANGELOG section exits non-zero"; else bad "[SC-005] missing CHANGELOG section exits non-zero" "exit was 0"; fi
assert_eq "[SC-005] package.json untouched without CHANGELOG section" "0.8.1" "$(node -e "console.log(require('$F3/package.json').version)")"
assert_eq "[SC-005] .specboot.json untouched without CHANGELOG section" "0.8.1" "$(node -e "console.log(require('$F3/.specboot.json').frameworkVersion)")"

# --- SC-009: atomic — corrupt .specboot.json aborts BEFORE touching package.json ---
F4="$(mktemp -d)"
make_fixture "$F4" "0.8.1" '## [0.9.0]'
echo "{ not-json" > "$F4/.specboot.json"
( cd "$F4" && bash "$SCRIPT" 0.9.0 ) >/tmp/rb-corrupt.out 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then ok "[SC-009] corrupt .specboot.json aborts"; else bad "[SC-009] corrupt .specboot.json aborts" "exit was 0"; fi
assert_eq "[SC-009] package.json NOT modified on corrupt peer" "0.8.1" "$(node -e "console.log(require('$F4/package.json').version)")"

# --- SC-010: downgrade / equal version rejected without writes ---
F5="$(mktemp -d)"
make_fixture "$F5" "0.9.0" '## [0.8.0]

## [0.9.0]'
( cd "$F5" && bash "$SCRIPT" 0.8.0 ) >/tmp/rb-downgrade.out 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then ok "[SC-010] downgrade aborts"; else bad "[SC-010] downgrade aborts" "exit was 0"; fi
assert_eq "[SC-010] package.json untouched on downgrade" "0.9.0" "$(node -e "console.log(require('$F5/package.json').version)")"
assert_eq "[SC-010] .specboot.json untouched on downgrade" "0.9.0" "$(node -e "console.log(require('$F5/.specboot.json').frameworkVersion)")"

rm -rf "$F1" "$F2" "$F3" "$F4" "$F5"

echo ""
echo "TDD tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
