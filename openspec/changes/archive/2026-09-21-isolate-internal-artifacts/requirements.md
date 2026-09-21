# Requirements — SPECBOOT-HARDEN-02: isolate-internal-artifacts

> Rastro: cada REQ traza a sus escenarios en `scenarios.md` (SC-001..SC-015).

## REQ-001 — Separar workflows internos y consumidores

`.github/workflows/release.yml` debe permanecer exclusivamente en el repositorio
Specboot. `deploy.yml` no debe instalarse automáticamente en consumidores; debe
quedar como plantilla opcional. Solo el workflow CI diseñado para consumidores
puede instalarse por defecto. Debe existir una ubicación explícita:
`templates/github/workflows/consumer-ci.yml`, `templates/github/workflows/deploy.example.yml`
y `templates/github/pull_request_template.md`. El paquete npm no debe incluir
`.github/workflows/**`. El workflow interno de publicación nunca debe copiarse
mediante `init` ni `update`.

**Traza**: SC-001, SC-004.

## REQ-002 — Reparar consumidores existentes

`specboot update` debe detectar el `release.yml` heredado de Specboot, eliminarlo
si coincide con cualquier firma de la **allowlist de fingerprints framework-owned**
— todos los fingerprints de contenido de las variantes de `release.yml` que
Specboot distribuyó antes de este cambio, derivados del historial git y
documentados como contenido legacy inmutable (nunca derivados del
`release.yml` interno actual, que puede evolucionar y ya no se distribuye) —
respaldándolo antes de eliminarlo, no eliminar workflows personalizados,
advertir y exigir resolución explícita si el archivo fue modificado, y preservar
todos los workflows ajenos al framework.

**Formalizado en**: `specs/specboot-update/spec.md` (delta normativo).

**Traza**: SC-002, SC-003.

## REQ-003 — Distribución verificable

`npm pack --dry-run` debe excluir los workflows internos. El paquete debe incluir
las plantillas necesarias para consumidores. `init` debe instalar realmente el PR
template (hoy se solicita pero no está incluido en la allowlist npm). `init` y
`update` deben usar listas explícitas de archivos, nunca copiar `.github` completo.

**Traza**: SC-001, SC-004.

## REQ-004 — Pre-flight reanudable de `/apply`

El pre-flight debe ejecutarse una sola vez por change, no antes de cada tarea. En
la primera ejecución se permite suciedad limitada a
`openspec/changes/{active-change}/**` (creada por `/plan-change`). Cambios ajenos
al change deben continuar bloqueando la entrada. Una vez iniciada la
implementación, `/apply` debe aceptar los cambios producidos por tareas anteriores.
Nunca debe exigir commits intermedios. `/commit` conserva ownership exclusivo de
`git add`, `git commit` y `git push`. Reanudar `/apply` debe continuar desde la
primera tarea pendiente.

**Traza**: SC-005, SC-006, SC-007.

## REQ-005 — Contratos de subagentes

El manifiesto debe extenderse con un contrato explícito de subagentes por agente:

```yaml
task:
  allow: []
  forbidden:
    - "*"
```

Reglas: `build` solo puede invocar `backend` y `frontend`; `reviewer`, `verify`,
`commit`, `archive`, `sdd-plan`, `sync-specs`, `backend` y `frontend` no pueden
lanzar subagentes; `/adversarial-review` puede seguir invocando un único
`reviewer` mediante `subtask: true`, y el reviewer no puede generar hijos. Los
front matter deben declarar `permission.task` conforme a este contrato.

**Traza**: SC-008, SC-009.

## REQ-006 — Validador fiel a OpenCode

El validador debe: leer `opencode.json` del proyecto validado y calcular permisos
efectivos con el orden defaults → globales → agente; implementar `*` y `?`
conforme a OpenCode (wildcards, no literales); comparar el `mode` real con el
manifiesto; validar `permission.task`; fiscalizar independientemente `can_commit`,
`can_push`, `can_manage_prs`, `can_run_arbitrary_code` y `can_spawn_subagents` (sin
derivar `can_push` o PR management desde `can_commit`); detectar bypasses mediante
variantes de Git, GitHub CLI y comandos compuestos (`;`, `&&`, `||`, `|` y
newline, con y sin espacios alrededor del separador), con el comentario del
validador y la documentación prometiendo exactamente la cobertura que el
validador comprueba; documentar que para agentes con
`can_run_arbitrary_code: true` las denegaciones pattern-based son defensa contra
errores accidentales (defensa en profundidad) y no una frontera de seguridad
frente a evasión deliberada vía wrappers (`bash -c`, `node -e`, subshells,
backticks); preferir allowlists de Git de solo lectura para agentes
implementadores; y considerar un wrapper seguro para `git push` del agente
`commit` (mantenido como hardening futuro), rechazando cualquier variante force.

**Traza**: SC-010, SC-011.

## REQ-007 — Contratos de comandos

Debe agregarse validación automática de `.opencode/commands/*.md` integrada en la
validación CI del framework: todos los comandos deben declarar `agent`; `/apply`
→ `build`; `/plan-change` → `sdd-plan`; `/verify` → `verify`; `/archive` →
`archive`; `/commit` → `commit`; `/adversarial-review` → `reviewer` y
`subtask: true`. La etiqueta visual del TUI no debe considerarse prueba del agente
efectivo: el contrato se valida desde el front matter.

**Traza**: SC-015.

## REQ-008 — Resolver correctamente el proyecto objetivo

Ejecutado desde `node_modules`, `bash node_modules/@gabrielzavando/specboot/specboot.sh --ci`
debe validar el directorio desde el cual fue invocado (el proyecto consumidor), no
el contenido del paquete. Debe cubrir igualmente `--init` desde `node_modules`,
`bash specboot.sh --ci` y `bash specboot.sh --init` ejecutados directamente.

**Formalizado en**: `specs/specboot-update/spec.md` (delta normativo, junto a
REQ-002). El validador de REQ-006 mantiene su integración (validador y manifiesto
leídos desde el paquete, `--root` explícito) sin duplicar esta norma.

**Traza**: SC-012.

## REQ-009 — Alinear documentación

`/archive` no debe prometer staging. Debe usarse siempre la ruta canónica
`openspec/changes/archive/`. La documentación de cada agente debe coincidir con
sus permisos efectivos (incluyendo `permission.task`). `plan-change` debe generar
`## Why` con máximo 1000 caracteres y validarlo antes de informar éxito. El README
debe distinguir workflows internos y plantillas consumidoras.
`check_permission_contracts()` debe moverse fuera de `check_ci_cd()` para eliminar
la dependencia implícita de orden.

**Traza**: SC-013, SC-014.
