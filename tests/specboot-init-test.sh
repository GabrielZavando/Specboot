#!/usr/bin/env bash
# TDD test for TICKET-3.1 — `specboot init` bootstraps a new project.
#
# Run: bash tests/specboot-init-test.sh
#
# Covers (RED first, then GREEN):
#   1. init in empty dir -> .specboot.json + framework files + docs skeleton
#   2. guard: existing .specboot.json -> warn + exit 0, no overwrite
#   3. no-overwrite of existing project files (e.g. custom AGENTS.md)
#   4. --template <dir> override for the framework source
#   5. docs skeleton only created when docs/ is missing
#   6. --interactive captures user-supplied values

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/specboot.sh"

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
assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "  ✓ $desc"; PASS=$((PASS + 1))
  else
    echo "  ✗ $desc (expected '$expected', got '$actual')"; FAIL=$((FAIL + 1))
  fi
}
assert_exists() {
  local desc="$1" path="$2"
  if [ -e "$path" ]; then
    echo "  ✓ $desc"; PASS=$((PASS + 1))
  else
    echo "  ✗ $desc (missing: $path)"; FAIL=$((FAIL + 1))
  fi
}

# ---------- Test 1: init in empty directory (Happy Path) ----------
EMPTY="$(mktemp -d)"
( cd "$EMPTY" && bash "$SCRIPT" init ) >/tmp/init-empty.out 2>&1
assert_exit "init in empty dir exits 0" 0 $?
assert_exists ".specboot.json created"            "$EMPTY/.specboot.json"
assert_exists "AGENTS.md copied"                  "$EMPTY/AGENTS.md"
assert_exists "specboot.sh copied"                "$EMPTY/specboot.sh"
assert_exists "validate-specboot.sh copied"       "$EMPTY/validate-specboot.sh"
assert_exists "check-refs.sh copied"              "$EMPTY/check-refs.sh"
assert_exists ".opencode/agents copied"           "$EMPTY/.opencode/agents"
assert_exists "ai-specs copied"                   "$EMPTY/ai-specs"
assert_exists "docs skeleton backend-standards"   "$EMPTY/docs/backend-standards.md"
assert_exists "docs skeleton project/domain"      "$EMPTY/docs/project/domain.md"
assert_exists "docs skeleton api/api-spec.yml"    "$EMPTY/docs/api/api-spec.yml"
assert_exists "docs skeleton data-model"           "$EMPTY/docs/data-model/data-model.md"
assert_exists ".github copied"                     "$EMPTY/.github"

# ---------- Test 2: guard — .specboot.json already exists ----------
EXISTING="$(mktemp -d)"
echo '{"frameworkVersion":"0.1.1","name":"x"}' > "$EXISTING/.specboot.json"
echo "custom-agents" > "$EXISTING/AGENTS.md"
( cd "$EXISTING" && bash "$SCRIPT" init ) >/tmp/init-existing.out 2>&1
assert_exit "init with existing config exits 0" 0 $?
assert_eq "AGENTS.md not overwritten by guard" "custom-agents" "$(cat "$EXISTING/AGENTS.md")"
if grep -q "specboot update" /tmp/init-existing.out; then
  echo "  ✓ guard advises 'specboot update'"; PASS=$((PASS + 1))
else
  echo "  ✗ guard advises 'specboot update'"; FAIL=$((FAIL + 1))
fi

# ---------- Test 3: no-overwrite of existing project files ----------
OVER="$(mktemp -d)"
echo "my custom AGENTS" > "$OVER/AGENTS.md"
( cd "$OVER" && bash "$SCRIPT" init ) >/tmp/init-over.out 2>&1
assert_exit "init preserves existing AGENTS.md (exit 0)" 0 $?
assert_eq "AGENTS.md preserved" "my custom AGENTS" "$(cat "$OVER/AGENTS.md")"
assert_exists "other framework files still copied" "$OVER/specboot.sh"

# ---------- Test 4: --template override ----------
TPL="$(mktemp -d)"
mkdir -p "$TPL/ai-specs"
echo "tpl-marker" > "$TPL/ai-specs/tpl-marker.txt"
TGT="$(mktemp -d)"
( cd "$TGT" && bash "$SCRIPT" init --template "$TPL" ) >/tmp/init-tpl.out 2>&1
assert_exit "init --template exits 0" 0 $?
assert_exists "template ai-specs copied" "$TGT/ai-specs/tpl-marker.txt"

# ---------- Test 5: docs skeleton only when missing ----------
NODOCS="$(mktemp -d)"
mkdir -p "$NODOCS/docs"
echo "existing-backend" > "$NODOCS/docs/backend-standards.md"
( cd "$NODOCS" && bash "$SCRIPT" init ) >/tmp/init-nodocs.out 2>&1
assert_exit "init with existing docs/ exits 0" 0 $?
assert_eq "existing docs not overwritten" "existing-backend" "$(cat "$NODOCS/docs/backend-standards.md")"

# ---------- Test 6: --interactive captures values ----------
INT="$(mktemp -d)"
printf 'MyProject\nnode\n.\n' | ( cd "$INT" && bash "$SCRIPT" init --interactive ) >/tmp/init-int.out 2>&1
assert_exit "init --interactive exits 0" 0 $?
assert_exists ".specboot.json created (interactive)" "$INT/.specboot.json"
if grep -q '"name": "MyProject"' "$INT/.specboot.json"; then
  echo "  ✓ interactive name captured"; PASS=$((PASS + 1))
else
  echo "  ✗ interactive name captured"; FAIL=$((FAIL + 1))
fi
if grep -q '"stack": "node"' "$INT/.specboot.json"; then
  echo "  ✓ interactive stack captured"; PASS=$((PASS + 1))
else
  echo "  ✗ interactive stack captured"; FAIL=$((FAIL + 1))
fi

rm -rf "$EMPTY" "$EXISTING" "$OVER" "$TPL" "$TGT" "$NODOCS" "$INT"

echo ""
echo "TDD tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
