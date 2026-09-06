#!/usr/bin/env bash
# TDD self-test for the mandatory steps contract (M-601 — change inject-mandatory-steps).
#
# Validates (per openspec/changes/inject-mandatory-steps/specs/mandatory-steps/spec.md):
#   - docs/openspec-tasks-mandatory-steps.md exists with the three phases
#     pre-implementation / during / post (SC-001)
#   - ai-specs/skills/plan-change/SKILL.md instructs injecting a
#     "## Mandatory Steps" section into every generated tasks.md, reading the
#     document at generation time, without a hardcoded copy (SC-002), and
#     validates the section in its Step 6 checklist (SC-003)
#   - AGENTS.md §2 (dynamic loading) references the document (SC-004)
#   - The document is distributed as a framework file: FRAMEWORK_ITEMS in
#     specboot.sh + package.json files allowlist + docs-standard.md tree +
#     framework-contract.md init skeleton, and it is NOT in REQUIRED_FILES
#     (SC-005)
#   - PLAN_MEJORAS_SPECBOOT.md marks M-601 [x], adds history row v3.6 and
#     registers Fase 10 follow-ups M-904..M-907; M-403 now marked completed
#     (sync-agent-permissions) (SC-006)
#   - Version 0.6.2 in package.json/.specboot.json (migrated pin: 0.6.1→0.6.2
#     in the M-904/M-905 bump) and historical CHANGELOG entry ## [0.6.0] without
#     Breaking changes (SC-007)
#
# The script must FAIL (RED) until tasks 1.2-1.5 and 2.1-2.3 land.
#
# Run: bash tests/mandatory-steps-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="$ROOT/docs/openspec-tasks-mandatory-steps.md"
SKILL="$ROOT/ai-specs/skills/plan-change/SKILL.md"
BRIDGE="$ROOT/AGENTS.md"
SPECBOOT="$ROOT/specboot.sh"
PKGJSON="$ROOT/package.json"
SPECBOOTJSON="$ROOT/.specboot.json"
DOCSSTD="$ROOT/docs/docs-standard.md"
CONTRACT="$ROOT/docs/framework-contract.md"
PLAN="$ROOT/PLAN_MEJORAS_SPECBOOT.md"
CHANGELOG="$ROOT/CHANGELOG.md"

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

# array_block <name> — raw block of an array definition in specboot.sh
array_block() {
  sed -n "/^${1}=(/,/^)/p" "$SPECBOOT"
}

# --- SC-001: mandatory steps document with the three phases ---
echo "Mandatory steps document (SC-001):"

check SC-001 "document exists" test -f "$DOC"
check SC-001 "declares its role: single source of truth injected by plan-change" \
  has_all "$DOC" "fuente única de verdad" "plan-change"
check SC-001 "pre-implementation phase: active branch follows the convention" \
  has_all "$DOC" "## Pre-implementación" "rama activa"
check SC-001 "pre-implementation phase: clean git state" \
  has_all "$DOC" "git limpio"
check SC-001 "during phase: module unit tests" \
  has_all "$DOC" "tests unitarios del módulo"
check SC-001 "during phase: new test fails before implementing (RED)" \
  has_all "$DOC" "antes de implementar" "RED"
check SC-001 "post phase: run verify" \
  has_all "$DOC" "verify"
check SC-001 "post phase: run adversarial-review" \
  has_all "$DOC" "adversarial-review"

# --- SC-002 / SC-003: plan-change injection and validation ---
echo "plan-change injection and validation (SC-002/SC-003):"

check SC-002 "skill references the mandatory-steps document" \
  has_all "$SKILL" "docs/openspec-tasks-mandatory-steps.md"
check SC-002 "skill instructs the ## Mandatory Steps section in every tasks.md" \
  has_all "$SKILL" "## Mandatory Steps"
check SC-002 "content is read at generation time (dynamic, not duplicated)" \
  has_all "$SKILL" "read at generation time"
check SC-002 "skill does not hardcode the checklist content" \
  lacks_all "$SKILL" "rama activa" "git limpio"
check SC-003 "Step 6 checklist validates the injected section" \
  has_all "$SKILL" "tasks.md includes the"

# --- SC-004: AGENTS.md dynamic loading reference ---
echo "AGENTS.md dynamic loading reference (SC-004):"

check SC-004 "bridge §2 references the mandatory-steps document" \
  has_all "$BRIDGE" "openspec-tasks-mandatory-steps.md"

# --- SC-005: framework distribution sync ---
echo "Framework distribution (SC-005):"

fw_block="$(array_block FRAMEWORK_ITEMS)"
req_block="$(array_block REQUIRED_FILES)"

check SC-005 "FRAMEWORK_ITEMS block found in specboot.sh" test -n "$fw_block"
check SC-005 "FRAMEWORK_ITEMS includes the document (init/update injection)" \
  grep -qF -- "docs/openspec-tasks-mandatory-steps.md" <<< "$fw_block"
check SC-005 "REQUIRED_FILES block found in specboot.sh" test -n "$req_block"
check SC-005 "document NOT in REQUIRED_FILES (minor must not break consumer --ci)" \
  bash -c "! grep -qF -- 'openspec-tasks-mandatory-steps' <<< \"\$1\"" _ "$req_block"
check SC-005 "npm files allowlist includes the document" \
  has_all "$PKGJSON" "docs/openspec-tasks-mandatory-steps.md"
check SC-005 "docs-standard.md canonical tree lists the document" \
  has_all "$DOCSSTD" "openspec-tasks-mandatory-steps.md"
check SC-005 "framework-contract.md init skeleton includes the document" \
  has_all "$CONTRACT" "openspec-tasks-mandatory-steps.md"

# --- SC-006: improvement plan record and follow-ups ---
echo "Improvement plan record (SC-006):"

check SC-006 "M-601 marked completed" \
  grep -qF -- "## [x] M-601" "$PLAN"
check SC-006 "history row v3.6 present" \
  grep -qF -- "| v3.6 |" "$PLAN"
check SC-006 "Fase 10 registers follow-ups M-904..M-907" \
  has_all "$PLAN" "FASE 10 — Follow-ups de auditoría" "M-904" "M-905" "M-906" "M-907"
check SC-006 "M-403 marked completed (sync-agent-permissions)" \
  grep -qF -- "## [x] M-403" "$PLAN"

# --- SC-007: version pins (0.6.2 after M-904/M-905 bump) + historical 0.6.0 notes ---
echo "Version pins (SC-007):"

check SC-007 "package.json declares 0.6.2" \
  grep -qF -- '"version": "0.6.2"' "$PKGJSON"
check SC-007 ".specboot.json reflects frameworkVersion 0.6.2" \
  grep -qF -- '"frameworkVersion": "0.6.2"' "$SPECBOOTJSON"
check SC-007 "CHANGELOG entry ## [0.6.0] present" \
  grep -q "^## \[0\.6\.0\]" "$CHANGELOG"

changelog_section="$(sed -n '/^## \[0\.6\.0\]/,/^## \[/p' "$CHANGELOG")"
check SC-007 "CHANGELOG 0.6.0 section is non-empty" test -n "$changelog_section"
check SC-007 "CHANGELOG 0.6.0 has no Breaking changes section" \
  bash -c "! grep -qF -- '### Breaking changes' <<< \"\$1\"" _ "$changelog_section"

# --- Summary ---
echo ""
echo "Mandatory steps contract: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
