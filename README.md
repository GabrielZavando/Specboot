# Zavando Specboot

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![OpenCode](https://img.shields.io/badge/OpenCode-ready-5B48E5)
![OpenSpec](https://img.shields.io/badge/OpenSpec-ff--change-22C55E)
![Status](https://img.shields.io/badge/Status-Template_SSD-0EA5E9)

Template boilerplate for **Spec-Driven Development (SSD)** using **OpenCode** + **OpenSpec**.

## ¿Qué es?

Repositorio de **configuración y estándares** para que los agentes IA tengan contexto antes de escribir código. **No contiene código de aplicación.**

Incluye:
- Estándares de backend, frontend y documentación
- Definiciones de agentes IA (backend-developer, frontend-developer, build)
- Skills reutilizables (enriquecer stories, commits, auditing, deploy, onboarding)
- Comandos personalizados para el ciclo SSD completo
- Contrato OpenAPI y modelo de datos

## Quick Start

```bash
# 1. Copia el template a tu proyecto
git clone https://github.com/zavando/specboot.git mi-proyecto
cd mi-proyecto

# 2. Ejecuta setup
bash setup.sh

# 3. Inicializa OpenSpec
openspec init

# 4. Personaliza (OBLIGATORIO)
#    - Edita docs/base-standards.md (sección 8)
#    - Edita docs/backend-standards.md y docs/frontend-standards.md
#    - Edita docs/api-spec.yml con tus endpoints
#    - Edita docs/data-model.md con tus entidades

# 5. Verifica personalización
bash setup.sh

# 6. Abre con OpenCode
opencode

# 7. Ejecuta tu primer ciclo SSD
/enrich-us TICKET-ID   # (opcional) si el ticket es vago
/plan-change TICKET-ID # genera specs
/apply TICKET-ID       # implementa (TDD)
/verify TICKET-ID      # valida contra escenarios
/archive TICKET-ID     # archiva el cambio
/commit                # commits + PR
```

## Estructura del Proyecto

```
.
├── docs/                          # 📋 ESTÁNDARES — editar para contexto
│   ├── base-standards.md          #   Reglas globales + contexto proyecto
│   ├── backend-standards.md       #   Stack backend
│   ├── frontend-standards.md      #   Stack frontend
│   ├── documentation-standards.md #   Cómo documentar
│   ├── api-spec.yml               #   Contrato OpenAPI
│   └── data-model.md              #   Entidades del dominio
│
├── ai-specs/                      # ⚙️ NO EDITAR — configuración IA
│   ├── README.md                  #   Índice central de agents y skills
│   ├── agents/                    #   Roles del agente IA
│   ├── skills/                    #   Flujos reutilizables
│   └── examples/                  #   Ejemplos OpenSpec
│
├── .github/workflows/             # CI/CD
│   ├── ci.yml                     #   Tests, lint, security
│   └── deploy.yml                 #   Deploy a staging/production
│
├── AGENTS.md                      # NO EDITAR — instrucciones OpenCode
├── opencode.json                  # ⚙️ EDITAR SOLO model
├── setup.sh                       # Script de inicialización
├── validate.sh                    # Validación de configuración
├── .env.example                   # Template de variables entorno
├── .commitlintrc.json             # Conventional commits enforced
└── README.md                      # Este archivo
```

## Archivos que DEBES editar

| Archivo | Qué editar |
|---------|-----------|
| `docs/base-standards.md` | Sección 8: stack, arquitectura, dominio, cliente |
| `docs/backend-standards.md` | Stack: runtime, framework, ORM, DB, tests |
| `docs/frontend-standards.md` | Stack: framework, CSS, build, tests |
| `docs/api-spec.yml` | Endpoints reales de tu API |
| `docs/data-model.md` | Entidades reales del dominio |
| `opencode.json` | Campo `model` si quieres otro proveedor |

## Flujo SSD — Comandos

| Comando | Descripción |
|---------|-------------|
| `/enrich-us TICKET-ID` | Refinar ticket vago con criterios Gherkin |
| `/plan-change TICKET-ID` | Generar specs (escenarios, requirements, tasks) |
| `/apply TICKET-ID` | Implementar primera tarea con TDD |
| `/verify TICKET-ID` | Validar código contra escenarios |
| `/adversarial-review` | Auditoría 7 fases (seguridad, tipos, perf, etc.) |
| `/archive TICKET-ID` | Archivar el cambio |
| `/commit` | Commits convencionales + Pull Request |

## Workflow Visual

```
/enrich-us (opcional)
       ↓
/plan-change → genera .openspec/<ticket>/
       ↓
/apply → implementa tasks (1 por vez, TDD)
       ↓
/verify → valida escenarios
       ↓
/adversarial-review (opcional)
/archive → cierra el cambio
       ↓
/commit → commits + PR
```

## Skills Disponibles

| Skill | Uso |
|-------|-----|
| `enrich-us` | `/enrich-us` antes de planificar |
| `commit` | `/commit` al final del ciclo |
| `code-auditing` | `/adversarial-review` antes de archivar |
| `using-git-worktrees` | Workspaces aislados por feature |
| `deploy` | Release, version bump, Docker, rollback |
| `onboarding` | Setup para nuevos desarrolladores |

Ver `ai-specs/README.md` para índice completo.

## Personalización Avanzada

### Cambiar modelo de IA

```json
// opencode.json
{
  "model": "anthropic/claude-sonnet-4-7",
  "agent": {
    "plan": { "model": "anthropic/claude-opus-4-7" }
  }
}
```

### Agregar nuevo skill

1. Crear `ai-specs/skills/mi-skill/SKILL.md`
2. Agregar a `AGENTS.md` → Available skills

### Configurar MCP servers

```json
// opencode.json
{
  "mcp": {
    "postgres": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-postgres", "--connection-string", "postgresql://..."]
    }
  }
}
```

### Permisos de bash personalizados

```json
// opencode.json
{
  "permission": {
    "bash": {
      "docker *": "allow",
      "rm -rf *": "ask",
      "*": "deny"
    }
  }
}
```

## CI/CD Incluido

- **`.github/workflows/ci.yml`**: Tests, lint, typecheck, security audit, commitlint
- **`.github/workflows/deploy.yml`**: Docker build, deploy a staging/producción, smoke tests, rollback
- **`.commitlintrc.json`**: Conventional Commits enforced

## Requisitos

| Herramienta | Versión mínima |
|-------------|---------------|
| Node.js | 20.19.0 |
| OpenCode | última |
| OpenSpec CLI | última |

```bash
npm install -g @fission-ai/openspec@latest
```

## Validación

Ejecuta `bash validate.sh` para verificar que todo está configurado:

```bash
✅ Valida estructura de archivos
✅ Valida symlinks
✅ Detecta placeholders sin reemplazar
✅ Valida JSON de opencode.json
✅ Verifica skills y ejemplos
```

## FAQ

**¿Necesito OpenSpec?** Sí. Sin él, `/plan-change`, `/apply`, `/verify` y `/archive` no funcionan.

**¿Puedo cambiar el modelo?** Sí. Edita `opencode.json > model`.

**¿Funciona con Cursor/Claude Code?** Sí. `bash setup.sh` crea los symlinks necesarios.

**¿Puedo usar esto con proyecto existente?** Sí. Copia el template y ejecuta los pasos de personalización.

---

## 📄 Licencia

MIT © 2026 [Gabriel Zavando](https://gabrielzavando.cl)

Basado en [lidr-specboot](https://github.com/LIDR-academy/lidr-specboot).