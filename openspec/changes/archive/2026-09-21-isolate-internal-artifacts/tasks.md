# Tasks — SPECBOOT-HARDEN-02: isolate-internal-artifacts

> Rastro: REQ-### ↔ SC-### definidos en `requirements.md` / `scenarios.md`.
> Este repo no usa `.specboot.json` con `layers`; los paths usan las carpetas
> reales del framework (`templates/`, `scripts/`, `tests/`, `.opencode/`, `docs/`).

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

## 1. Aislar workflows internos y plantillas consumidoras (REQ-001, REQ-003)

Prioridad: crítica | Capa: infrastructure | Estimación: alta

- [x] 1.1 Escribir el test TDD primero (RED): `tests/workflow-isolation-test.sh`
  con asserts SC-001/SC-004 — `npm pack --dry-run` sin `.github/workflows/**`
  (incluido `release.yml`), tarball con `templates/github/workflows/consumer-ci.yml`,
  `templates/github/workflows/deploy.example.yml` y
  `templates/github/pull_request_template.md`; y `specboot init` que instala
  `.github/workflows/ci.yml` + `.github/pull_request_template.md` en el proyecto
  sin `release.yml` ni workflow interno.
- [x] 1.2 Enmendar `tests/package-files-test.sh` (RED): el allowlist npm excluye
  `.github/workflows/**` e incluye `templates/github/**`; retirar el assert que
  exigía `.github/workflows/` publicado y el que prohibía rutas `.github/` fuera
  de `workflows/` (ahora el PR template se instala en `.github/` desde la
  plantilla).
- [x] 1.3 Crear `templates/github/workflows/consumer-ci.yml` — el workflow CI
  diseñado para consumidores (único que se instala por defecto), heredando el
  wiring de auth de GitHub Packages ya validado (SC-004 de consumer-ci-auth:
  `packages: read`, `NODE_AUTH_TOKEN`, registry-url en ambos jobs, Node 24,
  acciones v5, `hashFiles` solo a nivel step).
- [x] 1.4 Crear `templates/github/workflows/deploy.example.yml` — plantilla
  opcional de despliegue (NO instalada por init/update), derivada del deploy.yml
  interno pero agnóstica (`vars.DEPLOY_*`/`secrets.DEPLOY_*`, gated por
  `DEPLOY_ENABLED`).
- [x] 1.5 Crear `templates/github/pull_request_template.md` (fuente canónica del
  PR template que `init` instala en `.github/pull_request_template.md`).
- [x] 1.6 Actualizar `package.json#files`: remover `.github/workflows`, incluir
  `templates/github/` y la fuente del PR template; verificar que `release.yml`
  quede fuera del paquete.
- [x] 1.7 Actualizar `specboot.sh` (FRAMEWORK_ITEMS y lógica de init): reemplazar
  el item `.github` completo por una lista explícita de archivos; `init` instala
  el PR template y el workflow CI de consumidores desde `templates/github/` hacia
  `.github/` (creando `.github/workflows/` si falta); `release.yml` y el
  `deploy.yml` interno nunca se copian; nunca se copia `.github` completo.

Suggested Path: `templates/github/workflows/consumer-ci.yml`, `templates/github/workflows/deploy.example.yml`, `templates/github/pull_request_template.md`, `package.json`, `specboot.sh`
Test Path: `tests/workflow-isolation-test.sh`, `tests/package-files-test.sh`, `tests/specboot-init-test.sh`

## 2. Reparar consumidores contaminados vía update (REQ-002)

Prioridad: crítica | Capa: infrastructure | Estimación: media

> Delta normativo: `specs/specboot-update/spec.md` (detección por firma, respaldo
> previo, advertencia + resolución explícita ante no-coincidencia exacta,
> conservación de workflows personalizados).

- [x] 2.1 Escribir los tests TDD primero (RED) con fixtures consumidores: update
  sobre `tests/specboot-update-test.sh`/`tests/update-test.sh` o test nuevo —
  SC-002 (release heredado intacto → respaldo + eliminación), SC-003 (workflow
  personalizado sobrevive), release modificado → warning + resolución explícita,
  deploy.yml interno nunca instalado.
- [x] 2.2 Implementar en `specboot update` la detección del `release.yml`
  heredado mediante la firma conocida del archivo framework-owned (fingerprint de
  contenido contra el `release.yml` del propio framework o marcadores estables
  del archivo), respaldándolo en `.specboot-backup-*/` antes de eliminarlo.
- [x] 2.3 Implementar la advertencia y exigencia de resolución explícita cuando
  el `release.yml` heredado fue modificado (no eliminar automáticamente).
- [x] 2.4 Garantizar que los workflows personalizados y ajenos al framework
  sobreviven al update; update solo instala/reemplaza el workflow CI de
  consumidores desde la plantilla.
- [x] 2.5 Convertir la firma singular en allowlist de fingerprints históricos:
  reemplazar `KNOWN_RELEASE_FINGERPRINT` por `KNOWN_RELEASE_FINGERPRINTS` con
  todas las variantes de `release.yml` distribuidas antes del aislamiento
  (derivadas del historial git: v1 inicial, v2 bump node-24, v3 publish
  idempotente), documentadas como contenido legacy inmutable — nunca derivadas
  del `release.yml` interno actual, que puede evolucionar y ya no se distribuye.
  Fixtures y pruebas de reparación para cada variante + prueba de provenancia
  (cada entrada de la allowlist existe en el historial; cubre todos los commits
  pre-aislamiento; sin hashes inventados).

Suggested Path: `specboot.sh`
Test Path: `tests/specboot-update-test.sh`, `tests/update-test.sh`, `tests/fixtures/` (fixtures consumidores)

## 3. Pre-flight reanudable de `/apply` (REQ-004)

Prioridad: crítica | Capa: infrastructure | Estimación: media

- [x] 3.1 Escribir el test TDD primero (RED): `tests/apply-preflight-test.sh` —
  SC-005 (primera ejecución con suciedad limitada a
  `openspec/changes/{active-change}/**` pasa sin commit manual), SC-006 (tras
  tareas completadas, `/apply` continúa sobre el árbol dirty esperado desde la
  primera tarea pendiente), SC-007 (cambios ajenos preexistentes bloquean).
- [x] 3.2 Reescribir el pre-flight de `.opencode/commands/apply.md`: ejecutarlo
  una sola vez por change (no antes de cada tarea), con un mecanismo de marca
  reanudable por change que no interfiere con las evidencias de
  `verify`/`adversarial` (`openspec/state/*-results.json` permanecen
  fail-closed).
- [x] 3.3 Explicitar la suciedad permitida: primera ejecución limitada a
  `openspec/changes/{active-change}/**` (artefactos de `/plan-change`); después,
  cambios producidos por tareas anteriores del change; nunca commits
  intermedios; cambios ajenos siguen bloqueando.
- [x] 3.4 Explicitar la interacción con la checklist `## Mandatory Steps` (su
  ítem "Estado git limpio" se interpreta a nivel de change según REQ-004) y la
  reanudación desde la primera tarea pendiente; `/commit` conserva ownership
  exclusivo de `git add`/`git commit`/`git push` (sin cambios de contrato allí).

Suggested Path: `.opencode/commands/apply.md`
Test Path: `tests/apply-preflight-test.sh`

## 4. Contratos de subagentes en manifiesto y front matter (REQ-005)

Prioridad: crítica | Capa: infrastructure | Estimación: media

- [x] 4.1 Escribir los tests TDD primero (RED): extender
  `tests/permission-contracts-test.sh` y `tests/agent-permissions-test.sh` —
  SC-008 (agentes con `can_spawn_subagents: false` resuelven `task: deny`
  efectivo), SC-009 (`build` solo invoca `backend`/`frontend`).
- [x] 4.2 Extender `docs/agent-permission-contracts.yml` con el contrato
  `task: {allow, forbidden}` por agente: `build` con `allow: [backend, frontend]`
  y `forbidden: ["*"]`; `reviewer`, `verify`, `commit`, `archive`, `sdd-plan`,
  `sync-specs`, `backend` y `frontend` con `allow: []` y `forbidden: ["*"]`.
- [x] 4.3 Actualizar los front matter de `.opencode/agents/*.md`: `build`
  declara `permission.task` con allow para `backend`/`frontend` y deny para el
  resto; los ocho agentes restantes declaran `permission.task: deny` (el
  reviewer no genera hijos; `/adversarial-review` mantiene su invocación única
  vía `subtask: true` ya presente en el comando).
- [x] 4.4 Actualizar la documentación de los agentes afectados para que coincida
  con los permisos efectivos (parte del REQ-009, cerrada aquí para el contrato).

Suggested Path: `docs/agent-permission-contracts.yml`, `.opencode/agents/*.md`
Test Path: `tests/permission-contracts-test.sh`, `tests/agent-permissions-test.sh`

## 5. Validador fiel a OpenCode (REQ-006)

Prioridad: crítica | Capa: infrastructure | Estimación: alta

- [x] 5.1 Escribir los tests TDD primero (RED): fixtures de
  `tests/permission-contracts-test.sh` — SC-010 (cada flag fiscalizado
  independientemente y falla CI), SC-011 (patrones `*` y `?`, combinación
  defaults → globales → agente, comandos compuestos, variantes de force-push y
  de GitHub CLI).
- [x] 5.2 Implementar la lectura de `opencode.json` del proyecto validado (vía
  `--root`) y el cálculo de permisos efectivos con el orden defaults → globales
  → agente, conservando `last-match-wins` dentro de cada bloque.
- [x] 5.3 Corregir la semántica de patrones: `*` como comodín multi-carácter y
  `?` como comodín de un carácter conforme a OpenCode (hoy `?` se escapa como
  literal).
- [x] 5.4 Comparar el `mode` real del front matter con el manifiesto y validar
  `permission.task` (contrato de la Tarea 4).
- [x] 5.5 Fiscalizar independientemente `can_commit`, `can_push`,
  `can_manage_prs`, `can_run_arbitrary_code` y `can_spawn_subagents` (sin derivar
  push/PR desde `can_commit`).
- [x] 5.6 Implementar la detección de bypasses: variantes de Git (force-push en
  todas sus formas), GitHub CLI (`gh pr *` y variantes) y comandos compuestos
  (`;`, `&&`, `|` con comandos prohibidos embebidos en segmentos no iniciales).
- [x] 5.7 Preferir allowlists de Git de solo lectura para agentes implementadores
  (`build`/`backend`/`frontend`) en el manifiesto, con la justificación del
  alcance actualizada; evaluar un wrapper seguro de `git push` para el agente
  `commit` que rechace cualquier variante force (decisión documentada; la
  denegación efectiva de todas las variantes queda validada automáticamente).
- [x] 5.8 Ampliar la detección de bypass compuesto a los separadores `;`, `&&`,
  `||`, `|` y newline, con y sin espacios alrededor (fixtures RED→GREEN por
  variante, con fixture de control que demuestra ausencia de falsos positivos);
  extender los patrones compuestos en el manifiesto y en los front matter de
  `build`/`backend`/`frontend` para cubrir las variantes sin espacios; alinear
  el comentario del validador y la documentación con la cobertura exacta (sin
  prometer "cobertura total"): los wrappers y la ejecución de código arbitrario
  (`bash -c`, `node -e`, subshells, backticks) quedan gobernados por
  `can_run_arbitrary_code` y la nota de defensa en profundidad, no por el
  análisis pattern-based.
- [x] 5.9 Documentar el tradeoff de seguridad en el manifiesto: cuando
  `can_run_arbitrary_code: true`, las denegaciones pattern-based de git de
  escritura son defensa contra errores accidentales (defensa en profundidad),
  no una frontera de seguridad frente a evasión deliberada; el wrapper seguro
  de `git push` se mantiene documentado como hardening futuro.

Suggested Path: `scripts/validate-agent-permissions.mjs`, `docs/agent-permission-contracts.yml`, `.opencode/agents/build.md`, `.opencode/agents/backend.md`, `.opencode/agents/frontend.md`
Test Path: `tests/permission-contracts-test.sh`, `tests/fixtures/permission-contracts/*`, `tests/validator-opencode-test.sh`, `tests/agent-permissions-test.sh`

## 6. Resolver correctamente el proyecto objetivo (REQ-008)

Prioridad: crítica | Capa: infrastructure | Estimación: media

> Delta normativo: `specs/specboot-update/spec.md` (REQ-008, junto a REQ-002).
> El delta `agent-permissions` no duplica esta norma: mantiene solo la
> integración del validador (manifiesto y validador leídos desde el paquete,
> `--root` explícito).

- [x] 6.1 Escribir los tests TDD primero (RED): fixtures consumidores — SC-012,
  `bash node_modules/@gabrielzavando/specboot/specboot.sh --ci` valida el
  directorio de invocación (no el paquete) y detecta una configuración inválida
  allí; cubrir también `--init` desde `node_modules`, ambas formas directas y
  que `specboot update`/`specboot init` de proyecto siguen operando sobre el
  directorio de invocación.
- [x] 6.2 Corregir `specboot.sh`: los modos `--ci`/`--init` validan el directorio
  desde el cual fueron invocados (en dogfooding coincide con el repo; desde
  `node_modules`, el proyecto), sin cambiar la resolución del framework source
  para `init`/`update` de proyecto.
- [x] 6.3 Alinear `check_permission_contracts()` con la resolución corregida: el
  proyecto validado siempre vía `--root` al directorio de invocación; el
  validador y el manifiesto siguen leyéndose desde el paquete.

Suggested Path: `specboot.sh`
Test Path: `tests/specboot-init-test.sh`, `tests/specboot-update-test.sh`, `tests/fixtures/` (fixtures consumidores)

## 7. Contratos de comandos (REQ-007)

Prioridad: alta | Capa: infrastructure | Estimación: media

- [x] 7.1 Escribir el test TDD primero (RED): `tests/command-contracts-test.sh` —
  SC-015, todos los `.opencode/commands/*.md` declaran `agent`; mapeos `/apply`
  → `build`, `/plan-change` → `sdd-plan`, `/verify` → `verify`, `/archive` →
  `archive`, `/commit` → `commit`, `/adversarial-review` → `reviewer` +
  `subtask: true`; fixtures con comando sin `agent` y con descalce fallan.
- [x] 7.2 Implementar la validación desde el front matter (parser real, no
  etiqueta visual del TUI): integrarla en la validación CI del framework
  (validador de contratos o script hermano), reportando comando + regla causante
  con exit ≠ 0 ante descalce.
- [x] 7.3 Verificar que el contrato válido pasa y un fixture corrupto falla
  dentro de `specboot.sh --ci`.

Suggested Path: `scripts/` (validador de contratos de comandos), `specboot.sh`
Test Path: `tests/command-contracts-test.sh`

## 8. Alinear documentación y estructura de validación (REQ-009)

Prioridad: alta | Capa: docs | Estimación: media

- [x] 8.1 Test RED: aserciones en los tests de regresión — `archive.md` sin la
  promesa de staging, skill `archive` con la ruta canónica
  `openspec/changes/archive/`, skill `plan-change` con la validación de `## Why`
  (SC-013), README distinguiendo workflows internos y plantillas consumidoras.
- [x] 8.2 Corregir `.opencode/commands/archive.md` (description sin "staging") y
  `ai-specs/skills/archive/SKILL.md` (rutas `openspec/archive/` → canónica
  `openspec/changes/archive/`); revisar referencias asociadas sin romper
  `{file:...}`.
- [x] 8.3 Actualizar `ai-specs/skills/plan-change/SKILL.md`: generar `## Why`
  con máximo 1000 caracteres y validar la longitud antes de informar éxito
  (checklist del Step 6); verificar el proposal de este change como muestra.
- [x] 8.4 Corregir `README.md` para distinguir workflows internos del
  repositorio Specboot y plantillas consumidoras (`templates/github/`), y
  alinear `docs/framework-contract.md` (frontera de distribución: init/update
  con listas explícitas, nunca `.github` completo).
- [x] 8.5 Mover `check_permission_contracts()` fuera de `check_ci_cd()` en
  `specboot.sh` (eliminando la dependencia implícita de orden), manteniendo su
  comportamiento y sección visible.
- [x] 8.6 Verificación final SC-014: `bash tests/run-all.sh`, `bash
  specboot.sh --ci`, pruebas `init/update` y fixtures consumidores en verde;
  `bash check-refs.sh` con 0 errores.

Suggested Path: `.opencode/commands/archive.md`, `ai-specs/skills/archive/SKILL.md`, `ai-specs/skills/plan-change/SKILL.md`, `README.md`, `docs/framework-contract.md`, `specboot.sh`
Test Path: `tests/run-all.sh`, `tests/apply-preflight-test.sh`, `tests/workflow-isolation-test.sh`
