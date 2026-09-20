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

echo ""
echo "Permission contracts: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
