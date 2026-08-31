#!/usr/bin/env bash
# TDD test for scripts/dogfood-check.sh — framework dogfooding self-check.
#
# Verifies that scripts/dogfood-check.sh:
#   - exists and is executable
#   - runs check-refs.sh and specboot.sh --ci and exits 0 on a clean repo
#
# Run: bash tests/dogfood-check-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/scripts/dogfood-check.sh"

PASS=0
FAIL=0

# assert <description> <expected_exit> <actual_exit>
assert() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" -eq 0 ] && [ "$actual" -eq 0 ]; then
    echo "  ✓ $desc"
    PASS=$((PASS + 1))
  elif [ "$expected" -ne 0 ] && [ "$actual" -ne 0 ]; then
    echo "  ✓ $desc"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $desc (expected exit $expected, got $actual)"
    FAIL=$((FAIL + 1))
  fi
}

# --- Precondition (RED before implementation): script must exist ---
if [ ! -f "$SCRIPT" ]; then
  echo "  ✗ scripts/dogfood-check.sh does not exist yet (RED)"
  exit 1
fi

# --- Script must be executable ---
if [ ! -x "$SCRIPT" ]; then
  echo "  ✗ scripts/dogfood-check.sh is not executable (RED)"
  exit 1
fi
echo "  ✓ scripts/dogfood-check.sh exists and is executable"

# --- Running the dogfood check on the current repo must pass ---
bash "$SCRIPT" >/tmp/dogfood-check.out 2>&1
assert "dogfood-check passes on current repository" 0 $?

echo ""
echo "TDD tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
