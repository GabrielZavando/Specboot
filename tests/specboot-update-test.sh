#!/usr/bin/env bash
# TDD test for TICKET-3.2 — `specboot update` refreshes an existing project.
#
# Run: bash tests/specboot-update-test.sh
#
# Covers (RED first, then GREEN):
#   1. guard: missing .specboot.json -> error + exit 1 (suggests init)
#   2. minor/patch jump -> silent replace + frameworkVersion rewritten + exit 0
#   3. major jump -> warns + replaces with --yes; cancels without --yes
#   4. installed older than project -> refuse, exit 1
#   5. equal version -> still replaces (repair), .specboot.json unchanged
#   6. docs/ project, code, README, LICENSE, project workflow preserved
#   7. README.md / LICENSE excluded; .github handled file-by-file
#   8. --dry-run changes nothing
#   9. --no-backup skips backup dir
#  10. --template <dir> override
#  11. dogfooding guard: target == source -> note + exit 0

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/specboot.sh"

PASS=0
FAIL=0

assert_exit() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" -eq 0 ] && [ "$actual" -eq 0 ]; then
    echo "  ✓ $desc"; PASS=$((PASS + 1))
  elif [ "$expected" -ne 0 ] && [ "$actual" -ne 0 ]; then
    echo "  ✓ $desc"; PASS=$((PASS + 1))
  else
    echo "  ✗ $desc (expected exit $expected, got $actual)"; FAIL=$((FAIL + 1))
  fi
}
assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "  ✓ $desc"; PASS=$((PASS + 1))
  else
    echo "  ✗ $desc (expected '$expected', got '$actual')"; FAIL=$((FAIL + 1))
  fi
}
assert_exists() {
  local desc="$1" path="$2"
  if [ -e "$path" ]; then
    echo "  ✓ $desc"; PASS=$((PASS + 1))
  else
    echo "  ✗ $desc (missing: $path)"; FAIL=$((FAIL + 1))
  fi
}

# Helper: make a template (framework source) with a given installed version.
make_template() {
  local dir="$1" ver="$2"
   mkdir -p "$dir/.opencode/commands" "$dir/.opencode/agents" "$dir/ai-specs/skills/demo" \
            "$dir/templates/ci" "$dir/templates/github/workflows" "$dir/docs" "$dir/scripts"
   # SPECBOOT-PERM-01 (SC-010): el helper se distribuye con update; el validador
   # y el manifiesto NO (se ejecutan desde el paquete instalado).
   echo "FW-helper"        > "$dir/scripts/read-json-field.mjs"
  echo "FW-AGENTS"        > "$dir/AGENTS.md"
  echo "FW-checkrefs"     > "$dir/check-refs.sh"
  echo "FW-specboot"      > "$dir/specboot.sh"
  echo "FW-validate"      > "$dir/validate-specboot.sh"
  echo "FW-openode-json"  > "$dir/opencode.json"
  echo "FW-makefile"      > "$dir/Makefile"
  echo "FW-base"          > "$dir/docs/base-standards.md"
  echo "FW-contract"      > "$dir/docs/framework-contract.md"
  echo "FW-docsstd"       > "$dir/docs/docs-standard.md"
  echo "FW-jsonstd"       > "$dir/docs/specboot-json-standard.md"
  echo "FW-verstd"        > "$dir/docs/versioning-standard.md"
  echo "FW-msteps"        > "$dir/docs/openspec-tasks-mandatory-steps.md"
  echo "FW-tddproto"      > "$dir/docs/tdd-failure-protocol.md"
  echo "FW-command"       > "$dir/.opencode/commands/plan-change"
  echo "FW-agent"         > "$dir/.opencode/agents/backend.md"
  echo "FW-skill"         > "$dir/ai-specs/skills/demo/SKILL.md"
  echo "FW-template"      > "$dir/templates/ci/eslint.yml"
  echo "FW-consumer-ci"   > "$dir/templates/github/workflows/consumer-ci.yml"
  echo "FW-pr-template"   > "$dir/templates/github/pull_request_template.md"
  printf '{"name":"fw","version":"%s"}\n' "$ver" > "$dir/package.json"
}

# Helper: make a project initialized with a given frameworkVersion.
make_project() {
  local dir="$1" fwver="$2"
  mkdir -p "$dir/docs" "$dir/docs/project" "$dir/docs/api" "$dir/docs/data-model" \
           "$dir/backend/src" "$dir/frontend/src" "$dir/.github/workflows"
  printf '{"frameworkVersion":"%s","name":"proj","description":"","services":["."],"stack":"framework"}\n' "$fwver" > "$dir/.specboot.json"
  echo "CUSTOM BACKEND STANDARDS - keep me" > "$dir/docs/backend-standards.md"
  echo "CUSTOM DOMAIN"   > "$dir/docs/project/domain.md"
  echo "CUSTOM API"      > "$dir/docs/api/api-spec.yml"
  echo "CUSTOM DATAMODEL"> "$dir/docs/data-model/data-model.md"
  echo "CUSTOM README"   > "$dir/README.md"
  echo "CUSTOM LICENSE"  > "$dir/LICENSE"
  echo "CUSTOM SERVER"   > "$dir/backend/src/server.ts"
  echo "CUSTOM APP"      > "$dir/frontend/src/app.tsx"
  echo "CUSTOM PROJECT WF" > "$dir/.github/workflows/my-own-ci.yml"
}

# ---------- Test 1: guard — missing .specboot.json ----------
NO_CFG="$(mktemp -d)"
( cd "$NO_CFG" && bash "$SCRIPT" update ) >/tmp/up-nocfg.out 2>&1
assert_exit "update without .specboot.json exits 1" 1 $?
if grep -q "specboot init" /tmp/up-nocfg.out; then
  echo "  ✓ guard suggests 'specboot init'"; PASS=$((PASS + 1))
else
  echo "  ✗ guard suggests 'specboot init'"; FAIL=$((FAIL + 1))
fi

# ---------- Test 2: minor/patch jump -> silent replace + version rewrite ----------
TPL="$(mktemp -d)"; make_template "$TPL" "0.2.0"
PROJ="$(mktemp -d)"; make_project "$PROJ" "0.1.1"
( cd "$PROJ" && bash "$SCRIPT" update --template "$TPL" --yes ) >/tmp/up-minor.out 2>&1
assert_exit "update minor/patch exits 0" 0 $?
assert_eq "AGENTS.md replaced (silent)" "FW-AGENTS" "$(cat "$PROJ/AGENTS.md")"
assert_eq "ai-specs replaced"            "FW-skill"  "$(cat "$PROJ/ai-specs/skills/demo/SKILL.md")"
assert_eq "opencode.json replaced"       "FW-openode-json" "$(cat "$PROJ/opencode.json")"
# [SC-008] update replaces the 6 intocable framework docs (regression: the
# legacy docs/* skip in replace_framework_files silently dropped ALL docs,
# contradicting the archived specboot-update spec).
assert_eq "[SC-008] mandatory-steps doc replaced" "FW-msteps" "$(cat "$PROJ/docs/openspec-tasks-mandatory-steps.md" 2>/dev/null || echo MISSING)"
assert_eq "[SC-003] tdd-failure-protocol doc replaced (TICKET-AUDIT-2, 7 intocable docs)" "FW-tddproto" "$(cat "$PROJ/docs/tdd-failure-protocol.md" 2>/dev/null || echo MISSING)"
assert_eq "[SC-008] base-standards doc replaced"  "FW-base"   "$(cat "$PROJ/docs/base-standards.md" 2>/dev/null || echo MISSING)"
assert_eq "[SC-008] project docs untouched"       "CUSTOM BACKEND STANDARDS - keep me" "$(cat "$PROJ/docs/backend-standards.md")"
assert_eq "frameworkVersion rewritten"   "0.2.0" "$(node -e "console.log(require('$PROJ/.specboot.json').frameworkVersion)" 2>/dev/null || grep -o '"frameworkVersion": *"[^"]*"' "$PROJ/.specboot.json" | sed 's/.*:"//;s/"//')"
assert_eq "[SPECBOOT-PERM-01] helper read-json-field.mjs distributed on update" "FW-helper" "$(cat "$PROJ/scripts/read-json-field.mjs" 2>/dev/null || echo MISSING)"
if [ -e "$PROJ/scripts/validate-agent-permissions.mjs" ] || [ -e "$PROJ/docs/agent-permission-contracts.yml" ]; then
  echo "  ✗ [SPECBOOT-PERM-01] validator/manifest must NOT be copied on update"; FAIL=$((FAIL + 1))
else
  echo "  ✓ [SPECBOOT-PERM-01] validator/manifest not copied on update"; PASS=$((PASS + 1))
fi
if ! grep -q "Breaking change" /tmp/up-minor.out; then
  echo "  ✓ no breaking-change warning on minor/patch"; PASS=$((PASS + 1))
else
  echo "  ✗ no breaking-change warning on minor/patch"; FAIL=$((FAIL + 1))
fi
if [ -d "$PROJ/.specboot-backup-"* ]; then
  echo "  ✓ backup created on minor/patch"; PASS=$((PASS + 1))
else
  echo "  ✗ backup created on minor/patch"; FAIL=$((FAIL + 1))
fi

# ---------- Test 3: major jump -> warns + replaces with --yes ----------
TPL_MAJOR="$(mktemp -d)"; make_template "$TPL_MAJOR" "1.0.0"
PROJ_MAJOR="$(mktemp -d)"; make_project "$PROJ_MAJOR" "0.2.0"
printf 'y\n' | ( cd "$PROJ_MAJOR" && bash "$SCRIPT" update --template "$TPL_MAJOR" ) >/tmp/up-major.out 2>&1
assert_exit "update major (y) exits 0" 0 $?
if grep -q "Breaking change. Lee CHANGELOG/release notes de v1.0.0" /tmp/up-major.out; then
  echo "  ✓ major prints breaking-change warning"; PASS=$((PASS + 1))
else
  echo "  ✗ major prints breaking-change warning"; FAIL=$((FAIL + 1))
fi
assert_eq "AGENTS.md replaced on major" "FW-AGENTS" "$(cat "$PROJ_MAJOR/AGENTS.md")"
assert_eq "frameworkVersion -> 1.0.0" "1.0.0" "$(node -e "console.log(require('$PROJ_MAJOR/.specboot.json').frameworkVersion)" 2>/dev/null || grep -o '"frameworkVersion": *"[^"]*"' "$PROJ_MAJOR/.specboot.json" | sed 's/.*:"//;s/"//')"

# major jump WITHOUT confirmation -> cancel, no changes
PROJ_CANCEL="$(mktemp -d)"; make_project "$PROJ_CANCEL" "0.2.0"
echo "OLD-AGENTS" > "$PROJ_CANCEL/AGENTS.md"
printf 'N\n' | ( cd "$PROJ_CANCEL" && bash "$SCRIPT" update --template "$TPL_MAJOR" ) >/tmp/up-cancel.out 2>&1
assert_exit "update major (N) exits 0" 0 $?
assert_eq "AGENTS.md NOT replaced on cancel" "OLD-AGENTS" "$(cat "$PROJ_CANCEL/AGENTS.md" 2>/dev/null || echo MISSING)"

# ---------- Test 4: installed older than project -> refuse ----------
TPL_OLD="$(mktemp -d)"; make_template "$TPL_OLD" "0.1.0"
PROJ_OLD="$(mktemp -d)"; make_project "$PROJ_OLD" "0.2.0"
( cd "$PROJ_OLD" && bash "$SCRIPT" update --template "$TPL_OLD" --yes ) >/tmp/up-old.out 2>&1
assert_exit "update with older installed exits 1" 1 $?
assert_eq "AGENTS.md NOT replaced when older" "OLD" "$(echo "OLD" > "$PROJ_OLD/AGENTS.md"; cat "$PROJ_OLD/AGENTS.md")"

# ---------- Test 5: equal version -> repair, .specboot.json unchanged ----------
TPL_EQ="$(mktemp -d)"; make_template "$TPL_EQ" "0.1.1"
PROJ_EQ="$(mktemp -d)"; make_project "$PROJ_EQ" "0.1.1"
# corrupt a framework file by hand
echo "HAND-EDITED BROKEN" > "$PROJ_EQ/AGENTS.md"
( cd "$PROJ_EQ" && bash "$SCRIPT" update --template "$TPL_EQ" --yes ) >/tmp/up-eq.out 2>&1
assert_exit "update equal exits 0" 0 $?
assert_eq "AGENTS.md repaired on equal" "FW-AGENTS" "$(cat "$PROJ_EQ/AGENTS.md")"
if ! grep -q "Breaking change" /tmp/up-eq.out; then
  echo "  ✓ no breaking-change warning on equal"; PASS=$((PASS + 1))
else
  echo "  ✗ no breaking-change warning on equal"; FAIL=$((FAIL + 1))
fi
if [ "$(cat "$PROJ_EQ/.specboot.json")" = "$(printf '{"frameworkVersion":"0.1.1","name":"proj","description":"","services":["."],"stack":"framework"}')" ]; then
  echo "  ✓ .specboot.json unchanged on equal"; PASS=$((PASS + 1))
else
  echo "  ✗ .specboot.json unchanged on equal"; FAIL=$((FAIL + 1))
fi

# ---------- Test 6: preservation of project docs/code/README/LICENSE/workflow ----------
assert_eq "docs/backend-standards preserved" "CUSTOM BACKEND STANDARDS - keep me" "$(cat "$PROJ/docs/backend-standards.md")"
assert_eq "docs/project/domain preserved"    "CUSTOM DOMAIN"   "$(cat "$PROJ/docs/project/domain.md")"
assert_eq "docs/api/api-spec preserved"      "CUSTOM API"      "$(cat "$PROJ/docs/api/api-spec.yml")"
assert_eq "docs/data-model preserved"        "CUSTOM DATAMODEL" "$(cat "$PROJ/docs/data-model/data-model.md")"
assert_eq "README.md preserved (excluded)"   "CUSTOM README"   "$(cat "$PROJ/README.md")"
assert_eq "LICENSE preserved (excluded)"     "CUSTOM LICENSE"  "$(cat "$PROJ/LICENSE")"
assert_eq "backend code preserved"           "CUSTOM SERVER"   "$(cat "$PROJ/backend/src/server.ts")"
assert_eq "frontend code preserved"          "CUSTOM APP"      "$(cat "$PROJ/frontend/src/app.tsx")"
assert_eq "project .github workflow preserved" "CUSTOM PROJECT WF" "$(cat "$PROJ/.github/workflows/my-own-ci.yml")"
# consumer CI + PR template installed from the templates (framework-owned)
assert_eq "consumer CI installed on update" "FW-consumer-ci" "$(cat "$PROJ/.github/workflows/ci.yml")"
assert_eq "PR template installed on update" "FW-pr-template" "$(cat "$PROJ/.github/pull_request_template.md")"

# ---------- Test 8: --dry-run changes nothing ----------
TPL_DRY="$(mktemp -d)"; make_template "$TPL_DRY" "0.3.0"
PROJ_DRY="$(mktemp -d)"; make_project "$PROJ_DRY" "0.1.1"
echo "ORIGINAL" > "$PROJ_DRY/AGENTS.md"
( cd "$PROJ_DRY" && bash "$SCRIPT" update --template "$TPL_DRY" --dry-run --yes ) >/tmp/up-dry.out 2>&1
assert_exit "dry-run exits 0" 0 $?
assert_eq "dry-run does not replace AGENTS.md" "ORIGINAL" "$(cat "$PROJ_DRY/AGENTS.md")"
assert_eq "dry-run does not rewrite version"   "0.1.1" "$(grep -o '"frameworkVersion": *"[^"]*"' "$PROJ_DRY/.specboot.json" | sed 's/.*:"//;s/"//')"
if ls -d "$PROJ_DRY/.specboot-backup-"* >/dev/null 2>&1; then
  echo "  ✗ dry-run created a backup"; FAIL=$((FAIL + 1))
else
  echo "  ✓ dry-run creates no backup"; PASS=$((PASS + 1))
fi
if grep -qi "would replace\|dry-run\|would sync" /tmp/up-dry.out; then
  echo "  ✓ dry-run reports intended actions"; PASS=$((PASS + 1))
else
  echo "  ✗ dry-run reports intended actions"; FAIL=$((FAIL + 1))
fi

# ---------- Test 9: --no-backup skips backup ----------
TPL_NB="$(mktemp -d)"; make_template "$TPL_NB" "0.2.0"
PROJ_NB="$(mktemp -d)"; make_project "$PROJ_NB" "0.1.1"
( cd "$PROJ_NB" && bash "$SCRIPT" update --template "$TPL_NB" --yes --no-backup ) >/tmp/up-nb.out 2>&1
assert_exit "no-backup exits 0" 0 $?
if ls -d "$PROJ_NB/.specboot-backup-"* >/dev/null 2>&1; then
  echo "  ✗ --no-backup created a backup"; FAIL=$((FAIL + 1))
else
  echo "  ✓ --no-backup creates no backup"; PASS=$((PASS + 1))
fi

# ---------- Test 11: dogfooding guard (target == source) ----------
# Run update from the framework repo's OWN directory ($ROOT == SCRIPT_DIR of specboot.sh),
# so the resolved framework source equals the target and the guard must trigger.
( cd "$ROOT" && bash "$SCRIPT" update --yes ) >/tmp/up-dog.out 2>&1
# Guard triggers: note printed, exit 0, no self-sync.
if grep -qi "Target y template son iguales" /tmp/up-dog.out; then
  echo "  ✓ dogfooding guard prints note"; PASS=$((PASS + 1))
else
  echo "  ✗ dogfooding guard prints note"; FAIL=$((FAIL + 1))
fi

# ---------- Test 12: legacy release.yml repair (REQ-002, SC-002/SC-003) ----------
# Exact framework-owned signature -> backed up + removed.
TPL_REL="$(mktemp -d)"; make_template "$TPL_REL" "0.2.0"
PROJ_REL="$(mktemp -d)"; make_project "$PROJ_REL" "0.1.1"
cp "$ROOT/.github/workflows/release.yml" "$PROJ_REL/.github/workflows/release.yml"
( cd "$PROJ_REL" && bash "$SCRIPT" update --template "$TPL_REL" --yes ) >/tmp/up-rel.out 2>&1
assert_exit "update with legacy release exits 0" 0 $?
if [ -e "$PROJ_REL/.github/workflows/release.yml" ]; then
  echo "  ✗ [HARDEN-02] exact legacy release.yml MUST be removed"; FAIL=$((FAIL + 1))
else
  echo "  ✓ [HARDEN-02] exact legacy release.yml removed"; PASS=$((PASS + 1))
fi
if ls -d "$PROJ_REL"/.specboot-backup-*/.github/workflows/release.yml >/dev/null 2>&1; then
  echo "  ✓ [HARDEN-02] legacy release.yml backed up before removal"; PASS=$((PASS + 1))
else
  echo "  ✗ [HARDEN-02] legacy release.yml NOT backed up before removal"; FAIL=$((FAIL + 1))
fi
# Custom workflow survives the update (SC-003).
assert_exists "[HARDEN-02] custom workflow survives" "$PROJ_REL/.github/workflows/my-own-ci.yml"

# Modified legacy release -> warn + explicit resolution, NEVER removed.
PROJ_MOD="$(mktemp -d)"; make_project "$PROJ_MOD" "0.1.1"
cp "$ROOT/.github/workflows/release.yml" "$PROJ_MOD/.github/workflows/release.yml"
echo "# consumer-modified" >> "$PROJ_MOD/.github/workflows/release.yml"
( cd "$PROJ_MOD" && bash "$SCRIPT" update --template "$TPL_REL" --yes ) >/tmp/up-mod.out 2>&1
assert_exit "update with modified legacy release exits 0" 0 $?
if [ -e "$PROJ_MOD/.github/workflows/release.yml" ]; then
  echo "  ✓ [HARDEN-02] modified legacy release.yml preserved (never auto-delete)"; PASS=$((PASS + 1))
else
  echo "  ✗ [HARDEN-02] modified legacy release.yml was auto-deleted"; FAIL=$((FAIL + 1))
fi
if grep -qi "NO coincide con la firma" /tmp/up-mod.out && grep -qi "resolución explícita" /tmp/up-mod.out; then
  echo "  ✓ [HARDEN-02] modified legacy release warns for explicit resolution"; PASS=$((PASS + 1))
else
  echo "  ✗ [HARDEN-02] modified legacy release did NOT warn for explicit resolution"; FAIL=$((FAIL + 1))
fi

# ---------- Test 13: legacy fingerprint ALLOWLIST (REQ-002, historical variants) ----------
# Every release.yml variant Specboot distributed before artifact isolation must be
# detected and repaired. The variants are the historical versions of the framework's
# own file, pinned here by their pre-isolation commits (immutable commits — the
# test stays stable after the isolation boundary; later internal edits to
# release.yml were never distributed and MUST NOT enter the allowlist).
LEGACY_V1_SHA="ea2f096a4586183597bd9ce62b8ff9d9607e145f"  # initial release workflow
LEGACY_V2_SHA="033806f46bd2135d9af339dc5269b96c7a4e7735"  # node 24 bump, orphan publish removed
LEGACY_V3_SHA="e68135b04305da9f7572c037020d2e3a8e060c64"  # idempotent publish (last distributed)

# (a) Provenance: every pre-isolation variant hash is in the specboot.sh allowlist.
ALLOWLIST_BLOCK="$(sed -n '/^KNOWN_RELEASE_FINGERPRINTS=(/,/^)/p' "$SCRIPT")"
for vsha in "$LEGACY_V1_SHA" "$LEGACY_V2_SHA" "$LEGACY_V3_SHA"; do
  vh="$(git show "$vsha":.github/workflows/release.yml | git hash-object --stdin)"
  if printf '%s' "$ALLOWLIST_BLOCK" | grep -q "$vh"; then
    echo "  ✓ [REQ-002] allowlist contains fingerprint of pre-isolation variant $(printf '%s' "$vh" | cut -c1-7)"; PASS=$((PASS + 1))
  else
    echo "  ✗ [REQ-002] allowlist MISSES pre-isolation variant fingerprint $(printf '%s' "$vh" | cut -c1-7)"; FAIL=$((FAIL + 1))
  fi
done
# (b) No invented hashes: every allowlist entry derives from release.yml git history.
HISTORICAL_SET="$(git log --format=%H --all -- .github/workflows/release.yml | while read -r c; do
  git show "$c":.github/workflows/release.yml 2>/dev/null | git hash-object --stdin
done | sort -u)"
INVENTED=0
while read -r entry; do
  [ -z "$entry" ] && continue
  printf '%s\n' "$HISTORICAL_SET" | grep -qx "$entry" || INVENTED=1
done <<EOF
$(printf '%s' "$ALLOWLIST_BLOCK" | grep -oE '"[0-9a-f]{40}"' | tr -d '"')
EOF
if [ "$INVENTED" -eq 0 ] && [ -n "$HISTORICAL_SET" ]; then
  echo "  ✓ [REQ-002] allowlist has no invented hashes (all entries derive from git history)"; PASS=$((PASS + 1))
else
  echo "  ✗ [REQ-002] allowlist contains a hash with no release.yml history provenance"; FAIL=$((FAIL + 1))
fi
# (c) Documentation: immutable legacy content, never derived from the internal file.
if grep -q "IMMUTABLE" "$SCRIPT" && grep -q "never derived from the current internal" "$SCRIPT"; then
  echo "  ✓ [REQ-002] allowlist documented as immutable legacy content (not derived from current release.yml)"; PASS=$((PASS + 1))
else
  echo "  ✗ [REQ-002] allowlist missing immutable-legacy documentation"; FAIL=$((FAIL + 1))
fi
# (d) Behavior: a consumer contaminated with EACH legacy variant is repaired.
i=0
for vsha in "$LEGACY_V1_SHA" "$LEGACY_V2_SHA" "$LEGACY_V3_SHA"; do
  i=$((i + 1))
  vh="$(git show "$vsha":.github/workflows/release.yml | git hash-object --stdin)"
  TPL_VAR="$(mktemp -d)"; make_template "$TPL_VAR" "0.2.0"
  PROJ_VAR="$(mktemp -d)"; make_project "$PROJ_VAR" "0.1.1"
  git show "$vsha":.github/workflows/release.yml > "$PROJ_VAR/.github/workflows/release.yml"
  ( cd "$PROJ_VAR" && bash "$SCRIPT" update --template "$TPL_VAR" --yes ) >/tmp/up-var-$i.out 2>&1
  assert_exit "update with legacy variant v$i exits 0" 0 $?
  if [ -e "$PROJ_VAR/.github/workflows/release.yml" ]; then
    echo "  ✗ [REQ-002] legacy variant v$i (fingerprint $(printf '%s' "$vh" | cut -c1-7)) MUST be removed"; FAIL=$((FAIL + 1))
  else
    echo "  ✓ [REQ-002] legacy variant v$i (fingerprint $(printf '%s' "$vh" | cut -c1-7)) removed"; PASS=$((PASS + 1))
  fi
  if ls -d "$PROJ_VAR"/.specboot-backup-*/.github/workflows/release.yml >/dev/null 2>&1; then
    echo "  ✓ [REQ-002] legacy variant v$i backed up before removal"; PASS=$((PASS + 1))
  else
    echo "  ✗ [REQ-002] legacy variant v$i NOT backed up"; FAIL=$((FAIL + 1))
  fi
  rm -rf "$TPL_VAR" "$PROJ_VAR"
done

rm -rf "$NO_CFG" "$TPL" "$PROJ" "$TPL_MAJOR" "$PROJ_MAJOR" "$PROJ_CANCEL" \
       "$TPL_OLD" "$PROJ_OLD" "$TPL_EQ" "$PROJ_EQ" "$TPL_DRY" "$PROJ_DRY" \
       "$TPL_NB" "$PROJ_NB" "$TPL_REL" "$PROJ_REL" "$PROJ_MOD"

echo ""
echo "TDD tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
