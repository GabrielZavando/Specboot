#!/usr/bin/env bash
# TDD test for TICKET-AUDIT-3 — release-bump.sh: atomic version bump.
#
# Contract (corrected by protect-consumer-ci / SPECBOOT-HARDEN-04, REQ-006):
#   - SC-004: `bash release-bump.sh <semver>` updates package.json → version
#     and .specboot.json → frameworkVersion in ONE operation
#   - SC-005: the bump syncs ALL version files — package.json, package-lock.json
#     (root + packages[""]) and .specboot.json — in one atomic operation:
#     a corrupted lock aborts with no partial writes; a missing lock is
#     skipped with a note; invalid semver or a missing `## [X.Y.Z]` CHANGELOG
#     section aborts (exit != 0, no writes)
#   - SC-006 (inverts the old M-912 SC-001): the bump creates NO git tag —
#     tag creation belongs to the maintainer's post-merge phase, pointing
#     exactly at the main commit containing the bump
#
# The script lives at the repo root and acts on the CURRENT WORKING
# DIRECTORY, so tests run it inside temp fixtures with the version files
# pre-populated.
#
# Run: bash tests/release-bump-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/release-bump.sh"

PASS=0
FAIL=0

ok()  { echo "  ✓ $1"; PASS=$((PASS + 1)); }
bad() { echo "  ✗ $1: $2"; FAIL=$((FAIL + 1)); }

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then ok "$desc"; else bad "$desc" "expected '$expected', got '$actual'"; fi
}

make_fixture() {
  local dir="$1" ver="$2" changelog="$3"
  mkdir -p "$dir"
  printf '{\n  "name": "fw",\n  "version": "%s"\n}\n' "$ver" > "$dir/package.json"
  printf '{\n  "frameworkVersion": "%s",\n  "name": "proj"\n}\n' "$ver" > "$dir/.specboot.json"
  printf '%s\n' "$changelog" > "$dir/CHANGELOG.md"
}

# --- Precondition: script exists at the repo root ---
if [ ! -f "$SCRIPT" ]; then
  echo "  ✗ [SC-004] release-bump.sh does not exist at repo root"
  echo ""
  echo "TDD tests: 0 passed, 1 failed"
  exit 1
fi

# --- SC-004 + SC-005: happy path syncs ALL version files atomically ---
F1="$(mktemp -d)"
make_fixture "$F1" "0.8.1" '# Changelog

## [0.9.0] - 2026-09-16

- stuff'
# Realistic npm lockfile (lockfileVersion 3): root version + packages[""] entry.
printf '{\n  "name": "fw",\n  "version": "0.8.1",\n  "lockfileVersion": 3,\n  "packages": {\n    "": {\n      "name": "fw",\n      "version": "0.8.1"\n    }\n  }\n}\n' > "$F1/package-lock.json"
( cd "$F1" && bash "$SCRIPT" 0.9.0 ) >/tmp/rb-happy.out 2>&1
rc=$?
assert_eq "[SC-004] happy path exits 0" "0" "$rc"
assert_eq "[SC-004] package.json bumped" "0.9.0" "$(node -e "console.log(require('$F1/package.json').version)")"
assert_eq "[SC-004] .specboot.json bumped" "0.9.0" "$(node -e "console.log(require('$F1/.specboot.json').frameworkVersion)")"
assert_eq '[SC-005] package-lock.json root version bumped' "0.9.0" "$(node -e "console.log(JSON.parse(require('fs').readFileSync('$F1/package-lock.json','utf8')).version)")"
assert_eq '[SC-005] package-lock.json packages[""] version bumped' "0.9.0" "$(node -e "console.log(JSON.parse(require('fs').readFileSync('$F1/package-lock.json','utf8')).packages[''].version)")"
# No git repo here: success itself proves the script never touches git.
if grep -qi "git tag" /tmp/rb-happy.out; then
  bad "[SC-004] script output mentions git tag" "output mentions git tag"
else
  ok "[SC-004] no git tag mentioned"
fi

# --- SC-005: invalid semver aborts without writes ---
F2="$(mktemp -d)"
make_fixture "$F2" "0.8.1" '## [0.9.0]'
( cd "$F2" && bash "$SCRIPT" notsemver ) >/tmp/rb-badver.out 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then ok "[SC-005] invalid semver exits non-zero"; else bad "[SC-005] invalid semver exits non-zero" "exit was 0"; fi
assert_eq "[SC-005] package.json untouched on invalid semver" "0.8.1" "$(node -e "console.log(require('$F2/package.json').version)")"
assert_eq "[SC-005] .specboot.json untouched on invalid semver" "0.8.1" "$(node -e "console.log(require('$F2/.specboot.json').frameworkVersion)")"

# --- SC-005: missing CHANGELOG section aborts without writes ---
F3="$(mktemp -d)"
make_fixture "$F3" "0.8.1" '# Changelog

## [0.8.0] - 2026-09-01'
( cd "$F3" && bash "$SCRIPT" 0.9.0 ) >/tmp/rb-nochangelog.out 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then ok "[SC-005] missing CHANGELOG section exits non-zero"; else bad "[SC-005] missing CHANGELOG section exits non-zero" "exit was 0"; fi
assert_eq "[SC-005] package.json untouched without CHANGELOG section" "0.8.1" "$(node -e "console.log(require('$F3/package.json').version)")"
assert_eq "[SC-005] .specboot.json untouched without CHANGELOG section" "0.8.1" "$(node -e "console.log(require('$F3/.specboot.json').frameworkVersion)")"

# --- SC-009: atomic — corrupt .specboot.json aborts BEFORE touching package.json ---
F4="$(mktemp -d)"
make_fixture "$F4" "0.8.1" '## [0.9.0]'
echo "{ not-json" > "$F4/.specboot.json"
( cd "$F4" && bash "$SCRIPT" 0.9.0 ) >/tmp/rb-corrupt.out 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then ok "[SC-009] corrupt .specboot.json aborts"; else bad "[SC-009] corrupt .specboot.json aborts" "exit was 0"; fi
assert_eq "[SC-009] package.json NOT modified on corrupt peer" "0.8.1" "$(node -e "console.log(require('$F4/package.json').version)")"

# --- SC-010: downgrade / equal version rejected without writes ---
F5="$(mktemp -d)"
make_fixture "$F5" "0.9.0" '## [0.8.0]

## [0.9.0]'
( cd "$F5" && bash "$SCRIPT" 0.8.0 ) >/tmp/rb-downgrade.out 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then ok "[SC-010] downgrade aborts"; else bad "[SC-010] downgrade aborts" "exit was 0"; fi
assert_eq "[SC-010] package.json untouched on downgrade" "0.9.0" "$(node -e "console.log(require('$F5/package.json').version)")"
assert_eq "[SC-010] .specboot.json untouched on downgrade" "0.9.0" "$(node -e "console.log(require('$F5/.specboot.json').frameworkVersion)")"

# --- SC-005: atomicity — corrupt package-lock.json aborts BEFORE any write ---
F6="$(mktemp -d)"
make_fixture "$F6" "0.8.1" '## [0.9.0]'
echo "{ not-json" > "$F6/package-lock.json"
( cd "$F6" && bash "$SCRIPT" 0.9.0 ) >/tmp/rb-lock-corrupt.out 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then ok "[SC-005] corrupt package-lock.json aborts"; else bad "[SC-005] corrupt package-lock.json aborts" "exit was 0"; fi
assert_eq "[SC-005] package.json NOT modified on corrupt lock" "0.8.1" "$(node -e "console.log(require('$F6/package.json').version)")"
assert_eq "[SC-005] .specboot.json NOT modified on corrupt lock" "0.8.1" "$(node -e "console.log(require('$F6/.specboot.json').frameworkVersion)")"

# --- SC-005: package-lock.json absent → bump succeeds and notes the skip ---
F7="$(mktemp -d)"
make_fixture "$F7" "0.8.1" '## [0.9.0]'
# No package-lock.json on purpose.
( cd "$F7" && bash "$SCRIPT" 0.9.0 ) >/tmp/rb-lock-absent.out 2>&1
rc=$?
assert_eq "[SC-005] bump without lock exits 0" "0" "$rc"
assert_eq "[SC-005] package.json bumped without lock" "0.9.0" "$(node -e "console.log(require('$F7/package.json').version)")"
assert_eq "[SC-005] .specboot.json bumped without lock" "0.9.0" "$(node -e "console.log(require('$F7/.specboot.json').frameworkVersion)")"
if grep -q "package-lock" /tmp/rb-lock-absent.out && grep -qiE "not found|skipped" /tmp/rb-lock-absent.out; then
  ok "[SC-005] output notes the lock was skipped"
else
  bad "[SC-005] output notes the lock was skipped" "missing skip note in output"
fi

rm -rf "$F1" "$F2" "$F3" "$F4" "$F5" "$F6" "$F7"

# --- SC-006: bump with uncommitted changes creates NO git tag ---
# Inverts the old M-912 SC-001 (which required a tag after the bump): the tag
# used to be created while the bump changes were still uncommitted, so it
# could point at the commit BEFORE the bump. Tag creation belongs to the
# maintainer's post-merge phase.
FR="$(mktemp -d)"
git -C "$FR" init -q
git -C "$FR" config user.email t@t.local && git -C "$FR" config user.name t
make_fixture "$FR" "0.8.1" '# Changelog

## [0.9.0] - 2026-09-18'
printf '{\n  "name": "fw",\n  "version": "0.8.1",\n  "lockfileVersion": 3,\n  "packages": {\n    "": {\n      "name": "fw",\n      "version": "0.8.1"\n    }\n  }\n}\n' > "$FR/package-lock.json"
(cd "$FR" && git add package.json .specboot.json CHANGELOG.md package-lock.json && git -c user.email=t@t.local -c user.name=t commit -qm "base") >/dev/null 2>&1
( cd "$FR" && bash "$SCRIPT" 0.9.0 ) >/tmp/rb-notag.out 2>&1
rc=$?
if [ "$rc" -eq 0 ]; then ok "[SC-006] bump in git repo exits 0"; else bad "[SC-006] bump in git repo exits 0" "exit was $rc"; fi
assert_eq "[SC-006] package.json bumped" "0.9.0" "$(node -e "console.log(require('$FR/package.json').version)")"
assert_eq "[SC-006] .specboot.json bumped" "0.9.0" "$(node -e "console.log(require('$FR/.specboot.json').frameworkVersion)")"
assert_eq "[SC-006] package-lock.json bumped" "0.9.0" "$(node -e "console.log(JSON.parse(require('fs').readFileSync('$FR/package-lock.json','utf8')).version)")"
tags="$(git -C "$FR" tag -l)"
if [ -z "$tags" ]; then
  ok "[SC-006] bump creates NO git tag"
else
  bad "[SC-006] bump creates NO git tag" "tags found: $tags"
fi
rm -rf "$FR"

# SC-002: update.sh --bump reads version from package.json (not git describe)
if grep -qE "require\('\./package\.json'\)|require\(.+package\.json" "$ROOT/update.sh"; then
  ok "[SC-002] update.sh reads current version from package.json"
else
  bad "[SC-002] update.sh reads current version from package.json" "no package.json read found"
fi

# SC-003: versioning-standard documents the corrected tagging policy
# (bump never tags; tag is a post-merge maintainer action; GitHub Release is manual)
VS="$ROOT/docs/versioning-standard.md"
tokens_ok=0
for tok in "post-merge" "GitHub Release" "nunca crea tags"; do grep -qi "$tok" "$VS" || tokens_ok=1; done
[ "$tokens_ok" -eq 0 ] && ok "[SC-003] corrected tagging policy documented" || bad "[SC-003] corrected tagging policy documented" "missing policy tokens"

# SC-004: backfilled historical tags exist on the REMOTE (local checkouts in
# CI do not fetch tags — the backfill's contract is about origin, not the local clone)
missing=""
# Prefer the authoritative remote list; fall back to local tags for offline runs.
remote_tags="$(git ls-remote --tags origin 2>/dev/null | awk '{print $2}' | sed 's|refs/tags/||' || true)"
if [ -n "$remote_tags" ]; then
  for v in v0.6.4 v0.7.0 v0.8.0 v0.8.1 v0.9.0; do
    echo "$remote_tags" | grep -qxF "$v" || missing="$missing $v"
  done
else
  for v in v0.6.4 v0.7.0 v0.8.0 v0.8.1 v0.9.0; do
    git rev-parse -q --verify "refs/tags/$v" >/dev/null 2>&1 || missing="$missing $v"
  done
fi
[ -z "$missing" ] && ok "[SC-004] backfilled tags exist on origin (v0.6.4..v0.9.0)" || bad "[SC-004] backfilled tags exist on origin (v0.6.4..v0.9.0)" "missing:$missing"

echo ""
echo "TDD tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
