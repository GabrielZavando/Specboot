# Zavando Specboot

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![OpenCode](https://img.shields.io/badge/OpenCode-ready-5B48E5)
![OpenSpec](https://img.shields.io/badge/OpenSpec-new%20change-22C55E)
![Status](https://img.shields.io/badge/Status-Template_SDD-0EA5E9)

Template boilerplate for **Spec-Driven Development (SDD)** using **OpenCode** + **OpenSpec**.

## ¿Qué es?

Repositorio de **configuración y estándares** para que los agentes IA tengan contexto antes de escribir código. **No contiene código de aplicación.**

Incluye:
- Estándares de backend, frontend y documentación
- Agentes IA cableados vía ``file:...``: `plan`, `build` (full-stack), `verify`, `archive`, `reviewer`, y los subagentes `backend` / `frontend` (despachados por `/apply`)
- Skills reutilizables (enriquecer stories, commits, auditing, deploy, onboarding)
- Comandos personalizados para el ciclo SDD completo
- Contrato OpenAPI y modelo de datos
- **Stack-agnostic**: la CI detecta Node o Python y aplica la toolchain SOLID correspondiente
- **Modelo agnóstico**: la selección de IA la gestiona tu gestor externo (Omniroute/OpenCode), no el template

## Quick Start

```bash
# 1. Copia el template a tu proyecto
git clone https://github.com/GabrielZavando/Specboot.git mi-proyecto
cd mi-proyecto

# 2. Ejecuta setup
bash specboot.sh --init

# 3. Inicializa OpenSpec
openspec init

# 4. Personaliza (OBLIGATORIO)
#    - Edita docs/base-standards.md (sección 8)
#    - Edita docs/backend-standards.md y docs/frontend-standards.md
#    - Edita docs/api/api-spec.yml con tus endpoints
#    - Edita docs/data-model/data-model.md con tus entidades

# 5. Verifica personalización
bash specboot.sh --init

# 6. Abre con OpenCode
opencode

# 7. Ejecuta tu primer ciclo SDD
/enrich-us TICKET-ID   # (opcional) si el ticket es vago
/plan-change TICKET-ID # genera specs
/apply TICKET-ID       # implementa (TDD)
/verify TICKET-ID      # valida contra escenarios
/archive TICKET-ID     # archiva el cambio
/commit                # commits + PR
```

## Instalación como paquete NPM

Specboot se distribuye además como paquete privado `@gabrielzavando/specboot` en GitHub Packages, de modo que las aplicaciones consumidoras pueden instalarlo y actualizarlo con comandos NPM nativos (`npm install` / `npm update`).

### Autenticación (una vez por máquina)

Necesitas un Personal Access Token (PAT) con el scope `read:packages`. Créalo en <https://github.com/settings/tokens>.

Opción A — `npm login` interactivo:

```bash
npm login --registry=https://npm.pkg.github.com --scope=@gabrielzavando
# Username: tu usuario de GitHub
# Password: tu PAT (ghp_xxx)
# Email: tu email
```

Opción B — `.npmrc` global (`~/.npmrc`):

```ini
@gabrielzavando:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=ghp_xxx
```

### Instalación en un proyecto consumidor

```bash
npm install --save-dev @gabrielzavando/specboot
```

### Uso desde `node_modules`

Una vez instalado, los scripts de Specboot viven dentro de `node_modules`:

```bash
# Inicializar un proyecto nuevo (inyecta archivos del framework + .specboot.json + docs/)
bash node_modules/@gabrielzavando/specboot/specboot.sh init

# Inicializar con valores interactivos (nombre, stack, services)
bash node_modules/@gabrielzavando/specboot/specboot.sh init --interactive

# Verificar que la estructura del proyecto ya inicializado es correcta
bash node_modules/@gabrielzavando/specboot/specboot.sh --init

# Actualizar un proyecto existente (reemplaza archivos intocables, no toca docs/ ni código)
bash node_modules/@gabrielzavando/specboot/specboot.sh update

# Aceptar un salto major sin preguntar (CI / no-TTY)
bash node_modules/@gabrielzavando/specboot/specboot.sh update --yes

# Previsualizar sin cambiar nada
bash node_modules/@gabrielzavando/specboot/specboot.sh update --dry-run
```

> **`init` vs `--init`**: `specboot init` (sin guiones) **crea** el proyecto desde cero;
> `specboot.sh --init` (con guiones) sólo **verifica** la estructura de un proyecto ya
> inicializado. Si ya existe `.specboot.json`, `init` avisa y sugiere `specboot update`.

### Actualización

```bash
npm update @gabrielzavando/specboot
```

> 💡 Para publicar una nueva versión (maintainers): ejecuta `bash update.sh --bump patch|minor|major`, lo que genera un nuevo tag `vX.Y.Z` y dispara automáticamente el workflow de publicación a GitHub Packages. El modo de sincronización de `update.sh` está deprecado; usa `specboot update` para actualizar proyectos.

## Qué incluye el paquete

`@gabrielzavando/specboot` se publica como **dependencia de desarrollo**. El contenido
del paquete está definido por la allowlist `files` de `package.json` y contiene
**exclusivamente activos intocables del framework** (lo que el framework inyecta, no lo
que tú personalizas):

| Incluido en el paquete | Qué es |
| --- | --- |
| `.opencode/commands/` | Comandos del ciclo SDD (`/plan-change`, `/apply`, `/verify`, `/archive`, `/commit`, `/deploy`, …) |
| `.opencode/agents/` | Agentes IA (plan, build, verify, archive, reviewer) y subagentes (backend, frontend) |
| `ai-specs/` | Roles, skills y ejemplos reutilizables |
| `check-refs.sh`, `specboot.sh`, `validate-specboot.sh` | Scripts de setup y validación SDD |
| `templates/ci/` | Configs de referencia de CI (ESLint, dependency-cruiser, ruff, import-linter) |
| `docs/base-standards.md` | Estándares globales (intocable) |
| `docs/framework-contract.md` | Contrato del framework (intocable) |
| `docs/docs-standard.md` | Estándar de documentación (intocable) |
| `docs/specboot-json-standard.md` | Esquema de `.specboot.json` (intocable) |
| `docs/versioning-standard.md` | Estándar de versionado (intocable) |
| `opencode.json` | Configuración de OpenCode (sin `model` fijado) |
| `AGENTS.md` | Instrucciones de OpenCode (puente, intocable) |
| `Makefile` | Targets CI stack-agnostic (intocable) |
| `.github/workflows/` | CI/CD del framework (intocable) |
| `LICENSE`, `README.md` | Licencia MIT y este README |

> Son **5** los documentos estándar del framework que se publican (los listados arriba).
> El resto de `docs/` del repositorio **no** se incluye en el paquete.

## Qué es del proyecto (NO se publica)

Estos activos son propiedad y responsabilidad del desarrollador; **no** viajan en el
paquete npm (quedan fuera de la allowlist `files`):

- **Código de la aplicación** (`backend/`, `frontend/`, etc.).
- **`docs/` del proyecto**, salvo los 5 estándares del framework listados arriba
  (p.ej. `docs/backend-standards.md`, `docs/frontend-standards.md`,
  `docs/documentation-standards.md`, `docs/deploy-standards.md`, `docs/api/`,
  `docs/data-model/`, `docs/ci-standards.md`, `docs/project/`).
- **`.specboot.json`** del proyecto (raíces mono/multi-repo).
- **Servidores MCP** del proyecto.
- **Variables de entorno / GitHub vars** del proyecto.

> 💡 **Dogfooding**: el propio repositorio de desarrollo de Specboot contiene `docs/`
> propios (los listados arriba como "del proyecto") que **no** se publican — quedan
> filtrados por `files`. No los confundas con los 5 estándares que sí viajan en el
> paquete.

## Estructura del Proyecto

```
.
├── docs/                          # 📋 ESTÁNDARES — editar para contexto
│   ├── base-standards.md          #   Reglas globales + contexto proyecto
│   ├── backend-standards.md       #   Stack backend
│   ├── frontend-standards.md      #   Stack frontend
│   ├── documentation-standards.md #   Cómo documentar
│   ├── api/
│   │   └── api-spec.yml           #   Contrato OpenAPI
│   └── data-model/
│       └── data-model.md          #   Entidades del dominio
│
├── ai-specs/                      # ⚙️ NO EDITAR — configuración IA
│   ├── README.md                  #   Índice central de agents y skills
│   ├── agents/                    #   Roles del agente IA (contenido incrustado vía {file:})
│   ├── skills/                    #   Flujos reutilizables
│   └── examples/                  #   Ejemplos OpenSpec
│
├── .opencode/                     # ⚙️ Agentes y comandos nativos de OpenCode
│   ├── agents/                    #   plan, build, verify, archive, reviewer (más backend/frontend subagentes)
│   └── commands/                  #   /plan-change, /apply, /verify, /archive, /commit, /deploy, ...
│
├── templates/ci/                  # CI configs de referencia (instanciar en proyecto real)
│   ├── eslintrc.backend.js         #   ESLint NestJS: max-lines 300, complexity 10
│   ├── eslintrc.frontend.js        #   ESLint Angular: max-lines 400
│   ├── eslintrc.astro.js           #   ESLint Astro: max-lines warn
│   ├── .dependency-cruiser.js      #   DIP mecánico (domain|application → no infra/ORM/HTTP)
│   ├── .madge.config.json          #   Detección de dependencias circulares (Angular)
│   ├── ruff.toml                   #   Ruff (Python): complejidad 10 / línea 100
│   ├── .importlinter               #   import-linter (Python/Django): DIP por capas
│   └── package.ci.json             #   Snapshot de devDependencies
│
├── .github/workflows/             # CI/CD
│   ├── ci.yml                     #   Invoca make install/lint/test/build/audit/solid-lint/commitlint/template-integrity
│   └── deploy.yml                 #   Deploy a staging/production
│
├── AGENTS.md                      # NO EDITAR — instrucciones OpenCode
├── opencode.json                  # ⚙️ Sin campo "model": el modelo lo gestiona tu gestor (Omniroute/OpenCode)
├── .specboot.example.json         # Plantilla de .specboot.json (raíces mono/multi-repo)
├── Makefile                       # CI stack-agnostic: make install/lint/test/build/audit/commitlint/solid-lint
├── specboot.sh                    # Setup + validación SDD (--init / --ci)
├── check-refs.sh                  # Validación de integridad referencial (`file:...`)
├── update.sh                      # Sync tooling a proyectos y bump de versión
├── CHANGELOG.md                   # Historial de versiones (Keep a Changelog)
├── tests/                         # Tests del template
│   ├── check-refs-test.sh          #   Integridad referencial `file:...`
│   ├── update-test.sh              #   sync tool (update.sh)
│   └── solid-templates-test.sh     #   meta-validación CI templates SOLID (Ticket 4)
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
| `docs/deploy-standards.md` | Flujo de despliegue: entornos, versionado, Docker, rollback |
| `docs/api/api-spec.yml` | Endpoints reales de tu API |
| `docs/data-model/data-model.md` | Entidades reales del dominio |
| `opencode.json` | Opcional: añade `model` para fijar un proveedor distinto |

## Flujo SDD — Comandos

| Comando | Descripción |
|---------|-------------|
| `/enrich-us TICKET-ID` | Refinar ticket vago con criterios Gherkin |
| `/plan-change TICKET-ID` | Generar specs (escenarios, requirements, tasks) |
| `/apply TICKET-ID` | Implementar primera tarea con TDD |
| `/verify TICKET-ID` | Validar código contra escenarios |
| `/adversarial-review` | Auditoría 8 fases (incluye lente Architect/SOLID por stack) |
| `/archive TICKET-ID` | Archivar el cambio |
| `/commit` | Commits convencionales + Pull Request |
| `/deploy` | Release: version bump, build, deploy a staging/producción, smoke tests, rollback |

## Workflow Visual

```
/enrich-us (opcional)
       ↓
/plan-change → genera openspec/<ticket>/
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
| `code-auditing` | `/adversarial-review` antes de archivar (incluye lente Architect/SOLID por stack) |
| `using-git-worktrees` | Workspaces aislados por feature |
| `deploy` | Release, version bump, Docker, rollback |
| `onboarding` | Setup para nuevos desarrolladores |

Ver `ai-specs/README.md` para índice completo.

## Personalización Avanzada

### Modelo de IA (agnóstico)

Este template **no fija ningún modelo** en `opencode.json`. OpenCode usa el
modelo que tengas seleccionado en el momento de trabajar (el modelo activo de tu
proveedor/sesión), así el sistema es agnóstico al modelo de IA.

```json
// opencode.json — sin campo "model": OpenCode usa el modelo activo
{
  "agent": {
    "plan":     { "mode": "primary" },
    "build":    { "mode": "primary" },
    "reviewer": { "mode": "subagent" }
  }
}
```

Si quieres fijar un default de proyecto, añade `"model"` a nivel superior; y si
un agente necesita un modelo distinto, añade `"model"` solo en ese agente (los
demás heredan el modelo global). No dupliques el valor: basta un único punto de
configuración.

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

- **`.github/workflows/ci.yml`**: Dos jobs — `validate` (framework self-check: `check-refs.sh` + `specboot.sh --ci` + self-tests del framework condicionales) y `project-ci` (gate del proyecto: `make ci`). El proyecto no edita este archivo.
- **`.github/workflows/deploy.yml`**: Deploy genérico SSH+Docker gated por `vars.DEPLOY_ENABLED`; lee `vars.DOCKER_REPO`/`DEPLOY_HOST`/`DEPLOY_USER` y `secrets.DEPLOY_SSH_KEY`. Parametrizable sin editar el YAML.
- **`.commitlintrc.json`**: Conventional Commits enforced

## Makefile del framework (parametrizado por `.specboot.json`)

El `Makefile` es **intocable**: el proyecto no lo edita. Se parametriza vía `.specboot.json`
declarando `services` (rutas a carpetas con código) y `stack` (`node`, `python`,
`framework`, combinaciones en array, o `"auto"` para autodetección por manifiesto).

```json
{
  "frameworkVersion": "0.1.1",
  "services": ["backend", "frontend"],
  "stack": ["node", "python"]
}
```

Targets disponibles:

| Target | Qué hace |
|--------|----------|
| `make install` | Instala dependencias por servicio (npm/pip) según stack |
| `make lint` | Linting **propio del proyecto** por servicio (`npm run lint` / `ruff`) |
| `make test` | Tests por servicio (`npm test` / `pytest`) |
| `make build` | Compilación por servicio (`npm run build` / `python -m build`) |
| `make audit` | Auditoría de dependencias (`npm audit` / `pip-audit`) |
| `make solid-lint` | SOLID/DIP del framework por servicio (eslint@8 + dependency-cruiser + ruff + import-linter) |
| `make commitlint` | Valida mensajes de commit |
| `make refs` | Ejecuta `check-refs.sh` del proyecto |
| `make validate-specboot` | Valida `.specboot.json` (si `validate-specboot.sh` existe) |
| `make ci` | **CI gate del proyecto**: `refs` + `solid-lint` + `lint` + `test` + `audit` |

```bash
make ci            # CI gate del proyecto
make solid-lint    # SOLID/DIP por servicio
make lint          # linting propio del proyecto por servicio
make install       # instalar dependencias por servicio
```

> **Nota:** `make ci` es el gate del proyecto consumidor. La validación del propio
> framework (dogfooding) se hace con `bash specboot.sh --ci` (framework self-check),
> que es un comando **aparte**, no un target de este Makefile.
>
> El proyecto **no edita el Makefile**: para infraestructura específica (VPS, Docker,
> etc.) usa variables de entorno de GitHub Actions + configuración propia del proyecto.

## Workflows del framework

Los workflows son **intocables** y se parametrizan vía GitHub vars/secrets. El
proyecto consumidor no los edita: solo declara su infraestructura en GitHub.

```yaml
# .github/workflows/deploy.yml (del framework, no editar)
if: vars.DEPLOY_ENABLED == 'true'
vars.DOCKER_REPO, vars.DEPLOY_HOST, vars.DEPLOY_USER
secrets.DEPLOY_SSH_KEY
```

```bash
# En GitHub repo del proyecto:
# Settings → Secrets and variables → Actions
#   Vars:  DEPLOY_ENABLED=true, DOCKER_REPO=..., DEPLOY_HOST=..., DEPLOY_USER=...
#   Secrets: DEPLOY_SSH_KEY=***
```

`ci.yml` expone dos jobs: `validate` (dogfooding del framework: `check-refs.sh` +
`specboot.sh --ci` + self-tests condicionales del framework) y `project-ci` (gate del
proyecto: `make ci`). Para infraestructura específica (VPS, Docker, repo distinto) el
proyecto usa variables de entorno de GitHub, no edita el YAML.

## Desarrollar Specboot con Specboot (Dogfooding)

El propio framework se desarrolla usando su flujo SDD. Para hacer un cambio en Specboot:

1. Crea una rama `feature/ticket-X.Y-descripcion` desde `main`.
2. Ejecuta el flujo: `/plan-change` → `/apply` → `/verify` → `/archive` → `/commit`.
3. Valida con el script de dogfooding: `bash scripts/dogfood-check.sh` (corre `check-refs.sh` + `specboot.sh --ci`).
4. Al cerrar una fase, haz rebase a `main`, push y un solo PR.

El framework es su propio proyecto SDD: `AGENTS.md` es el puente que carga `docs/`, los agentes son prefabricados, y la actualización de archivos intocables se hace con `specboot update` (en proyectos consumidores; en el repo del framework es no-op porque target==source).

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

Ejecuta `bash specboot.sh --ci` para validar la configuración en modo CI (sin efectos secundarios), o `bash specboot.sh --init` para verificar la estructura del proyecto:

```bash
# Validación estricta para CI (exit 1 si hay errores)
bash specboot.sh --ci

# Integridad referencial: `file:...` en opencode.json y SKILL.md
bash check-refs.sh

# Setup local: verifica estructura del proyecto
bash specboot.sh --init

# Ayuda
bash specboot.sh --help
```

✅ Valida estructura de archivos (lista única compartida entre --init y --ci)
✅ Verifica que el proyecto es OpenCode-only (sin symlinks de .claude/.cursor)
✅ Detecta placeholders sin reemplazar
✅ Valida JSON de opencode.json
✅ Verifica skills y ejemplos
✅ Verifica integridad referencial de `file:...` (check-refs.sh)

## Versionado y actualización

Specboot se versiona con **semver vía git tags** (ej. `v0.1.0`, `v0.2.0`). El historial
de cambios vive en `CHANGELOG.md` (formato Keep a Changelog).

- **Actualizar un proyecto ya creado** (sin tocar `docs/` personalizado):
  ```bash
  bash update.sh --template /ruta/a/nuevo/specboot
  ```
  Sincroniza `ai-specs/`, `AGENTS.md`, `specboot.sh`, `check-refs.sh`, `Makefile`
  y `templates/` (configs de CI SOLID/POO del Ticket 4).
  Usa `--dry-run` para previsualizar.

- **Cortar un release** (mantenedores):
  ```bash
  bash update.sh --bump minor   # crea tag vX.Y.Z y entrada en CHANGELOG.md
  git push origin vX.Y.Z
  ```

## FAQ

**¿Necesito OpenSpec?** Sí. Sin él, `/plan-change`, `/apply`, `/verify` y `/archive` no funcionan.

**¿Puedo fijar un modelo?** Sí (opcional). Añade `"model"` a nivel superior en `opencode.json` si quieres usar un proveedor distinto al de tu sesión activa; si lo omites, OpenCode usa el modelo activo.

**¿Es solo OpenCode?** Sí. Este template es **OpenCode-only**: los agentes y skills viven en `ai-specs/` y se consumen vía ``file:...`` en `opencode.json`. No se crean symlinks ni configuraciones para Claude Code (`.claude/`) ni Cursor (`.cursor/`). Ver `docs/base-standards.md` §6.

**¿Puedo usar esto con proyecto existente?** Sí. Copia el template y ejecuta los pasos de personalización.

**¿Funciona en Windows?** Sí. `specboot.sh --ci`/`--init` validan la estructura y la integridad referencial sin crear symlinks (el template es OpenCode-only). `opencode.json` y los agentes/skills en `ai-specs/` se leen directamente, así que no hay requisito de symlinks ni de Developer Mode.

---

## 📄 Licencia

MIT © 2026 [Gabriel Zavando](https://gabrielzavando.cl)

Basado en [lidr-specboot](https://github.com/LIDR-academy/lidr-specboot).