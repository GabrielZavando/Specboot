#!/usr/bin/env bash
# TDD test for SPECBOOT-HARDEN-02 — command contracts (REQ-007, SC-015).
# Validates .opencode/commands/*.md from the front matter: every command declares
# `agent` with the contracted mappings and `subtask: true` for adversarial-review.
#
# Run: bash tests/command-contracts-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VAL="$ROOT/scripts/validate-command-contracts.mjs"

PASS=0
FAIL=0
ok()  { echo "  ✓ $1"; PASS=$((PASS + 1)); }
bad() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

# SC-015 valid: the real repo commands satisfy the contract.
if node "$VAL" --root "$ROOT" >/dev/null 2>&1; then
  ok  "[SC-015] all real commands declare the contracted agent (front matter)"
else
  bad "[SC-015] real commands do NOT satisfy the contract"
fi

# Corrupted fixtures must each fail.
make_bad_project() {
  local dir="$1" file="$2" body="$3"
  mkdir -p "$dir/.opencode/commands"
  printf -- '---\n%s\n---\n' "$body" > "$dir/.opencode/commands/$file"
}

# no agent
D1="$(mktemp -d)"; trap 'rm -rf "$D1" "$D2" "$D3"' EXIT
make_bad_project "$D1" "noagent.md" 'description: no agent'
if node "$VAL" --root "$D1" >/dev/null 2>&1; then
  bad "[SC-015] command without 'agent' must fail"
else
  ok  "[SC-015] command without 'agent' fails"
fi

# wrong agent (plan-change must be sdd-plan)
D2="$(mktemp -d)"
make_bad_project "$D2" "plan-change.md" 'description: wrong
agent: build'
if node "$VAL" --root "$D2" >/dev/null 2>&1; then
  bad "[SC-015] plan-change with agent=build must fail (expected sdd-plan)"
else
  ok  "[SC-015] mismatched agent fails (plan-change -> sdd-plan)"
fi

# adversarial-review missing subtask: true
D3="$(mktemp -d)"
make_bad_project "$D3" "adversarial-review.md" 'description: ar
agent: reviewer'
if node "$VAL" --root "$D3" >/dev/null 2>&1; then
  bad "[SC-015] adversarial-review without subtask: true must fail"
else
  ok  "[SC-015] adversarial-review without subtask: true fails"
fi

echo ""
echo "command-contracts: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]