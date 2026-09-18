#!/usr/bin/env bash
# TDD self-test for the plan-change proposal template contract (M-909 — change
# cycle-hygiene, REQ-004).
#
# Validates that the plan-change skill:
#   - includes "## Why" and "## What Changes" sections in its proposal.md
#     template (Step 5, artifact 1) — SC-004
#   - validates their presence in its Step 6 checklist — SC-004
#
# These sections are what `openspec archive` expects in proposal.md; without
# them every archive emits a non-blocking proposal warning (backlog Fase 11
# item 3).
#
# The script must FAIL (RED) until task 5 lands.
#
# Run: bash tests/plan-proposal-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT/ai-specs/skills/plan-change/SKILL.md"

PASS=0
FAIL=0

ok() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
bad() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

check() {
  local sc="$1" label="$2"
  shift 2
  if "$@"; then
    ok "[$sc] $label"
  else
    bad "[$sc] $label"
  fi
}

has_all() {
  local file="$1"; shift
  local tok
  [ -f "$file" ] || return 1
  for tok in "$@"; do
    grep -qF -- "$tok" "$file" || return 1
  done
  return 0
}

# --- SC-004: proposal template carries Why and What Changes ---
echo "Proposal template contract (SC-004, M-909):"

check SC-004 "template declares the ## Why section" \
  has_all "$SKILL" "## Why"
check SC-004 "template declares the ## What Changes section" \
  has_all "$SKILL" "## What Changes"
check SC-004 "template instruction ties sections to proposal.md" \
  has_all "$SKILL" "proposal.md" "## Why"
check SC-004 "Step 6 checklist validates both sections" \
  has_all "$SKILL" "includes \`## Why\` and \`## What Changes\`"

# --- Summary ---
echo ""
echo "plan proposal template contract: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
