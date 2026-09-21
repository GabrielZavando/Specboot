# Proposal: Aislar artefactos internos y cerrar contratos operacionales

- **Ticket ID**: SPECBOOT-HARDEN-02
- **Título original**: Aislar artefactos internos y cerrar contratos operacionales
- **Prioridad**: Crítica
- **Tag**: `[docs]` (inferido) — el tag SOLO guía la carga de estándares de
  documentación; NO limita los estándares aplicables ni el dispatch de
  implementación (el agente `build` despacha por dominio de tarea:
  backend/frontend/fullstack) y no debe considerarse restricción de alcance
- **Change name**: `isolate-internal-artifacts`
- **Change type**: tooling/framework — automatizaciones y contratos operacionales
  del propio framework; fusiona deltas de capacidades del framework
  (`specboot-update`, `specboot-workflows`, `agent-permissions`, `cycle-hygiene`,
  `npm-distribution`), sin specs de dominio

## Why

`package.json` publica `.github/workflows` y `specboot init` copia `.github`
completo, entregando a los consumidores `release.yml`, que ejecuta `npm publish`
en cada push a `main`: un consumidor puede publicar el paquete del framework sin
quererlo. Además, `apply.md` exige el árbol git limpio antes de cada tarea y
bloquea changes multi-tarea; el validador de permisos trata `?` como literal,
asume `deny` implícito, ignora `opencode.json` global, no valida `permission.task`
ni compara `mode`, y deriva push/PR desde `can_commit`; los agentes sin
subagentes no declaran `task: deny`; `archive` promete staging y usa rutas no
canónicas; y `--ci` desde `node_modules` valida el paquete en vez del consumidor.
Sin contratos explícitos y verificables, estas brechas se reintroducen en silencio.

## What Changes

Incluido:

- **REQ-001 — Aislar workflows internos y consumidores**: `release.yml` permanece
  exclusivamente en el repositorio Specboot; `deploy.yml` deja de instalarse
  automáticamente y pasa a plantilla opcional
  (`templates/github/workflows/deploy.example.yml`); solo el workflow CI diseñado
  para consumidores se instala por defecto; ubicación explícita
  `templates/github/workflows/consumer-ci.yml` + `templates/github/pull_request_template.md`;
  el paquete npm excluye `.github/workflows/**`; `init`/`update` usan listas
  explícitas de archivos y nunca copian `.github` completo.
- **REQ-002 — Reparar consumidores existentes**: `specboot update` detecta el
  `release.yml` heredado de Specboot, lo respalda antes de eliminarlo si coincide
  con la firma conocida del archivo framework-owned, advierte y exige resolución
  explícita si fue modificado, y nunca elimina workflows personalizados.
- **REQ-003 — Distribución verificable**: `npm pack --dry-run` excluye los
  workflows internos; el paquete incluye las plantillas necesarias para
  consumidores; `init` instala realmente el PR template (hoy se solicita pero no
  se distribuye por npm).
- **REQ-004 — Pre-flight reanudable de `/apply`**: el pre-flight corre una vez por
  change, no antes de cada tarea; la primera ejecución admite suciedad limitada a
  `openspec/changes/{active-change}/**` (creada por `/plan-change`); cambios
  ajenos al change siguen bloqueando; tras iniciar la implementación `/apply`
  acepta los cambios producidos por tareas anteriores; nunca exige commits
  intermedios; reanuda desde la primera tarea pendiente; `/commit` conserva
  ownership exclusivo de `git add`, `git commit` y `git push`.
- **REQ-005 — Contratos de subagentes**: el manifiesto se extiende con el contrato
  `task: {allow, forbidden}`; `build` solo puede invocar `backend` y `frontend`;
  `reviewer`, `verify`, `commit`, `archive`, `sdd-plan`, `sync-specs`, `backend` y
  `frontend` no pueden lanzar subagentes; `/adversarial-review` mantiene un único
  `reviewer` mediante `subtask: true`, sin que el reviewer genere hijos.
- **REQ-006 — Validador fiel a OpenCode**: leer `opencode.json` y calcular
  permisos efectivos (defaults → globales → agente); implementar `*` y `?`
  conforme a OpenCode; comparar el `mode` real con el manifiesto; validar
  `permission.task`; fiscalizar independientemente `can_commit`, `can_push`,
  `can_manage_prs`, `can_run_arbitrary_code` y `can_spawn_subagents` (sin derivar
  push/PR desde `can_commit`); detectar bypasses mediante variantes de Git, GitHub
  CLI y comandos compuestos; preferir allowlists de Git de solo lectura para
  agentes implementadores; evaluar un wrapper seguro de `git push` para el agente
  `commit` que rechace cualquier variante force.
- **REQ-007 — Contratos de comandos**: validación automática de
  `.opencode/commands/*.md` desde el front matter (la etiqueta visual del TUI no
  es prueba del agente efectivo): todos declaran `agent`; `/apply` → `build`,
  `/plan-change` → `sdd-plan`, `/verify` → `verify`, `/archive` → `archive`,
  `/commit` → `commit`, `/adversarial-review` → `reviewer` + `subtask: true`.
- **REQ-008 — Resolver correctamente el proyecto objetivo**: `--ci` y `--init`
  validan el directorio desde el cual fueron invocados (repo en dogfooding;
  proyecto cuando se ejecuta desde `node_modules/@gabrielzavando/specboot`), no el
  contenido del paquete.
- **REQ-009 — Alinear documentación**: `/archive` no promete staging; ruta
  canónica `openspec/changes/archive/`; docs de cada agente coinciden con permisos
  efectivos; `plan-change` genera `## Why` con máximo 1000 caracteres y lo valida
  antes de informar éxito; README distingue workflows internos y plantillas
  consumidoras; `check_permission_contracts()` fuera de `check_ci_cd()`.

Fuera de alcance (per ticket): cambiar el mecanismo de publicación del propio
paquete Specboot, eliminar el subagente `reviewer`, diseñar despliegues
específicos para aplicaciones consumidoras, hacer merge o push automático.
