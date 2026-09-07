#!/usr/bin/env bash
# TDD self-test for the mandatory deploy checklist (M-903 — change enforce-commit-gates).
#
# Validates (per openspec/changes/enforce-commit-gates/specs/deploy-checklist/spec.md):
#   - ai-specs/skills/deploy/SKILL.md declares a mandatory, project-agnostic
#     minimum checklist (6 items) and the blocking rule: if any item fails,
#     the deploy stops before the version bump (SC-009)
#   - docs/deploy-standards.md (template) lists "Rollback procedure defined"
#     and "OpenSpec change archived" in its Pre-deploy Checklist (SC-010)
#
# The script must FAIL (RED) until tasks 3.2/3.3 land.
#
# Run: bash tests/deploy-checklist-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT/ai-specs/skills/deploy/SKILL.md"
TEMPLATE="$ROOT/docs/deploy-standards.md"

PASS=0
FAIL=0

ok() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
bad() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

# has_all <file> <token> [<token>...] — every token must appear (fixed-string)
has_all() {
  local file="$1"; shift
  local tok
  for tok in "$@"; do
    if ! grep -qF -- "$tok" "$file"; then
      return 1
    fi
  done
  return 0
}

for f in "$SKILL" "$TEMPLATE"; do
  if [ ! -f "$f" ]; then
    echo "  ✗ required file missing: $f"
    exit 1
  fi
done

# --- SC-009: mandatory minimum checklist in the deploy skill ---
echo "Deploy skill mandatory checklist (SC-009):"

if grep -qF -- '## Mandatory pre-deploy checklist' "$SKILL"; then
  ok "[SC-009] deploy skill declares the mandatory pre-deploy checklist section"
else
  bad "[SC-009] deploy skill declares the mandatory pre-deploy checklist section"
fi

if grep -qF -- 'Tests green' "$SKILL"; then
  ok "[SC-009] checklist item: tests green"
else
  bad "[SC-009] checklist item: tests green"
fi

if grep -qF -- 'Lint without critical' "$SKILL"; then
  ok "[SC-009] checklist item: lint without critical errors"
else
  bad "[SC-009] checklist item: lint without critical errors"
fi

if grep -qF -- 'Build succeeds' "$SKILL"; then
  ok "[SC-009] checklist item: build succeeds"
else
  bad "[SC-009] checklist item: build succeeds"
fi

if grep -qF -- 'Security audit without critical' "$SKILL"; then
  ok "[SC-009] checklist item: security audit without critical vulnerabilities"
else
  bad "[SC-009] checklist item: security audit without critical vulnerabilities"
fi

if grep -qF -- 'Rollback procedure defined' "$SKILL"; then
  ok "[SC-009] checklist item: rollback procedure defined"
else
  bad "[SC-009] checklist item: rollback procedure defined"
fi

if grep -qF -- 'OpenSpec change archived' "$SKILL"; then
  ok "[SC-009] checklist item: OpenSpec change archived"
else
  bad "[SC-009] checklist item: OpenSpec change archived"
fi

if grep -qF -- 'stops before the version bump' "$SKILL"; then
  ok "[SC-009] blocking rule: deploy stops before the version bump when an item fails"
else
  bad "[SC-009] blocking rule: deploy stops before the version bump when an item fails"
fi

# --- SC-010: deploy-standards template checklist includes rollback + archived change ---
echo "deploy-standards template checklist (SC-010):"

if grep -qF -- 'Rollback procedure defined' "$TEMPLATE"; then
  ok "[SC-010] template Pre-deploy Checklist includes rollback procedure defined"
else
  bad "[SC-010] template Pre-deploy Checklist includes rollback procedure defined"
fi

if grep -qF -- 'OpenSpec change archived' "$TEMPLATE"; then
  ok "[SC-010] template Pre-deploy Checklist includes OpenSpec change archived"
else
  bad "[SC-010] template Pre-deploy Checklist includes OpenSpec change archived"
fi

# --- Summary ---
echo ""
echo "Deploy checklist contract: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
