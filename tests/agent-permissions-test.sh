#!/usr/bin/env bash
# TDD self-test for the agent permission sync contract (M-403 — change
# sync-agent-permissions).
#
# Validates (per openspec/changes/sync-agent-permissions/specs/agent-permissions/spec.md):
#   - .opencode/agents/verify.md allows pytest, as documented in the verify
#     agent role (SC-001), and its role documents npm run test (SC-002)
#   - .opencode/agents/archive.md allows every command its role and skill
#     document: git status *, git diff, git log, node -e (SC-003), with rm
#     scoped to the Step 7 tickets cleanup (SC-004) and no git commit promised
#     in the role (SC-005)
#   - reviewer and plan agents stay in bidirectional sync with their roles
#     (SC-006, SC-007)
#   - every restrictive block keeps the "*": deny fallback (SC-008)
#   - PLAN_MEJORAS_SPECBOOT.md marks M-403 [x] with history row v3.7 (SC-010)
#
# The script must FAIL (RED) until tasks 2.1, 2.2, 3.1, 3.2 and 5.2 land.
# SC-006/SC-007/SC-008 asserts are regression guards: they pass today and
# must keep passing.
#
# Run: bash tests/agent-permissions-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERIFY="$ROOT/.opencode/agents/verify.md"
VERIFY_ROLE="$ROOT/ai-specs/agents/verify-agent.md"
ARCHIVE="$ROOT/.opencode/agents/archive.md"
ARCHIVE_ROLE="$ROOT/ai-specs/agents/archive-agent.md"
REVIEWER="$ROOT/.opencode/agents/reviewer.md"
AUDIT_SKILL="$ROOT/ai-specs/skills/code-auditing/SKILL.md"
PLAN_AGENT="$ROOT/.opencode/agents/plan.md"
PLAN_ROLE="$ROOT/ai-specs/agents/plan-agent.md"
PLAN="$ROOT/PLAN_MEJORAS_SPECBOOT.md"

PASS=0
FAIL=0

ok() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
bad() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

# check <SC> <label> <command...> — runs the command; success counts as ok
check() {
  local sc="$1" label="$2"
  shift 2
  if "$@"; then
    ok "[$sc] $label"
  else
    bad "[$sc] $label"
  fi
}

# has_all <file> <token>... — every token must appear (fixed string)
has_all() {
  local file="$1"; shift
  local tok
  [ -f "$file" ] || return 1
  for tok in "$@"; do
    grep -qF -- "$tok" "$file" || return 1
  done
  return 0
}

# lacks_all <file> <token>... — none of the tokens may appear (fixed string)
lacks_all() {
  local file="$1"; shift
  local tok
  [ -f "$file" ] || return 0
  for tok in "$@"; do
    if grep -qF -- "$tok" "$file"; then
      return 1
    fi
  done
  return 0
}

# --- SC-001: verify agent can run pytest ---
echo "Verify agent permissions (SC-001):"

check SC-001 "verify block allows pytest (role documents it)" \
  has_all "$VERIFY" '"pytest *": allow'

# --- SC-002: verify role documents every allow pattern (vice-versa) ---
echo "Verify role documentation (SC-002):"

check SC-002 "verify role documents npm run test (block allows it)" \
  has_all "$VERIFY_ROLE" "npm run test"
check SC-002 "verify role still documents pytest" \
  has_all "$VERIFY_ROLE" "pytest"

# --- SC-003: archive block matches documented commands ---
echo "Archive agent permissions (SC-003):"

check SC-003 "archive block allows git status with args (Step 2 --porcelain)" \
  has_all "$ARCHIVE" '"git status *": allow'
check SC-003 "archive block allows git diff (Step 3 --stat)" \
  has_all "$ARCHIVE" '"git diff": allow' '"git diff *": allow'
check SC-003 "archive block allows git log (role documents it)" \
  has_all "$ARCHIVE" '"git log": allow' '"git log *": allow'
check SC-003 "archive block allows node -e (Step 5 token-light reads)" \
  has_all "$ARCHIVE" '"node -e *": allow'

# --- SC-004: archive rm scoped to the documented cleanup ---
echo "Archive rm scoping (SC-004):"

check SC-004 "archive block allows rm openspec/tickets/* (Step 7 cleanup)" \
  has_all "$ARCHIVE" '"rm openspec/tickets/*": allow'
check SC-004 "archive block has no rm -rf over openspec/changes" \
  lacks_all "$ARCHIVE" "rm -rf openspec/changes"
check SC-004 "archive block has no rm pattern over openspec/archive" \
  lacks_all "$ARCHIVE" "rm -rf openspec/archive"

# --- SC-005: archive role does not promise git commit ---
echo "Archive role documentation (SC-005):"

check SC-005 "archive role no longer lists git commit (ownership rule)" \
  lacks_all "$ARCHIVE_ROLE" "git commit"
check SC-005 "archive role documents node -e (Step 5 reads)" \
  has_all "$ARCHIVE_ROLE" "node -e"

# --- SC-006: reviewer stays in sync with code-auditing skill ---
echo "Reviewer agent sync (SC-006):"

check SC-006 "reviewer block allows the audited toolchain" \
  has_all "$REVIEWER" '"npm audit *": allow' '"npx eslint *": allow' \
          '"npx dependency-cruiser *": allow'
check SC-006 "reviewer block allows read-only git and file access" \
  has_all "$REVIEWER" '"git diff": allow' '"git diff *": allow' \
          '"git status": allow' '"ls *": allow' '"cat *": allow'
check SC-006 "reviewer block allows evidence directory creation" \
  has_all "$REVIEWER" '"mkdir -p openspec/*": allow'
check SC-006 "code-auditing skill documents the audited toolchain" \
  has_all "$AUDIT_SKILL" "npm audit" "npx eslint" "npx dependency-cruiser" \
          "git diff" "git status" "mkdir -p openspec"

# --- SC-007: plan agent stays in sync with its role ---
echo "Plan agent sync (SC-007):"

check SC-007 "plan block restricts bash to openspec" \
  has_all "$PLAN_AGENT" '"openspec *": allow' '"*": deny'
check SC-007 "plan block restricts edit to openspec artifacts" \
  has_all "$PLAN_AGENT" '"openspec/**": allow'
check SC-007 "plan role documents the openspec-only contract" \
  has_all "$PLAN_ROLE" "openspec *" "openspec/**"

# --- SC-008: deny fallback preserved in every restrictive block ---
echo "Deny fallbacks (SC-008):"

check SC-008 "verify block keeps wildcard deny" has_all "$VERIFY" '"*": deny'
check SC-008 "reviewer block keeps wildcard deny" has_all "$REVIEWER" '"*": deny'
check SC-008 "archive block keeps wildcard deny" has_all "$ARCHIVE" '"*": deny'
check SC-008 "plan block keeps wildcard deny" has_all "$PLAN_AGENT" '"*": deny'

# --- SC-010: improvement plan records the ticket completion ---
echo "Improvement plan record (SC-010):"

check SC-010 "M-403 marked completed" \
  grep -qF -- "## [x] M-403" "$PLAN"
check SC-010 "history row v3.7 present" \
  grep -qF -- "| v3.7 |" "$PLAN"

# --- Summary ---
echo ""
echo "Agent permissions sync contract: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
