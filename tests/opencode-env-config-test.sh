#!/usr/bin/env bash
# TDD self-test for the opencode-env-config change (FW-ENV).
#
# Validates (per openspec/changes/opencode-env-config/):
#   - SC-001: every apiKey under provider.*.options in opencode.json uses the
#     {env:VAR} interpolation syntax; no literal key remains (in particular the
#     former OmniRoute key string must be gone from the file)
#   - SC-002: .opencode/providers.example.json exists, is valid JSON, has
#     provider.openrouter.options.apiKey == "{env:OPENROUTER_API_KEY}" and
#     >= 3 openrouter models
#   - SC-003: docs/opencode-providers-config.md exists and mentions "{env:"
#     and "providers.example.json"
#   - SC-004: .env.example contains OMNIROUTE_API_KEY= and OPENROUTER_API_KEY=
#   - SC-005: docs/opencode-providers-config.md documents the behavior when the
#     env var is missing ("{env:" plus one of: no defini / ausente / falta)
#   - SC-006: bash check-refs.sh exits 0 (specboot.sh --ci is left to Task 5
#     to avoid recursion)
#
# Run: bash tests/opencode-env-config-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OPENCODE_JSON="$ROOT/opencode.json"
EXAMPLE_JSON="$ROOT/.opencode/providers.example.json"
GUIDE="$ROOT/docs/opencode-providers-config.md"
ENV_EXAMPLE="$ROOT/.env.example"

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

# --- SC-001: no literal apiKey in opencode.json ---
echo "opencode.json env interpolation (SC-001):"

check SC-001 "every apiKey under provider.*.options matches {env:VAR}" \
  python3 - "$OPENCODE_JSON" <<'PY'
import json, re, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
pattern = re.compile(r"^\{env:.+\}$")
for name, provider in data.get("provider", {}).items():
    options = provider.get("options", {})
    if "apiKey" in options:
        if not pattern.match(str(options["apiKey"])):
            sys.exit(1)
sys.exit(0)
PY

check SC-001 "former literal key string no longer present in opencode.json" \
  bash -c '! grep -qF "sk-aad2f9f3" "$1"' _ "$OPENCODE_JSON"

# --- SC-002: providers example file ---
echo "OpenRouter providers example (SC-002):"

check SC-002 ".opencode/providers.example.json exists" test -f "$EXAMPLE_JSON"
check SC-002 "example file is valid JSON with openrouter provider, env apiKey and >= 3 models" \
  python3 - "$EXAMPLE_JSON" <<'PY'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
provider = data.get("provider", {}).get("openrouter", {})
if provider.get("options", {}).get("apiKey") != "{env:OPENROUTER_API_KEY}":
    sys.exit(1)
if len(provider.get("models", {})) < 3:
    sys.exit(1)
sys.exit(0)
PY

# --- SC-003: documentation guide exists and references both artifacts ---
echo "Providers config guide (SC-003):"

check SC-003 "docs/opencode-providers-config.md exists" test -f "$GUIDE"
check SC-003 "guide mentions the {env: interpolation syntax and the example file" \
  has_all "$GUIDE" "{env:" "providers.example.json"

# --- SC-004: .env.example registers both variables ---
echo ".env.example variables (SC-004):"

check SC-004 ".env.example declares OMNIROUTE_API_KEY= and OPENROUTER_API_KEY=" \
  has_all "$ENV_EXAMPLE" "OMNIROUTE_API_KEY=" "OPENROUTER_API_KEY="

# --- SC-005: guide documents behavior when the variable is missing ---
echo "Missing-variable behavior documented (SC-005):"

check SC-005 "guide documents the missing-variable behavior (no defini / ausente / falta)" \
  bash -c 'f="$1"; [ -f "$f" ] && grep -qF "{env:" "$f" && (grep -qEi "no defini|ausente|falta" "$f")' _ "$GUIDE"

# --- SC-006: reference integrity ---
echo "check-refs.sh (SC-006):"

check SC-006 "bash check-refs.sh exits 0" bash "$ROOT/check-refs.sh"

# --- Summary ---
echo ""
echo "opencode-env-config: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
