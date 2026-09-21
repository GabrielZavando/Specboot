#!/usr/bin/env bash
# TDD test for SPECBOOT-HARDEN-02 — target project resolution (REQ-008, SC-012).
#
# `specboot.sh --ci`/`--init` MUST validate the directory from which the script
# was invoked (the framework repo in dogfooding; the consumer project when run
# from node_modules/@gabrielzavando/specboot), NEVER the package's own content.
#
# Run: bash tests/target-resolution-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/specboot.sh"

PASS=0
FAIL=0
ok()  { echo "  ✓ $1"; PASS=$((PASS + 1)); }
bad() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

PROJ="$(mktemp -d)"
trap 'rm -rf "$PROJ"' EXIT

# A bare project has no framework files: if --ci validated the invocation dir it
# reports missing structure -> non-zero. If it validated the package/repo (bug),
# it would pass.
( cd "$PROJ" && bash "$SCRIPT" --ci ) >/tmp/tr-ci.out 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
  ok  "[SC-012] --ci from a consumer dir validates THAT dir (non-zero on incomplete project)"
else
  bad "[SC-012] --ci validated the package instead of the invocation dir (should be non-zero)"
fi

( cd "$PROJ" && bash "$SCRIPT" --init ) >/tmp/tr-init.out 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
  ok  "[SC-012] --init from a consumer dir validates THAT dir (non-zero on incomplete project)"
else
  bad "[SC-012] --init validated the package instead of the invocation dir (should be non-zero)"
fi

# Direct invocation from the framework repo passes (validates the repo).
( cd "$ROOT" && bash specboot.sh --ci ) >/tmp/tr-root-ci.out 2>&1
rc=$?
if [ "$rc" -eq 0 ]; then
  ok  "[SC-012] --ci from the repo root validates it and passes"
else
  bad "[SC-012] --ci from the repo root failed (exit $rc)"
fi

# The --ci output must reference the PROJ dir (its missing file structure), not
# be silent about it — confirm it inspected the invocation directory.
if grep -qE "FALTA|specboot.sh|check-refs" /tmp/tr-ci.out; then
  ok  "[SC-012] --ci output reflects the consumer's (missing) structure"
else
  bad "[SC-012] --ci output did not reflect the consumer's structure"
fi

echo ""
echo "target-resolution: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]