# Changelog

All notable changes to Specboot are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2026-09-05

### Added

- **M-501** (Fase 5) — Auto-refutación estructurada de hallazgos `CRITICAL` en `adversarial-review`: protocolo formal de 4 pasos (hipótesis de refutación → búsqueda de evidencia contradictoria en código/tests → decisión mantener/descartar con motivo → registro hallazgo+refutación) reemplazando la heurística de una línea, y anexo "Descartados" en el reporte (hallazgo original + refutación + motivo) fuera del veredicto, con contador `summary.discarded` alineado al JSON (`ai-specs/skills/code-auditing/SKILL.md`).
- **M-502** (Fase 5) — `/adversarial-review` persiste `openspec/state/adversarial-result.json` tras cada auditoría (incluido NO-SHIP, last-run-wins, trackeado en git) con esquema versionado (`schema_version: 1`, `verdict: SHIP|NO-SHIP`, `confidence` 0.0–1.0, `timestamp` ISO-8601, `findings{total,critical,warnings,info,discarded}`); self-test ejecutable `tests/adversarial-state-test.sh` valida el fixture canónico `ai-specs/examples/adversarial-results-example.json` (`ai-specs/skills/code-auditing/SKILL.md`, `tests/adversarial-state-test.sh`).

### Changed

- `archive` añade el campo opcional `adversarial: {verdict, timestamp, source}` a la entrada del manifest cuando existe evidencia con `change` coincidente; si falta, es inválida o ajena → advierte y sugiere `/adversarial-review` sin bloquear (gate duro = M-901) (`ai-specs/skills/archive/SKILL.md`).
- `commit` (Step 2) lee el veredicto como gate informado suave: `SHIP` vigente para el change activo omite la confirmación manual, `NO-SHIP` advierte y exige decisión explícita, ausente/ajeno mantiene el flujo previo; staleness warn-only (`ai-specs/skills/commit/SKILL.md`).
- Permisos del subagente `reviewer` sincronizados con su rol (patrón M-403): añadidos `cat`, `ls` y `mkdir -p openspec/*` (única escritura = evidencia en `openspec/state/`, vía `cat` por redirección), eliminado `git log` sin uso documentado; descripciones actualizadas en `AGENTS.md`, `.opencode/commands/adversarial-review.md` y `ai-specs/README.md` ("read-only sobre código, persiste evidencia").
- `.specboot.json` del repo sincronizado con la nueva versión (`frameworkVersion: 0.4.0`).

## [0.3.0] - 2026-09-04

### Added

- **M-201/M-202** (Fase 2) — Convención de `Suggested Path` / `Test Path` en toda tarea de `tasks.md` (con defaults por `.specboot.json` `services`/`layers`) y paso de validación de coherencia de diseño en `plan-change` (sección `Design Validation`; conflictos críticos detienen la generación) (`ai-specs/skills/plan-change/SKILL.md`).
- **M-301/M-302** (Fase 3) — Protocolo de fallo TDD: máximo 3 intentos consecutivos, `TDD Failure Report` (`Task`, `Attempt`, `Error`, `Suggested investigation`) y detención inmediata; detención explícita del agente tras completar cada tarea, esperando instrucción del usuario (`.opencode/commands/apply.md`, `ai-specs/agents/build-agent.md`).
- **M-401** (Fase 4) — `/verify` persiste `openspec/state/verify-results.json` tras cada ejecución con esquema versionado (`schema_version: 1`, `status`, `evidence_mode`, mapeo de escenarios `SC-NNN`); `/commit` lo usa como gate informado suave (PASS omite la pregunta, PARTIAL/FAIL advierte, ausente mantiene la pregunta; staleness warn-only) y `archive` añade `verification: {status, timestamp, source}` a la entrada del manifest (`ai-specs/skills/verify/SKILL.md`, `ai-specs/skills/commit/SKILL.md`, `ai-specs/skills/archive/SKILL.md`).
- **M-402** (Fase 4) — Convención de nombrado de tests con ID de escenario (`[SC-NNN]` en títulos JS/TS, `test_sc{NNN}_` en identificadores Python) documentada en los agentes generadores de tests, y prioridad de evidencia en `verify` Step 5c: match por nombre (fuerte) > mención textual (débil, nunca PASS) > UNTESTED (`ai-specs/agents/build-agent.md`, `ai-specs/agents/backend-developer.md`, `ai-specs/agents/frontend-developer.md`, `ai-specs/skills/verify/SKILL.md`).
- **M-403** — Registrado en `PLAN_MEJORAS_SPECBOOT.md` como ticket `patch` (sincronizar permisos bash del subagente verify con su documentación; descubierto durante M-401). Pendiente de implementar.

### Changed

- Descripciones de `verify` actualizadas en `AGENTS.md`, `.opencode/agents/verify.md`, `.opencode/commands/verify.md`, `ai-specs/README.md` y `ai-specs/agents/verify-agent.md`: read-only sobre código y specs, con única excepción la escritura de evidencia en `openspec/state/verify-results.json` (incluye permiso `mkdir -p openspec/*` en el permission block del agente).
- Self-test ejecutable del contrato de `verify-results.json`: `tests/verify-state-test.sh` valida el fixture canónico `ai-specs/examples/verify-results-example.json` (claves, enums, invariante `static → PARTIAL sin PASS`).
- `.specboot.json` del repo sincronizado con la nueva versión (`frameworkVersion: 0.3.0`).

## [0.2.0] - 2026-09-04

### Added

- **M-101** — `enrich-us` ahora genera las secciones estratégicas *Estimación*, *Riesgo*, *Dependencias* y *Alternativas descartadas* en todo ticket enriquecido, para que `plan-change` dimensione y priorice las tareas con contexto (`ai-specs/skills/enrich-us/SKILL.md`, `ai-specs/examples/enrich-us-auth-reset.md`).
- **M-102** — Convención de identificadores estables `SC-{NNN}` en todos los escenarios Gherkin generados por `enrich-us` y `plan-change`, y trazabilidad de evidencia de pruebas en `verify` por patrón `SC-{NNN}` (`ai-specs/skills/enrich-us/SKILL.md`, `ai-specs/skills/plan-change/SKILL.md`, `ai-specs/skills/verify/SKILL.md`, `ai-specs/examples/scenarios-example.md`).

## [0.1.2] - 2026-08-31

### Fixed

- Desbloqueado el publish automático: `release.yml` falló con `You cannot publish over the previously published versions: 0.1.1` porque el merge a `main` no llevó bump de versión. `package.json` pasa de `0.1.1` a `0.1.2` (el workflow no hace bump automático por diseño: el mantenedor bumpa antes del merge).
- `package.json` `bin`: `./specboot.sh` → `specboot.sh` (path pre-normalizado). Silencia el warning de npm en publish (`"bin[specboot]" script name ... was invalid and removed`), que solo normalizaba el path — la entrada CLI sobrevive en el tarball publicado.

## [0.1.1] - 2026-08-29

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

### Breaking changes

None. (Esta subsección es la plantilla canónica: en un release `major` debe listar los
cambios clasificados como `major` en `docs/versioning-standard.md`, y si aplica una sección
`### Migration` con los pasos de migración de `.specboot.json` / `docs/` / env.)

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
