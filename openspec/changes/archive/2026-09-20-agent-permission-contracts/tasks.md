# Tasks — SPECBOOT-PERM-01: agent-permission-contracts

> Rastro: REQ-### ↔ SC-### definidos en `requirements.md` / `scenarios.md`.
> Este repo no usa `.specboot.json` con `services`; los paths usan las carpetas
> reales del framework (`scripts/`, `tests/`, `.opencode/agents/`, `docs/`).

## Mandatory Steps

Esta checklist es **obligatoria, no sugerida**. Aplica a toda tarea de
implementación ejecutada vía `/apply`, tanto en el propio framework Specboot
(dogfooding) como en cualquier proyecto consumidor.

### Pre-implementación

Antes de escribir la primera línea de la tarea actual:

- [x] La **rama activa** sigue la convención vigente del proyecto (ej.
  `feature/*`, `fix/*`); trabajar sobre ella, nunca directamente sobre la rama
  principal.
- [x] Estado **git limpio**: sin cambios sin commitear (ni staged) antes de
  empezar; si hay trabajo en curso, resolverlo primero.

### Durante la implementación

- [x] **Test nuevo que falla antes de implementar (RED)**: escribir el test del
  escenario (`SC-NNN`) y verificar que falla antes de escribir código de
  producción.
- [x] Ejecutar los **tests unitarios del módulo** tocado mientras se itera
  (ciclo RED-GREEN-REFACTOR), no solo al final.

### Post-implementación

Antes de dar la tarea por cerrada:

- [x] **Ejecutar `verify`**: la verificación del change corre y produce
  evidencia persistente (`openspec/state/verify-results.json`).
- [x] **Ejecutar `adversarial-review`**: la auditoría adversarial corre y
  produce veredicto persistente (`openspec/state/adversarial-result.json`).

> Ambos pasos post alimentan los gates duros de `/commit` (M-901): sin
> `PASS` + `SHIP` vigentes para el change activo, el commit bloquea.

---

## 1. Manifiesto de contratos (REQ-001)

Prioridad: alta | Capa: infrastructure | Estimación: media

- [x] 1.1 Escribir el test/fixture TDD primero: caso válido y caso sin manifiesto (SC-001, SC-008) en RED.
- [x] 1.2 Crear el manifiesto YAML framework-owned con una entrada por agente: editable paths, bash requerido, prohibiciones, evidencias persistentes y flags `can_commit`/`can_push`/`can_manage_prs`/`can_run_arbitrary_code`/`can_spawn_subagents`.
- [x] 1.3 Documentar en el manifiesto la justificación de alcance de `build`, `backend` y `frontend` (REQ-007).

Suggested Path: `docs/agent-permission-contracts.yml`
Test Path: `tests/permission-contracts-test.sh`, `tests/fixtures/permission-contracts/*`

## 2. Validador automático (REQ-002, REQ-008)

Prioridad: alta | Capa: infrastructure | Estimación: alta

- [x] 2.1 Test RED: fixtures YAML — catch-all antes de excepción (SC-002), permiso requerido ausente (SC-008), alcance excedido (SC-009), force-push no cubierto (SC-006).
- [x] 2.2 Implementar el validador con interfaz CLI `node scripts/validate-agent-permissions.mjs --root <proyecto>`: descubre `.opencode/agents/*.md` **bajo `--root`** (nunca asume `cwd` como proyecto), parsea front matter con parser YAML real (`node` + **`js-yaml` como dependencia de ejecución** en `package.json#dependencies`, **resuelta desde el directorio del propio validador** — no del `node_modules` hoisted del consumidor), calcula permisos efectivos con `last-match-wins`, compara contra el manifiesto (leído desde el paquete del framework).
- [x] 2.3 Reporte por descalce: agente + capacidad + regla causante; exit ≠ 0.
- [x] 2.4 Cubrir REQ-003/REQ-004/REQ-005 con fixtures específicos (SC-003, SC-004, SC-005).
  - Cerrado junto a la Tarea 3: fixture `bad-ownership` (SC-005: `can_commit: false` con `git commit` efectivamente allow → violación), y el validador pasa limpio sobre los agentes reales `verify`/`reviewer` (evidencia efectiva de SC-003/SC-004 en el repo).
- [x] 2.5 Test de ejecución dual: dogfooding (desde el repo) y consumidor (desde `node_modules/@gabrielzavando/specboot/`), incluyendo consumidor **sin `js-yaml` hoisted** en su raíz (regla: el validador nunca se instala en el proyecto; solo el helper se distribuye).

Suggested Path: `scripts/validate-agent-permissions.mjs`
Test Path: `tests/permission-contracts-test.sh`, `tests/fixtures/permission-contracts/*`

## 3. Auditoría y corrección de bloques de permisos (REQ-002..REQ-007)

Prioridad: alta | Capa: infrastructure | Estimación: media

- [x] 3.1 Test RED: aserciones de contrato por agente (SC-003..SC-007) en `tests/permission-contracts-test.sh`.
- [x] 3.2 Corregir `opencode.json` y `.opencode/agents/{archive,backend,build,commit,frontend,reviewer,sdd-plan,sync-specs,verify}.md` hasta que el validador pase.
  - Nota: `opencode.json` no requirió cambios; los agentes `verify`, `reviewer`, `sdd-plan` y `sync-specs` ya cumplían. Se corrigieron `archive` (sin `git add`, sin `node -e`), `commit` (sin `node -e`) y los implementadores `build`/`backend`/`frontend` (denies de commit/push/force-push/gh PR + evidencias intocables).
- [x] 3.3 Implementar `scripts/read-json-field.mjs` (ESM, solo lectura, con **allowlist cerrada de archivos y campos autorizados** hardcodeada en el propio helper) y reemplazar `node -e *` en `archive` y `commit` + actualizar roles/skills (`archive-agent.md`, `skills/archive/SKILL.md`, `skills/commit/SKILL.md`) para que documenten el helper (SC-007). Migrados en `agent-permissions-test.sh` los asserts que exigían `node -e *` (tensión documentada resuelta); removida de `verify-agent.md` la documentación de `node -e` (cierra además fallo baseline SC-004).
- [x] 3.4 Documentar la justificación REQ-007 en los roles de `build`, `backend` y `frontend` (force-push denied, commit ownership denied, operaciones destructivas con confirmación, evidencias intocables).

Suggested Path: `.opencode/agents/*.md`, `opencode.json`, `scripts/read-json-field.mjs`, `ai-specs/agents/archive-agent.md`, `ai-specs/skills/commit/SKILL.md`
Test Path: `tests/permission-contracts-test.sh`, `tests/agent-permissions-test.sh` (regresión: decisión de ajustar los asserts de `node -e *` de SC-003/SC-006 al nuevo helper; verificar con el usuario antes de tocar ese archivo)

## 4. Integración con CI y estructura requerida (REQ-009, REQ-011)

Prioridad: media | Capa: infrastructure | Estimación: baja

- [x] 4.1 Test RED: `specboot.sh --ci` muestra `→ Verificando contratos de permisos de agentes...` y falla con un fixture corrupto (SC-001).
- [x] 4.2 Enganchar el validador en `specboot.sh --ci` (antes de cualquier publicación/distribución) invocándolo **desde el directorio real del framework** y pasando `--root` al proyecto: en dogfooding `$SCRIPT_DIR`, en consumidor `node_modules/@gabrielzavando/specboot`.
- [x] 4.3 Actualizar las listas estructurales con el split correcto: **helper** → `package.json#files` + `UPDATE_ITEMS` (entry file-level `scripts/read-json-field.mjs`) + `REQUIRED_FILES`; **validador + manifiesto** → solo `package.json#files` (viven en el paquete, nunca se copian al proyecto). Verificar que ningún agente/skill del ciclo actual quede fuera de la estructura requerida.
  - Nota: esta tarea también arregló dos fallos preexistentes detectados por `run-all.sh`: allowlist de `package-files-test.sh` (ahora reconoce `docs/agent-permission-contracts.yml` como doc del framework) y wording `read-only` en `ai-specs/skills/verify/SKILL.md` (assert de traspaso de tick).

Suggested Path: `specboot.sh`
Test Path: `tests/permission-contracts-test.sh`, `tests/package-files-test.sh`

## 5. Distribución init/update (REQ-010)

Prioridad: media | Capa: infrastructure | Estimación: media

- [x] 5.1 Test RED: proyecto temporal con `specboot init` y otro con `specboot update` deben contener **agentes + helper** idénticos al framework; el validador corre desde el paquete instalado (`node_modules/@gabrielzavando/specboot`) con `--root` al proyecto y pasa (SC-010). Incluir fixture consumidor sin `js-yaml` hoisted.
- [x] 5.2 Añadir a `package.json#files` los tres artefactos (helper, validador, manifiesto) y al flujo init/update **solo** el helper (`FRAMEWORK_ITEMS` para init, `UPDATE_ITEMS` + `REQUIRED_FILES`); extender `tests/specboot-init-test.sh`, `tests/specboot-update-test.sh` y `tests/package-files-test.sh` con esta cobertura (incluidos asserts negativos: validador/manifiesto nunca se copian al proyecto).
- [x] 5.3 Verificación final SC-011: `git diff --check`, `bash check-refs.sh`, `bash specboot.sh --ci` en verde; además `bash tests/run-all.sh` completo en verde.

Suggested Path: `specboot.sh`
Test Path: `tests/specboot-init-test.sh`, `tests/specboot-update-test.sh`
