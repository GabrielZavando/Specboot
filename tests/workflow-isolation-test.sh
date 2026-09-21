#!/usr/bin/env bash
# TDD test for SPECBOOT-HARDEN-02 — workflow isolation (REQ-001/REQ-003).
#
# SC-001: a fresh project receives the consumer CI workflow + PR template, but
#         NOT release.yml nor the internal publish workflow.
# SC-004: `npm pack --dry-run` contains no internal workflows under
#         .github/workflows/**, and includes the consumer templates under
#         templates/github/.
#
# Run: bash tests/workflow-isolation-test.sh
# Exits 0 on success, 1 when the contract is violated (RED before impl).

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/specboot.sh"
cd "$ROOT"

PASS=0
FAIL=0
ok()   { echo "  ✓ $1"; PASS=$((PASS + 1)); }
bad()  { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }
have() { local p="$1"; [ -e "$p" ]; }

echo "🔍 Workflow isolation (SPECBOOT-HARDEN-02, REQ-001/REQ-003)..."

# --- SC-004: npm tarball excludes internal workflows, includes templates ---
TARBALL_JSON="$(npm pack --dry-run --json 2>/dev/null)"
TARBALL_FILES="$(printf '%s' "$TARBALL_JSON" | node -e '
let s = "";
process.stdin.on("data", d => (s += d)).on("end", () => {
  const packs = JSON.parse(s);
  const arr = Array.isArray(packs) ? packs : [packs];
  const files = (arr[0] && arr[0].files ? arr[0].files : []).map(f => f.path);
  process.stdout.write(files.join("\n"));
});
')"

if printf '%s\n' "$TARBALL_FILES" | grep -q '^\.github/'; then
  bad "[SC-004] tarball MUST NOT contain any .github/** file (found internal workflows)"
else
  ok  "[SC-004] tarball contains no .github/** (internal workflows excluded)"
fi

for tpl in \
  templates/github/workflows/consumer-ci.yml \
  templates/github/workflows/deploy.example.yml \
  templates/github/pull_request_template.md; do
  if printf '%s\n' "$TARBALL_FILES" | grep -qx "$tpl"; then
    ok  "[SC-004] tarball includes $tpl"
  else
    bad "[SC-004] tarball MISSING consumer template: $tpl"
  fi
done

# --- SC-001: fresh init installs consumer CI + PR template, not release.yml ---
TMP="$(mktemp -d)"
( cd "$TMP" && bash "$SCRIPT" init ) >/tmp/wf-init.out 2>&1

have "$TMP/.github/workflows/ci.yml" \
  && ok  "[SC-001] init installs consumer CI workflow (.github/workflows/ci.yml)" \
  || bad "[SC-001] init did NOT install .github/workflows/ci.yml"

have "$TMP/.github/pull_request_template.md" \
  && ok  "[SC-001] init installs PR template (.github/pull_request_template.md)" \
  || bad "[SC-001] init did NOT install .github/pull_request_template.md"

if have "$TMP/.github/workflows/release.yml"; then
  bad "[SC-001] init MUST NOT install release.yml (internal publish workflow leaked)"
else
  ok  "[SC-001] no release.yml installed by init"
fi

if have "$TMP/.github/workflows/deploy.yml"; then
  bad "[SC-001] init MUST NOT install the internal deploy.yml workflow"
else
  ok  "[SC-001] no internal deploy.yml installed by init"
fi

# The only workflows a fresh project should have is the consumer CI.
N_WF="$(find "$TMP/.github/workflows" -maxdepth 1 -name '*.yml' 2>/dev/null | wc -l | tr -d ' ')"
if [ "$N_WF" = "1" ]; then
  ok  "[SC-001] fresh project has exactly one workflow (consumer CI)"
else
  bad "[SC-001] expected exactly 1 workflow in .github/workflows, found $N_WF"
fi

rm -rf "$TMP"

echo ""
echo "workflow-isolation: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
