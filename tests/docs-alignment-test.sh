#!/usr/bin/env bash
# TDD test for SPECBOOT-HARDEN-02 — documentation alignment (REQ-009, SC-013).
# Locks: archive.md no staging promise; archive skill canonical path; plan-change
# `## Why` length validation; README/framework-contract internal-vs-templates.
#
# Run: bash tests/docs-alignment-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0
ok()  { echo "  ✓ $1"; PASS=$((PASS + 1)); }
bad() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }
has() { grep -qi "$1" "$2"; }

echo "🔍 Docs alignment (SPECBOOT-HARDEN-02, REQ-009)..."

if ! grep -qi "staging" "$ROOT/.opencode/commands/archive.md"; then
  ok  "[REQ-009] archive.md does not promise staging"
else
  bad "[REQ-009] archive.md still promises staging"
fi

if ! grep -q "openspec/archive/" "$ROOT/ai-specs/skills/archive/SKILL.md" \
   && grep -q "openspec/changes/archive/" "$ROOT/ai-specs/skills/archive/SKILL.md"; then
  ok  "[REQ-009] archive skill uses canonical openspec/changes/archive/"
else
  bad "[REQ-009] archive skill uses a non-canonical path"
fi

if has "1000 caracteres" "$ROOT/ai-specs/skills/plan-change/SKILL.md" \
   && has "## Why" "$ROOT/ai-specs/skills/plan-change/SKILL.md"; then
  ok  "[SC-013] plan-change skill validates `## Why` (≤ 1000 chars)"
else
  bad "[SC-013] plan-change skill missing `## Why` length validation"
fi

if has "templates/github" "$ROOT/README.md" \
   && has "internos" "$ROOT/README.md" \
   && has "release.yml" "$ROOT/README.md"; then
  ok  "[REQ-009] README distinguishes internal workflows vs consumer templates"
else
  bad "[REQ-009] README missing internal-vs-templates distinction"
fi

if has "templates/github" "$ROOT/docs/framework-contract.md" \
   && has "internos" "$ROOT/docs/framework-contract.md"; then
  ok  "[REQ-009] framework-contract documents the new distribution boundary"
else
  bad "[REQ-009] framework-contract missing distribution-boundary update"
fi

echo ""
echo "docs-alignment: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]