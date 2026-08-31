#!/usr/bin/env bash
# TDD test for TICKET-6.1 — validates .github/workflows/release.yml structure.
#
# Verifies that release.yml:
#   - exists
#   - is valid YAML (yaml.safe_load)
#   - triggers on push to main AND on Release published
#   - has a `validate` job running check-refs.sh + specboot.sh --ci + make ci + tests/*.sh
#   - has a `publish` job with needs: validate, npm publish, NODE_AUTH_TOKEN, packages: write
#   - has NO hashFiles in job-level `if` (only at step level)
#   - does NOT invoke update.sh --bump
#   - uses actions/checkout@v5, actions/setup-node@v5, node-version: '24'
#
# Run: bash tests/release-workflow-test.sh
# Exits 0 when all assertions pass, 1 otherwise.

# NOTE: shellcheck disable=SC1090 — this script is intentionally self-contained.

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

WORKFLOW=".github/workflows/release.yml"

PASS=0
FAIL=0

pass() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

echo "🔍 Validating release.yml workflow (TICKET-6.1)..."

# --- Precondition: file must exist ---
if [ ! -f "$WORKFLOW" ]; then
  echo "  ✗ release.yml does not exist (RED)"
  exit 1
fi

# --- 1. YAML is valid ---
if python3 -c "import yaml; yaml.safe_load(open('$WORKFLOW'))" 2>/dev/null; then
  pass "release.yml parses as valid YAML"
else
  fail "release.yml is not valid YAML"
fi

# --- 2. Triggers on push to main ---
if grep -qE 'branches:\s*\[\s*main\s*\]|branches:\s*$' "$WORKFLOW" && grep -q 'push' "$WORKFLOW"; then
  pass "triggers on push (main branch)"
else
  fail "does not trigger on push to main"
fi

# --- 2b. Triggers on release published ---
if grep -q 'release:' "$WORKFLOW" && grep -q 'published' "$WORKFLOW"; then
  pass "triggers on release published"
else
  fail "does not trigger on release published"
fi

# --- 3. validate job exists ---
if grep -q 'validate:' "$WORKFLOW"; then
  pass "has validate job"
else
  fail "missing validate job"
fi

# --- 3b. validate runs check-refs.sh ---
if grep -q 'check-refs.sh' "$WORKFLOW"; then
  pass "validate runs check-refs.sh"
else
  fail "validate does not run check-refs.sh"
fi

# --- 3c. validate runs specboot.sh --ci ---
if grep -q 'specboot.sh --ci' "$WORKFLOW" || grep -q 'specboot.sh.*--ci' "$WORKFLOW"; then
  pass "validate runs specboot.sh --ci"
else
  fail "validate does not run specboot.sh --ci"
fi

# --- 3d. validate runs make ci ---
if grep -q 'make ci' "$WORKFLOW"; then
  pass "validate runs make ci"
else
  fail "validate does not run make ci"
fi

# --- 3e. validate runs tests/*.sh ---
if grep -q 'tests/' "$WORKFLOW" || grep -q 'tests/\*-test.sh' "$WORKFLOW" || grep -q 'hashFiles.*tests' "$WORKFLOW"; then
  pass "validate runs tests/*.sh"
else
  fail "validate does not run tests/*.sh"
fi

# --- 4. publish job exists with needs: validate ---
if grep -q 'publish:' "$WORKFLOW" && grep -q 'needs: validate' "$WORKFLOW"; then
  pass "publish job exists with needs: validate"
else
  fail "publish job missing or not dependent on validate"
fi

# --- 4b. publish runs npm publish ---
if grep -q 'npm publish' "$WORKFLOW"; then
  pass "publish runs npm publish"
else
  fail "publish does not run npm publish"
fi

# --- 4c. publish runs npm pack --dry-run ---
if grep -q 'npm pack.*dry-run' "$WORKFLOW"; then
  pass "publish runs npm pack --dry-run"
else
  fail "publish does not run npm pack --dry-run"
fi

# --- 4d. publish uses GITHUB_TOKEN ---
if grep -q 'NODE_AUTH_TOKEN' "$WORKFLOW" && grep -q 'GITHUB_TOKEN' "$WORKFLOW"; then
  pass "publish uses NODE_AUTH_TOKEN with GITHUB_TOKEN"
else
  fail "publish does not use NODE_AUTH_TOKEN with GITHUB_TOKEN"
fi

# --- 4e. permissions: packages: write ---
if grep -q 'packages: write' "$WORKFLOW"; then
  pass "has packages: write permission"
else
  fail "missing packages: write permission"
fi

# --- 5. No hashFiles in job-level if ---
# A job-level `if:` sits at exactly 4 spaces of indentation (under the job key).
# A step-level `if:` sits at 8+ spaces (under steps -> step). hashFiles is
# permitted only at step level. Match job-level specifically: ^    if: (4 spaces).
if grep -nE '^    if:.*hashFiles' "$WORKFLOW" 2>/dev/null; then
  fail "release.yml uses hashFiles in a job-level if"
else
  pass "no hashFiles in job-level if"
fi

# --- 6. Does NOT invoke update.sh --bump ---
if grep -q 'update\.sh' "$WORKFLOW"; then
  fail "workflow invokes update.sh (should not)"
else
  pass "does not invoke update.sh --bump"
fi

# --- 7. Publish if uses explicit parentheses for precedence ---
if grep -q '(github.event_name == .push.' "$WORKFLOW" && grep -q 'github.event_name == .release.' "$WORKFLOW"; then
  pass "publish if uses grouped parentheses for push-to-main OR release"
else
  fail "publish if does not use explicit parentheses for precedence"
fi

# --- 8. Uses actions/checkout@v5 ---
if grep -q 'actions/checkout@v5' "$WORKFLOW"; then
  pass "uses actions/checkout@v5"
else
  fail "does not use actions/checkout@v5"
fi

# --- 8b. Uses actions/setup-node@v5 ---
if grep -q 'actions/setup-node@v5' "$WORKFLOW"; then
  pass "uses actions/setup-node@v5"
else
  fail "does not use actions/setup-node@v5"
fi

# --- 8c. Uses node-version: '24' ---
if grep -q "node-version: '24'" "$WORKFLOW"; then
  pass "uses node-version: '24'"
else
  fail "does not use node-version: '24'"
fi

echo ""
echo "TDD tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
