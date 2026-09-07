#!/usr/bin/env bash
# TDD self-test for the verify-results.json schema (M-401 — change persist-verify-results).
#
# Validates the canonical fixture ai-specs/examples/verify-results-example.json
# against the versioned contract (schema_version: 1) declared in
# openspec/changes/persist-verify-results/specs/verification-state/spec.md:
#   - required keys: schema_version, change, ticket_id, status, evidence_mode,
#     timestamp, tasks{total,passed,failed,untested}, scenarios[]
#   - status enums: PASS|PARTIAL|FAIL (global), PASS|FAIL|UNTESTED (per scenario)
#   - evidence_mode: executable|static
#   - scenario id pattern SC-{NNN}, unique within the file
#   - tasks.total == passed + failed + untested
#   - semantic rule: evidence_mode=static -> status=PARTIAL, no scenario PASS
#
# JSON parsing uses node -e (framework convention: "node -e, nunca jq" — Makefile).
#
# Run: bash tests/verify-state-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE="$ROOT/ai-specs/examples/verify-results-example.json"

PASS=0
FAIL=0

ok() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
bad() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

# check_eq <description> <expected> <actual>
check_eq() {
  if [ "$2" = "$3" ]; then
    ok "$1"
  else
    bad "$1 (expected '$2', got '$3')"
  fi
}

# --- Precondition (RED before implementation): fixture must exist ---
if [ ! -f "$FIXTURE" ]; then
  echo "  ✗ ai-specs/examples/verify-results-example.json does not exist yet (RED)"
  exit 1
fi
echo "  ✓ [SC-002] canonical fixture exists"

# --- node is required for JSON validation (framework convention) ---
if ! command -v node >/dev/null 2>&1; then
  echo "  ✗ node is required but not installed"
  exit 1
fi

# --- Inline schema validator (schema_version: 1 contract) ---
VALIDATOR="$(mktemp /tmp/verify-state-validator.XXXXXX.js)"
NEGATIVE="$(mktemp /tmp/verify-state-negative.XXXXXX.json)"
trap 'rm -f "$VALIDATOR" "$NEGATIVE"' EXIT

cat > "$VALIDATOR" <<'EOF'
#!/usr/bin/env node
// Schema validator for openspec/state/verify-results.json (schema_version: 1).
// Usage: node <this-script> <verify-results.json>
// Prints one line per violation to stderr; exits 1 if any violation is found.
'use strict';

const fs = require('fs');

const GLOBAL_STATUSES = ['PASS', 'PARTIAL', 'FAIL'];
const SCENARIO_STATUSES = ['PASS', 'FAIL', 'UNTESTED'];
const EVIDENCE_MODES = ['executable', 'static'];
const REQUIRED_KEYS = [
  'schema_version',
  'change',
  'ticket_id',
  'status',
  'evidence_mode',
  'timestamp',
  'tasks',
  'scenarios',
];
const TASK_COUNTERS = ['total', 'passed', 'failed', 'untested'];

const violations = [];
const add = (msg) => violations.push(msg);

let data;
try {
  data = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
} catch (err) {
  console.error('schema violation: invalid JSON (' + err.message + ')');
  process.exit(1);
}

if (typeof data !== 'object' || data === null || Array.isArray(data)) {
  console.error('schema violation: root must be a JSON object');
  process.exit(1);
}

// Required keys
const missingKeys = REQUIRED_KEYS.filter((key) => !(key in data));
if (missingKeys.length > 0) {
  missingKeys.forEach((key) => add('missing required key: ' + key));
  violations.forEach((v) => console.error('schema violation: ' + v));
  process.exit(1);
}

// schema_version
if (data.schema_version !== 1) {
  add('schema_version must be 1 (got ' + JSON.stringify(data.schema_version) + ')');
}

// non-empty strings
['change', 'ticket_id'].forEach((key) => {
  if (typeof data[key] !== 'string' || data[key].length === 0) {
    add(key + ' must be a non-empty string');
  }
});

// global status enum
if (!GLOBAL_STATUSES.includes(data.status)) {
  add('status must be one of ' + GLOBAL_STATUSES.join('|') + ' (got ' + JSON.stringify(data.status) + ')');
}

// evidence_mode enum
if (!EVIDENCE_MODES.includes(data.evidence_mode)) {
  add('evidence_mode must be one of ' + EVIDENCE_MODES.join('|') + ' (got ' + JSON.stringify(data.evidence_mode) + ')');
}

// timestamp: ISO-8601 parseable
if (typeof data.timestamp !== 'string' || Number.isNaN(Date.parse(data.timestamp))) {
  add('timestamp must be an ISO-8601 date string (got ' + JSON.stringify(data.timestamp) + ')');
}

// tasks counters
if (typeof data.tasks !== 'object' || data.tasks === null || Array.isArray(data.tasks)) {
  add('tasks must be an object');
} else {
  let countersValid = true;
  TASK_COUNTERS.forEach((key) => {
    const value = data.tasks[key];
    if (typeof value !== 'number' || !Number.isInteger(value) || value < 0) {
      add('tasks.' + key + ' must be a non-negative integer (got ' + JSON.stringify(value) + ')');
      countersValid = false;
    }
  });
  if (countersValid && data.tasks.total !== data.tasks.passed + data.tasks.failed + data.tasks.untested) {
    add('tasks.total must equal passed + failed + untested');
  }
}

// scenarios
if (!Array.isArray(data.scenarios) || data.scenarios.length === 0) {
  add('scenarios must be a non-empty array');
} else {
  data.scenarios.forEach((scenario, index) => {
    if (typeof scenario !== 'object' || scenario === null || Array.isArray(scenario)) {
      add('scenarios[' + index + '] must be an object');
      return;
    }
    ['id', 'test', 'status'].forEach((key) => {
      if (!(key in scenario)) add('scenarios[' + index + '] missing required key: ' + key);
    });
    if (typeof scenario.id !== 'string' || !/^SC-\d{3}$/.test(scenario.id)) {
      add('scenarios[' + index + '].id must match SC-{NNN} (got ' + JSON.stringify(scenario.id) + ')');
    }
    if (typeof scenario.test !== 'string' || scenario.test.length === 0) {
      add('scenarios[' + index + '].test must be a non-empty string');
    }
    if (!SCENARIO_STATUSES.includes(scenario.status)) {
      add('scenarios[' + index + '].status must be one of ' + SCENARIO_STATUSES.join('|') + ' (got ' + JSON.stringify(scenario.status) + ')');
    }
  });

  // duplicate ids
  const ids = data.scenarios
    .filter((s) => s && typeof s.id === 'string')
    .map((s) => s.id);
  const duplicates = ids.filter((id, index) => ids.indexOf(id) !== index);
  if (duplicates.length > 0) {
    add('duplicate scenario ids: ' + Array.from(new Set(duplicates)).join(', '));
  }
}

// semantic invariant (REQ-003): static evidence never produces PASS
if (data.evidence_mode === 'static') {
  if (data.status !== 'PARTIAL') {
    add('with evidence_mode=static the global status must be PARTIAL (got ' + JSON.stringify(data.status) + ')');
  }
  if (Array.isArray(data.scenarios)) {
    data.scenarios.forEach((scenario, index) => {
      if (scenario && scenario.status === 'PASS') {
        add('scenarios[' + index + '] must not be PASS when evidence_mode=static');
      }
    });
  }
}

if (violations.length > 0) {
  violations.forEach((v) => console.error('schema violation: ' + v));
  process.exit(1);
}
process.exit(0);
EOF

node "$VALIDATOR" "$FIXTURE" >/tmp/verify-state-positive.out 2>&1
check_eq "[SC-002] canonical fixture satisfies the schema_version 1 contract" "0" "$?"

# --- Explicit spot-checks of the contract elements on the fixture ---
SCHEMA_VERSION="$(node -e "const d=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));console.log(d.schema_version)" "$FIXTURE")"
check_eq "[SC-002] schema_version is 1" "1" "$SCHEMA_VERSION"

GLOBAL_STATUS="$(node -e "const d=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));console.log(d.status)" "$FIXTURE")"
check_eq "[SC-002] global status uses the PASS|PARTIAL|FAIL vocabulary" "PASS" "$GLOBAL_STATUS"

EVIDENCE_MODE="$(node -e "const d=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));console.log(d.evidence_mode)" "$FIXTURE")"
check_eq "[SC-002] evidence_mode uses the executable|static vocabulary" "executable" "$EVIDENCE_MODE"

SCENARIO_IDS="$(node -e "const d=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));console.log(d.scenarios.map((s)=>s.id).join(' '))" "$FIXTURE")"
check_eq "[SC-002] scenario ids follow SC-{NNN} (spot-check)" "SC-001 SC-002" "$SCENARIO_IDS"

# --- Negative tests: the validator must REJECT contract deviations ---

# expect_violation <description> <json-document>
expect_violation() {
  local desc="$1" json="$2"
  printf '%s' "$json" > "$NEGATIVE"
  if node "$VALIDATOR" "$NEGATIVE" >/dev/null 2>&1; then
    bad "$desc (validator accepted an invalid document)"
  else
    ok "$desc"
  fi
}

expect_violation "[SC-002] rejects missing schema_version" \
  '{"change":"add-auth","ticket_id":"PROJ-123","status":"PASS","evidence_mode":"executable","timestamp":"2026-09-04T14:30:00Z","tasks":{"total":1,"passed":1,"failed":0,"untested":0},"scenarios":[{"id":"SC-001","test":"t","status":"PASS"}]}'

expect_violation "[SC-002] rejects lowercase global status (pre-M401 fragile format)" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"PROJ-123","status":"passed","evidence_mode":"executable","timestamp":"2026-09-04T14:30:00Z","tasks":{"total":1,"passed":1,"failed":0,"untested":0},"scenarios":[{"id":"SC-001","test":"t","status":"PASS"}]}'

expect_violation "[SC-002] rejects invalid evidence_mode" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"PROJ-123","status":"PARTIAL","evidence_mode":"static-fallback","timestamp":"2026-09-04T14:30:00Z","tasks":{"total":1,"passed":0,"failed":0,"untested":1},"scenarios":[{"id":"SC-001","test":"t","status":"UNTESTED"}]}'

expect_violation "[SC-002] rejects non-ISO timestamp" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"PROJ-123","status":"PASS","evidence_mode":"executable","timestamp":"yesterday","tasks":{"total":1,"passed":1,"failed":0,"untested":0},"scenarios":[{"id":"SC-001","test":"t","status":"PASS"}]}'

expect_violation "[SC-002] rejects tasks.total mismatch" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"PROJ-123","status":"PASS","evidence_mode":"executable","timestamp":"2026-09-04T14:30:00Z","tasks":{"total":5,"passed":4,"failed":0,"untested":0},"scenarios":[{"id":"SC-001","test":"t","status":"PASS"}]}'

expect_violation "[SC-002] rejects scenario id without SC-{NNN} pattern" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"PROJ-123","status":"PASS","evidence_mode":"executable","timestamp":"2026-09-04T14:30:00Z","tasks":{"total":1,"passed":1,"failed":0,"untested":0},"scenarios":[{"id":"SC-1","test":"t","status":"PASS"}]}'

expect_violation "[SC-002] rejects uppercase per-scenario status" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"PROJ-123","status":"PASS","evidence_mode":"executable","timestamp":"2026-09-04T14:30:00Z","tasks":{"total":1,"passed":1,"failed":0,"untested":0},"scenarios":[{"id":"SC-001","test":"t","status":"PASSED"}]}'

expect_violation "[SC-002] rejects duplicate scenario ids" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"PROJ-123","status":"PASS","evidence_mode":"executable","timestamp":"2026-09-04T14:30:00Z","tasks":{"total":2,"passed":2,"failed":0,"untested":0},"scenarios":[{"id":"SC-001","test":"t1","status":"PASS"},{"id":"SC-001","test":"t2","status":"PASS"}]}'

expect_violation "[SC-003] rejects PASS scenario under static evidence (REQ-003)" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"PROJ-123","status":"PASS","evidence_mode":"static","timestamp":"2026-09-04T14:30:00Z","tasks":{"total":1,"passed":1,"failed":0,"untested":0},"scenarios":[{"id":"SC-001","test":"t","status":"PASS"}]}'

expect_violation "[SC-003] rejects static evidence with PARTIAL but a PASS scenario" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"PROJ-123","status":"PARTIAL","evidence_mode":"static","timestamp":"2026-09-04T14:30:00Z","tasks":{"total":2,"passed":1,"failed":0,"untested":1},"scenarios":[{"id":"SC-001","test":"t1","status":"PASS"},{"id":"SC-002","test":"t2","status":"UNTESTED"}]}'

echo ""
echo "TDD tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
