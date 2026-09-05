#!/usr/bin/env bash
# TDD self-test for the M-902 CI architecture evaluation (change enforce-commit-gates).
#
# Validates (per openspec/changes/enforce-commit-gates — REQ-005 / SC-008):
#   1. The CI architecture decision "keep 2 jobs / 1 file" is registered and
#      justified in PLAN_MEJORAS_SPECBOOT.md (closure "evaluado, sin acción").
#   2. The proven contract stays intact: ci.yml still declares BOTH jobs
#      (validate + project-ci) and openspec/specs/specboot-workflows/spec.md
#      still requires them — this change must NOT migrate the CI architecture.
#
# The script must FAIL (RED) until task 2.2 documents the decision.
#
# Run: bash tests/ci-evaluation-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CI="$ROOT/.github/workflows/ci.yml"
SPEC="$ROOT/openspec/specs/specboot-workflows/spec.md"
PLAN="$ROOT/PLAN_MEJORAS_SPECBOOT.md"

PASS=0
FAIL=0

ok() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
bad() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

# has_all <file> <token> [<token>...] — every token must appear (fixed-string)
has_all() {
  local file="$1"; shift
  local tok
  for tok in "$@"; do
    if ! grep -qF -- "$tok" "$file"; then
      return 1
    fi
  done
  return 0
}

for f in "$CI" "$SPEC" "$PLAN"; do
  if [ ! -f "$f" ]; then
    echo "  ✗ required file missing: $f"
    exit 1
  fi
done

# --- 1. The proven CI contract stays intact (no migration without evidence) ---
echo "CI contract intact (2 jobs / 1 file):"

if grep -qE '^  validate:' "$CI"; then
  ok "[SC-008] ci.yml still declares the validate job (framework self-check)"
else
  bad "[SC-008] ci.yml still declares the validate job (framework self-check)"
fi

if grep -qE '^  project-ci:' "$CI"; then
  ok "[SC-008] ci.yml still declares the project-ci job (project gate)"
else
  bad "[SC-008] ci.yml still declares the project-ci job (project gate)"
fi

if grep -qF 'Requirement: `ci.yml` has a `validate` job' "$SPEC"; then
  ok "[SC-008] specboot-workflows spec still requires the validate job"
else
  bad "[SC-008] specboot-workflows spec still requires the validate job"
fi

if grep -qF 'Requirement: `ci.yml` has a `project-ci` job' "$SPEC"; then
  ok "[SC-008] specboot-workflows spec still requires the project-ci job"
else
  bad "[SC-008] specboot-workflows spec still requires the project-ci job"
fi

# --- 2. M-902 evaluation closed as "keep, no action" with justification ---
echo "M-902 evaluation registered in PLAN_MEJORAS_SPECBOOT.md:"

if grep -qE '^## \[x\] M-902' "$PLAN"; then
  ok "[SC-008] M-902 is closed in the roadmap ([x] heading)"
else
  bad "[SC-008] M-902 is closed in the roadmap ([x] heading)"
fi

if grep -E '^\| v3\.5 \|' "$PLAN" | grep -qF 'M-902' && grep -E '^\| v3\.5 \|' "$PLAN" | grep -qF 'evaluado, sin acción'; then
  ok "[SC-008] M-902 closure registered in the v3.5 history row ('evaluado, sin acción')"
else
  bad "[SC-008] M-902 closure registered in the v3.5 history row ('evaluado, sin acción')"
fi

if has_all "$PLAN" 'decisión: mantener' 'sin evidencia de fricción'; then
  ok "[SC-008] M-902 decision records the keep rationale without consumer-friction evidence"
else
  bad "[SC-008] M-902 decision records the keep rationale without consumer-friction evidence"
fi

# --- Summary ---
echo ""
echo "CI evaluation contract: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
