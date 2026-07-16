#!/usr/bin/env bash
# check-refs.sh — Referential integrity check for the SSD template.
#
# Verifies that every {file:...} reference found in opencode.json and in all
# SKILL.md files resolves to an existing file (relative to the repository root).
# Broken references are reported as errors and make the script exit non-zero.
#
# Usage:
#   bash check-refs.sh [--root DIR]   Check references (default: repo root)
#   bash check-refs.sh --help         Show this help

# Run from the repository root unless --root is provided.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR"

while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT="$2"; shift 2 ;;
    --help|-h) sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Opción desconocida: $1"; exit 2 ;;
  esac
done

cd "$ROOT" || { echo "No se pudo acceder a $ROOT"; exit 2; }

# Do NOT use 'set -e': this script counts errors and must keep running.
set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

ERRORS=0
CHECKED=0
SKILLS_SCANNED=0

pass() { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; ERRORS=$((ERRORS + 1)); }

# Extract the path inside every {file:...} token in a file (deduplicated).
extract_file_refs() {
  local file="$1"
  [ -f "$file" ] || return 0
  grep -oE '\{file:[^}]+\}' "$file" 2>/dev/null | sed -E 's/^\{file:(.+)\}$/\1/' | sort -u
}

# Verify one reference and count it.
check_ref() {
  local ref="$1"
  [ -z "$ref" ] && return
  CHECKED=$((CHECKED + 1))
  if [ -f "$ref" ]; then
    pass "$ref"
  else
    fail "Referencia rota: {file:$ref} (no existe)"
  fi
}

echo "🔗 Zavando Specboot — Reference Integrity"
echo "========================================="
echo "Root: $ROOT"
echo ""

echo "→ Verificando {file:...} en opencode.json..."
if [ ! -f "opencode.json" ]; then
  fail "opencode.json no encontrado en $ROOT"
else
  while IFS= read -r ref; do
    check_ref "$ref"
  done <<< "$(extract_file_refs opencode.json)"
fi

echo ""
echo "→ Verificando {file:...} en SKILL.md..."
while IFS= read -r skill; do
  [ -z "$skill" ] && continue
  SKILLS_SCANNED=$((SKILLS_SCANNED + 1))
  while IFS= read -r ref; do
    check_ref "$ref"
  done <<< "$(extract_file_refs "$skill")"
done <<< "$(find ai-specs/skills -type f -name SKILL.md 2>/dev/null | sort)"

echo ""
echo "========================================="
echo -e "  ${RED}Errores: $ERRORS${NC}"
echo "  Refs verificadas: $CHECKED"
echo "  SKILL.md escaneados: $SKILLS_SCANNED"

if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo -e "${RED}❌ Integridad referencial fallida${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}✅ Integridad referencial correcta${NC}"
exit 0
