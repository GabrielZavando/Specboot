#!/usr/bin/env bash
# TDD self-test for the commit hard evidence gates (M-901 — change enforce-commit-gates).
#
# Validates the decision-matrix contract declared in
# openspec/changes/enforce-commit-gates/specs/commit-gates/spec.md:
#   - /commit proceeds ONLY with verify status PASS + adversarial verdict SHIP,
#     both matching the active change (field `change`)
#   - PARTIAL / FAIL / NO-SHIP / missing / invalid / foreign evidence BLOCKS,
#     offering re-run, abort, or --force — never a blind question
#   - --force bypass is registered via the git trailer
#     `Gate-Bypass: --force (verify=<...>; adversarial=<...>)`
#   - staleness stays warn-only; reading is token-light (node -e, never jq)
#   - descriptions stay synchronized with the contract (M-403 lesson, SC-011)
#
# Contract markers are asserted against ai-specs/skills/commit/SKILL.md and the
# state-matrix fixtures in ai-specs/examples/commit-gate-fixtures/ (task 1.2).
# The script must FAIL (RED) until tasks 1.2/1.3/1.4 land.
#
# JSON parsing uses node (framework convention: "node -e, nunca jq" — Makefile).
#
# Run: bash tests/commit-gate-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT/ai-specs/skills/commit/SKILL.md"
FIXTURES="$ROOT/ai-specs/examples/commit-gate-fixtures"

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

# lacks_all <file> <token> [<token>...] — none of the tokens may appear
lacks_all() {
  local file="$1"; shift
  local tok
  for tok in "$@"; do
    if grep -qF -- "$tok" "$file"; then
      return 1
    fi
  done
  return 0
}

# --- Precondition (RED before implementation): fixtures must exist ---
if [ ! -d "$FIXTURES" ]; then
  echo "  ✗ ai-specs/examples/commit-gate-fixtures/ does not exist yet (RED)"
  exit 1
fi

MISSING_FIXTURE=0
for f in verify-pass.json verify-partial.json verify-fail.json verify-foreign.json \
         verify-invalid.json adversarial-ship.json adversarial-no-ship.json adversarial-foreign.json; do
  if [ ! -f "$FIXTURES/$f" ]; then
    echo "  ✗ fixture missing: $f (RED — task 1.2)"
    MISSING_FIXTURE=1
  fi
done
if [ "$MISSING_FIXTURE" -ne 0 ]; then
  exit 1
fi

# --- node is required for JSON validation (framework convention) ---
if ! command -v node >/dev/null 2>&1; then
  echo "  ✗ node is required but not installed"
  exit 1
fi

# --- Inline fixture validator (schema_version: 1 contracts) ---
# Usage: node validator <file> <verify|adversarial> [invalid | <field> <value>]
#   invalid           → the file MUST fail to parse (matrix state: invalid JSON)
#   <field> <value>   → schema-valid AND d[field] === value (matrix role check)
VALIDATOR="$(mktemp /tmp/commit-gate-validator.XXXXXX.js)"
trap 'rm -f "$VALIDATOR"' EXIT

cat > "$VALIDATOR" <<'EOF'
#!/usr/bin/env node
// Fixture validator for the commit-gate state matrix (schema_version: 1).
'use strict';
const fs = require('fs');

const [, , file, type, field, value] = process.argv;
let raw;
try {
  raw = fs.readFileSync(file, 'utf8');
} catch (e) {
  console.error('unreadable: ' + e.message);
  process.exit(2);
}

if (field === 'invalid') {
  try {
    JSON.parse(raw);
    console.error('expected invalid JSON but it parsed');
    process.exit(1);
  } catch (e) {
    process.exit(0); // intended invalid state confirmed
  }
}

let d;
try {
  d = JSON.parse(raw);
} catch (e) {
  console.error('invalid JSON: ' + e.message);
  process.exit(1);
}

const violations = [];
const add = (m) => violations.push(m);
const isInt = (n) => typeof n === 'number' && Number.isInteger(n) && n >= 0;
const iso = (t) => typeof t === 'string' && !Number.isNaN(Date.parse(t));

if (d.schema_version !== 1) add('schema_version must be 1');
for (const k of ['change', 'ticket_id', 'timestamp']) {
  if (typeof d[k] !== 'string' || d[k].length === 0) add(`missing key: ${k}`);
}
if (!iso(d.timestamp)) add('timestamp is not ISO-8601');

if (type === 'verify') {
  if (!['PASS', 'PARTIAL', 'FAIL'].includes(d.status)) add('status must be PASS|PARTIAL|FAIL');
  if (!['executable', 'static'].includes(d.evidence_mode)) add('evidence_mode must be executable|static');
  const t = d.tasks || {};
  for (const k of ['total', 'passed', 'failed', 'untested']) {
    if (!isInt(t[k])) add(`tasks.${k} must be a non-negative integer`);
  }
  if (isInt(t.total) && t.total !== t.passed + t.failed + t.untested) {
    add('invariant broken: tasks.total != passed + failed + untested');
  }
  if (!Array.isArray(d.scenarios)) add('scenarios must be an array');
} else if (type === 'adversarial') {
  if (!['SHIP', 'NO-SHIP'].includes(d.verdict)) add('verdict must be SHIP|NO-SHIP');
  if (typeof d.confidence !== 'number' || d.confidence < 0 || d.confidence > 1) {
    add('confidence must be a number in 0.0-1.0');
  }
  const f = d.findings || {};
  for (const k of ['total', 'critical', 'warnings', 'info', 'discarded']) {
    if (!isInt(f[k])) add(`findings.${k} must be a non-negative integer`);
  }
  if (isInt(f.total) && isInt(f.critical)) {
    if (f.critical > f.total) add('invariant broken: critical > total');
    if (f.total !== f.critical + f.warnings + f.info) {
      add('invariant broken: total != critical + warnings + info');
    }
  }
} else {
  add('unknown fixture type: ' + type);
}

if (field && value && field !== 'invalid') {
  if (d[field] !== value) add(`matrix role mismatch: ${field} expected '${value}', got '${JSON.stringify(d[field])}'`);
}

if (violations.length) {
  violations.forEach((v) => console.error(v));
  process.exit(1);
}
process.exit(0);
EOF

# --- A. State-matrix fixtures (schema-valid, each in its matrix role) ---
echo "State-matrix fixtures (schema_version: 1):"

if node "$VALIDATOR" "$FIXTURES/verify-pass.json" verify status PASS 2>/dev/null; then
  ok "[SC-001] verify-pass.json is valid evidence (status PASS)"
else
  bad "[SC-001] verify-pass.json is valid evidence (status PASS)"
fi

if node "$VALIDATOR" "$FIXTURES/verify-partial.json" verify status PARTIAL 2>/dev/null; then
  ok "[SC-002] verify-partial.json is valid evidence (status PARTIAL)"
else
  bad "[SC-002] verify-partial.json is valid evidence (status PARTIAL)"
fi

if node "$VALIDATOR" "$FIXTURES/verify-fail.json" verify status FAIL 2>/dev/null; then
  ok "[SC-002] verify-fail.json is valid evidence (status FAIL)"
else
  bad "[SC-002] verify-fail.json is valid evidence (status FAIL)"
fi

if node "$VALIDATOR" "$FIXTURES/verify-foreign.json" verify change other-change 2>/dev/null; then
  ok "[SC-003] verify-foreign.json is valid evidence (foreign change)"
else
  bad "[SC-003] verify-foreign.json is valid evidence (foreign change)"
fi

if node "$VALIDATOR" "$FIXTURES/verify-invalid.json" verify invalid 2>/dev/null; then
  ok "[SC-003] verify-invalid.json is invalid JSON as intended"
else
  bad "[SC-003] verify-invalid.json is invalid JSON as intended"
fi

if node "$VALIDATOR" "$FIXTURES/adversarial-ship.json" adversarial verdict SHIP 2>/dev/null; then
  ok "[SC-001] adversarial-ship.json is valid evidence (verdict SHIP)"
else
  bad "[SC-001] adversarial-ship.json is valid evidence (verdict SHIP)"
fi

if node "$VALIDATOR" "$FIXTURES/adversarial-no-ship.json" adversarial verdict NO-SHIP 2>/dev/null; then
  ok "[SC-004] adversarial-no-ship.json is valid evidence (verdict NO-SHIP)"
else
  bad "[SC-004] adversarial-no-ship.json is valid evidence (verdict NO-SHIP)"
fi

if node "$VALIDATOR" "$FIXTURES/adversarial-foreign.json" adversarial change other-change 2>/dev/null; then
  ok "[SC-005] adversarial-foreign.json is valid evidence (foreign change)"
else
  bad "[SC-005] adversarial-foreign.json is valid evidence (foreign change)"
fi

# --- B. Hard-gate contract markers in the commit skill ---
echo "Commit skill contract (ai-specs/skills/commit/SKILL.md):"

if grep -qF -- "gates duros" "$SKILL"; then
  ok "[SC-001] Step 2 declares the hard evidence gateway (gates duros)"
else
  bad "[SC-001] Step 2 declares the hard evidence gateway (gates duros)"
fi

if has_all "$SKILL" 'status: "PASS"' 'verdict: "SHIP"' 'coincide con el change de referencia'; then
  ok "[SC-001] proceeds only with PASS + SHIP matching the reference change"
else
  bad "[SC-001] proceeds only with PASS + SHIP matching the reference change"
fi

if has_all "$SKILL" 'PARTIAL' 'FAIL' 'bloquea y ofrece' '--force'; then
  ok "[SC-002] blocks on PARTIAL/FAIL offering re-run, abort or --force"
else
  bad "[SC-002] blocks on PARTIAL/FAIL offering re-run, abort or --force"
fi

if has_all "$SKILL" 'ausente, inválida o ajena' 'bloquea y ofrece'; then
  ok "[SC-003] blocks when verify evidence is missing, invalid or foreign"
else
  bad "[SC-003] blocks when verify evidence is missing, invalid or foreign"
fi

if grep -qF -- "no pregunta a ciegas" "$SKILL"; then
  ok "[SC-003] never falls back to the blind pre-M-401 question"
else
  bad "[SC-003] never falls back to the blind pre-M-401 question"
fi

if has_all "$SKILL" 'NO-SHIP' 'bloquea y ofrece' '/adversarial-review'; then
  ok "[SC-004] blocks on NO-SHIP offering re-audit, abort or --force"
else
  bad "[SC-004] blocks on NO-SHIP offering re-audit, abort or --force"
fi

if grep -qF -- "deja de ser opcional" "$SKILL"; then
  ok "[SC-005] adversarial absence/foreignness blocks (no longer optional)"
else
  bad "[SC-005] adversarial absence/foreignness blocks (no longer optional)"
fi

if grep -qF -- "Gate-Bypass: --force (verify=" "$SKILL"; then
  ok "[SC-006] registers the bypass with the Gate-Bypass trailer"
else
  bad "[SC-006] registers the bypass with the Gate-Bypass trailer"
fi

if grep -qF -- "no se emite" "$SKILL"; then
  ok "[SC-006] emits no trailer when gates pass"
else
  bad "[SC-006] emits no trailer when gates pass"
fi

if has_all "$SKILL" 'staleness' 'warn-only'; then
  ok "[SC-007] staleness check is warn-only"
else
  bad "[SC-007] staleness check is warn-only"
fi

if has_all "$SKILL" 'change de referencia' 'recién archivado' 'prefijo de fecha'; then
  ok "[SC-012] post-archive commit resolves the reference change from the just-archived change"
else
  bad "[SC-012] post-archive commit resolves the reference change from the just-archived change"
fi

if grep -qF -- "node -e" "$SKILL" && ! grep -qw "jq" "$SKILL"; then
  ok "[SC-001] token-light reading via node -e (never jq)"
else
  bad "[SC-001] token-light reading via node -e (never jq)"
fi

# --- C. Stale soft-gate wording must be gone ---
echo "Stale soft-gate wording removed:"

if lacks_all "$SKILL" '¿Ejecutaste' 'no bloquea ni exige pregunta' 'gates informados suaves' 'es M-901'; then
  ok "[SC-003] blind question, soft-gate title and future-gate wording removed"
else
  bad "[SC-003] blind question, soft-gate title and future-gate wording removed"
fi

# --- D. Description sync (M-403 lesson, SC-011) ---
echo "Description sync (SC-011):"

if grep -F -- '/commit' "$ROOT/AGENTS.md" | grep -F -- '--force' | grep -qiF 'gate'; then
  ok "[SC-011] AGENTS.md /commit row declares hard gates + --force"
else
  bad "[SC-011] AGENTS.md /commit row declares hard gates + --force"
fi

if lacks_all "$ROOT/ai-specs/skills/verify/SKILL.md" 'gate informado suave' 'M-901 (futuro' 'futuro, junto con'; then
  ok "[SC-011] verify skill consumer note declares the hard gate"
else
  bad "[SC-011] verify skill consumer note declares the hard gate"
fi

if lacks_all "$ROOT/ai-specs/skills/archive/SKILL.md" 'el gate duro es M-901'; then
  ok "[SC-011] archive skill references the active hard gate"
else
  bad "[SC-011] archive skill references the active hard gate"
fi

if lacks_all "$ROOT/ai-specs/skills/code-auditing/SKILL.md" 'es M-901 en'; then
  ok "[SC-011] code-auditing skill references the active hard gate"
else
  bad "[SC-011] code-auditing skill references the active hard gate"
fi

if grep -qF -- '--force' "$ROOT/.opencode/commands/commit.md"; then
  ok "[SC-011] commit command description declares the gates"
else
  bad "[SC-011] commit command description declares the gates"
fi

# --- Summary ---
echo ""
echo "Commit gate contract: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
