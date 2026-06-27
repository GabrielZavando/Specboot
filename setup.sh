#!/bin/bash
# setup.sh — Inicializar symlinks y verificar estructura del repo SSD
# Ejecutar desde la raíz del proyecto: bash setup.sh

set -e

echo "🔧 Zavando Specboot — Setup SSD"
echo "================================"

# Crear symlinks para compatibilidad multi-agente
echo ""
echo "→ Creando symlinks y verificando archivos de agente..."

# AGENTS.md es el archivo de instrucciones principal para OpenCode/Codex
[ -f "AGENTS.md" ] && echo "  ✓ AGENTS.md existe" || echo "  ✗ FALTA AGENTS.md"

# .claude/skills → ai-specs/skills
mkdir -p .claude
if [ ! -L ".claude/skills" ]; then
  ln -s ../ai-specs/skills .claude/skills
  echo "  ✓ .claude/skills → ai-specs/skills"
else
  echo "  ✓ .claude/skills (ya existe)"
fi

# .claude/agents → ai-specs/agents
if [ ! -L ".claude/agents" ]; then
  ln -s ../ai-specs/agents .claude/agents
  echo "  ✓ .claude/agents → ai-specs/agents"
else
  echo "  ✓ .claude/agents (ya existe)"
fi

# .cursor/rules → ai-specs (Cursor)
mkdir -p .cursor
if [ ! -L ".cursor/rules" ]; then
  ln -s ../ai-specs .cursor/rules
  echo "  ✓ .cursor/rules → ai-specs"
else
  echo "  ✓ .cursor/rules (ya existe)"
fi

# Verificar estructura
echo ""
echo "→ Verificando estructura..."

FILES=(
  "docs/base-standards.md"
  "docs/backend-standards.md"
  "docs/frontend-standards.md"
  "docs/documentation-standards.md"
  "docs/api-spec.yml"
  "docs/data-model.md"
  "ai-specs/agents/backend-developer.md"
  "ai-specs/agents/frontend-developer.md"
  "ai-specs/agents/build-agent.md"
  "ai-specs/skills/enrich-us/SKILL.md"
  "ai-specs/skills/commit/SKILL.md"
  "ai-specs/skills/code-auditing/SKILL.md"
  "ai-specs/skills/using-git-worktrees/SKILL.md"
  "opencode.json"
  ".github/pull_request_template.md"
  "LICENSE"
)

ALL_OK=true
for f in "${FILES[@]}"; do
  if [ -f "$f" ]; then
    echo "  ✓ $f"
  else
    echo "  ✗ FALTA: $f"
    ALL_OK=false
  fi
done

# Verificar placeholders comunes (no deben existir en un proyecto personalizado)
echo ""
echo "→ Verificando configuración personalizada..."

PLACEHOLDERS=(
  "\[definir stack"
  "\[Clean Architecture"
  "\[descripción del dominio"
  "\[nombre del cliente"
  "\[definir stack del proyecto"
)

PLACEHOLDER_FOUND=false
for placeholder in "${PLACEHOLDERS[@]}"; do
  if grep -rqE "$placeholder" docs/ 2>/dev/null; then
    echo "  ⚠️  Placeholder encontrado: $placeholder"
    grep -rlE "$placeholder" docs/ | while read -r file; do
      echo "      → $file"
    done
    PLACEHOLDER_FOUND=true
  fi
done

if [ "$PLACEHOLDER_FOUND" = true ]; then
  echo ""
  echo "⚠️  ATENCIÓN: Se detectaron placeholders sin reemplazar."
  echo "   Ejecuta los pasos de personalización en el README (sección 8)."
  echo "   Archivos afetados: docs/base-standards.md, docs/backend-standards.md, docs/frontend-standards.md"
else
  echo "  ✓ Sin placeholders detectados"
fi

# Verificar que opencode.json tenga un model válido
echo ""
echo "→ Verificando opencode.json..."

if grep -q '"model": "deepseek-v4-flash-free"' opencode.json 2>/dev/null; then
  echo "  ⚠️  opencode.json usa el model por defecto (deepseek-v4-flash-free)"
  echo "   Considera cambiarlo por tu modelo preferido en la sección 'model'"
else
  echo "  ✓ Model personalizado detectado"
fi

echo ""
if [ "$ALL_OK" = true ]; then
  echo "✅ Setup completo."

  if [ "$PLACEHOLDER_FOUND" = true ]; then
    echo ""
    echo "⚠️  Recuerda personalizar los archivos docs/ antes de comenzar."
  fi

  echo ""
  echo "Próximos pasos:"
  echo "   1. Editar docs/base-standards.md con el stack del proyecto"
  echo "   2. Editar docs/backend-standards.md y docs/frontend-standards.md"
  echo "   3. Actualizar opencode.json con el modelo y reglas del proyecto"
  echo "   4. Ejecutar: openspec init"
  echo "   5. Comenzar con: /enrich-us TICKET-ID o /plan-change TICKET-ID"
else
  echo "⚠️  Faltan archivos. Revisar estructura del repositorio."
  exit 1
fi