#!/usr/bin/env bash
# TDD self-test for the SPECBOOT-PREC-01 baseline (change permission-baseline).
#
# Validates (per openspec/changes/permission-baseline/specs):
#   - SC-001: the baseline snapshot exists with strict location separation —
#     raw data in openspec/state/baseline/ (JSONs) and the human-readable
#     report in docs/baseline/specboot-prec-01-baseline.md, without credentials
#   - SC-002: real validator results are preserved in openspec/state/baseline/
#   - SC-003: the permission validator runs clean against the real agents
#     (0 deltas — regression guard)
#
# The script must FAIL (RED) until Task 1.2-1.4 land (snapshot missing).
# SC-003 asserts are regression guards: they pass today and must keep passing.
#
# Run: bash tests/baseline-capabilities-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASELINE_DIR="$ROOT/openspec/state/baseline"
BASELINE_REPORT="$ROOT/docs/baseline/specboot-prec-01-baseline.md"
VALIDATOR="$ROOT/scripts/validate-agent-permissions.mjs"
FIXTURES="$ROOT/tests/fixtures/permission-contracts"

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

# valid_json <file> — the file parses as JSON
valid_json() {
  node -e "try { JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8')); } catch (e) { process.exit(1); }" "$1" 2>/dev/null
}

# --- SC-001: baseline snapshot with strict location separation ---
echo "Baseline snapshot (SC-001):"

check SC-001 "baseline raw data directory exists (openspec/state/baseline/)" \
  test -d "$BASELINE_DIR"
check SC-001 "environment snapshot exists" \
  test -f "$BASELINE_DIR/environment.json"
check SC-001 "environment snapshot is valid JSON" \
  valid_json "$BASELINE_DIR/environment.json"
check SC-001 "environment snapshot records Specboot version" \
  has_all "$BASELINE_DIR/environment.json" "0.11.1"
check SC-001 "environment snapshot records main SHA (b252a63)" \
  has_all "$BASELINE_DIR/environment.json" "b252a63"
check SC-001 "environment snapshot references apiKey as env placeholder (sin credenciales)" \
  has_all "$BASELINE_DIR/environment.json" "{env:OMNIROUTE_API_KEY}"
check SC-001 "environment snapshot declares volume-approximation metrics policy" \
  has_all "$BASELINE_DIR/environment.json" "aproximación_de_volumen"
check SC-001 "human report exists (docs/baseline/)" \
  test -f "$BASELINE_REPORT"
check SC-001 "human report documents methodology, reproduction and conclusions" \
  has_all "$BASELINE_REPORT" "Metodología" "reproduc" "Conclusiones"

# --- SC-002: real validator results preserved ---
echo "Real validator results (SC-002):"

check SC-002 "agent permission validator result preserved" \
  test -f "$BASELINE_DIR/validate-agent-permissions.json"
check SC-002 "agent permission validator result is valid JSON" \
  valid_json "$BASELINE_DIR/validate-agent-permissions.json"
check SC-002 "command contracts validator result preserved" \
  test -f "$BASELINE_DIR/validate-command-contracts.json"
check SC-002 "specboot --ci result preserved" \
  test -f "$BASELINE_DIR/specboot-ci.json"
check SC-002 "run-all result preserved" \
  test -f "$BASELINE_DIR/run-all.json"
check SC-002 "results record exit codes" \
  has_all "$BASELINE_DIR/validate-agent-permissions.json" "exitCode"

# --- SC-003: permission matrix without differences (regression guard) ---
echo "Permission matrix regression guard (SC-003):"

check SC-003 "validator passes against real agents (0 deltas)" \
  bash -c 'node "$1/scripts/validate-agent-permissions.mjs" --root "$1" >/dev/null 2>&1' _ "$ROOT"

# --- SC-004..SC-008: negative regression fixtures (Task 2) ---
# Mapeo SC-011: bad-ownership ya cubre "archive no stagea" (clase ownership:
# agente sin commit con git commit efectivo allow); bad-force-push ya cubre
# "variantes de force-push"; bad-excess-scope cubre el mecanismo de scope.
# Solo se añaden fixtures para lo NO cubierto: build-evidence (SC-004),
# reviewer-edit-code (SC-005) y commit-subagents (SC-007).
echo "Negative regression fixtures (SC-004..SC-008):"

# SC-004: build writes foreign evidence (new fixture — RED until it exists)
check SC-004 "build writing foreign evidence fails (fixture bad-build-evidence)" \
  bash -c 'test -f "$2/bad-build-evidence/manifest.yml" && ! node "$1" --root "$2/bad-build-evidence" --manifest "$2/bad-build-evidence/manifest.yml" >/dev/null 2>&1' _ "$VALIDATOR" "$FIXTURES"
check SC-004 "bad-build-evidence reports agent=build evidence violation" \
  bash -c 'test -f "$2/bad-build-evidence/manifest.yml" && node "$1" --root "$2/bad-build-evidence" --manifest "$2/bad-build-evidence/manifest.yml" 2>&1 | grep -qi "agent=build"' _ "$VALIDATOR" "$FIXTURES"

# SC-005: verify/reviewer edit code (new fixture — RED until it exists)
check SC-005 "verify/reviewer editing code fails (fixture bad-reviewer-edit-code)" \
  bash -c 'test -f "$2/bad-reviewer-edit-code/manifest.yml" && ! node "$1" --root "$2/bad-reviewer-edit-code" --manifest "$2/bad-reviewer-edit-code/manifest.yml" >/dev/null 2>&1' _ "$VALIDATOR" "$FIXTURES"

# SC-006: archive stagea — reused fixture bad-ownership (regression guard)
check SC-006 "non-commit agent staging fails (reused fixture bad-ownership)" \
  bash -c '! node "$1" --root "$2/bad-ownership" --manifest "$2/bad-ownership/manifest.yml" >/dev/null 2>&1' _ "$VALIDATOR" "$FIXTURES"

# SC-007: commit spawns subagents (new fixture — RED until it exists)
check SC-007 "commit spawning subagents fails (fixture bad-commit-subagents)" \
  bash -c 'test -f "$2/bad-commit-subagents/manifest.yml" && ! node "$1" --root "$2/bad-commit-subagents" --manifest "$2/bad-commit-subagents/manifest.yml" >/dev/null 2>&1' _ "$VALIDATOR" "$FIXTURES"

# SC-008: force-push variants stay forbidden — reused fixture bad-force-push (regression guard)
check SC-008 "force-push not denied fails (reused fixture bad-force-push)" \
  bash -c '! node "$1" --root "$2/bad-force-push" --manifest "$2/bad-force-push/manifest.yml" >/dev/null 2>&1' _ "$VALIDATOR" "$FIXTURES"

# --- SC-011/SC-012: reuse without duplicates + no capability amplification ---
# Guardias de regresión: pasan hoy y deben seguir pasando (la sustancia ya
# existe; el gap era la ausencia de aserciones etiquetadas — convención
# build-agent de nombres públicos con SC-NNN, añadidas post-verify per
# base-standards §7, subtarea 2.4).
echo "Reuse and amplification guards (SC-011, SC-012):"

# SC-011: reused fixtures remain the originals; only the missing ones were added (no duplicates)
check SC-011 "negative fixture set matches the SC-011 mapping (no duplicates for covered cases)" \
  bash -c 'for d in good bad-catchall bad-unknown-agent bad-ownership bad-force-push bad-missing-required bad-excess-scope bad-build-evidence bad-reviewer-edit-code bad-commit-subagents; do test -d "$1/$d" || exit 1; done' _ "$FIXTURES"

# SC-012: baseline/benchmark scripts do not write to permission blocks, manifest or opencode.json
check SC-012 "benchmark script does not write to permission blocks or manifest" \
  bash -c '! grep -qE "writeFileSync\([^)]*(\.opencode|opencode\.json|agent-permission-contracts)" "$1/scripts/benchmark-permissions.mjs"' _ "$ROOT"
check SC-012 "baseline test does not write to permission blocks or manifest" \
  bash -c '! grep -qE "writeFileSync\([^)]*(\.opencode|opencode\.json|agent-permission-contracts)" "$1/tests/baseline-capabilities-test.sh"' _ "$ROOT"

echo ""
echo "Baseline capabilities contract: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
