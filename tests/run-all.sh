#!/usr/bin/env bash
# Canonical runner for all framework self-tests (M-911).
#
# Runs every tests/*-test.sh and reports a summary. Exits non-zero if any test
# fails. This is the canonical way to run the full suite for agents: the
# invocation `bash tests/run-all.sh` is covered by the primary allowlist entry
# `"bash tests/*": allow`, so no confirmation prompt is ever needed (the
# equivalent `for t in tests/*-test.sh; do bash "$t"; done` starts with `for`
# and requires explicit confirmation).
#
# Usage: bash tests/run-all.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PASS=0
FAIL=0
FAILED_TESTS=()

for t in tests/*-test.sh; do
  [ -f "$t" ] || continue
  if bash "$t" >/dev/null 2>&1; then
    echo "  ✓ $t"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $t"
    FAIL=$((FAIL + 1))
    FAILED_TESTS+=("$t")
  fi
done

echo ""
if [ "$FAIL" -gt 0 ]; then
  echo "run-all: $PASS passed, $FAIL failed"
  for t in "${FAILED_TESTS[@]}"; do
    echo "  failing: $t"
  done
  exit 1
fi

echo "run-all: $PASS passed, 0 failed"
exit 0
