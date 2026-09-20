# Requirements — SPECBOOT-PERM-01: agent-permission-contracts

Cada requerimiento es trazable a al menos un escenario de `scenarios.md`.

### REQ-001 — Manifiesto de contratos (SC-001, SC-008, SC-009)

Crear una fuente de verdad declarativa (YAML, framework-owned) que defina
para cada agente: rutas editables, comandos bash requeridos, operaciones
expresamente prohibidas, archivos que debe persistir, y banderas booleanas
(`can_commit`, `can_push`, `can_manage_prs`, `can_run_arbitrary_code`,
`can_spawn_subagents`). El validador no infiere responsabilidades desde prosa
libre: solo compara permisos efectivos contra el manifiesto.

### REQ-002 — Semántica last-match-wins (SC-001, SC-002, SC-006)

El validador calcula el permiso efectivo respetando el orden de evaluación de
OpenCode: la **última** regla que calza gana. Debe detectar: catch-all antes de
excepciones (regla requerida anulada), reglas genéricas finales que anulan
permisos requeridos, prohibiciones específicas precedidas por permisos
generales, y variantes de force-push que no prevalecen sobre `git push *`.

### REQ-003 — Contrato de verify (SC-004)

`verify` solo puede modificar `openspec/state/verify-results.json`, puede
crear `openspec/state`, puede ejecutar los runners documentados en su rol
(`npm test`, `npm run test *`, `npx vitest *`, `npx jest *`, `pytest *`,
`bash tests/*`, `bash scripts/*`, `openspec validate *`), puede obtener
timestamps UTC y no puede modificar código, documentación, `tasks.md` ni
otros estados. Persistencia fallida termina con error (contractual con su
rol).

### REQ-004 — Contrato de reviewer (SC-003)

`reviewer` solo puede modificar `openspec/state/adversarial-result.json`,
puede ejecutar la toolchain auditada (`npm audit *`, `npx eslint *`,
`npx dependency-cruiser *`), puede obtener timestamps UTC y no puede modificar
código, tests, documentación, specs ni `tasks.md`. Persistencia fallida
termina con error.

### REQ-005 — Ownership del commit (SC-005, SC-006)

Solo el agente `commit` puede ejecutar `git add`, `git commit`, `git push` y
operaciones de PR con `gh`. Todos los demás agentes tienen `git commit` y
`git push` efectivamente `deny`. El force-push queda `deny` para **todos**
(incluido `commit`) en sus variantes: `--force`, `--force-with-lease`, `-f` y
formas intermedias/trailing.

### REQ-006 — Sin bypasses de escritura (SC-007)

Auditar comandos que saltan la restricción de `edit`: `node -e *`,
`python -c *`, `python3 -c *`, `cat >`, `tee`, `sed -i` y shells/scripts
arbitrarios. Cuando un agente solo necesite leer campos JSON, reemplazar
`node -e *` por `scripts/read-json-field.mjs` (ESM, solo lectura, con
**allowlist cerrada de archivos y campos autorizados** hardcodeada dentro del
helper; no acepta rutas JSON arbitrarias del llamador). Aplica especialmente a
`archive` y `commit`.

### REQ-007 — Alcance de agentes implementadores (SC-005, SC-006)

Documentar explícitamente (en roles y en el manifiesto, sección de
justificación) por qué `build`, `backend` y `frontend` necesitan edición de
código. Mantener: force-push denegado, ownership de commit denegado,
operaciones destructivas de shell denegadas o sujetas a confirmación, y
prohibición de modificar las evidencias de verify/adversarial manualmente.
### REQ-008 — Validador automático (SC-001..SC-009)

Validador que: (1) descubre `.opencode/agents/*.md` **en el proyecto
objetivo**, que recibe mediante el argumento explícito `--root <dir>` (nunca
asume `cwd` como proyecto); (2) parsea su front matter YAML con `js-yaml`
declarado como **dependencia de ejecución del paquete**, resuelta **desde el
directorio donde vive el validador** (su propio `node_modules`), sin depender
del hoisting de npm en el consumidor; (3) calcula permisos efectivos con
`last-match-wins`; (4) compara contra el manifiesto; (5) reporta agente +
capacidad + regla causante de cada descalce; y (6) termina con exit code ≠ 0
ante cualquier descalce.

**Ubicación de ejecución (obligatoria)**: el validador vive dentro del
paquete Specboot y se ejecuta siempre **desde el directorio real del
framework**:
- Dogfooding: desde el propio repo (`scripts/validate-agent-permissions.mjs`).
- Consumidor: desde `node_modules/@gabrielzavando/specboot/scripts/validate-agent-permissions.mjs`.
El proyecto validado se pasa siempre con `--root`; el manifiesto se lee
desde el paquete del framework, no del proyecto.

### REQ-009 — Integración con CI (SC-001, SC-011)

Enlazar el validador en `bash specboot.sh --ci`, antes de cualquier publicación
o distribución, mostrando la sección identificable
`→ Verificando contratos de permisos de agentes...` en el resumen.

### REQ-010 — Distribución (SC-010, modo dual dogfooding/consumidor)

Split de distribución obligatorio:

- **Validador + manifiesto**: solo en el paquete (`package.json#files`); se
  ejecutan desde el directorio real del framework (repo en dogfooding,
  `node_modules/@gabrielzavando/specboot` en consumidores). **No** van a
  `UPDATE_ITEMS` ni a `REQUIRED_FILES`: se consultan en `node_modules`, no se
  copian al proyecto.
- **Helper `scripts/read-json-field.mjs`**: se distribuye al proyecto porque
  lo invocan directamente los agentes del proyecto → `package.json#files`,
  `UPDATE_ITEMS` (entry file-level `scripts/read-json-field.mjs`, no el dir
  `scripts/` completo) y `REQUIRED_FILES` de `specboot.sh`.
- `specboot init` y `specboot update` instalan los agentes corregidos y el
  helper; los tests de init/update cubren ambos modos, incluyendo un
  consumidor **sin `js-yaml` hoisted** en su `node_modules` raíz.

### REQ-011 — Archivos requeridos (SC-010, SC-011)

Actualizar las validaciones estructurales para incluir todos los agentes,
skills, helpers y archivos de contrato necesarios del ciclo SDD actual
(`/plan-change`, `/verify`, `/adversarial-review`, `/archive`, `/commit`).
Ninguno puede quedar fuera de la estructura requerida del framework.
