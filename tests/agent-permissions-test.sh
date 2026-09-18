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
#     (SC-006, SC-007); plan allows branch-creating git (per
#     docs/git-workflow-standards.md) but never commit/push (SC-007)
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
COMMIT_AGENT="$ROOT/.opencode/agents/commit.md"
COMMIT_CMD="$ROOT/.opencode/commands/commit.md"
AUDIT_SKILL="$ROOT/ai-specs/skills/code-auditing/SKILL.md"
# TICKET-AUDIT-3 (SC-001/SC-002): agent renamed plan → sdd-plan because
# `plan` is a reserved OpenCode built-in name that forces read-only plan mode.
PLAN_AGENT="$ROOT/.opencode/agents/sdd-plan.md"
PLAN_ROLE="$ROOT/ai-specs/agents/plan-agent.md"
PLAN="$ROOT/PLAN_MEJORAS_SPECBOOT.md"
# M-908 (change fix-agent-permissions): primary allowlist + sync-specs agent
OCFG="$ROOT/opencode.json"
SYNC_AGENT="$ROOT/.opencode/agents/sync-specs.md"
SYNC_CMD="$ROOT/.opencode/commands/sync-specs.md"
SYNC_SKILL="$ROOT/ai-specs/skills/sync-specs/SKILL.md"
ARCHIVE_SKILL="$ROOT/ai-specs/skills/archive/SKILL.md"

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
check SC-007 "plan block allows branch-creating git for ticket branch" \
  has_all "$PLAN_AGENT" '"git checkout *": allow' '"git switch *": allow' \
          '"git branch *": allow' '"git status": allow'
check SC-007 "plan role documents the git-acotado contract" \
  has_all "$PLAN_ROLE" "git checkout" "git switch" "git branch" \
          "git commit" "git push"
check SC-007 "plan block does not allow git commit or push (ownership)" \
  lacks_all "$PLAN_AGENT" '"git commit": allow' '"git push": allow'

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

# --- sdd-cycle-hardening (TICKET-AUDIT-1) ---
# SC-005/SC-006: dedicated commit agent with minimal permissions
echo "Commit agent dedicated + minimal permissions (SC-005/SC-006):"

check SC-005 "commit agent file exists" test -f "$COMMIT_AGENT"
check SC-005 "commit agent is primary" has_all "$COMMIT_AGENT" "mode: primary"
check SC-005 "commit agent denies editing" has_all "$COMMIT_AGENT" "edit: deny"
check SC-005 "commit agent does not load build-agent role" \
  lacks_all "$COMMIT_AGENT" "build-agent.md"
check SC-005 "commit command runs under the commit agent" \
  has_all "$COMMIT_CMD" "agent: commit"
check SC-006 "commit block allows scoped git/gh chains" \
  has_all "$COMMIT_AGENT" '"git status' '"git diff' '"git log' \
        '"git add *": allow' '"git commit *": allow' '"git push *": allow' \
        '"git fetch' '"git merge-base' '"gh *": allow'
check SC-006 "commit block allows evidence/extraction helpers" \
  has_all "$COMMIT_AGENT" '"node -e *": allow' '"ls *": allow' \
        '"cat *": allow' '"mkdir -p openspec/*": allow'
check SC-006 "commit block denies force push" \
  has_all "$COMMIT_AGENT" '"git push --force*": deny'

# --- TICKET-AUDIT-2 (force-push-deny coverage, SC-005/SC-006) ---
echo "Commit force-push coverage (SC-005):"

check SC-005 "commit block denies mid-command force push" \
  has_all "$COMMIT_AGENT" '"git push *--force*": deny'
check SC-005 "commit block denies short-flag push" \
  has_all "$COMMIT_AGENT" '"git push -f*": deny'
check SC-005 "commit block denies trailing short-flag push" \
  has_all "$COMMIT_AGENT" '"git push * -f": deny'
check SC-006 "commit role documents the full deny set" \
  has_all "$COMMIT_AGENT" "git push *--force*" "git push -f*" "git push * -f"
check SC-006 "commit block keeps wildcard deny" \
  has_all "$COMMIT_AGENT" '"*": deny'

# SC-011: verify allows bare npm test
echo "Verify bare npm test (SC-011):"

check SC-011 "verify block allows npm test without args" \
  has_all "$VERIFY" '"npm test": allow'

# SC-008: archive has no orphaned CHANGELOG edit permission
echo "Archive CHANGELOG permission removal (SC-008):"

check SC-008 "archive block does not allow editing CHANGELOG.md" \
  lacks_all "$ARCHIVE" '"CHANGELOG.md": allow'

# --- TICKET-AUDIT-3: reserved-name collision resolved (SC-001/SC-002) ---
echo "Reserved plan name removed (SC-001):"

check SC-001 "no command declares agent: plan" \
  bash -c '! grep -lE "^agent: plan$" "$1"/.opencode/commands/*.md 2>/dev/null | grep -q .' _ "$ROOT"
check SC-001 "planning commands declare agent: sdd-plan" \
  bash -c 'cd "$1" && grep -qF "agent: sdd-plan" .opencode/commands/plan-change.md && grep -qF "agent: sdd-plan" .opencode/commands/enrich-us.md && grep -qF "agent: sdd-plan" .opencode/commands/explain.md' _ "$ROOT"
check SC-002 "sdd-plan keeps primary mode and openspec-only edit" \
  has_all "$PLAN_AGENT" "mode: primary" '"openspec/**": allow'
check SC-002 "sdd-plan keeps branch git and denies commit/push" \
  has_all "$PLAN_AGENT" '"git branch *": allow' '"git push": deny' '"git commit": deny'

# --- M-908 (fix-agent-permissions): primary allowlist covers routine tooling ---
echo "Primary allowlist routine tooling (SC-001, M-908):"

check SC-001 "opencode.json allows bash tests (framework guards)" \
  has_all "$OCFG" '"bash tests/*": "allow"'
check SC-001 "opencode.json allows bash scripts (dogfood-check)" \
  has_all "$OCFG" '"bash scripts/*": "allow"'
check SC-001 "opencode.json allows check-refs and specboot self-checks" \
  has_all "$OCFG" '"bash check-refs.sh": "allow"' '"bash specboot.sh *": "allow"' \
          '"bash validate-specboot.sh": "allow"'
check SC-001 "opencode.json allows node, mkdir, date (evidence reads, dirs, timestamps)" \
  has_all "$OCFG" '"node *": "allow"' '"mkdir *": "allow"' '"date *": "allow"'
check SC-001 "opencode.json allows python3 (YAML checks)" \
  has_all "$OCFG" '"python3 *": "allow"'
check SC-001 "opencode.json keeps gh out of primary allowlist (unused in maintainer flow)" \
  bash -c '! grep -qF "\"gh *\"" "$1"' _ "$OCFG"

# --- M-908: destructive commands stay gated (SC-002) ---
echo "Destructive commands stay gated (SC-002, M-908):"

check SC-002 "opencode.json keeps rm -rf in ask" \
  has_all "$OCFG" '"rm -rf *": "ask"'
check SC-002 "opencode.json keeps unlisted commands in ask (fallback)" \
  has_all "$OCFG" '"*": "ask"'

# --- M-908: /sync-specs runs under its dedicated agent (SC-003) ---
echo "sync-specs dedicated agent (SC-003, M-908):"

check SC-003 "sync-specs agent file exists" test -f "$SYNC_AGENT"
check SC-003 "sync-specs command declares agent: sync-specs" \
  has_all "$SYNC_CMD" "agent: sync-specs"
check SC-003 "sync-specs agent is primary with openspec-only edit" \
  has_all "$SYNC_AGENT" "mode: primary" '"openspec/**": allow' '"*": deny'
check SC-003 "sync-specs agent allows scoped read bash" \
  has_all "$SYNC_AGENT" '"openspec *": allow' '"git status": allow' \
          '"git diff": allow' '"ls *": allow' '"cat *": allow'
check SC-003 "sync-specs agent denies commit/push (ownership)" \
  lacks_all "$SYNC_AGENT" '"git commit": allow' '"git push": allow'

# --- M-908: verify agent runs framework guards without delegating (SC-004) ---
echo "Verify framework dogfooding permissions (SC-004, M-908):"

check SC-004 "verify block allows bash tests and scripts (framework guards)" \
  has_all "$VERIFY" '"bash tests/*": allow' '"bash scripts/*": allow'
check SC-004 "verify block allows node -e and date (evidence + timestamps)" \
  has_all "$VERIFY" '"node -e *": allow' '"date *": allow'
check SC-004 "verify role documents bash tests dogfooding" \
  has_all "$VERIFY_ROLE" "bash tests/"

# --- M-908: archive cleanup + checkbox ticking without friction (SC-005) ---
echo "Archive frictionless cleanup (SC-005, M-908):"

check SC-005 "archive block allows rm -f openspec/tickets/* (silent cleanup)" \
  has_all "$ARCHIVE" '"rm -f openspec/tickets/*": allow'
check SC-005 "archive skill instructs checkbox ticking via edit tool" \
  has_all "$ARCHIVE_SKILL" "edit tool"

# --- M-911 (permissions-cycle-completion) ---
echo "Permissions cycle completion (M-911):"

check SC-001 "archive block allows mkdir -p openspec/*" \
  has_all "$ARCHIVE" '"mkdir -p openspec/*": allow'

RUNALL="$ROOT/tests/run-all.sh"
check SC-002 "canonical runner tests/run-all.sh exists" test -f "$RUNALL"
check SC-002 "run-all.sh is executable" test -x "$RUNALL"
check SC-002 "run-all.sh loops over all *-test.sh" \
  has_all "$RUNALL" "tests/*-test.sh" "for"
check SC-002 "run-all.sh fails if any test fails" \
  has_all "$RUNALL" "exit 1"

check SC-003 "commit skill reads stalenessPaths from .specboot.json" \
  has_all "$ROOT/ai-specs/skills/commit/SKILL.md" "stalenessPaths"
check SC-004 "commit skill documents the fallback default list" \
  has_all "$ROOT/ai-specs/skills/commit/SKILL.md" "src"

# W5 schema/materialization
check SC-003 ".specboot.json standard documents stalenessPaths" \
  has_all "$ROOT/docs/specboot-json-standard.md" "stalenessPaths"
check SC-003 ".specboot.json schema validates stalenessPaths" \
  has_all "$ROOT/validate-specboot.sh" "stalenessPaths"

# SC-005/006: trust model + check-refs variant in opencode.json
check SC-005 "commit skill documents canonical staleness command marker" \
  has_all "$ROOT/ai-specs/skills/commit/SKILL.md" "git log --format" "--date=iso"
check SC-006 "framework-contract documents node/python3 trust model" \
  has_all "$ROOT/docs/framework-contract.md" "node *" "python3 *"
check SC-006 "opencode.json allows bash check-refs.sh with args" \
  has_all "$OCFG" '"bash check-refs.sh *": "allow"'
echo ""
echo "Agent permissions sync contract: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
