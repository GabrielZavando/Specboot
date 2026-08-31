#!/usr/bin/env bash
# dogfood-check.sh - Framework dogfooding self-check.
#
# Runs the two framework-level validations used when developing Specboot
# with its own SDD flow:
#   1. check-refs.sh    - referential integrity of {file:...} references
#   2. specboot.sh --ci - framework self-check (structure + integrity)
#
# Aborts (non-zero exit) if either validation fails (set -e).
# Run: bash scripts/dogfood-check.sh

set -euo pipefail

echo "🐶 Specboot dogfood check"
echo "-----------------------------------"

echo "→ check-refs.sh"
bash check-refs.sh

echo "→ specboot.sh --ci"
bash specboot.sh --ci

echo "-----------------------------------"
echo "✅ Dogfood check passed"
