# Zavando Specboot

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![OpenCode](https://img.shields.io/badge/OpenCode-ready-5B48E5)
![OpenSpec](https://img.shields.io/badge/OpenSpec-ff--change-22C55E)
![Status](https://img.shields.io/badge/Status-Template_SSD-0EA5E9)

Template boilerplate de **Spec-Driven Development (SSD)** para proyectos que usan **OpenCode** + **OpenSpec**.

## 📖 ¿Qué es esto?

Zavando Specboot es un repositorio de **configuración y estándares** que se copia al inicio de un proyecto nuevo para que los asistentes de IA (OpenCode, Codex, Cursor) tengan el contexto necesario antes de escribir cualquier línea de código.

**No contiene código de producto.** Contiene:

- **Estándares** de backend, frontend y documentación
- **Definiciones de agente** IA (backend-developer, frontend-developer, build)
- **Skills reutilizables** (enriquecer user stories, commit convencionales, code auditing)
- **Comandos personalizados** para el ciclo SSD completo
- **Contrato OpenAPI** y **modelo de datos** actualizables

### ¿Para quién es?

- Equipos que usan **OpenCode** como asistente de desarrollo
- Proyectos que quieren aplicar **TDD y Spec-Driven Development** de forma disciplinada
- Desarrolladores que quieren que la IA entienda el **stack, la arquitectura y las reglas del proyecto** antes de escribir código

### ¿Qué problema resuelve?

Sin este template, el asistente IA arranca sin contexto: no sabe si el proyecto usa NestJS o Express, PostgreSQL o MySQL, Clean Architecture o MVC. El resultado es código genérico que hay que corregir. Con este template, el agente IA **lee los estándares primero** y genera código coherente desde el primer intento.

---

## 🚀 Quick Start — Guía detallada

Guía paso a paso para copiar este template en un proyecto nuevo y empezar a usarlo con OpenCode + OpenSpec.

### Prerrequisitos

Antes de empezar, asegúrate de tener instalado:

| Herramienta | Versión mínima | Verificar instalación | Instalación |
|-------------|---------------|----------------------|-------------|
| **Node.js** | 20.19.0 | `node --version` | [nodejs.org](https://nodejs.org) |
| **OpenCode** | última | `opencode --version` | [opencode.ai](https://opencode.ai) |
| **OpenSpec CLI** | última | `openspec --version` | `npm install -g @fission-ai/openspec@latest` |

> ⚠️ Si `openspec --version` falla después de instalar, abre una **nueva terminal** o ejecuta `hash -r` para refrescar el PATH.

---

### Paso 1: Copia el template a tu proyecto

Elige una de estas dos opciones:

<details>
<summary><b>Opción A — Usando el template de GitHub (recomendado)</b></summary>

Si el repositorio está configurado como template en GitHub:

```bash
# Crea un nuevo repositorio desde el template
gh repo create mi-proyecto --template zavando/specboot --clone
cd mi-proyecto
```

Si no tienes `gh` instalado, usa la interfaz web: botón **"Use this template"** en GitHub.
</details>

<details>
<summary><b>Opción B — Copia manual desde el repositorio descargado</b></summary>

```bash
# Clona o descarga el template
git clone https://github.com/zavando/specboot.git
cd specboot

# Luego cópialo a tu proyecto
cp -rn * ../mi-proyecto/
cp -rn .github ../mi-proyecto/
cd ../mi-proyecto
```
</details>

---

### Paso 2: Ejecuta el setup inicial

```bash
bash setup.sh
```

**¿Qué hace este script?**

1. Verifica que todos los archivos del template estén presentes
2. Crea symlinks para compatibilidad con Claude Code (`.claude/`) y Cursor (`.cursor/rules/`)
3. Muestra los siguientes pasos

**Output esperado:**

```
🔧 Zavando Specboot — Setup SSD
→ Creando symlinks y verificando archivos de agente...
  ✓ AGENTS.md existe
  ✓ .claude/skills → ai-specs/skills
  ✓ .claude/agents → ai-specs/agents
  ✓ .cursor/rules → ai-specs
→ Verificando estructura...
  ✓ docs/base-standards.md
  ✓ docs/backend-standards.md
  ✓ docs/frontend-standards.md
  ✓ docs/documentation-standards.md
  ✓ docs/api-spec.yml
  ✓ docs/data-model.md
  ✓ ai-specs/agents/backend-developer.md
  ✓ ai-specs/agents/frontend-developer.md
  ✓ ai-specs/agents/build-agent.md
  ✓ ai-specs/skills/enrich-us/SKILL.md
  ✓ ai-specs/skills/commit/SKILL.md
  ✓ ai-specs/skills/code-auditing/SKILL.md
  ✓ ai-specs/skills/using-git-worktrees/SKILL.md
  ✓ opencode.json
  ✓ .github/pull_request_template.md
✅ Setup completo. Próximos pasos:
   1. Editar docs/base-standards.md con el stack del proyecto
   2. Editar docs/backend-standards.md y docs/frontend-standards.md
   3. Actualizar opencode.json con el modelo y reglas del proyecto
   4. Ejecutar: openspec init
   5. Comenzar con: /enrich-us TICKET-ID o /plan-change TICKET-ID
```

> ❌ **Si ves algún `✗ FALTA:`** significa que faltan archivos. Re-clona el template o verifica que la copia fue completa.

---

### Paso 3: Inicializa OpenSpec

```bash
openspec init
```

Esto crea el directorio oculto `.openspec/` donde se almacenarán los artefactos de cada cambio (scenarios, requirements, tasks).

**Output esperado:**

```
✔ OpenSpec initialized in .openspec/
```

> ⚠️ **No edites manualmente los archivos dentro de `.openspec/`**. OpenSpec los gestiona automáticamente cuando ejecutas `/plan-change` y `/archive`.

---

### Paso 4: Personaliza los archivos de contexto (obligatorio)

Este paso es **fundamental**. El template viene con placeholders genéricos. Si no los reemplazas, el agente IA generará código sin conocer tu stack real.

Edita los siguientes archivos **uno por uno**:

#### 4a. `docs/base-standards.md` — Sección 8: contexto del proyecto

Localiza la sección `## 8. Contexto del proyecto` al final del archivo y reemplaza los placeholders:

```diff
- Stack: [definir stack del proyecto aquí]
+ Stack: NestJS 11 + Prisma + PostgreSQL 16 + React 19 + Tailwind v4

- Arquitectura: [Clean Architecture / MVC / etc.]
+ Arquitectura: Clean Architecture con capas: Presentation, Application, Domain, Infrastructure

- Dominio: [descripción del dominio de negocio]
+ Dominio: E-commerce B2B con catálogo de productos, carrito de compras y órdenes

- Cliente: [nombre del cliente]
+ Cliente: RetailStore SPA
```

#### 4b. `docs/backend-standards.md` — sección "Stack específico"

```diff
- Runtime: Node.js 20 / PHP 8.2 / Python 3.11
+ Runtime: Node.js 22

- Framework: Express / Laravel / FastAPI
+ Framework: NestJS 11

- ORM: Prisma / Eloquent / SQLAlchemy
+ ORM: Prisma 6

- Base de datos: PostgreSQL / MySQL
+ Base de datos: PostgreSQL 16

- Cache: Redis
+ Cache: Redis 7

- Tests: Jest / PHPUnit / pytest
+ Tests: Vitest + Supertest (E2E)
```

#### 4c. `docs/frontend-standards.md` — sección "Stack específico"

```diff
- Framework: Astro / React / Vue / Next.js
+ Framework: React 19 con Next.js 15 (App Router)

- CSS: Tailwind CSS v4
+ CSS: Tailwind CSS v4 + shadcn/ui

- Build: Vite
+ Build: Next.js (built-in) + Turbopack

- Tests: Vitest / Playwright
+ Tests: Vitest + Playwright + Testing Library

- Deploy: Cloudflare Pages / Vercel / Netlify
+ Deploy: Vercel
```

#### 4d. `docs/data-model.md`

Reemplaza las entidades de ejemplo (User, Order) con las entidades reales de tu dominio:

```markdown
## Entidades del dominio

### Product

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | UUID (PK) | Identificador único |
| name | VARCHAR(200) | Nombre del producto |
| slug | VARCHAR(200) UNIQUE | Slug para URL |
| description | TEXT | Descripción del producto |
| price | DECIMAL(10,2) | Precio en CLP (incluye IVA) |
| stock | INTEGER | Stock disponible |
| category_id | UUID (FK → categories) | Categoría del producto |
| is_active | BOOLEAN | Visible en tienda |
| created_at | TIMESTAMP | Fecha de creación |
| updated_at | TIMESTAMP | Última modificación |

### Relaciones

```
Category 1--N Product
Product N--N Order (via OrderItem)
Order 1--N OrderItem
```

### Reglas de negocio

- Un producto no puede venderse si `stock = 0` e `is_active = false`
- El precio incluye IVA; el backend debe calcular el desglose
- Una orden no puede modificarse después de 24 horas de creada
```

#### 4e. `docs/api-spec.yml`

Agrega los endpoints reales de tu API. El template ya incluye un health check como punto de partida:

```yaml
paths:
  /health:
    get:
      summary: Health check
      ...

  # ──────────────────────────────────────
  # Agrega aquí tus endpoints reales
  # ──────────────────────────────────────

  /api/v1/products:
    get:
      summary: Listar productos (paginado)
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
      responses:
        "200":
          description: Lista de productos
```

> 💡 **Tip:** Mantén este archivo sincronizado con la implementación. Cada vez que `/apply` modifique un endpoint, el agente actualizará `api-spec.yml` automáticamente.

---

### Paso 5: Verifica que todo está correcto

Ejecuta `setup.sh` nuevamente para confirmar que no hay errores después de tus ediciones:

```bash
bash setup.sh
```

Si ves solo `✓` verdes, estás listo.

---

### Paso 6: Abre el proyecto con OpenCode

```bash
cd tu-proyecto
opencode
```

**¿Qué ocurre al abrir OpenCode?**

1. OpenCode lee `AGENTS.md` automáticamente
2. Carga los archivos listados en `opencode.json > instructions`
3. Los agentes IA cargan sus roles desde `ai-specs/agents/`
4. Los skills están disponibles en `ai-specs/skills/`
5. Los custom commands (`/plan-change`, `/apply`, etc.) están listos para usarse

---

### Paso 7: Ejecuta tu primer ciclo SSD completo

Prueba que todo funciona con un cambio de ejemplo:

```bash
# En la sesión de OpenCode:

# 1. (Opcional) Enriquecer user story si está vaga
/enrich-us DEMO-001

# 2. Generar specs y tasks
/plan-change DEMO-001

# 3. Implementar la primera tarea (TDD)
/apply DEMO-001

# 4. Validar contra escenarios
/verify DEMO-001

# 5. Archivar el cambio
/archive DEMO-001

# 6. Hacer commit y PR
/commit
```

> ✅ Si llegaste hasta aquí sin errores, tu proyecto está configurado y listo para desarrollo SSD.

---

### Resumen visual del flujo de inicio

```
  1. template      2. bash setup.sh        3. openspec init
       │                 │                       │
       └──────▶  cp -rn * mi-proyecto/           │
                                                  ▼
                                    4. Editar docs/ (stack, modelo, API)
                                                  │
                                                  ▼
                                    5. bash setup.sh (verificar)
                                                  │
                                                  ▼
                                    6. opencode (cargar contexto)
                                                  │
                                                  ▼
                         7. /plan-change PRIMER-TICKET
                                  │
                          ┌───────┴────────┐
                          ▼                ▼
                    /apply            /enrich-us
                    /verify           (si está vaga)
                    /archive
                    /commit
```

---

## 📁 Estructura del proyecto

```
.
├── docs/                          # 📝 ESTÁNDARES — editar para contexto del proyecto
│   ├── base-standards.md          #   Reglas globales + contexto del proyecto (editar sección 8)
│   ├── backend-standards.md       #   Stack backend (framework, ORM, DB, tests)
│   ├── frontend-standards.md      #   Stack frontend (framework, CSS, build, tests)
│   ├── documentation-standards.md #   Cómo documentar código y APIs
│   ├── api-spec.yml               #   🚨 Contrato OpenAPI (actualizar con cada endpoint)
│   └── data-model.md              #   🚨 Entidades del dominio (actualizar con cada cambio)
│
├── ai-specs/                      # ⚙️ NO EDITAR — definiciones de agente y skills
│   ├── agents/                    #   Roles del agente IA
│   │   ├── backend-developer.md   #     Responsable de backend
│   │   ├── frontend-developer.md  #     Responsable de frontend
│   │   └── build-agent.md         #     Full-stack (invocado por /apply)
│   ├── skills/                    #   Flujos reutilizables
│   │   ├── enrich-us/SKILL.md     #     Enriquecer user story
│   │   ├── commit/SKILL.md        #     Conventional commits + PR
│   │   ├── code-auditing/SKILL.md #     Auditoría de código (7 fases)
│   │   └── using-git-worktrees/SKILL.md
│   └── examples/
│       └── tasks.md               #   Ejemplo de artefacto OpenSpec
│
├── AGENTS.md                      # 📖 NO EDITAR — instrucciones que OpenCode lee al iniciar
├── opencode.json                  # ⚙️ EDITAR SOLO modelo — configuración de agentes y comandos
├── .github/
│   └── pull_request_template.md   # 📝 Template de PR para GitHub
├── setup.sh                       # 🔧 Script de inicialización
├── LICENSE                        # 📄 MIT
└── README.md                      # 📖 Este archivo
```

### Archivos que DEBES editar (personalización obligatoria)

| Archivo | ¿Qué editar? | Ejemplo |
|---------|-------------|---------|
| `docs/base-standards.md` | Sección 8: stack, arquitectura, dominio, cliente | `Stack: NestJS 11 + Prisma + PostgreSQL` |
| `docs/backend-standards.md` | Sección "Stack específico" | `Framework: NestJS 11`, `ORM: Prisma 6` |
| `docs/frontend-standards.md` | Sección "Stack específico" | `Framework: React 19`, `CSS: Tailwind v4` |
| `docs/api-spec.yml` | Endpoints reales de tu API | `/api/v1/products`, `/api/v1/orders` |
| `docs/data-model.md` | Entidades reales del dominio | `Product`, `Order`, `Category` |

### Archivos que NO debes editar (salvo que sepas exactamente lo que haces)

| Archivo | Razón |
|---------|-------|
| `AGENTS.md` | OpenCode lo lee automáticamente al iniciar sesión. Cambiarlo puede romper el contexto del agente. |
| `opencode.json` | Define agentes y comandos. Solo debes cambiar el campo `model` si quieres otro proveedor. |
| `ai-specs/agents/*.md` | Definen el rol y comportamiento del agente IA. |
| `ai-specs/skills/*/SKILL.md` | Flujos de trabajo reutilizables. La mayoría usa placeholders. |
| `ai-specs/examples/tasks.md` | Solo referencia visual del formato de artefactos OpenSpec. |

---

## 🧠 Flujo SSD — Paso a paso

El ciclo de desarrollo completo consta de 7 comandos que se ejecutan secuencialmente dentro de OpenCode. Cada comando corresponde a una fase del Spec-Driven Development.

### 1. `/enrich-us TICKET-ID` — (opcional) Refinar user story

**Cuándo usarlo:** Cuando el ticket o user story es vago, incompleto o no tiene criterios de aceptación claros.

**Qué hace internamente:**
1. Carga el skill `ai-specs/skills/enrich-us/SKILL.md`
2. Ejecuta el agente `plan` en modo read-only (analiza, no edita)
3. Enriquese la story con: formato As/Quiero/Para, criterios Gherkin, edge cases, Definition of Done

**Output esperado:**
```markdown
## User Story enriquecida: TICKET-123

**Como** usuario registrado
**Quiero** resetear mi contraseña
**Para** poder acceder si la olvidé

**Escenario 1: Reset exitoso**
- Dado que soy un usuario registrado con email válido
- Cuando solicito reset de contraseña
- Entonces recibo un email con link de reset
```

**Siguiente paso:** `/plan-change TICKET-ID`

---

### 2. `/plan-change TICKET-ID` — Generar especificaciones

**Cuándo usarlo:** Al iniciar un nuevo cambio. Es el paso **obligatorio** que inicia el ciclo SSD.

**Qué hace internamente:**
1. Ejecuta el comando `openspec ff-change TICKET-ID` en la terminal
2. OpenSpec analiza el ticket y genera artefactos en `.openspec/TICKET-ID/`:
   - `scenarios.md` — escenarios de aceptación
   - `requirements.md` — requerimientos funcionales y técnicos
   - `tasks.md` — lista de tareas a implementar (la usa `/apply`)
3. Muestra el `tasks.md` para confirmación visual

**Output esperado:**
```
✔ Change TICKET-123 created
  .openspec/TICKET-123/
  ├── scenarios.md
  ├── requirements.md
  └── tasks.md
```

**Siguiente paso:** `/apply TICKET-ID`

---

### 3. `/apply TICKET-ID` — Implementar con TDD

**Cuándo usarlo:** Después de generar los specs con `/plan-change`.

**Qué hace internamente:**
1. Lee `tasks.md` del cambio activo
2. Identifica la primera tarea pendiente (no marcada como `[x]`)
3. Carga `ai-specs/agents/build-agent.md`
4. Detecta si la tarea es backend, frontend o ambas
5. Carga los estándares y el rol de agente correspondiente
6. **TDD cycle por tarea:**
   - Escribe el test que falla (🔴 red)
   - Implementa el mínimo código para que pase (🟢 green)
   - Refactoriza si es necesario (🔵 refactor)
7. Actualiza `docs/api-spec.yml` si la tarea modifica la API
8. Actualiza `docs/data-model.md` si la tarea modifica el modelo de datos
9. Marca la tarea como completada en `tasks.md`
10. Pasa a la siguiente tarea pendiente

**Regla importante:** El agente implementa **una tarea a la vez**. Si hay 5 tareas, ejecuta `/apply` una vez, revisa, y vuelve a ejecutarlo para la siguiente.

**Siguiente paso:** `/verify TICKET-ID`

---

### 4. `/verify TICKET-ID` — Validar contra especificaciones

**Cuándo usarlo:** Después de implementar con `/apply`.

**Qué hace internamente:**
1. Lee `scenarios.md` y `requirements.md` del cambio
2. Revisa el código implementado contra cada escenario
3. Ejecuta la suite de tests
4. Genera un reporte de cobertura de escenarios

**Output esperado:**
```
Verification Report for TICKET-123
  ✅ 5/5 scenarios covered
  ✅ All tests passing (42 passed, 0 failed)
  ✅ API spec matches implementation
  ✅ Data model updated
```

**Siguiente paso:** `/adversarial-review` (opcional) o `/archive TICKET-ID`

---

### 5. `/adversarial-review` — Auditoría de calidad (opcional)

**Cuándo usarlo:** Antes de archivar, para cambios críticos o cuando se requiere una revisión de seguridad/calidad.

**Qué hace internamente:**
1. Carga `ai-specs/skills/code-auditing/SKILL.md`
2. Ejecuta el agente `reviewer` en modo subagent
3. Realiza auditoría en **7 fases**:
   - 🔒 **Seguridad:** inputs sin sanitizar, credenciales expuestas, SQLi, XSS, CSRF
   - 🏷️ **Tipos y contratos:** `any` sin justificación, API spec desactualizado
   - ⚡ **Performance:** N+1 queries, over-fetching, recursos sin liberar
   - 🗑️ **Código muerto:** funciones no usadas, imports huérfanos
   - 📚 **Best practices:** APIs deprecadas, vulnerabilidades en dependencias
   - 🧪 **Tests:** cobertura baja, mocks frágiles, casos edge faltantes
   - 🔄 **OpenSpec Alignment:** código vs escenarios, requirements, tasks.md

**Output esperado:**
```markdown
### Hallazgos críticos (bloquean el merge)
- [ ] Password hashing usa SHA-256 en vez de bcrypt

### Hallazgos importantes (resolver en siguiente sprint)
- [ ] Función `formatDate` duplicada en 3 archivos
```

**Siguiente paso:** Corregir hallazgos → `/verify` → `/archive TICKET-ID`

---

### 6. `/archive TICKET-ID` — Archivar el cambio

**Cuándo usarlo:** Cuando todas las tareas están completadas y verificadas.

**Qué hace internamente:**
1. Verifica que todas las tareas en `tasks.md` están marcadas como completadas
2. Ejecuta `openspec archive` para mover los artefactos a la carpeta de cambios archivados
3. Confirma que el cambio está finalizado

**Output esperado:**
```
✔ Change TICKET-123 archived
```

**Siguiente paso:** `/commit`

---

### 7. `/commit` — Commit convencional + Pull Request

**Cuándo usarlo:** Al final del ciclo, después de archivar.

**Qué hace internamente:**
1. Carga `ai-specs/skills/commit/SKILL.md`
2. Verifica que todos los tests pasen
3. Revisa el diff completo
4. Agrupa los cambios en commits lógicos:
   - Si hay cambios en `docs/api-spec.yml` → commit de tipo `docs`
   - Si hay cambios en `.openspec/` → commit de tipo `docs`
   - Si hay cambios de funcionalidad → commit de tipo `feat`
5. Crea un Pull Request usando `.github/pull_request_template.md`
6. Referencia el ticket OpenSpec en el PR body

**Output esperado:**
```
Created PR #42: feat(auth): implement password reset
  https://github.com/tu-repo/mi-proyecto/pull/42
```

**Fin del ciclo** ✅

---

## ⚙️ Referencia de comandos

Todos los comandos están definidos en `opencode.json` y se ejecutan dentro de la sesión de OpenCode.

| Comando | Agente | Modo | ¿Qué hace? | ¿Cuándo usarlo? |
|---------|--------|------|-----------|----------------|
| `/enrich-us TICKET-ID` | `plan` | read-only | Enriquece una user story vaga con criterios Gherkin, edge cases y DoD | Cuando el ticket no está bien definido |
| `/plan-change TICKET-ID` | `plan` | read-only | Ejecuta `openspec ff-change` y genera escenarios, requirements y tasks | **Siempre** al iniciar un cambio |
| `/apply TICKET-ID` | `build` | read-write | Implementa la primera tarea pendiente con TDD (test → código → refactor) | Después de `/plan-change` |
| `/verify TICKET-ID` | `build` | read-write | Valida el código contra los escenarios y ejecuta tests | Después de `/apply` |
| `/adversarial-review` | `reviewer` | read-only | Auditoría de 7 fases: seguridad, tipos, performance, código muerto, best practices, tests, OpenSpec alignment | Antes de archivar (opcional) |
| `/archive TICKET-ID` | `build` | read-write | Ejecuta `openspec archive` para finalizar el cambio | Cuando todas las tareas están completas |
| `/commit` | `build` | read-write | Agrupa cambios en commits semánticos y crea PR | Al final del ciclo |

---

## 🔧 Personalización avanzada

Opciones para equipos que quieran ir más allá de la configuración básica.

### Cambiar el modelo por defecto

Edita `opencode.json`:

```json
{
  "model": "anthropic/claude-sonnet-4-7",
  "agent": {
    "plan": {
      "model": "anthropic/claude-opus-4-7"
    }
  }
}
```

Puedes definir modelos distintos para cada agente (plan, build, reviewer).

### Agregar un nuevo skill

1. Crea `ai-specs/skills/mi-skill/SKILL.md`
2. En `AGENTS.md`, agrégalo a la sección "Available skills":

```markdown
Available skills:
- `ai-specs/skills/mi-skill/SKILL.md` — descripción de mi skill
```

3. Si quieres un custom command que lo use, agrégalo en `opencode.json > command`

### Configurar MCP servers

En `opencode.json`:

```json
{
  "mcp": {
    "mi-servidor": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-postgres", "--connection-string", "postgresql://..."]
    }
  }
}
```

### Ajustar permisos de bash

En `opencode.json > permission > bash`, puedes permitir comandos adicionales:

```json
{
  "bash": {
    "docker *": "ask",
    "aws *": "deny",
    "*": "ask"
  }
}
```

### Deshabilitar la edición en el agente build

Si quieres que el agente build no pueda editar archivos:

```json
{
  "build": {
    "permission": {
      "edit": "deny",
      "bash": "allow"
    }
  }
}
```

---

## ❓ FAQ

### ¿Necesito OpenSpec sí o sí?

**Sí.** OpenSpec es el motor del ciclo SSD. Sin él, los comandos `/plan-change`, `/apply`, `/verify` y `/archive` no funcionan. Instálalo con:

```bash
npm install -g @fission-ai/openspec@latest
```

### ¿Puedo usar otro modelo que no sea `deepseek-v4-flash-free`?

**Sí.** Edita el campo `model` en `opencode.json`. Puedes usar Claude, GPT, Gemini o cualquier modelo compatible con OpenCode. Cada agente (plan, build, reviewer) puede tener su propio modelo.

### ¿Funciona si mi proyecto es solo backend o solo frontend?

**Sí.** El agente build-agent.md detecta automáticamente el tipo de tarea y carga solo los estándares relevantes:

- Tarea backend → carga `backend-standards.md` + `backend-developer.md`
- Tarea frontend → carga `frontend-standards.md` + `frontend-developer.md`
- Tarea full-stack → carga ambos

### ¿Qué pasa si edito AGENTS.md?

OpenCode lo leerá con tus modificaciones. Si cambias la estructura de skills o las reglas no negociables, los agentes IA pueden comportarse de forma inesperada. **Solo edítalo si sabes lo que haces.**

### ¿Cómo agrego un nuevo endpoint a la API?

Dos opciones:

1. **Manual:** Edita `docs/api-spec.yml` y agrega el path, parámetros y respuestas
2. **Automático (recomendado):** Durante `/apply`, el agente actualizará `api-spec.yml` automáticamente si la tarea modifica la API

### ¿Qué pasa si ejecuto `/apply` antes de `/plan-change`?**

El agente build buscará el `tasks.md` en `.openspec/`. Si no existe porque no ejecutaste `/plan-change`, fallará con un mensaje claro:

```
No active OpenSpec change found. Run /plan-change TICKET-ID first.
```

### ¿Puedo usar este template con Cursor o Claude Code?

**Sí.**
- **Cursor:** Ejecuta `bash setup.sh` para crear los symlinks en `.cursor/rules/`
- **Claude Code:** El template es compatible, pero los custom commands solo funcionan en OpenCode

### ¿Cómo migro si ya tengo un proyecto empezado?

1. Copia el template a tu proyecto: `cp -rn zavando-specboot/* tu-proyecto/`
2. Ejecuta `bash setup.sh`
3. Edita `docs/` con tu stack real (ver Paso 4 de Quick Start)
4. Ejecuta `openspec init`
5. Los cambios anteriores no se verán afectados. Los nuevos cambios usarán el flujo SSD.

---

## 📄 Licencia

MIT © 2026 [Gabriel Zavando](https://gabrielzavando.cl)

Este proyecto está basado en [lidr-specboot](https://github.com/LIDR-academy/lidr-specboot).

```
MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```
