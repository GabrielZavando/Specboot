#!/usr/bin/env bash
# TDD self-test for the SPECBOOT-PREC-01 semimanual benchmark recorder
# (change permission-baseline).
#
# Validates (per openspec/changes/permission-baseline/specs/cycle-benchmark):
#   - SC-010: the auxiliary script exists and runs the existing permission
#     validators (a simple runner — NOT an automated orchestrator, which
#     corresponds to SPECBOOT-REL-01)
#   - SC-009: the recording template exists with the explicit
#     `aproximación_de_volumen` label and the fields duración/llamadas/
#     reintentos/resultado de calidad/bytes — never mathematical token
#     estimation
#
# The script must FAIL (RED) until Task 3.2-3.3 land (recorder and template
# missing).
#
# Run: bash tests/benchmark-recorder-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RECORDER="$ROOT/scripts/benchmark-permissions.mjs"
TEMPLATE="$ROOT/openspec/state/benchmark/registro-inicial.md"

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

# --- SC-010: auxiliary script exists and runs the existing validators ---
echo "Benchmark recorder script (SC-010):"

check SC-010 "auxiliary script exists (scripts/benchmark-permissions.mjs)" \
  test -f "$RECORDER"
check SC-010 "script runs the agent permission validator" \
  has_all "$RECORDER" "validate-agent-permissions.mjs"
check SC-010 "script runs the command contracts validator" \
  has_all "$RECORDER" "validate-command-contracts.mjs"
check SC-010 "script documents the no-orchestrator boundary (SPECBOOT-REL-01)" \
  has_all "$RECORDER" "SPECBOOT-REL-01"

# --- SC-009/SC-010: recording template with explicit labeling ---
echo "Recording template (SC-009, SC-010):"

check SC-009 "template exists (openspec/state/benchmark/registro-inicial.md)" \
  test -f "$TEMPLATE"
check SC-009 "template labels metrics as aproximación_de_volumen" \
  has_all "$TEMPLATE" "aproximación_de_volumen"
check SC-009 "template forbids mathematical token estimation" \
  has_all "$TEMPLATE" "Nunca calcular o estimar tokens matemáticamente"
check SC-010 "template records duration" \
  has_all "$TEMPLATE" "duración"
check SC-010 "template records calls" \
  has_all "$TEMPLATE" "llamadas"
check SC-010 "template records retries" \
  has_all "$TEMPLATE" "reintentos"
check SC-010 "template records quality result" \
  has_all "$TEMPLATE" "calidad"
check SC-010 "template records measured bytes" \
  has_all "$TEMPLATE" "bytes"
check SC-010 "template covers /adversarial-review and /archive runs" \
  has_all "$TEMPLATE" "/adversarial-review" "/archive"

# --- SC-010: representative changes referenced by the template (Task 4) ---
echo "Representative changes (SC-010):"

CHANGES="$ROOT/tests/fixtures/benchmark-changes"

check SC-010 "template references the representative change set" \
  has_all "$TEMPLATE" "benchmark-changes"
check SC-010 "representative change fixtures exist (backend, frontend, framework, docs)" \
  bash -c 'for d in backend frontend framework docs; do test -f "$1/$d/change.md" || exit 1; done' _ "$CHANGES"
check SC-010 "shared scenarios document the three ticket conditions" \
  has_all "$CHANGES/scenarios.md" "Reanudación" "Evidencia ausente" "Modificación posterior"

echo ""
echo "Benchmark recorder contract: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
