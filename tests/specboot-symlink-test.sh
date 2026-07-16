#!/usr/bin/env bash
# TDD test for specboot.sh symlink creation with copy fallback (Windows-safe).
#
# Run: bash tests/specboot-symlink-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/specboot.sh"

PASS=0
FAIL=0
assert() {
  local desc="$1" cond="$2"
  if [ "$cond" -eq 0 ]; then echo "  ✓ $desc"; PASS=$((PASS + 1))
  else echo "  ✗ $desc"; FAIL=$((FAIL + 1)); fi
}

if [ ! -f "$SCRIPT" ]; then echo "  ✗ specboot.sh missing (RED)"; exit 1; fi

# --- Case A: ln unavailable -> must fall back to copy (no silent failure) ---
A="$(mktemp -d)"
mkdir -p "$A/ai-specs/skills" "$A/ai-specs/agents"
FAKE="$(mktemp -d)"
printf '#!/bin/sh\necho "ln disabled" >&2\nexit 1\n' > "$FAKE/ln"
chmod +x "$FAKE/ln"
( cd "$A" && PATH="$FAKE:$PATH" bash -c "source '$SCRIPT'; create_symlinks" ) >/dev/null 2>&1
if [ -d "$A/.claude/skills" ]; then assert "fallback creates .claude/skills as copy" 0
else assert "fallback creates .claude/skills as copy" 1; fi
if [ -d "$A/.claude/agents" ]; then assert "fallback creates .claude/agents as copy" 0
else assert "fallback creates .claude/agents as copy" 1; fi
if [ -L "$A/.claude/skills" ]; then assert "fallback did NOT create a symlink" 1
else assert "fallback did NOT create a symlink" 0; fi

# --- Case B: ln available -> creates real symlinks ---
B="$(mktemp -d)"
mkdir -p "$B/ai-specs/skills" "$B/ai-specs/agents"
( cd "$B" && bash -c "source '$SCRIPT'; create_symlinks" ) >/dev/null 2>&1
if [ -L "$B/.claude/skills" ]; then assert "ln creates .claude/skills as symlink" 0
else assert "ln creates .claude/skills as symlink" 1; fi
if [ -L "$B/.claude/agents" ]; then assert "ln creates .claude/agents as symlink" 0
else assert "ln creates .claude/agents as symlink" 1; fi

rm -rf "$A" "$B" "$FAKE"
echo ""
echo "TDD tests: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
