#!/bin/bash
# setup.sh — Inicializar symlinks y verificar estructura del repo SSD
# Ejecutar desde la raíz del proyecto: bash setup.sh

set -e

echo "🔧 Zavando Specboot — Setup SSD"
echo "================================"

# Crear symlinks para compatibilidad multi-agente
echo "→ Creando symlinks y verificando archivos de agente..."

# AGENTS.md es el archivo de instrucciones principal para OpenCode/Codex
[ -f "AGENTS.md" ] && echo "  ✓ AGENTS.md existe" || echo "  ✗ FALTA AGENTS.md"

# .claude/skills → ai-specs/skills
mkdir -p .claude
if [ ! -L ".claude/skills" ]; then
  ln -s ../ai-specs/skills .claude/skills
  echo "  ✓ .claude/skills → ai-specs/skills"
fi

# .claude/agents → ai-specs/agents
if [ ! -L ".claude/agents" ]; then
  ln -s ../ai-specs/agents .claude/agents
  echo "  ✓ .claude/agents → ai-specs/agents"
fi

# .cursor/rules → ai-specs (Cursor)
mkdir -p .cursor
if [ ! -L ".cursor/rules" ]; then
  ln -s ../ai-specs .cursor/rules
  echo "  ✓ .cursor/rules → ai-specs"
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

echo ""
if [ "$ALL_OK" = true ]; then
  echo "✅ Setup completo. Próximos pasos:"
  echo "   1. Editar docs/base-standards.md con el stack del proyecto"
  echo "   2. Editar docs/backend-standards.md y docs/frontend-standards.md"
  echo "   3. Actualizar opencode.json con el modelo y reglas del proyecto"
  echo "   4. Ejecutar: openspec init"
  echo "   5. Comenzar con: /enrich-us TICKET-ID o /plan-change TICKET-ID"
else
  echo "⚠️  Faltan archivos. Revisar estructura del repositorio."
  exit 1
fi
