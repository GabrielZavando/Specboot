#!/usr/bin/env bash
# TDD self-test for the adversarial-result.json schema (M-502 — change persist-adversarial-verdict).
#
# Validates the canonical fixture ai-specs/examples/adversarial-results-example.json
# against the versioned contract (schema_version: 1) declared in
# openspec/changes/persist-adversarial-verdict/specs/adversarial-state/spec.md:
#   - required keys: schema_version, change, ticket_id, verdict, confidence,
#     timestamp, findings{total,critical,warnings,info,discarded}
#   - verdict enum: SHIP|NO-SHIP
#   - confidence: numeric 0.0-1.0
#   - timestamp: ISO-8601 parseable
#   - findings counters: non-negative integers
#   - invariants: total == critical + warnings + info, critical <= total
#
# JSON parsing uses node -e (framework convention: "node -e, nunca jq" — Makefile).
#
# Run: bash tests/adversarial-state-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE="$ROOT/ai-specs/examples/adversarial-results-example.json"

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
  echo "  ✗ ai-specs/examples/adversarial-results-example.json does not exist yet (RED)"
  exit 1
fi
echo "  ✓ [SC-002] canonical fixture exists"

# --- node is required for JSON validation (framework convention) ---
if ! command -v node >/dev/null 2>&1; then
  echo "  ✗ node is required but not installed"
  exit 1
fi

# --- Inline schema validator (schema_version: 1 contract) ---
VALIDATOR="$(mktemp /tmp/adversarial-state-validator.XXXXXX.js)"
NEGATIVE="$(mktemp /tmp/adversarial-state-negative.XXXXXX.json)"
trap 'rm -f "$VALIDATOR" "$NEGATIVE"' EXIT

cat > "$VALIDATOR" <<'EOF'
#!/usr/bin/env node
// Schema validator for openspec/state/adversarial-result.json (schema_version: 1).
// Usage: node <this-script> <adversarial-result.json>
// Prints one line per violation to stderr; exits 1 if any violation is found.
'use strict';

const fs = require('fs');

const VERDICTS = ['SHIP', 'NO-SHIP'];
const REQUIRED_KEYS = [
  'schema_version',
  'change',
  'ticket_id',
  'verdict',
  'confidence',
  'timestamp',
  'findings',
];
const COUNTERS = ['total', 'critical', 'warnings', 'info', 'discarded'];

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

// verdict enum
if (!VERDICTS.includes(data.verdict)) {
  add('verdict must be one of ' + VERDICTS.join('|') + ' (got ' + JSON.stringify(data.verdict) + ')');
}

// confidence: numeric within 0.0-1.0
if (typeof data.confidence !== 'number' || Number.isNaN(data.confidence) || data.confidence < 0 || data.confidence > 1) {
  add('confidence must be a number between 0.0 and 1.0 (got ' + JSON.stringify(data.confidence) + ')');
}

// timestamp: ISO-8601 parseable
if (typeof data.timestamp !== 'string' || Number.isNaN(Date.parse(data.timestamp))) {
  add('timestamp must be an ISO-8601 date string (got ' + JSON.stringify(data.timestamp) + ')');
}

// findings counters
if (typeof data.findings !== 'object' || data.findings === null || Array.isArray(data.findings)) {
  add('findings must be an object');
} else {
  let countersValid = true;
  COUNTERS.forEach((key) => {
    const value = data.findings[key];
    if (typeof value !== 'number' || !Number.isInteger(value) || value < 0) {
      add('findings.' + key + ' must be a non-negative integer (got ' + JSON.stringify(value) + ')');
      countersValid = false;
    }
  });
  if (countersValid) {
    if (data.findings.total !== data.findings.critical + data.findings.warnings + data.findings.info) {
      add('findings.total must equal critical + warnings + info');
    }
    if (data.findings.critical > data.findings.total) {
      add('findings.critical must not exceed findings.total');
    }
  }
}

if (violations.length > 0) {
  violations.forEach((v) => console.error('schema violation: ' + v));
  process.exit(1);
}
process.exit(0);
EOF

node "$VALIDATOR" "$FIXTURE" >/tmp/adversarial-state-positive.out 2>&1
check_eq "[SC-002] canonical fixture satisfies the schema_version 1 contract" "0" "$?"

# --- Explicit spot-checks of the contract elements on the fixture ---
SCHEMA_VERSION="$(node -e "const d=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));console.log(d.schema_version)" "$FIXTURE")"
check_eq "[SC-002] schema_version is 1" "1" "$SCHEMA_VERSION"

VERDICT="$(node -e "const d=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));console.log(d.verdict)" "$FIXTURE")"
check_eq "[SC-002] verdict uses the SHIP|NO-SHIP vocabulary" "SHIP" "$VERDICT"

CONFIDENCE="$(node -e "const d=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));console.log(d.confidence)" "$FIXTURE")"
check_eq "[SC-002] confidence is within 0.0-1.0" "0.9" "$CONFIDENCE"

FINDINGS_DISCARDED="$(node -e "const d=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));console.log(d.findings.discarded)" "$FIXTURE")"
check_eq "[SC-004] findings.discarded counts refuted findings" "2" "$FINDINGS_DISCARDED"

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
  '{"change":"add-auth","ticket_id":"M-501-502","verdict":"SHIP","confidence":0.9,"timestamp":"2026-09-05T15:00:00Z","findings":{"total":3,"critical":0,"warnings":2,"info":1,"discarded":0}}'

expect_violation "[SC-002] rejects lowercase verdict (pre-M502 fragile format)" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"M-501-502","verdict":"ship","confidence":0.9,"timestamp":"2026-09-05T15:00:00Z","findings":{"total":3,"critical":0,"warnings":2,"info":1,"discarded":0}}'

expect_violation "[SC-002] rejects invalid verdict outside SHIP|NO-SHIP" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"M-501-502","verdict":"MAYBE","confidence":0.9,"timestamp":"2026-09-05T15:00:00Z","findings":{"total":3,"critical":0,"warnings":2,"info":1,"discarded":0}}'

expect_violation "[SC-002] rejects confidence out of range" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"M-501-502","verdict":"SHIP","confidence":1.5,"timestamp":"2026-09-05T15:00:00Z","findings":{"total":3,"critical":0,"warnings":2,"info":1,"discarded":0}}'

expect_violation "[SC-002] rejects non-ISO timestamp" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"M-501-502","verdict":"SHIP","confidence":0.9,"timestamp":"yesterday","findings":{"total":3,"critical":0,"warnings":2,"info":1,"discarded":0}}'

expect_violation "[SC-002] rejects findings.total mismatch" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"M-501-502","verdict":"SHIP","confidence":0.9,"timestamp":"2026-09-05T15:00:00Z","findings":{"total":5,"critical":1,"warnings":2,"info":1,"discarded":0}}'

expect_violation "[SC-002] rejects critical exceeding total" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"M-501-502","verdict":"NO-SHIP","confidence":0.4,"timestamp":"2026-09-05T15:00:00Z","findings":{"total":1,"critical":3,"warnings":0,"info":0,"discarded":0}}'

expect_violation "[SC-002] rejects negative findings counter" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"M-501-502","verdict":"SHIP","confidence":0.9,"timestamp":"2026-09-05T15:00:00Z","findings":{"total":3,"critical":0,"warnings":2,"info":1,"discarded":-1}}'

expect_violation "[SC-002] rejects findings as array instead of object" \
  '{"schema_version":1,"change":"add-auth","ticket_id":"M-501-502","verdict":"SHIP","confidence":0.9,"timestamp":"2026-09-05T15:00:00Z","findings":[3,0,2,1,0]}'

# --- Positive control: NO-SHIP verdicts are equally valid documents (SC-005) ---
printf '%s' '{"schema_version":1,"change":"add-auth","ticket_id":"M-501-502","verdict":"NO-SHIP","confidence":0.4,"timestamp":"2026-09-05T15:00:00Z","findings":{"total":2,"critical":2,"warnings":0,"info":0,"discarded":1}}' > "$NEGATIVE"
if node "$VALIDATOR" "$NEGATIVE" >/dev/null 2>&1; then
  ok "[SC-005] accepts a NO-SHIP verdict document"
else
  bad "[SC-005] accepts a NO-SHIP verdict document (validator rejected a valid document)"
fi

echo ""
echo "TDD tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
