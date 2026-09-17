#!/usr/bin/env bash
# TDD self-test for the sync-specs command (M-701 — change sync-specs).
#
# Validates (per openspec/changes/sync-specs/specs/sync-specs/spec.md):
#   - Skill exists at ai-specs/skills/sync-specs/SKILL.md and declares the
#     contract: applies deltas without archiving (SC-001), token-light
#     quantitative reporting (SC-002), no-active-change no-op (SC-003),
#     idempotency "sin diferencias" (SC-004), MODIFIED-on-missing treated as
#     ADDED, single-active-change premise, and never touches the manifest
#   - Command exists at .opencode/commands/sync-specs.md and delegates to the
#     skill via its {file:...} reference (SC-005)
#   - AGENTS.md §5.3 optional-tools table registers sync-specs and
#     check-refs.sh stays green (SC-005)
#
# The script must FAIL (RED) until tasks 2-4 land.
#
# Run: bash tests/sync-specs-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT/ai-specs/skills/sync-specs/SKILL.md"
COMMAND="$ROOT/.opencode/commands/sync-specs.md"
BRIDGE="$ROOT/AGENTS.md"

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

# --- SC-001..SC-004: skill contract ---
echo "sync-specs skill contract (SC-001..SC-004):"

check SC-001 "skill file exists" test -f "$SKILL"
check SC-001 "syncs WITHOUT archiving the change" \
  has_all "$SKILL" "sin archivar"
check SC-001 "never touches the manifest (own archive)" \
  has_all "$SKILL" "openspec/state/manifest.json"
check SC-001 "MODIFIED on missing spec is treated as ADDED" \
  has_all "$SKILL" "MODIFIED" "ADDED"
check SC-001 "malformed deltas abort without partial application" \
  has_all "$SKILL" "abortar"
check SC-001 "single active change premise (no multi-change, no TICKET-ID arg)" \
  has_all "$SKILL" "único change activo"
check SC-002 "token-light: no full spec reads into context" \
  has_all "$SKILL" "token-light"
check SC-002 "report is a quantitative summary" \
  has_all "$SKILL" "resumen cuantitativo"
check SC-003 "no active change -> explicit report, modifies nothing" \
  has_all "$SKILL" "no hay change activo"
check SC-004 "idempotent re-run reports no differences" \
  has_all "$SKILL" "sin diferencias"

# --- SC-005: command registration ---
echo "Command registration (SC-005):"

check SC-005 "command file exists" test -f "$COMMAND"
check SC-005 "command delegates to the skill via {file:...} reference" \
  has_all "$COMMAND" "{file:ai-specs/skills/sync-specs/SKILL.md}"
check SC-005 "skill registered in AGENTS.md (check-refs requirement)" \
  has_all "$BRIDGE" "sync-specs"
check SC-005 "command documented in AGENTS.md §5.3 optional tools" \
  bash -c "sed -n '/5.3/,/^## 6/p' '$BRIDGE' | grep -qF -- 'sync-specs'"
check SC-005 "check-refs stays green" bash -c "bash '$ROOT/check-refs.sh' >/dev/null 2>&1"

# --- Summary ---
echo ""
echo "sync-specs contract: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
