#!/usr/bin/env bash
# TDD regression test for change fix-consumer-ci-yaml (SPECBOOT-HOTFIX-01,
# SC-001 + SC-002) — the distributed consumer CI workflow template must be
# valid YAML for GitHub Actions.
#
# Bug (shipped in 0.11.0): templates/github/workflows/consumer-ci.yml declared
# a step `name` as an unquoted plain scalar containing `: ` (`Project gate
# (make ci: refs + solid-lint + lint + test + audit)`). YAML forbids `: ` in a
# plain scalar, so GitHub Actions rejected the workflow with "Invalid workflow
# file: yaml syntax on line 42". The existing guards
# (consumer-ci-auth-test.sh, release-workflow-test.sh) only YAML-validate the
# repo's INTERNAL workflows (.github/workflows/*), never the distributed
# template — so the regression reached 0.11.0.
#
# Verifies that templates/github/workflows/consumer-ci.yml:
#   - [SC-001] parses as valid YAML (job `ci` creatable, no syntax error)
#   - [SC-002] has no unquoted `name` value containing `: ` (or ending with
#     `:`), reporting the ambiguous name and line if the ambiguity returns
#   - [SC-003] a consumer carrying the BROKEN 0.11.0 workflow (derived from
#     git history: git show v0.11.0:templates/github/workflows/consumer-ci.yml)
#     receives the CORRECTED template via `specboot update` and the resulting
#     YAML is valid (tri-state repair path: backed up into .specboot-backup-*/
#     before replacement)
#
#   NOTE (post-audit refinement): the transient [SC-004] scope asserts were
#   REMOVED from this permanent test (adversarial-review WARNING, 2026-09-24).
#   The change's scope constraint (REQ-005) is TRANSIENT: it is verified at
#   change level via the current diff review (documented by /verify), never as
#   a permanent constraint — baking it here would false-fail future changes
#   touching files outside this hotfix's allowlist or the internal workflows
#   against v0.11.0.
#
# Run: bash tests/consumer-ci-yaml-test.sh
# Exits 0 when all assertions pass, 1 otherwise.

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

WORKFLOW="templates/github/workflows/consumer-ci.yml"
SCRIPT="$ROOT/specboot.sh"

PASS=0
FAIL=0

pass() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

echo "🔍 Validating consumer CI template YAML validity (fix-consumer-ci-yaml)..."

# --- Precondition: file must exist ---
if [ ! -f "$WORKFLOW" ]; then
  echo "  ✗ consumer CI template does not exist: $WORKFLOW"
  exit 1
fi

# --- 1. [SC-001] YAML is valid (house pattern: python3 + PyYAML, loud failure
#        when the parser is unavailable — never a silent skip) ---
if python3 -c "import yaml; yaml.safe_load(open('$WORKFLOW'))" 2>/dev/null; then
  pass "[SC-001] consumer CI template parses as valid YAML"
else
  fail "[SC-001] consumer CI template is not valid YAML (GitHub Actions rejects it with 'Invalid workflow file')"
fi

# --- 2. [SC-002] no unquoted `name:` value contains ': ' ---
# A quoted name ("...: ...") is valid YAML and unambiguous. An unquoted plain
# scalar containing ': ' (or ending with ':') is rejected by the Actions YAML
# parser. The check is line-based (no regex-engine pitfalls with quote
# classes) and covers both step-level (`- name: ...`) and workflow-level
# (`name: ...`) declarations, excluding quoted values.
AMBIGUOUS="$(python3 - "$WORKFLOW" <<'PYEOF'
import sys

hits = []
for lineno, line in enumerate(open(sys.argv[1]), 1):
    stripped = line.strip()
    if stripped.startswith("- name:"):
        value = stripped[len("- name:"):].strip()
    elif stripped.startswith("name:"):
        value = stripped[len("name:"):].strip()
    else:
        continue
    if value.startswith('"') or value.startswith("'"):
        continue
    if ": " in value or value.endswith(":"):
        hits.append("%d: %s" % (lineno, stripped))
print("\n".join(hits))
PYEOF
)"
if [ -z "$AMBIGUOUS" ]; then
  pass "[SC-002] no unquoted step name contains ': ' (ambiguous YAML syntax)"
else
  fail "[SC-002] unquoted step name contains ': ' — GitHub Actions rejects the workflow; quote the value or rephrase without ': ': $AMBIGUOUS"
fi

# --- 3. [SC-003] a consumer with the BROKEN 0.11.0 workflow receives the
#        corrected template via `specboot update` and the resulting YAML is
#        valid. The fixture variant is derived from immutable git history
#        (the tag v0.11.0), never copied from the live template.
SC3_PROJ="$(mktemp -d)"
mkdir -p "$SC3_PROJ/.github/workflows" "$SC3_PROJ/docs"
printf '{"frameworkVersion":"0.11.0","name":"proj","description":"","services":["."],"stack":"framework"}\n' > "$SC3_PROJ/.specboot.json"
git show v0.11.0:templates/github/workflows/consumer-ci.yml > "$SC3_PROJ/.github/workflows/ci.yml"
git show v0.11.0:templates/github/workflows/consumer-ci.yml > /tmp/sc3-ci-orig.yml
( cd "$SC3_PROJ" && bash "$SCRIPT" update --template "$ROOT" --yes ) >/tmp/sc3-update.out 2>&1
if [ $? -eq 0 ]; then
  pass "[SC-003] update over the broken 0.11.0 ci.yml exits 0"
else
  fail "[SC-003] update over the broken 0.11.0 ci.yml failed (see /tmp/sc3-update.out)"
fi
# (a) The resulting YAML is valid — the regression-detecting core: if the
#     template ever reverts to the broken variant, update installs it and this
#     assert fails (the consumer would end with a workflow GitHub Actions
#     rejects with 'Invalid workflow file').
if python3 -c "import yaml; yaml.safe_load(open('$SC3_PROJ/.github/workflows/ci.yml'))" 2>/dev/null; then
  pass "[SC-003] resulting consumer ci.yml parses as valid YAML after update"
else
  fail "[SC-003] resulting consumer ci.yml is NOT valid YAML after update (a broken template reached the consumer)"
fi
# (b) The resulting content is the corrected current template
if cmp -s "$SC3_PROJ/.github/workflows/ci.yml" "$ROOT/templates/github/workflows/consumer-ci.yml"; then
  pass "[SC-003] consumer ci.yml replaced with the corrected template"
else
  fail "[SC-003] consumer ci.yml does NOT match the corrected template after update"
fi
# (c) The broken 0.11.0 variant was backed up before replacement (tri-state
#     repair path, docs/versioning-standard.md §5.1)
if ls "$SC3_PROJ"/.specboot-backup-*/.github/workflows/ci.yml >/dev/null 2>&1 \
  && cmp -s /tmp/sc3-ci-orig.yml "$SC3_PROJ"/.specboot-backup-*/.github/workflows/ci.yml; then
  pass "[SC-003] broken 0.11.0 variant backed up before replacement"
else
  fail "[SC-003] broken 0.11.0 variant NOT backed up before replacement (tri-state repair path broken)"
fi
# (d) Detection power: the fixture variant derived from git (v0.11.0) IS the
#     broken one — if git history drifts so the tag's template is valid, this
#     fails loudly instead of passing a vacuous test.
if grep -q 'name: Project gate (make ci: ' /tmp/sc3-ci-orig.yml; then
  pass "[SC-003] fixture variant derived from git is the broken 0.11.0 one (detection power)"
else
  fail "[SC-003] fixture variant derived from git is NOT the broken 0.11.0 one (fixture drift — detection power lost)"
fi
rm -rf "$SC3_PROJ" /tmp/sc3-ci-orig.yml

echo ""
echo "TDD tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
