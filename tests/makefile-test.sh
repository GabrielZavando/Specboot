#!/usr/bin/env bash
# TDD test for the parametrized framework Makefile (TICKET-4.1).
# Verifies per-service iteration (lint/test), default services, and graceful skip.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MK="$ROOT/Makefile"
PASS=0; FAIL=0
ok()  { echo "  ✅ $1"; PASS=$((PASS+1)); }
bad() { echo "  ❌ $1"; FAIL=$((FAIL+1)); }

# ----- Test A: multi-service node, per-service lint + test -----
echo "→ Test A: multi-service node lint/test run per service"
TMP="$(mktemp -d)"
printf '{"services":["s1","s2"],"stack":["node"]}' > "$TMP/.specboot.json"
mkdir -p "$TMP/s1" "$TMP/s2"
echo '{"name":"s1","scripts":{"lint":"touch s1.linted","test":"touch s1.tested"}}' > "$TMP/s1/package.json"
echo '{"name":"s2","scripts":{"lint":"touch s2.linted","test":"touch s2.tested"}}' > "$TMP/s2/package.json"
( cd "$TMP" && make -s -f "$MK" lint >/dev/null 2>&1 )
if [ -f "$TMP/s1/s1.linted" ] && [ -f "$TMP/s2/s2.linted" ]; then ok "lint ran for both s1 and s2"; else bad "lint did not run per-service"; fi
( cd "$TMP" && make -s -f "$MK" test >/dev/null 2>&1 )
if [ -f "$TMP/s1/s1.tested" ] && [ -f "$TMP/s2/s2.tested" ]; then ok "test ran for both s1 and s2"; else bad "test did not run per-service"; fi
rm -rf "$TMP"

# ----- Test B: missing service dir -> skip, exit 0 -----
echo "→ Test B: missing service dir skips with exit 0"
TMP="$(mktemp -d)"
printf '{"services":["ghost"],"stack":["node"]}' > "$TMP/.specboot.json"
( cd "$TMP" && make -s -f "$MK" lint > "$TMP/out.log" 2>&1 ); RC=$?
if [ "$RC" -eq 0 ]; then ok "make lint exited 0 for missing service"; else bad "make lint exited $RC (expected 0)"; fi
if grep -q "saltando" "$TMP/out.log"; then ok "warned about missing service"; else bad "no skip warning for missing service"; fi
rm -rf "$TMP"

# ----- Test C: stack framework -> app targets skip, exit 0 -----
echo "→ Test C: stack framework skips app lint, exit 0"
TMP="$(mktemp -d)"
printf '{"services":["."],"stack":"framework"}' > "$TMP/.specboot.json"
( cd "$TMP" && make -s -f "$MK" lint >/dev/null 2>&1 ); RC=$?
if [ "$RC" -eq 0 ]; then ok "make lint exited 0 for framework stack"; else bad "make lint exited $RC (expected 0)"; fi
rm -rf "$TMP"

echo ""
echo "RESULT: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
