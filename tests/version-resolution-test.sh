#!/usr/bin/env bash
# TDD test for change fix-consumer-mode — consumer-safe version resolution.
#
# Run: bash tests/version-resolution-test.sh
#
# Bug: in a consumer project, `specboot.sh --version` returned the PROJECT's
# root package.json version (CWD lookup) instead of the framework's, which
# hard-failed `specboot.sh --ci` right after a successful `specboot update`
# ("frameworkVersion (0.6.3) es mayor que la versión instalada (0.1.0)").
#
# Covers (RED first, then GREEN):
#  [SC-001] --version resolves the framework version in a consumer fixture
#  [SC-002] get_framework_version resolves bare relative paths (node_modules/...)
#  [SC-003] dogfooding unchanged (framework repo, no self-dependency)
#  [SC-005] validate-specboot.sh -> specboot.sh --version chain passes when
#           frameworkVersion matches the installed version (consumer fixture)
#  [SC-006] init writes the framework version as frameworkVersion (not the
#           consumer project's decoy 9.9.9)
#  [SC-007] mismatch messages (both branches) suggest verifying the
#           installation (npm ls @gabrielzavando/specboot) with the pinned
#           spec texts intact: declared < installed -> warning exit 0;
#           declared > installed -> error exit 1

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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
assert_contains() {
  local desc="$1" needle="$2" haystack="$3"
  if echo "$haystack" | grep -qF -- "$needle"; then
    echo "  ✓ $desc"; PASS=$((PASS + 1))
  else
    echo "  ✗ $desc (missing '$needle')"; FAIL=$((FAIL + 1))
  fi
}

# Real framework version (dynamic: survives version bumps; no hardcoded pin).
FRAMEWORK_VERSION="$(node -e "console.log(require('$ROOT/package.json').version)" 2>/dev/null || true)"
if [ -z "$FRAMEWORK_VERSION" ]; then
  echo "✗ cannot read the framework version from $ROOT/package.json (node required)"
  exit 1
fi

# Helper: build a consumer-like fixture:
#   - decoy root package.json version 9.9.9 (deliberately higher than the framework)
#   - node_modules/@gabrielzavando/specboot/package.json with the framework version
#   - copies of specboot.sh + validate-specboot.sh (as specboot update would ship them)
#   - optional .specboot.json with a declared frameworkVersion
make_consumer_fixture() {
  local dir="$1" fwver="$2" declared="$3"
  mkdir -p "$dir/node_modules/@gabrielzavando/specboot"
  cp "$ROOT/specboot.sh" "$dir/specboot.sh"
  cp "$ROOT/validate-specboot.sh" "$dir/validate-specboot.sh"
  printf '{"name":"consumer-app","version":"9.9.9"}\n' > "$dir/package.json"
  printf '{"name":"@gabrielzavando/specboot","version":"%s"}\n' "$fwver" \
    > "$dir/node_modules/@gabrielzavando/specboot/package.json"
  if [ -n "$declared" ]; then
    printf '{"frameworkVersion":"%s","name":"proj","description":"","services":["."],"stack":"framework"}\n' "$declared" \
      > "$dir/.specboot.json"
  fi
}

# Helper: call get_framework_version with an explicit argument in a sourced
# subshell (specboot.sh is source-safe: the main block is guarded by
# BASH_SOURCE[0] = $0). Runs in a subshell so `set -u` from the sourced script
# cannot leak into this harness.
call_get_framework_version() {
  local dir="$1" arg="$2"
  ( cd "$dir" && bash -c 'source ./specboot.sh; get_framework_version "$1"' _ "$arg" )
}

# Helper: run the init JSON writer through the sourced script (subshell), then
# extract the written frameworkVersion with node (handles both compact and
# 2-space-indented JSON, unlike the grep+sed idiom which only fits compact).
init_writes_framework_version() {
  local dir="$1"
  ( cd "$dir" && FIXTURE="$dir" bash -c 'source ./specboot.sh; create_initial_specboot_json "$FIXTURE" 0' ) >/dev/null 2>&1
  node -e "try{console.log(require('$dir/.specboot.json').frameworkVersion)}catch(e){process.exit(1)}" 2>/dev/null
}

# ---------- [SC-001] --version resolves the framework version in a consumer ----------
FIX1="$(mktemp -d)"; make_consumer_fixture "$FIX1" "$FRAMEWORK_VERSION" ""
OUT1="$( cd "$FIX1" && bash specboot.sh --version )"
assert_eq "[SC-001] --version returns the framework version (not the decoy 9.9.9)" \
  "$FRAMEWORK_VERSION" "$OUT1"

# ---------- [SC-002] get_framework_version resolves bare relative paths ----------
OUT2="$( call_get_framework_version "$FIX1" "node_modules/@gabrielzavando/specboot" )"
assert_eq "[SC-002] bare relative path resolves the installed package version" \
  "$FRAMEWORK_VERSION" "$OUT2"

# ---------- [SC-003] dogfooding unchanged ----------
if [ -e "$ROOT/node_modules/@gabrielzavando/specboot" ]; then
  ROOT_SELF_DEP=1
else
  ROOT_SELF_DEP=0
fi
assert_eq "[SC-003] framework repo has no self-dependency in node_modules (precondition)" \
  0 "$ROOT_SELF_DEP"
OUT3="$( cd "$ROOT" && bash specboot.sh --version )"
assert_eq "[SC-003] --version returns the framework version in dogfooding" \
  "$FRAMEWORK_VERSION" "$OUT3"

# ---------- [SC-005] validate chain passes when frameworkVersion matches ----------
FIX5="$(mktemp -d)"; make_consumer_fixture "$FIX5" "$FRAMEWORK_VERSION" "$FRAMEWORK_VERSION"
OUT5="$( cd "$FIX5" && bash validate-specboot.sh 2>&1 )"
RC5=$?
assert_exit "[SC-005] validate-specboot.sh exits 0 when frameworkVersion matches" 0 "$RC5"
assert_contains "[SC-005] validator reports the versions coincide (no spurious hard error)" \
  "coincide" "$OUT5"

# ---------- [SC-006] init writes the framework version as frameworkVersion ----------
FIX6="$(mktemp -d)"; make_consumer_fixture "$FIX6" "$FRAMEWORK_VERSION" ""
OUT6="$( init_writes_framework_version "$FIX6" )"
assert_eq "[SC-006] init writes the framework version (not the decoy 9.9.9)" \
  "$FRAMEWORK_VERSION" "$OUT6"

# ---------- [SC-007] mismatch messages suggest verifying install ----------
# (a) declared < installed -> non-blocking warning + hint
FIX7="$(mktemp -d)"; make_consumer_fixture "$FIX7" "$FRAMEWORK_VERSION" "0.0.1"
OUT7="$( cd "$FIX7" && bash validate-specboot.sh 2>&1 )"
RC7=$?
assert_exit "[SC-007] declared < installed warns non-blockingly (exit 0)" 0 "$RC7"
assert_contains "[SC-007] warning suggests verifying the installation (npm ls @gabrielzavando/specboot)" \
  "npm ls @gabrielzavando/specboot" "$OUT7"
assert_contains "[SC-007] warning keeps the pinned 'framework desactualizado' text" \
  "framework desactualizado" "$OUT7"

# (b) declared > installed -> hard error + hint (the ticket's ironic case)
FIX7G="$(mktemp -d)"; make_consumer_fixture "$FIX7G" "$FRAMEWORK_VERSION" "9.8.0"
OUT7G="$( cd "$FIX7G" && bash validate-specboot.sh 2>&1 )"
RC7G=$?
assert_exit "[SC-007] declared > installed errors (exit 1)" 1 "$RC7G"
assert_contains "[SC-007] error suggests verifying the installation (npm ls @gabrielzavando/specboot)" \
  "npm ls @gabrielzavando/specboot" "$OUT7G"
assert_contains "[SC-007] error keeps the pinned 'versión más nueva' text" \
  "versión más nueva" "$OUT7G"

# ---------- cleanup ----------
rm -rf "$FIX1" "$FIX5" "$FIX6" "$FIX7" "$FIX7G"

echo ""
echo "TDD tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
