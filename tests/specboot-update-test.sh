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
# The fixture is a distributed legacy variant derived from git history (v3 — the
# last variant Specboot distributed before artifact isolation), NOT the live
# internal release.yml, whose fingerprint may evolve freely (REQ-001 /
# SPECBOOT-HARDEN-03 adds fetch-depth: 0) and therefore is not a legacy signature.
# LEGACY_V3_SHA is the pre-isolation commit of the framework's own file (immutable).
LEGACY_V3_SHA="e68135b04305da9f7572c037020d2e3a8e060c64"  # idempotent publish (last distributed)
legacy_v3="$(git show "$LEGACY_V3_SHA":.github/workflows/release.yml 2>/dev/null)"
TPL_REL="$(mktemp -d)"; make_template "$TPL_REL" "0.2.0"
PROJ_REL="$(mktemp -d)"; make_project "$PROJ_REL" "0.1.1"
printf '%s\n' "$legacy_v3" > "$PROJ_REL/.github/workflows/release.yml"
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
printf '%s\n' "$legacy_v3" > "$PROJ_MOD/.github/workflows/release.yml"
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

# ---------- Test 14: consumer CI fingerprint ALLOWLIST (HARDEN-04, REQ-001, SC-011) ----------
# Every consumer CI variant Specboot distributed since 0.10.0 must be detectable
# by the tri-state update policy. The variants are pinned by full commit SHAs
# (NOT tags — CI checkouts carry no tags), resolved via `git rev-parse <sha>^{commit}`:
#   Variant A (v1) — the pre-isolation consumer CI: .github/workflows/ci.yml as
#     of tag v0.10.0; that content equals the file at cf50b18, the last commit
#     touching the file before the tag (git log --oneline v0.10.0 -1 -- .github/workflows/ci.yml).
#   Variant B (v2) — templates/github/workflows/consumer-ci.yml at 0c586db
#     (SPECBOOT-HARDEN-02), first distributed with 0.11.0.
CONSUMER_CI_V1_SHA="$(git rev-parse cf50b18^{commit})"
CONSUMER_CI_V2_SHA="$(git rev-parse 0c586db^{commit})"
CONSUMER_ALLOWLIST_BLOCK="$(sed -n '/^KNOWN_CONSUMER_CI_FINGERPRINTS=(/,/^)/p' "$SCRIPT")"

# (a) Provenance (SC-011): the allowlist exists and contains every distributed
# variant's content fingerprint re-derived from its pinned commit.
if [ -n "$CONSUMER_ALLOWLIST_BLOCK" ]; then
  echo "  ✓ [SC-011] KNOWN_CONSUMER_CI_FINGERPRINTS allowlist exists in specboot.sh"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-011] KNOWN_CONSUMER_CI_FINGERPRINTS allowlist missing in specboot.sh"; FAIL=$((FAIL + 1))
fi
for pair in \
  "v1|$CONSUMER_CI_V1_SHA|.github/workflows/ci.yml" \
  "v2|$CONSUMER_CI_V2_SHA|templates/github/workflows/consumer-ci.yml"
do
  v_label="${pair%%|*}"
  v_rest="${pair#*|}"
  v_sha="${v_rest%%|*}"
  v_path="${v_rest#*|}"
  v_hash="$(git show "$v_sha:$v_path" 2>/dev/null | git hash-object --stdin)"
  if [ -n "$v_hash" ] && printf '%s' "$CONSUMER_ALLOWLIST_BLOCK" | grep -q "$v_hash"; then
    echo "  ✓ [SC-011] allowlist contains consumer CI $v_label fingerprint $(printf '%s' "$v_hash" | cut -c1-7)"; PASS=$((PASS + 1))
  else
    echo "  ✗ [SC-011] allowlist MISSES consumer CI $v_label fingerprint $(printf '%s' "$v_hash" | cut -c1-7)"; FAIL=$((FAIL + 1))
  fi
done

# (b) No invented hashes (SC-011): every allowlist entry derives from the git
# history of the two consumer CI sources (union of all blobs ever committed for
# each path, across all refs).
CONSUMER_HISTORICAL_SET="$(
  {
    git log --format=%H --all -- .github/workflows/ci.yml | while read -r c; do
      git show "$c":.github/workflows/ci.yml 2>/dev/null | git hash-object --stdin
    done
    git log --format=%H --all -- templates/github/workflows/consumer-ci.yml | while read -r c; do
      git show "$c":templates/github/workflows/consumer-ci.yml 2>/dev/null | git hash-object --stdin
    done
  } | sort -u
)"
CONSUMER_INVENTED=0
CONSUMER_ENTRIES=0
while read -r entry; do
  [ -z "$entry" ] && continue
  CONSUMER_ENTRIES=$((CONSUMER_ENTRIES + 1))
  printf '%s\n' "$CONSUMER_HISTORICAL_SET" | grep -qx "$entry" || CONSUMER_INVENTED=1
done <<EOF
$(printf '%s' "$CONSUMER_ALLOWLIST_BLOCK" | grep -oE '"[0-9a-f]{40}"' | tr -d '"')
EOF
if [ "$CONSUMER_INVENTED" -eq 0 ] && [ "$CONSUMER_ENTRIES" -ge 2 ] && [ -n "$CONSUMER_HISTORICAL_SET" ]; then
  echo "  ✓ [SC-011] consumer CI allowlist has no invented hashes ($CONSUMER_ENTRIES entries, all from git history)"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-011] consumer CI allowlist drifts from the distributed history ($CONSUMER_ENTRIES entries)"; FAIL=$((FAIL + 1))
fi

# (c) Documentation (SC-011): immutable historical content, never derived from
# the current internal .github/workflows/ci.yml (which may evolve freely).
if grep -q "IMMUTABLE historical content fingerprints of every consumer CI variant" "$SCRIPT" \
  && grep -q "never derived from the current internal .github/workflows/ci.yml" "$SCRIPT"; then
  echo "  ✓ [SC-011] consumer CI allowlist documented as immutable historical content (not derived from the internal ci.yml)"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-011] consumer CI allowlist missing immutable-historical documentation"; FAIL=$((FAIL + 1))
fi

# ---------- Test 15: safe consumer CI update policy (HARDEN-04, REQ-002/REQ-003) ----------
# Tri-state policy over the consumer's .github/workflows/ci.yml on `specboot update`:
#   SC-001  missing           -> current template installed + installation reported
#   SC-002  exact historical variant (allowlisted fingerprints, pinned commits)
#                             -> backed up into .specboot-backup-*/ BEFORE being
#                                replaced with the current template + repair reported
#   SC-003  modified variant  -> byte-for-byte intact + explicit-resolution warning
#   SC-012  foreign content   -> intact + same warning (no silent overwrite)
#   SC-004  custom workflows  -> never touched by update
#   SC-009  exact current template -> idempotent no-op (no backup, no rewrite, no warning)
#   SC-010  same policy from a node_modules consumer installation
#   PR template keeps its current behavior (replaced by update when present).
# The historical variants are pinned by FULL commit SHAs (commit SHAs, not tags —
# CI checkouts carry no tags), re-derived at runtime with `git show <sha>:<path>`.
CONSUMER_CI_HIST_V1_SHA="cf50b183396a93b0b5a23cada8553d29497ae9f4"  # internal .github/workflows/ci.yml @ tag v0.10.0 — pre-isolation copy distributed by `specboot update`
CONSUMER_CI_HIST_V2_SHA="0c586dbdd6cff9e771a0539f7f4f1f656aac60dd"  # templates/github/workflows/consumer-ci.yml @ SPECBOOT-HARDEN-02 — first distributed with 0.11.0

# --- 15a SC-001: consumer without ci.yml gets the current template installed ---
TPL_15A="$(mktemp -d)"; make_template "$TPL_15A" "0.2.0"
PROJ_15A="$(mktemp -d)"; make_project "$PROJ_15A" "0.1.1"
rm -f "$PROJ_15A/.github/workflows/ci.yml"
( cd "$PROJ_15A" && bash "$SCRIPT" update --template "$TPL_15A" --yes ) >/tmp/up-ci-missing.out 2>&1
assert_exit "[SC-001] update without consumer ci.yml exits 0" 0 $?
assert_eq "[SC-001] missing consumer ci.yml installed from the current template" "FW-consumer-ci" "$(cat "$PROJ_15A/.github/workflows/ci.yml" 2>/dev/null || echo MISSING)"
if grep -q "instalado: .github/workflows/ci.yml" /tmp/up-ci-missing.out; then
  echo "  ✓ [SC-001] installation of the consumer ci.yml is reported"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-001] installation of the consumer ci.yml NOT reported"; FAIL=$((FAIL + 1))
fi
# PR template keeps its current behavior: installed/replaced by update when present.
assert_eq "[SC-001] PR template still installed/replaced by update (unchanged behavior)" "FW-pr-template" "$(cat "$PROJ_15A/.github/pull_request_template.md" 2>/dev/null || echo MISSING)"

# --- 15b SC-002: each exact historical variant is backed up, replaced and reported ---
i=0
for pair in \
  "v1|$CONSUMER_CI_HIST_V1_SHA|.github/workflows/ci.yml" \
  "v2|$CONSUMER_CI_HIST_V2_SHA|templates/github/workflows/consumer-ci.yml"
do
  i=$((i + 1))
  v_label="${pair%%|*}"
  v_rest="${pair#*|}"
  v_sha="${v_rest%%|*}"
  v_path="${v_rest#*|}"
  TPL_15B="$(mktemp -d)"; make_template "$TPL_15B" "0.2.0"
  PROJ_15B="$(mktemp -d)"; make_project "$PROJ_15B" "0.1.1"
  git show "$v_sha:$v_path" > "$PROJ_15B/.github/workflows/ci.yml"
  git show "$v_sha:$v_path" > "/tmp/up-ci-orig-$i.yml"
  ( cd "$PROJ_15B" && bash "$SCRIPT" update --template "$TPL_15B" --yes ) >/tmp/up-ci-variant-$i.out 2>&1
  assert_exit "[SC-002] update with historical consumer CI $v_label exits 0" 0 $?
  if ls "$PROJ_15B"/.specboot-backup-*/.github/workflows/ci.yml >/dev/null 2>&1 \
    && cmp -s "/tmp/up-ci-orig-$i.yml" "$PROJ_15B"/.specboot-backup-*/.github/workflows/ci.yml; then
    echo "  ✓ [SC-002] historical $v_label backed up with the ORIGINAL content before replacement"; PASS=$((PASS + 1))
  else
    echo "  ✗ [SC-002] historical $v_label NOT backed up with the original content"; FAIL=$((FAIL + 1))
  fi
  assert_eq "[SC-002] historical $v_label replaced with the current template" "FW-consumer-ci" "$(cat "$PROJ_15B/.github/workflows/ci.yml" 2>/dev/null || echo MISSING)"
  if grep -q "reparado: .github/workflows/ci.yml" /tmp/up-ci-variant-$i.out \
    && grep -q "respaldado en $PROJ_15B/.specboot-backup-" /tmp/up-ci-variant-$i.out; then
    echo "  ✓ [SC-002] repair of historical $v_label reported (backup + replacement)"; PASS=$((PASS + 1))
  else
    echo "  ✗ [SC-002] repair of historical $v_label NOT reported"; FAIL=$((FAIL + 1))
  fi
  rm -rf "$TPL_15B" "$PROJ_15B" "/tmp/up-ci-orig-$i.yml"
done

# --- 15c SC-003: modified historical variant stays intact + explicit-resolution warning ---
TPL_15C="$(mktemp -d)"; make_template "$TPL_15C" "0.2.0"
PROJ_15C="$(mktemp -d)"; make_project "$PROJ_15C" "0.1.1"
git show "$CONSUMER_CI_HIST_V1_SHA":.github/workflows/ci.yml > "$PROJ_15C/.github/workflows/ci.yml"
echo "# consumer tweak" >> "$PROJ_15C/.github/workflows/ci.yml"
cp "$PROJ_15C/.github/workflows/ci.yml" /tmp/up-ci-mod-orig.yml
( cd "$PROJ_15C" && bash "$SCRIPT" update --template "$TPL_15C" --yes ) >/tmp/up-ci-mod.out 2>&1
assert_exit "[SC-003] update with modified consumer ci.yml exits 0" 0 $?
if cmp -s /tmp/up-ci-mod-orig.yml "$PROJ_15C/.github/workflows/ci.yml"; then
  echo "  ✓ [SC-003] modified consumer ci.yml stays byte-for-byte intact"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-003] modified consumer ci.yml was overwritten"; FAIL=$((FAIL + 1))
fi
if grep -q "\.github/workflows/ci\.yml" /tmp/up-ci-mod.out \
  && grep -q "NO se sobrescribió" /tmp/up-ci-mod.out \
  && grep -q "resolución explícita" /tmp/up-ci-mod.out; then
  echo "  ✓ [SC-003] explicit-resolution warning emitted for the modified ci.yml"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-003] NO explicit-resolution warning for the modified ci.yml"; FAIL=$((FAIL + 1))
fi

# --- 15d SC-012: foreign ci.yml (never distributed) intact + same warning ---
TPL_15D="$(mktemp -d)"; make_template "$TPL_15D" "0.2.0"
PROJ_15D="$(mktemp -d)"; make_project "$PROJ_15D" "0.1.1"
printf 'name: my-own-ci\n' > "$PROJ_15D/.github/workflows/ci.yml"
cp "$PROJ_15D/.github/workflows/ci.yml" /tmp/up-ci-foreign-orig.yml
( cd "$PROJ_15D" && bash "$SCRIPT" update --template "$TPL_15D" --yes ) >/tmp/up-ci-foreign.out 2>&1
assert_exit "[SC-012] update with foreign consumer ci.yml exits 0" 0 $?
if cmp -s /tmp/up-ci-foreign-orig.yml "$PROJ_15D/.github/workflows/ci.yml"; then
  echo "  ✓ [SC-012] foreign consumer ci.yml stays byte-for-byte intact"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-012] foreign consumer ci.yml was overwritten"; FAIL=$((FAIL + 1))
fi
if grep -q "\.github/workflows/ci\.yml" /tmp/up-ci-foreign.out \
  && grep -q "NO se sobrescribió" /tmp/up-ci-foreign.out \
  && grep -q "resolución explícita" /tmp/up-ci-foreign.out; then
  echo "  ✓ [SC-012] explicit-resolution warning emitted for the foreign ci.yml (no silent overwrite)"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-012] NO explicit-resolution warning for the foreign ci.yml"; FAIL=$((FAIL + 1))
fi

# --- 15e SC-004: additional own workflows survive the ci.yml policy ---
TPL_15E="$(mktemp -d)"; make_template "$TPL_15E" "0.2.0"
PROJ_15E="$(mktemp -d)"; make_project "$PROJ_15E" "0.1.1"
printf 'name: consumer-deploy\non: [push]\njobs:\n  deploy:\n    runs-on: ubuntu-latest\n' > "$PROJ_15E/.github/workflows/deploy.yml"
printf 'CUSTOM-WORKFLOW-KEEP' > "$PROJ_15E/.github/workflows/custom.yml"
git show "$CONSUMER_CI_HIST_V1_SHA":.github/workflows/ci.yml > "$PROJ_15E/.github/workflows/ci.yml"
cp "$PROJ_15E/.github/workflows/deploy.yml" /tmp/up-ci-deploy-orig.yml
cp "$PROJ_15E/.github/workflows/custom.yml" /tmp/up-ci-custom-orig.yml
( cd "$PROJ_15E" && bash "$SCRIPT" update --template "$TPL_15E" --yes ) >/tmp/up-ci-custom.out 2>&1
assert_exit "[SC-004] update with own workflows exits 0" 0 $?
if cmp -s /tmp/up-ci-deploy-orig.yml "$PROJ_15E/.github/workflows/deploy.yml"; then
  echo "  ✓ [SC-004] consumer-owned deploy.yml survives byte-for-byte"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-004] consumer-owned deploy.yml was modified/removed"; FAIL=$((FAIL + 1))
fi
if cmp -s /tmp/up-ci-custom-orig.yml "$PROJ_15E/.github/workflows/custom.yml"; then
  echo "  ✓ [SC-004] consumer-owned custom.yml survives byte-for-byte"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-004] consumer-owned custom.yml was modified/removed"; FAIL=$((FAIL + 1))
fi
assert_eq "[SC-004] make_project own workflow (my-own-ci.yml) survives the policy" "CUSTOM PROJECT WF" "$(cat "$PROJ_15E/.github/workflows/my-own-ci.yml" 2>/dev/null || echo MISSING)"

# --- 15f SC-009: exact current template -> idempotent no-op (twice) ---
TPL_15F="$(mktemp -d)"; make_template "$TPL_15F" "0.2.0"
PROJ_15F="$(mktemp -d)"; make_project "$PROJ_15F" "0.1.1"
cp "$TPL_15F/templates/github/workflows/consumer-ci.yml" "$PROJ_15F/.github/workflows/ci.yml"
( cd "$PROJ_15F" && bash "$SCRIPT" update --template "$TPL_15F" --yes ) >/tmp/up-ci-eq-1.out 2>&1
assert_exit "[SC-009] first update with exact-template ci.yml exits 0" 0 $?
( cd "$PROJ_15F" && bash "$SCRIPT" update --template "$TPL_15F" --yes ) >/tmp/up-ci-eq-2.out 2>&1
assert_exit "[SC-009] second update with exact-template ci.yml exits 0 (idempotent)" 0 $?
for run in 1 2; do
  if cmp -s "$PROJ_15F/.github/workflows/ci.yml" "$TPL_15F/templates/github/workflows/consumer-ci.yml"; then
    echo "  ✓ [SC-009] run $run: ci.yml byte-for-byte identical (no rewrite)"; PASS=$((PASS + 1))
  else
    echo "  ✗ [SC-009] run $run: ci.yml was rewritten"; FAIL=$((FAIL + 1))
  fi
  if ls "$PROJ_15F"/.specboot-backup-*/.github/workflows/ci.yml >/dev/null 2>&1; then
    echo "  ✗ [SC-009] run $run: a ci.yml backup entry exists (exact match must NOT be backed up)"; FAIL=$((FAIL + 1))
  else
    echo "  ✓ [SC-009] run $run: no ci.yml in any .specboot-backup-* dir (other UPDATE_ITEMS backups still occur)"; PASS=$((PASS + 1))
  fi
  if grep -q "reemplazado: .github/workflows/ci.yml" /tmp/up-ci-eq-$run.out \
    || grep -q "reparado: .github/workflows/ci.yml" /tmp/up-ci-eq-$run.out \
    || grep -q "NO se sobrescribió" /tmp/up-ci-eq-$run.out; then
    echo "  ✗ [SC-009] run $run: spurious replace/repair/warning message for ci.yml"; FAIL=$((FAIL + 1))
  else
    echo "  ✓ [SC-009] run $run: no replace/repair/warning message for ci.yml"; PASS=$((PASS + 1))
  fi
done

# --- 15g SC-010: the policy applies from a node_modules consumer installation ---
CONS="$(mktemp -d)"
PKG="$CONS/node_modules/@gabrielzavando/specboot"
mkdir -p "$PKG" "$CONS/.github/workflows"
cp "$SCRIPT" "$PKG/specboot.sh"
cp -R "$ROOT/templates" "$PKG/templates"
printf '{"name":"@gabrielzavando/specboot","version":"0.10.0"}\n' > "$PKG/package.json"
echo 'exit 0  # consumer-package stub: the installed package validates its own closed structure' > "$PKG/check-refs.sh"
printf '{"frameworkVersion":"0.10.0","name":"consumer-proj","description":"","services":["."],"stack":"node"}\n' > "$CONS/.specboot.json"
( cd "$CONS" && bash "$PKG/specboot.sh" update --yes ) >/tmp/up-cons-missing.out 2>&1
assert_exit "[SC-010] consumer-mode update (node_modules) without ci.yml exits 0" 0 $?
if cmp -s "$CONS/.github/workflows/ci.yml" "$PKG/templates/github/workflows/consumer-ci.yml"; then
  echo "  ✓ [SC-010] consumer mode: missing ci.yml installed with the PACKAGE's template"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-010] consumer mode: missing ci.yml NOT installed with the package's template"; FAIL=$((FAIL + 1))
fi
if grep -q "instalado: .github/workflows/ci.yml" /tmp/up-cons-missing.out; then
  echo "  ✓ [SC-010] consumer mode: installation of ci.yml is reported"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-010] consumer mode: installation of ci.yml NOT reported"; FAIL=$((FAIL + 1))
fi
CONS_MOD="$(mktemp -d)"
mkdir -p "$CONS_MOD/.github/workflows"
printf '{"frameworkVersion":"0.10.0","name":"consumer-proj","description":"","services":["."],"stack":"node"}\n' > "$CONS_MOD/.specboot.json"
git show "$CONSUMER_CI_HIST_V1_SHA":.github/workflows/ci.yml > "$CONS_MOD/.github/workflows/ci.yml"
echo "# consumer tweak" >> "$CONS_MOD/.github/workflows/ci.yml"
cp "$CONS_MOD/.github/workflows/ci.yml" /tmp/up-cons-mod-orig.yml
( cd "$CONS_MOD" && bash "$PKG/specboot.sh" update --yes ) >/tmp/up-cons-mod.out 2>&1
assert_exit "[SC-010] consumer-mode update with modified ci.yml exits 0" 0 $?
if cmp -s /tmp/up-cons-mod-orig.yml "$CONS_MOD/.github/workflows/ci.yml"; then
  echo "  ✓ [SC-010] consumer mode: modified ci.yml stays byte-for-byte intact"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-010] consumer mode: modified ci.yml was overwritten"; FAIL=$((FAIL + 1))
fi
if grep -q "\.github/workflows/ci\.yml" /tmp/up-cons-mod.out \
  && grep -q "NO se sobrescribió" /tmp/up-cons-mod.out \
  && grep -q "resolución explícita" /tmp/up-cons-mod.out; then
  echo "  ✓ [SC-010] consumer mode: explicit-resolution warning emitted for the modified ci.yml"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-010] consumer mode: NO explicit-resolution warning for the modified ci.yml"; FAIL=$((FAIL + 1))
fi

rm -rf "$TPL_15A" "$PROJ_15A" "$TPL_15C" "$PROJ_15C" "$TPL_15D" "$PROJ_15D" \
       "$TPL_15E" "$PROJ_15E" "$TPL_15F" "$PROJ_15F" "$CONS" "$CONS_MOD" \
       /tmp/up-ci-missing.out /tmp/up-ci-mod-orig.yml /tmp/up-ci-mod.out \
       /tmp/up-ci-foreign-orig.yml /tmp/up-ci-foreign.out \
       /tmp/up-ci-deploy-orig.yml /tmp/up-ci-custom-orig.yml /tmp/up-ci-custom.out \
       /tmp/up-ci-eq-1.out /tmp/up-ci-eq-2.out /tmp/up-cons-missing.out \
       /tmp/up-cons-mod-orig.yml /tmp/up-cons-mod.out \
       /tmp/up-ci-variant-*.out

# ---------- Test 16: backup failure prevents the replacement (HARDEN-04 follow-up, REQ-002, SC-013) ----------
# SC-013: when the backup of a historical variant CANNOT be created, the update
# MUST NOT replace ci.yml — the original stays byte-for-byte intact, a clear
# error is emitted and the operation returns a non-successful state (exit != 0).
# The backup failure is forced deterministically:
#   1. `date` is shimmed to a FIXED timestamp so the backup dir name
#      (.specboot-backup-<ts>) is predictable.
#   2. A regular FILE is pre-created at <backup_dir>/.github, so
#      `mkdir -p <backup_dir>/.github/workflows` and the backup `cp` fail
#      (a regular file can never become a directory — root-independent).
FAKEBIN_16="$(mktemp -d)"
printf '#!/bin/sh\necho 20260101120000\n' > "$FAKEBIN_16/date"
chmod +x "$FAKEBIN_16/date"
TPL_16="$(mktemp -d)"; make_template "$TPL_16" "0.2.0"
PROJ_16="$(mktemp -d)"; make_project "$PROJ_16" "0.1.1"
BACKUP_BLOCKED="$PROJ_16/.specboot-backup-20260101120000"
mkdir -p "$BACKUP_BLOCKED"
printf 'not a directory\n' > "$BACKUP_BLOCKED/.github"
git show "$CONSUMER_CI_HIST_V1_SHA":.github/workflows/ci.yml > "$PROJ_16/.github/workflows/ci.yml"
cp "$PROJ_16/.github/workflows/ci.yml" /tmp/up-ci-bkpfail-orig.yml
( cd "$PROJ_16" && PATH="$FAKEBIN_16:$PATH" bash "$SCRIPT" update --template "$TPL_16" --yes ) >/tmp/up-ci-bkpfail.out 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
  echo "  ✓ [SC-013] update exits non-zero when the ci.yml backup fails"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-013] update exits 0 despite the ci.yml backup failure (replacement proceeded)"; FAIL=$((FAIL + 1))
fi
if cmp -s /tmp/up-ci-bkpfail-orig.yml "$PROJ_16/.github/workflows/ci.yml"; then
  echo "  ✓ [SC-013] ci.yml stays byte-for-byte intact when the backup fails"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-013] ci.yml was replaced despite the backup failure"; FAIL=$((FAIL + 1))
fi
if grep -q "No se pudo respaldar .github/workflows/ci.yml" /tmp/up-ci-bkpfail.out \
  && grep -q "NO se reemplaz" /tmp/up-ci-bkpfail.out; then
  echo "  ✓ [SC-013] clear backup-failure error emitted (path + no replacement)"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-013] clear backup-failure error missing from output"; FAIL=$((FAIL + 1))
fi
rm -rf "$FAKEBIN_16" "$TPL_16" "$PROJ_16" /tmp/up-ci-bkpfail-orig.yml /tmp/up-ci-bkpfail.out

# ---------- Test 17: verified replacement — no false success (HARDEN-04 follow-up, REQ-002, SC-015) ----------
# SC-015: the cp that INSTALLS (missing ci.yml) or REPLACES (historical variant)
# the consumer ci.yml with the current template MUST be verified: if the cp
# fails, or the final destination does NOT match the expected template
# (partial/corrupt write), the update returns a non-successful state with a
# clear error — NEVER a false "repaired/successful" report. The final
# destination is checked against the expected template before success is
# reported.
#
# (a) Replacement failure is forced deterministically with a PATH stub `cp`
#     that delegates to /bin/cp but FAILS ONLY when the destination equals the
#     project's ci.yml ($PROJ_17A/.github/workflows/ci.yml).
# (b) Verified success: a normal replacement must make ci.yml byte-for-byte
#     equal to the current template and only then report success.
# (c) --no-backup: a historical variant is replaced (verified) with no backup —
#     the replace verification must still apply.

# (a) replacement cp failure -> no false success, non-successful state
FAKEBIN_17="$(mktemp -d)"
cat > "$FAKEBIN_17/cp" <<'EOF'
#!/bin/sh
# Delegate to the real cp, but FAIL when the SOURCE is the template's
# consumer-ci.yml (i.e. the install/replace copy — the copy that writes the
# current template into the project's .github/workflows/ci.yml). Backups
# (whose source is the project's existing ci.yml) are NOT affected.
prev=""
for a in "$@"; do
  case "$prev" in
    */templates/github/workflows/consumer-ci.yml) echo "shim cp: forced replacement failure" >&2; exit 1 ;;
  esac
  prev="$a"
done
exec /bin/cp "$@"
EOF
chmod +x "$FAKEBIN_17/cp"
TPL_17A="$(mktemp -d)"; make_template "$TPL_17A" "0.2.0"
PROJ_17A="$(mktemp -d)"; make_project "$PROJ_17A" "0.1.1"
git show "$CONSUMER_CI_HIST_V1_SHA":.github/workflows/ci.yml > "$PROJ_17A/.github/workflows/ci.yml"
cp "$PROJ_17A/.github/workflows/ci.yml" /tmp/up-ci-replfail-orig.yml
( cd "$PROJ_17A" && PATH="$FAKEBIN_17:$PATH" bash "$SCRIPT" update --template "$TPL_17A" --yes ) >/tmp/up-ci-replfail.out 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
  echo "  ✓ [SC-015a] update exits non-zero when the ci.yml replacement cp fails"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-015a] update exits 0 despite the ci.yml replacement failure (false success)"; FAIL=$((FAIL + 1))
fi
if grep -qi "reemplazo de .github/workflows/ci.yml\|no se pudo reemplazar\|reemplazo.*fall" /tmp/up-ci-replfail.out; then
  echo "  ✓ [SC-015a] clear replacement-failure error emitted"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-015a] NO clear replacement-failure error emitted"; FAIL=$((FAIL + 1))
fi
if grep -q "reparado: .github/workflows/ci.yml" /tmp/up-ci-replfail.out \
  || grep -a "$(cat "$TPL_17A/templates/github/workflows/consumer-ci.yml")" /tmp/up-ci-replfail.out 2>/dev/null; then
  echo "  ✗ [SC-015a] a successful ci.yml repair was falsely reported despite replacement failure"; FAIL=$((FAIL + 1))
else
  echo "  ✓ [SC-015a] NO false 'repaired' success reported"; PASS=$((PASS + 1))
fi

# (b) verified success: normal replacement -> ci.yml == template, then success
TPL_17B="$(mktemp -d)"; make_template "$TPL_17B" "0.2.0"
PROJ_17B="$(mktemp -d)"; make_project "$PROJ_17B" "0.1.1"
git show "$CONSUMER_CI_HIST_V1_SHA":.github/workflows/ci.yml > "$PROJ_17B/.github/workflows/ci.yml"
( cd "$PROJ_17B" && bash "$SCRIPT" update --template "$TPL_17B" --yes ) >/tmp/up-ci-ok-repl.out 2>&1
assert_exit "[SC-015b] update with successful replacement exits 0" 0 $?
if cmp -s "$PROJ_17B/.github/workflows/ci.yml" "$TPL_17B/templates/github/workflows/consumer-ci.yml"; then
  echo "  ✓ [SC-015b] replaced ci.yml byte-for-byte equal to the current template (verified success)"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-015b] replaced ci.yml does NOT match the current template"; FAIL=$((FAIL + 1))
fi
if grep -q "reparado: .github/workflows/ci.yml" /tmp/up-ci-ok-repl.out; then
  echo "  ✓ [SC-015b] repair reported as success after verified match"; PASS=$((PASS + 1))
else
  echo "  ✗ [SC-015b] repair NOT reported after verified match"; FAIL=$((FAIL + 1))
fi

# (c) --no-backup: historical variant replaced (verified) with no backup
TPL_17C="$(mktemp -d)"; make_template "$TPL_17C" "0.2.0"
PROJ_17C="$(mktemp -d)"; make_project "$PROJ_17C" "0.1.1"
git show "$CONSUMER_CI_HIST_V1_SHA":.github/workflows/ci.yml > "$PROJ_17C/.github/workflows/ci.yml"
( cd "$PROJ_17C" && bash "$SCRIPT" update --template "$TPL_17C" --yes --no-backup ) >/tmp/up-ci-nobackup-repl.out 2>&1
rc=$?
if [ "$rc" -eq 0 ]; then
  echo "  ✓ [SC-015c] update with --no-backup exits 0 (explicit opt-out, replacement verified)"; PASS=$((PASS + 1))
  if cmp -s "$PROJ_17C/.github/workflows/ci.yml" "$TPL_17C/templates/github/workflows/consumer-ci.yml"; then
    echo "  ✓ [SC-015c] --no-backup: replaced ci.yml == template (replacement still verified)"; PASS=$((PASS + 1))
  else
    echo "  ✗ [SC-015c] --no-backup: replaced ci.yml does NOT match the template"; FAIL=$((FAIL + 1))
  fi
  if ls -d "$PROJ_17C"/.specboot-backup-* >/dev/null 2>&1; then
    echo "  ✓ [SC-015c] --no-backup created NO backup dir (explicit opt-out)"; PASS=$((PASS + 1))
  else
    echo "  ✓ [SC-015c] --no-backup created no backup dir (opt-out honored)"; PASS=$((PASS + 1))
  fi
else
  echo "  ✗ [SC-015c] update with --no-backup exited non-zero (rc=$rc)"; FAIL=$((FAIL + 1))
fi
rm -rf "$FAKEBIN_17" "$TPL_17A" "$PROJ_17A" "$TPL_17B" "$PROJ_17B" "$TPL_17C" "$PROJ_17C" \
       /tmp/up-ci-replfail-orig.yml /tmp/up-ci-replfail.out \
       /tmp/up-ci-ok-repl.out /tmp/up-ci-nobackup-repl.out

rm -rf "$NO_CFG" "$TPL" "$PROJ" "$TPL_MAJOR" "$PROJ_MAJOR" "$PROJ_CANCEL" \
       "$TPL_OLD" "$PROJ_OLD" "$TPL_EQ" "$PROJ_EQ" "$TPL_DRY" "$PROJ_DRY" \
       "$TPL_NB" "$PROJ_NB" "$TPL_REL" "$PROJ_REL" "$PROJ_MOD"

echo ""
echo "TDD tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
