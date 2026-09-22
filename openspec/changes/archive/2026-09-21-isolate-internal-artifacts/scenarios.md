# Scenarios — SPECBOOT-HARDEN-02: isolate-internal-artifacts

> Mapeo 1:1 de los escenarios de aceptación del ticket (SC-001..SC-014),
> preservando sus IDs. SC-015 agrega cobertura de REQ-007 (trazabilidad exigida
> por el skill `plan-change`: todo requisito traza a al menos un escenario).
> Change de tooling/framework: no hay entidades de dominio ni endpoints API
> que verificar (Step 4½: "none", sin conflictos críticos).
> Deltas normativos: SC-002/SC-003 y SC-012 se formalizan en
> `specs/specboot-update/spec.md`; SC-001/SC-004 en `specs/specboot-workflows/`
> y `specs/npm-distribution/`; SC-005..SC-007 en `specs/cycle-hygiene/`;
> SC-008..SC-011 y SC-015 en `specs/agent-permissions/`.

### SC-001: Un proyecto nuevo recibe CI y PR template, pero no `release.yml` ni publicación npm

- **GIVEN** el framework Specboot con `templates/github/workflows/consumer-ci.yml`,
  `templates/github/workflows/deploy.example.yml` y `templates/github/pull_request_template.md`
- **WHEN** un proyecto nuevo ejecuta `specboot init` desde el paquete instalado
- **THEN** el proyecto recibe el workflow CI de consumidores en
  `.github/workflows/ci.yml` y el PR template en `.github/pull_request_template.md`
- **AND** el proyecto NO recibe `.github/workflows/release.yml`, ni el workflow
  interno `deploy.yml` como workflow activo, ni el mecanismo de publicación npm
  del framework (`release.yml` nunca se copia mediante `init` ni `update`)

### SC-002: Actualizar un consumidor contaminado elimina de forma segura el release heredado

- **GIVEN** un proyecto consumidor contaminado con una variante del
  `release.yml` heredado de Specboot intacta (coincide con cualquiera de las
  firmas de la allowlist de fingerprints framework-owned, derivadas del
  historial git: contenido legacy inmutable)
- **WHEN** el proyecto ejecuta `specboot update`
- **THEN** el `release.yml` heredado es respaldado antes de eliminarse y luego
  eliminado de `.github/workflows/`
- **AND** la salida del update reporta la eliminación y la ubicación del respaldo

### SC-003: Workflows personalizados sobreviven a `specboot update`

- **GIVEN** un proyecto consumidor con un workflow personalizado
  (`.github/workflows/mi-deploy.yml`) y sin relación con el framework
- **WHEN** el proyecto ejecuta `specboot update`
- **THEN** el workflow personalizado permanece intacto
- **AND** ningún paso del update elimina o sobrescribe workflows ajenos al framework

### SC-004: `npm pack --dry-run` no contiene workflows internos

- **GIVEN** el `files` allowlist de `package.json` sin `.github/workflows/**` y con
  las plantillas de consumidores incluidas
- **WHEN** `npm pack --dry-run` corre en el repositorio Specboot
- **THEN** el tarball no contiene ningún archivo bajo `.github/workflows/`
  (incluido `release.yml`)
- **AND** el tarball incluye `templates/github/workflows/consumer-ci.yml`,
  `templates/github/workflows/deploy.example.yml`,
  `templates/github/pull_request_template.md` (fuente de los artifacts que
  `init` instala en `.github/`)

### SC-005: `/apply` comienza con artefactos de planificación sin exigir commit manual

- **GIVEN** un change recién generado por `/plan-change` con suciedad limitada a
  `openspec/changes/{active-change}/**` (artefactos untracked) y rama de ticket
  correcta
- **WHEN** `/apply` ejecuta su pre-flight por primera vez para ese change
- **THEN** el pre-flight pasa sin exigir commit o stash manual
- **AND** la implementación de la primera tarea comienza normalmente

### SC-006: Después de completar una tarea, `/apply` continúa con la siguiente sobre el árbol dirty esperado

- **GIVEN** un change en ejecución con al menos una tarea completada (el árbol
  contiene cambios de código producidos por tareas anteriores, sin commitear)
- **WHEN** `/apply` reanuda el change
- **THEN** el pre-flight no vuelve a bloquear por el árbol dirty producido por el
  propio change
- **AND** `/apply` continúa desde la primera tarea pendiente (`- [ ]` de
  `tasks.md`) sin exigir commits intermedios

### SC-007: Cambios ajenos preexistentes siguen bloqueando `/apply`

- **GIVEN** un árbol con cambios sin commitear ajenos al change activo (por
  ejemplo código modificado fuera de `openspec/changes/{active-change}/**` y
  fuera de las tareas del change) antes de iniciar la implementación
- **WHEN** `/apply` ejecuta su pre-flight
- **THEN** la entrada es bloqueada con un mensaje explícito listando los archivos
  ajenos y pidiendo commit o stash
- **AND** la suciedad permitida se limita a `openspec/changes/{active-change}/**`
  en la primera ejecución y a los cambios producidos por tareas previas del
  change después

### SC-008: Agentes con `can_spawn_subagents: false` resuelven efectivamente `task: deny`

- **GIVEN** el manifiesto con el contrato `task: {allow: [], forbidden: ["*"]}`
  para `reviewer`, `verify`, `commit`, `archive`, `sdd-plan`, `sync-specs`,
  `backend` y `frontend`, y sus front matter declarando `permission.task`
- **WHEN** el validador calcula el permiso efectivo `task` para cualquier nombre
  de subagente en esos agentes
- **THEN** el resultado efectivo es `deny`
- **AND** cualquier agente con `can_spawn_subagents: false` sin `permission.task:
  deny` efectivo falla la validación con agente + capacidad + regla causante

### SC-009: `build` solo puede invocar `backend` y `frontend`

- **GIVEN** el manifiesto con el contrato `task: {allow: [backend, frontend],
  forbidden: ["*"]}` para `build`, y su front matter declarando `permission.task`
- **WHEN** el validador evalúa la invocación de `backend` y `frontend` desde
  `build`
- **THEN** ambas resuelven efectivamente `allow`
- **AND** la invocación de cualquier otro subagente (`verify`, `reviewer`,
  `commit`, `archive`, `sdd-plan`, `sync-specs`) desde `build` resuelve `deny`

### SC-010: Cada flag del manifiesto falla CI cuando se incumple

- **GIVEN** el validador extendido que fiscaliza independientemente `can_commit`,
  `can_push`, `can_manage_prs`, `can_run_arbitrary_code` y `can_spawn_subagents`
- **WHEN** un fixture incumple cada flag (por ejemplo `can_push: false` con
  `git push` efectivamente allow, o `can_manage_prs: false` con `gh pr create *`
  allow, o `can_spawn_subagents: false` con `task` permisivo)
- **THEN** cada incumplimiento se reporta como violación independiente (agente +
  capacidad + regla) y `specboot.sh --ci` sale con código ≠ 0
- **AND** ningún flag se deriva de otro (desmarcar `can_commit` no oculta una
  violación de `can_push` ni de PR management)

### SC-011: Los patrones `*`, `?`, comandos compuestos y variantes de force-push se evalúan correctamente

- **GIVEN** el validador con semántica de patrones fiel a OpenCode
- **WHEN** se evalúan patrones con `*` (comodín multi-carácter) y `?` (comodín de
  un carácter), permisos efectivos combinando defaults → globales de
  `opencode.json` → agente, comandos compuestos (`;`, `&&`, `||`, `|` y
  newline, cada uno con y sin espacios alrededor) y variantes de force-push
  (`--force`, `--force-with-lease`, `-f`, variantes con argumentos intermedios)
  y variantes de GitHub CLI
- **THEN** cada caso resuelve conforme a la semántica de OpenCode
- **AND** los fixtures de bypass (comando compuesto que esconde `git push --force`
  o `gh pr create` en un segmento no inicial) resuelven a `deny` donde el contrato
  lo exige
- **AND** el comentario del validador y la documentación prometen exactamente la
  cobertura comprobada; los wrappers de código arbitrario (`bash -c`, `node -e`,
  subshells, backticks) quedan gobernados por `can_run_arbitrary_code` y la nota
  de defensa en profundidad, sin prometer una frontera pattern-based imposible

### SC-012: Ejecutar `--ci` desde el paquete valida el consumidor y detecta una configuración inválida allí

- **GIVEN** un proyecto consumidor con el framework instalado en
  `node_modules/@gabrielzavando/specboot` y una configuración inválida en el
  consumidor (por ejemplo un agente con permisos que incumplen el manifiesto)
- **WHEN** el consumidor ejecuta `bash node_modules/@gabrielzavando/specboot/specboot.sh --ci`
- **THEN** la validación corre sobre el directorio desde el cual fue invocado (el
  proyecto consumidor), no sobre el contenido del paquete
- **AND** la configuración inválida del consumidor es detectada y reportada (y el
  equivalente `--init` también opera sobre el directorio de invocación)
- **AND** `specboot update` y `specboot init` de proyecto siguen operando sobre el
  directorio de invocación (normativa completa de REQ-008 en
  `specs/specboot-update/spec.md`)

### SC-013: `proposal.md` no genera warnings por extensión de `## Why`

- **GIVEN** el skill `plan-change` actualizado para generar `## Why` con máximo
  1000 caracteres y validarlo antes de informar éxito
- **WHEN** un nuevo change proposal es generado
- **THEN** su `## Why` cumple el límite de 1000 caracteres y la validación corre
  antes de reportar éxito
- **AND** `openspec archive` no emite warnings por la sección `## Why` del
  proposal generado

### SC-014: `tests/run-all.sh`, `specboot.sh --ci`, pruebas `init/update` y fixtures consumidores terminan en verde

- **GIVEN** el change aplicado con sus tests de regresión (workflow isolation,
  permisos, comandos, pre-flight, target resolution)
- **WHEN** corren `bash tests/run-all.sh`, `bash specboot.sh --ci`, las pruebas
  `init/update` (`tests/specboot-init-test.sh`, `tests/update-test.sh`,
  `tests/specboot-update-test.sh`) y los fixtures consumidores
- **THEN** todos terminan en verde
- **AND** `bash check-refs.sh` reporta 0 errores

### SC-015: El contrato de comandos se valida desde el front matter y falla CI ante descalce

- **GIVEN** la validación automática de `.opencode/commands/*.md` integrada en CI
- **WHEN** cada comando es evaluado desde su front matter (no desde la etiqueta
  visual del TUI)
- **THEN** todos declaran `agent`, con los mapeos `/apply` → `build`,
  `/plan-change` → `sdd-plan`, `/verify` → `verify`, `/archive` → `archive`,
  `/commit` → `commit` y `/adversarial-review` → `reviewer` + `subtask: true`
- **AND** un fixture con un comando sin `agent`, con agente descalzado o sin
  `subtask: true` en `adversarial-review` falla CI con comando + regla causante
