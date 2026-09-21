#!/usr/bin/env bash
# TDD self-test for the permission contracts manifest and validator
# (SPECBOOT-PERM-01 — change agent-permission-contracts).
#
# Validated so far (per openspec/changes/agent-permission-contracts/...
#   specs/agent-permissions/spec.md):
#   - SC-001: contracts manifest exists at docs/agent-permission-contracts.yml
#     (REQ-001)
#   - SC-008: the manifest covers every agent under .opencode/agents/*.md —
#     a missing entry is a violation (REQ-001)
#   - REQ-001: every manifest entry declares editable paths, required bash
#     commands, forbidden operations, evidence files and the five capability
#     flags (can_commit, can_push, can_manage_prs, can_run_arbitrary_code,
#     can_spawn_subagents)
#   - SC-003/SC-004: verify and reviewer evidence files are exactly the
#     declared ones (openspec/state/verify-results.json resp.
#     openspec/state/adversarial-result.json)
#   - REQ-007: implementer agents (build, backend, frontend) carry a
#     non-empty justification
#
# The script must FAIL (RED) until tasks 1.x land.
#
# Run: bash tests/permission-contracts-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$ROOT/docs/agent-permission-contracts.yml"

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

# node_assert <script> — runs the embedded node assertion against the manifest
node_assert() {
  node -e "$1" "$ROOT" 2>/dev/null
}

# --- SC-001: manifest exists ---
echo "Permission contracts manifest (SC-001):"

check SC-001 "contracts manifest exists at docs/agent-permission-contracts.yml" \
  test -f "$MANIFEST"

# --- SC-008: manifest covers every agent + REQ-001 required keys ---
echo "Manifest coverage and structure (SC-008, REQ-001):"

check SC-008 "manifest covers every agent in .opencode/agents/" \
  node_assert '
const fs = require("fs"), path = require("path");
const yaml = require(path.join(process.argv[1], "node_modules", "js-yaml"));
const root = process.argv[1];
const manifestPath = path.join(root, "docs/agent-permission-contracts.yml");
if (!fs.existsSync(manifestPath)) process.exit(1);
const agentsDir = path.join(root, ".opencode", "agents");
let doc;
try { doc = yaml.load(fs.readFileSync(manifestPath, "utf8")); }
catch (e) { process.exit(1); }
if (!doc || typeof doc !== "object" || !doc.agents) process.exit(1);
const files = fs.readdirSync(agentsDir).filter(f => f.endsWith(".md")).map(f => f.slice(0, -3));
const missing = files.filter(a => !doc.agents[a]);
process.exit(missing.length === 0 ? 0 : 1);
'

check REQ-001 "every manifest entry declares the required contract keys" \
  node_assert '
const fs = require("fs"), path = require("path");
const yaml = require(path.join(process.argv[1], "node_modules", "js-yaml"));
const root = process.argv[1];
const doc = yaml.load(fs.readFileSync(path.join(root, "docs/agent-permission-contracts.yml"), "utf8"));
const flags = ["can_commit","can_push","can_manage_prs","can_run_arbitrary_code","can_spawn_subagents"];
for (const [name, cfg] of Object.entries(doc.agents || {})) {
  if (!cfg.edit || !Array.isArray(cfg.edit.allow) || !Array.isArray(cfg.edit.forbidden)) process.exit(1);
  if (!cfg.bash || !Array.isArray(cfg.bash.required) || !Array.isArray(cfg.bash.forbidden)) process.exit(1);
  if (!cfg.evidence || !Array.isArray(cfg.evidence.must_write)) process.exit(1);
  for (const f of flags) if (typeof cfg[f] !== "boolean") process.exit(1);
}
process.exit(0);
'

# --- SC-003/SC-004: evidence scoping of verify and reviewer ---
echo "Evidence scoping (SC-003, SC-004):"

check SC-004 "verify manifest entry persists only openspec/state/verify-results.json" \
  node_assert '
const fs = require("fs"), path = require("path");
const yaml = require(path.join(process.argv[1], "node_modules", "js-yaml"));
const root = process.argv[1];
const doc = yaml.load(fs.readFileSync(path.join(root, "docs/agent-permission-contracts.yml"), "utf8"));
const v = (doc.agents.verify || {});
const ok = v.evidence && v.evidence.must_write.length === 1
  && v.evidence.must_write[0] === "openspec/state/verify-results.json"
  && v.edit.allow.length === 1 && v.edit.allow[0] === "openspec/state/verify-results.json"
  && v.can_commit === false && v.can_push === false;
process.exit(ok ? 0 : 1);
'

check SC-003 "reviewer manifest entry persists only openspec/state/adversarial-result.json" \
  node_assert '
const fs = require("fs"), path = require("path");
const yaml = require(path.join(process.argv[1], "node_modules", "js-yaml"));
const root = process.argv[1];
const doc = yaml.load(fs.readFileSync(path.join(root, "docs/agent-permission-contracts.yml"), "utf8"));
const r = (doc.agents.reviewer || {});
const ok = r.evidence && r.evidence.must_write.length === 1
  && r.evidence.must_write[0] === "openspec/state/adversarial-result.json"
  && r.edit.allow.length === 1 && r.edit.allow[0] === "openspec/state/adversarial-result.json"
  && r.can_commit === false && r.can_push === false;
process.exit(ok ? 0 : 1);
'

# --- REQ-007: implementer justification ---
echo "Implementer justification (REQ-007):"

check REQ-007 "build, backend, frontend carry a non-empty justification" \
  node_assert '
const fs = require("fs"), path = require("path");
const yaml = require(path.join(process.argv[1], "node_modules", "js-yaml"));
const root = process.argv[1];
const doc = yaml.load(fs.readFileSync(path.join(root, "docs/agent-permission-contracts.yml"), "utf8"));
for (const name of ["build", "backend", "frontend"]) {
  const a = doc.agents[name];
  if (!a || typeof a.justification !== "string" || a.justification.trim().length < 40) process.exit(1);
}
process.exit(0);
'

# --- Task 2: validator over fixtures (REQ-002, REQ-008) ---
FIXTURES="$ROOT/tests/fixtures/permission-contracts"
VALIDATOR="$ROOT/scripts/validate-agent-permissions.mjs"

echo "Validator — fixtures (SC-002, SC-006, SC-008, SC-009):"

check SC-001 "validator script exists (scripts/validate-agent-permissions.mjs)" \
  test -f "$VALIDATOR"

check SC-002 "catch-all after exception fails (fixture bad-catchall)" \
  bash -c '! node "$1" --root "$2/bad-catchall" --manifest "$2/bad-catchall/manifest.yml" >/dev/null 2>&1' _ "$VALIDATOR" "$FIXTURES"

check SC-008 "missing required permission fails (fixture bad-missing-required)" \
  bash -c '! node "$1" --root "$2/bad-missing-required" --manifest "$2/bad-missing-required/manifest.yml" >/dev/null 2>&1' _ "$VALIDATOR" "$FIXTURES"

check SC-009 "exceeded edit scope fails (fixture bad-excess-scope)" \
  bash -c '! node "$1" --root "$2/bad-excess-scope" --manifest "$2/bad-excess-scope/manifest.yml" >/dev/null 2>&1' _ "$VALIDATOR" "$FIXTURES"

check SC-006 "force-push not effectively denied fails (fixture bad-force-push)" \
  bash -c '! node "$1" --root "$2/bad-force-push" --manifest "$2/bad-force-push/manifest.yml" >/dev/null 2>&1' _ "$VALIDATOR" "$FIXTURES"

check SC-001 "valid contract passes (fixture good)" \
  bash -c 'node "$1" --root "$2/good" --manifest "$2/good/manifest.yml" >/dev/null 2>&1' _ "$VALIDATOR" "$FIXTURES"

echo "Validator — reporting detail (REQ-008):"

check REQ-008 "failing fixture reports agent + capability + rule" \
  bash -c 'node "$1" --root "$2/bad-missing-required" --manifest "$2/bad-missing-required/manifest.yml" 2>&1 | grep -qiE "agent.*demo|demo.*capab"' _ "$VALIDATOR" "$FIXTURES"

check REQ-008 "discovered agent file missing from manifest is flagged (bad-unknown-agent)" \
  bash -c '! node "$1" --root "$2/good" --manifest "$2/bad-unknown-agent/manifest.yml" >/dev/null 2>&1' _ "$VALIDATOR" "$FIXTURES"

echo "Validator — dual execution dogfooding/consumidor (SC-010):"

check SC-010 "dogfooding: validator runs from repo against the good fixture manifest" \
  bash -c 'node "$1" --root "$2/good" --manifest "$2/good/manifest.yml" >/dev/null 2>&1' _ "$VALIDATOR" "$FIXTURES"

check SC-010 "consumer: validator runs from node_modules package without hoisted js-yaml" \
  bash -c '
set -e
ROOT="$1"; FIX="$2"
CONSUMER="$(mktemp -d)"
trap "rm -rf \"$CONSUMER\"" EXIT
# Paquete instalado: validador + manifiesto + su propia dependencia js-yaml
PKG="$CONSUMER/node_modules/@gabrielzavando/specboot"
mkdir -p "$PKG/scripts" "$PKG/docs" "$PKG/node_modules"
cp "$ROOT/scripts/validate-agent-permissions.mjs" "$PKG/scripts/"
cp "$FIX/good/manifest.yml" "$PKG/docs/agent-permission-contracts.yml"
cp -R "$ROOT/node_modules/js-yaml" "$PKG/node_modules/"
# El proyecto consumidor: agentes válidos pero SIN js-yaml en su raíz
mkdir -p "$CONSUMER/.opencode/agents"
cp "$FIX/good/.opencode/agents/demo.md" "$CONSUMER/.opencode/agents/"
! ls "$CONSUMER/node_modules/js-yaml" >/dev/null 2>&1 || exit 1
node "$PKG/scripts/validate-agent-permissions.mjs" --root "$CONSUMER" >/dev/null 2>&1
' _ "$ROOT" "$FIXTURES"

check SC-005 "ownership: git commit effectively denied for non-commit agent (fixture bad-ownership)" \
  bash -c '! node "$1" --root "$2/bad-ownership" --manifest "$2/bad-ownership/manifest.yml" >/dev/null 2>&1' _ "$VALIDATOR" "$FIXTURES"

# --- Task 3: real agent files must satisfy the manifest ---
echo "Validator — real agents against the manifest (SC-001, SC-003..SC-007):"

check SC-001 "all real agents in this repo satisfy the manifest" \
  bash -c 'node "$1/scripts/validate-agent-permissions.mjs" --root "$1" >/dev/null 2>&1' _ "$ROOT"

check SC-007 "scripts/read-json-field.mjs exists (read-only JSON field helper)" \
  test -f "$ROOT/scripts/read-json-field.mjs"

check SC-007 "read-json-field.mjs rejects files outside its closed allowlist" \
  bash -c '! node "$1/scripts/read-json-field.mjs" package.json name >/dev/null 2>&1' _ "$ROOT"

check SC-007 "read-json-field.mjs rejects fields outside its closed allowlist" \
  bash -c '! node "$1/scripts/read-json-field.mjs" openspec/state/verify-results.json password >/dev/null 2>&1' _ "$ROOT"

check SC-007 "read-json-field.mjs reads an allowed field (sandbox, nunca toca archivos del repo)" \
  bash -c '
HELPER="$1/scripts/read-json-field.mjs"
SBX="$(mktemp -d)"
trap "rm -rf \"$SBX\"" EXIT
mkdir -p "$SBX/openspec/state"
printf "{\"verdict\":\"PASS\"}" > "$SBX/openspec/state/verify-results.json"
cd "$SBX"
out="$(node "$HELPER" openspec/state/verify-results.json verdict 2>/dev/null)"
[ "$out" = "PASS" ]
' _ "$ROOT"

check SC-005 "archive agent no longer allows git add (ownership)" \
  bash -c '! grep -qF "\"git add *\": allow" "$1/.opencode/agents/archive.md"' _ "$ROOT"

check SC-007 "archive and commit no longer allow node -e *" \
  bash -c '! grep -qF "\"node -e *\": allow" "$1/.opencode/agents/archive.md" \
    && ! grep -qF "\"node -e *\": allow" "$1/.opencode/agents/commit.md"' _ "$ROOT"

# --- Task 4: CI integration + estructura requerida (REQ-009, REQ-011) ---
echo "CI integration (SC-001, REQ-009, REQ-011):"

check SC-001 "specboot.sh --ci muestra la sección de contratos de permisos" \
  bash -c 'bash "$1/specboot.sh" --ci 2>&1 | grep -qF "Verificando contratos de permisos de agentes"' _ "$ROOT"

check SC-001 "specboot.sh --ci pasa en verde con contratos conformes" \
  bash -c 'cd "$1" && bash specboot.sh --ci >/dev/null 2>&1' _ "$ROOT"

check REQ-011 "specboot.sh REQUIRED_FILES incluye el helper distribuido" \
  bash -c 'grep -qF "\"scripts/read-json-field.mjs\"" "$1/specboot.sh"' _ "$ROOT"

check REQ-011 "specboot.sh UPDATE_ITEMS incluye el helper (file-level)" \
  bash -c 'awk "/^UPDATE_ITEMS=\(/,/^\)/" "$1/specboot.sh" | grep -qF "\"scripts/read-json-field.mjs\""' _ "$ROOT"

check REQ-011 "package.json#files incluye validador, manifiesto y helper" \
  node_assert '
const fs = require("fs"), path = require("path");
const pkg = JSON.parse(fs.readFileSync(path.join(process.argv[1], "package.json"), "utf8"));
const f = pkg.files || [];
  const need = ["scripts/validate-agent-permissions.mjs", "scripts/read-json-field.mjs", "docs/agent-permission-contracts.yml"];
process.exit(need.every(n => f.includes(n)) ? 0 : 1);
'

check REQ-009 "run_ci invoca la verificación de contratos de permisos" \
  bash -c 'grep -qF "check_permission_contracts" "$1/specboot.sh"' _ "$ROOT"

check REQ-009 "specboot.sh --ci falla fail-closed cuando Node.js no está disponible" \
  bash -c '
ROOT="$1"
BIN=$(mktemp -d); trap "rm -rf \"$BIN\"" EXIT
# Stub PATH sin node: symlinks a las herramientas básicas, omitiendo node.
for c in bash grep awk sed cat tr head tail date ls cp mkdir mv rm dirname basename readlink wc sort uniq mktemp cut xargs; do
  p=$(command -v "$c" 2>/dev/null) && ln -s "$p" "$BIN/$c"
done
if env PATH="$BIN" command -v node >/dev/null 2>&1; then exit 1; fi
out=$(cd "$ROOT" && env PATH="$BIN" bash specboot.sh --ci 2>&1)
rc=$?
[ $rc -ne 0 ] || exit 1
printf "%s" "$out" | grep -qF "Verificando contratos de permisos de agentes" || exit 1
printf "%s" "$out" | grep -qiF "no disponible" || exit 1
' _ "$ROOT"

echo ""
echo "Permission contracts: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
