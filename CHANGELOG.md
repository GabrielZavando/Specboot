# Changelog

All notable changes to Specboot are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `ai-specs/agents/plan-agent.md`: nuevo archivo dedicado para el agente de planificación, con reglas de derivación de nombres descriptivos de changes (2-4 palabras kebab-case desde el título del ticket).
- `ai-specs/examples/enrich-us-auth-reset.md`: ejemplo completo de enriquecimiento de ticket (AUTH-042, password reset) extraído del skill para carga bajo demanda.
- `ai-specs/reference/commits.md`: documentación de referencia humana para formato de commits, tipos permitidos, semver y commitlint. No se carga automáticamente en el contexto de los agentes.
- `ai-specs/skills/plan-change/SKILL.md`: skill dedicado para generación de changes con nombres descriptivos, referenciado desde el comando `/plan-change`.

### Changed

- **opencode.json**:
  - Corregido error crítico: `"agent": null` → `"agent": "plan"` en comando `enrich-us`.
  - Movido prompt inline del agente `plan` (~15 líneas) a `{file:ai-specs/agents/plan-agent.md}`, eliminando overhead de cargar `instructions[]` dos veces.
  - Eliminado campo `"model"` global y por agente: el sistema ahora es agnóstico al modelo y usa el seleccionado en tiempo de ejecución.
  - Actualizado comando `/apply` para detectar dinámicamente el dominio (backend/frontend/full-stack) y adoptar el rol correspondiente.
  - Actualizadas descripciones de `/enrich-us` (opcional) y `/adversarial-review` (herramienta de rescate).
  - Comando `/plan-change` ahora referencia `{file:ai-specs/skills/plan-change/SKILL.md}` en lugar de lógica inline duplicada.
  - Comando `/adversarial-review` ahora usa template genérico "Run the audit process" en lugar de hardcodear "7-phase audit".
  - Eliminado `docs/documentation-standards.md` de `instructions[]`: ahora se carga condicionalmente solo en tareas de documentación.

- **AGENTS.md**:
  - Reemplazada instrucción incondicional "Always read these files" por lógica condicional: cada archivo de contexto se carga solo si la tarea lo requiere.
  - Reorganizadas tablas de skills y comandos en dos categorías: "Standard cycle" y "Optional tools".
  - Marcado `enrich-us` como skill opcional (solo para tickets mal formados).
  - Marcado `adversarial-review` como herramienta de rescate (no parte del ciclo estándar).
  - Marcado `/deploy` como opcional en la tabla de comandos del ciclo estándar.
  - Ciclo estándar documentado: `plan-change` → `apply` → `verify` → `archive` → `commit` → `deploy` (opcional).

- **base-standards.md**:
  - Eliminadas secciones §4 (skills), §5 (comandos) y §6 (orquestación OpenCode) — contenido de gobernanza ya vive en AGENTS.md.
  - Consolidado como única fuente de principios de código (§1, §2, §9) y contexto de proyecto (§8).

- **ai-specs/agents/build-agent.md**:
  - Agregada carga condicional de `docs/documentation-standards.md` solo cuando la tarea modifica documentación.

- **ai-specs/agents/backend-developer.md** y **frontend-developer.md**:
  - Eliminado bloque "Comportamiento en cada tarea" que duplicaba el ciclo TDD genérico (~40 líneas por agente).
  - Cada agente ahora contiene solo el paso diferencial: declaración de diseño específica del stack antes de escribir tests.
  - Agregada referencia explícita a `build-agent.md` como única fuente del ciclo TDD completo.

- **ai-specs/agents/plan-agent.md**:
  - Reemplazada instrucción "Always load" por carga condicional basada en el tipo de ticket.
  - El agente ahora solo carga `docs/api/api-spec.yml`, `docs/data-model/data-model.md`, o `documentation-standards.md` cuando el ticket explícitamente lo requiere.

- **ai-specs/skills/enrich-us/SKILL.md**:
  - Movido ejemplo AUTH-042 completo (~80 líneas) a `ai-specs/examples/enrich-us-auth-reset.md`.
  - Skill ahora contiene solo template + referencia al ejemplo, reduciendo de 278 a ~180 líneas por invocación.

- **ai-specs/skills/commit/SKILL.md**:
  - Movidas explicaciones genéricas (Conventional Commits, semver, commitlint) a `ai-specs/reference/commits.md`.
  - Skill ahora contiene solo proceso específico del proyecto: precondiciones, agrupación de commits, template PR, tips y common mistakes.
  - Reducido de 275 a ~120 líneas por invocación.
  - Actualizada descripción para clarificar que `/adversarial-review` es opcional antes de `/commit`, no obligatorio.

- **docs/documentation-standards.md**:
  - Reducido de ~204 a 52 líneas: eliminadas secciones genéricas de Conventional Commits, semver y commitlint (movidas a `ai-specs/reference/commits.md`).
  - Eliminado de `instructions[]` en `opencode.json`: ahora se carga condicionalmente solo en tareas de documentación.

- **templates/ci/**:
  - Agregadas reglas ESLint `max-lines` (300 backend, 400 frontend) y `max-params` para mecanizar umbrales SRP.
  - Extendido `.dependency-cruiser.js` con regla `no-infra-from-domain` para enforce DIP mecánicamente.
  - Actualizado `code-auditing/SKILL.md` Fase 8 para indicar que estos chequeos ahora son mecánicos vía lint.

### Fixed

- Error de validación en `opencode.json`: `command.enrich-us.agent` tenía valor `null` en lugar de string, impidiendo abrir el proyecto con OpenCode.
- Inconsistencia entre `commit/SKILL.md` (hacía `/adversarial-review` obligatorio) y `AGENTS.md` (lo marca como herramienta de rescate opcional).
- Inconsistencia entre comando `/adversarial-review` (hardcodeaba "7-phase audit") y `code-auditing/SKILL.md` (tiene 8 fases incluyendo SOLID/POO).

### Removed

- Agentes `backend` y `frontend` del bloque `agent` en `opencode.json`: estaban definidos pero ningún comando los usaba. El agente `build` ya detecta dinámicamente el dominio y adopta el rol correspondiente.
- Duplicación del ciclo TDD genérico en `backend-developer.md` y `frontend-developer.md` (ahora solo en `build-agent.md`).
- Conocimiento genérico de Conventional Commits y semver en `commit/SKILL.md` y `documentation-standards.md` (movido a `ai-specs/reference/commits.md` para carga bajo demanda).
- Ejemplo AUTH-042 inline en `enrich-us/SKILL.md` (movido a `ai-specs/examples/` para carga bajo demanda).
- Lógica inline duplicada de derivación de nombres de changes en `opencode.json` (ahora delegada a `plan-change/SKILL.md`).
- Change huérfano `ticket-001` en `openspec/changes/` (archivado).

## [0.1.0] - 2026-07-16

### Added
- SDD template: `AGENTS.md`, `opencode.json` y agentes (`plan`, `build`, `reviewer`).
- Estándares base y por área: `docs/base-standards.md`, `backend-`, `frontend-`, `documentation-`.
- Skills reutilizables en `ai-specs/skills/` (enrich-us, commit, code-auditing, using-git-worktrees, deploy, onboarding).
- `specboot.sh`: setup (`--init`) y validación (`--ci`) con lista única de archivos requeridos y symlinks.
- `check-refs.sh`: validación de integridad referencial de tokens `{file:...}` en `opencode.json` y `SKILL.md`.
- `Makefile` stack-agnostic que expone `install/lint/test/build/audit/commitlint/refs`.
- `update.sh`: sincroniza el tooling del template a proyectos existentes sin tocar `docs/`, y `--bump` para releases semver.
- `CHANGELOG.md` y versionado por git tags (`vX.Y.Z`).
