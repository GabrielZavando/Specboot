# Changelog

All notable changes to Specboot are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `ai-specs/agents/plan-agent.md`: nuevo archivo dedicado para el agente de planificación, con reglas de derivación de nombres descriptivos de changes (2-4 palabras kebab-case desde el título del ticket).
- `ai-specs/examples/enrich-us-auth-reset.md`: ejemplo completo de enriquecimiento de ticket (AUTH-042, password reset) extraído del skill para carga bajo demanda.
- `docs/documentation-standards.md` § "Conventional Commits — Referencia": documentación de referencia humana para formato de commits, tipos permitidos, semver y commitlint.

### Changed

- **opencode.json**:
  - Corregido error crítico: `"agent": null` → `"agent": "plan"` en comando `enrich-us`.
  - Habilitados permisos `bash: "allow"` en agentes `backend` y `frontend` para permitir ejecución de tests durante `/apply`.
  - Movido prompt inline del agente `plan` (~15 líneas) a `{file:ai-specs/agents/plan-agent.md}`, eliminando overhead de cargar `instructions[]` dos veces.
  - Eliminado campo `"model"` global y por agente: el sistema ahora es agnóstico al modelo y usa el seleccionado en tiempo de ejecución.
  - Actualizado comando `/apply` para detectar dinámicamente el dominio (backend/frontend/full-stack) y adoptar el agente correspondiente.
  - Actualizadas descripciones de `/enrich-us` (opcional) y `/adversarial-review` (herramienta de rescate).

- **AGENTS.md**:
  - Reorganizadas tablas de skills y comandos en dos categorías: "Standard cycle" y "Optional tools".
  - Marcado `enrich-us` como skill opcional (solo para tickets mal formados).
  - Marcado `adversarial-review` como herramienta de rescate (no parte del ciclo estándar).
  - Ciclo estándar documentado: `plan-change` → `apply` → `verify` → `archive` → `commit` → `deploy` (opcional).

- **base-standards.md**:
  - Eliminadas secciones §4 (skills), §5 (comandos) y §6 (orquestación OpenCode) — contenido de gobernanza ya vive en AGENTS.md.
  - Consolidado como única fuente de principios de código (§1, §2, §9) y contexto de proyecto (§8).

- **ai-specs/agents/backend-developer.md** y **frontend-developer.md**:
  - Eliminado bloque "Comportamiento en cada tarea" que duplicaba el ciclo TDD genérico (~40 líneas por agente).
  - Cada agente ahora contiene solo el paso diferencial: declaración de diseño específica del stack antes de escribir tests.
  - Agregada referencia explícita a `build-agent.md` como única fuente del ciclo TDD completo.

- **ai-specs/skills/enrich-us/SKILL.md**:
  - Movido ejemplo AUTH-042 completo (~80 líneas) a `ai-specs/examples/enrich-us-auth-reset.md`.
  - Skill ahora contiene solo template + referencia al ejemplo, reduciendo de 278 a ~180 líneas por invocación.

- **ai-specs/skills/commit/SKILL.md**:
  - Movidas explicaciones genéricas (Conventional Commits, semver, commitlint) a `docs/documentation-standards.md`.
  - Skill ahora contiene solo proceso específico del proyecto: precondiciones, agrupación de commits, template PR, tips y common mistakes.
  - Reducido de 275 a ~120 líneas por invocación.

- **templates/ci/**:
  - Agregadas reglas ESLint `max-lines` (300 backend, 400 frontend) y `max-params` para mecanizar umbrales SRP.
  - Extendido `.dependency-cruiser.js` con regla `no-infra-from-domain` para enforce DIP mecánicamente.
  - Actualizado `code-auditing/SKILL.md` Fase 8 para indicar que estos chequeos ahora son mecánicos via lint.

### Fixed

- Error de validación en `opencode.json`: `command.enrich-us.agent` tenía valor `null` en lugar de string, impidiendo abrir el proyecto con OpenCode.

### Removed

- Duplicación del ciclo TDD genérico en `backend-developer.md` y `frontend-developer.md` (ahora solo en `build-agent.md`).
- Conocimiento genérico de Conventional Commits y semver en `commit/SKILL.md` (movido a documentación de referencia humana).
- Ejemplo AUTH-042 inline en `enrich-us/SKILL.md` (movido a `ai-specs/examples/` para carga bajo demanda).

### Changed
- **Template is OpenCode-only**: removed `.claude/` and `.cursor/` symlinks; no Claude Code or Cursor configuration is generated. Agent/skill artifacts live in `ai-specs/` and are consumed by OpenCode via `{file:...}` references in `opencode.json` (base-standards.md §6, README FAQ).
- `specboot.sh`: dropped symlink creation and the Windows copy fallback; `--init`/`--ci` now only validate structure, placeholders, JSON and referential integrity.
- Removed `tests/specboot-symlink-test.sh` (tested the removed symlink behavior).
- README: corrected clone URL, OpenSpec badge (`new change`), clarified `model` is optional, and replaced the Cursor/Claude FAQ with an OpenCode-only note.
- CI: `build` job upload tolerates a missing `dist/` (`if-no-files-found: warn`) so the template repo passes CI without a build artifact.
- `deploy.yml`: jobs are guarded by `hashFiles('Dockerfile') != ''` so tag pushes on the template (no Dockerfile) do not attempt a Node/Docker deploy.
- `AGENTS.md`: restored the skill trigger table (name + trigger) that was replaced by a pointer to `ai-specs/README.md`. Since `AGENTS.md` is the file auto-loaded via `instructions[]` and `ai-specs/README.md` is not, the pointer left the auto-load matching mechanism with nothing to match against.
- `check-refs.sh`: added a guard that fails if any `ai-specs/skills/*/` folder is not mentioned in `AGENTS.md`, to catch this class of drift automatically.

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
