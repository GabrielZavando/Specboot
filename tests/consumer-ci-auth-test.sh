#!/usr/bin/env bash
# TDD test for change fix-consumer-mode (SC-004) — consumer authentication
# wiring for GitHub Packages in the distributed ci.yml.
#
# Bug: the ci.yml shipped to consumers (replaced file-by-file by
# `specboot update`) lacked the three auth links documented in the README
# ("Vía A"): permissions `packages: read`, env `NODE_AUTH_TOKEN`, and
# `registry-url` in setup-node — so consumer `npm install` hit E401 on
# npm.pkg.github.com. Each update reintroduced the regression.
#
# Verifies that .github/workflows/ci.yml:
#   - is valid YAML
#   - [SC-004] declares `packages: read` (workflow-level permissions)
#   - [SC-004] declares NODE_AUTH_TOKEN with secrets.GITHUB_TOKEN
#   - [SC-004] sets registry-url: https://npm.pkg.github.com in BOTH jobs
#   - keeps the standing contracts (counter-regressions):
#       jobs `validate` + `project-ci`, `make ci` gate, setup-node@v5,
#       node-version: '24', step-level hashFiles
#
# Run: bash tests/consumer-ci-auth-test.sh
# Exits 0 when all assertions pass, 1 otherwise.

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

WORKFLOW=".github/workflows/ci.yml"

PASS=0
FAIL=0

pass() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

count() { grep -c "$1" "$WORKFLOW" 2>/dev/null || true; }

echo "🔍 Validating ci.yml consumer auth wiring (fix-consumer-mode / SC-004)..."

# --- Precondition: file must exist ---
if [ ! -f "$WORKFLOW" ]; then
  echo "  ✗ ci.yml does not exist"
  exit 1
fi

# --- 1. YAML is valid ---
if python3 -c "import yaml; yaml.safe_load(open('$WORKFLOW'))" 2>/dev/null; then
  pass "ci.yml parses as valid YAML"
else
  fail "ci.yml is not valid YAML"
fi

# --- 2. [SC-004] permissions include packages: read (workflow level) ---
if grep -qE '^\s*packages:\s*read\s*$' "$WORKFLOW"; then
  pass "[SC-004] permissions declare packages: read"
else
  fail "[SC-004] permissions do not declare packages: read (consumer GITHUB_TOKEN cannot read the package)"
fi

# --- 2b. contents: read is preserved ---
if grep -qE '^\s*contents:\s*read\s*$' "$WORKFLOW"; then
  pass "permissions keep contents: read"
else
  fail "permissions lost contents: read"
fi

# --- 3. [SC-004] NODE_AUTH_TOKEN wired to the runner-provided GITHUB_TOKEN ---
if grep -q 'NODE_AUTH_TOKEN' "$WORKFLOW" && grep -q 'secrets.GITHUB_TOKEN' "$WORKFLOW"; then
  pass "[SC-004] NODE_AUTH_TOKEN is wired to secrets.GITHUB_TOKEN"
else
  fail "[SC-004] NODE_AUTH_TOKEN / secrets.GITHUB_TOKEN missing (npm reaches GitHub Packages without credentials)"
fi

# --- 4. [SC-004] registry-url in BOTH jobs' setup-node ---
REG_COUNT="$(count 'registry-url: https://npm.pkg.github.com')"
if [ "${REG_COUNT:-0}" -ge 2 ]; then
  pass "[SC-004] registry-url: https://npm.pkg.github.com declared in both jobs ($REG_COUNT occurrences)"
else
  fail "[SC-004] registry-url declared in fewer than 2 setup-node steps (got $REG_COUNT, need 2: validate + project-ci)"
fi

# --- Counter-regressions: standing contracts must survive the change ---
if grep -q '^  validate:' "$WORKFLOW" && grep -q '^  project-ci:' "$WORKFLOW"; then
  pass "both jobs (validate + project-ci) still declared"
else
  fail "job structure changed: validate/project-ci missing"
fi

if grep -q 'run: make ci' "$WORKFLOW"; then
  pass "project-ci still runs the make ci gate"
else
  fail "project-ci no longer runs make ci"
fi

SETUP_COUNT="$(count 'actions/setup-node@v5')"
if [ "${SETUP_COUNT:-0}" -ge 2 ]; then
  pass "actions/setup-node@v5 still used in both jobs ($SETUP_COUNT occurrences)"
else
  fail "actions/setup-node@v5 count dropped (got $SETUP_COUNT, need 2)"
fi

NODE_COUNT="$(count "node-version: '24'")"
if [ "${NODE_COUNT:-0}" -ge 2 ]; then
  pass "node-version: '24' still pinned in both jobs ($NODE_COUNT occurrences)"
else
  fail "node-version: '24' count dropped (got $NODE_COUNT, need 2)"
fi

if grep -q 'hashFiles' "$WORKFLOW"; then
  pass "step-level hashFiles self-test gate preserved"
else
  fail "step-level hashFiles self-test gate lost"
fi

echo ""
echo "TDD tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
