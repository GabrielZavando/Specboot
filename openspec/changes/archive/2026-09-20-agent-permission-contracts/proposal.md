# Proposal: Formalizar y validar contratos de permisos de agentes OpenCode

- **Ticket ID**: SPECBOOT-PERM-01
- **Título original**: Formalizar y validar contratos de permisos de agentes OpenCode
- **Tag**: `[backend]` (inferido, confirmado por el usuario)
- **Change name**: `agent-permission-contracts`

## Why

El commit de bootstrap `eedb3a9` desbloqueó el ciclo SDD corrigiendo el orden
`last-match-wins`, acotando la escritura de evidencias de `verify` y
`reviewer`, haciendo la persistencia fail-closed y alineando `archive.md` con
`archive-agent.md`. Sin embargo, esas correcciones solo se verifican hoy con
tests de tokens de texto (`tests/agent-permissions-test.sh`) y revisión
manual: `specboot.sh --ci` valida sintaxis, estructura y referencias, pero
**no comprueba la semántica efectiva de los permisos** de los agentes.

Sin una validación semántica, cualquier cambio futuro puede reintroducir
silenciosamente regresiones como:

- Un catch-all `"*": deny` colocado antes de una excepción requerida
  (anulándola).
- Patrones de escritura demasiado amplios en agentes read-only.
- `git commit` / `git push` permitidos en agentes que no son `commit`.
- Variantes de force-push no cubiertas por las denegaciones existentes.
- Bypasses de escritura vía `node -e *`, `python -c *`, `sed -i`, `tee`, etc.

Los permisos deben pasar a ser **contratos explícitos, verificables
automáticamente y protegidos contra regresiones** antes de que el framework se
distribuya.

## What Changes

Incluido:

- Manifiesto declarativo de contratos por agente (REQ-001): fuente de verdad
  que define para cada agente rutas editables, comandos bash requeridos,
  prohibiciones explícitas, archivos que debe persistir, capacidad de
  commit/push/PR, ejecución de código arbitrario y lanzamiento de subagentes.
- Auditoría y corrección de los bloques de permisos de `opencode.json` y los
  10 agentes de `.opencode/agents/` (archive, backend, build, commit,
  frontend, reviewer, sdd-plan, sync-specs, verify) más los skills/roles que
  referencian, garantizando (REQ-002…REQ-007):
  - Semántica `last-match-wins` correcta (catch-all antes de excepciones,
    force-push denegado en todas sus variantes).
  - `verify` escribe únicamente `openspec/state/verify-results.json`;
    `reviewer` únicamente `openspec/state/adversarial-result.json`; ambos con
    persistencia fail-closed.
  - Ownership de commit: solo el agente `commit` ejecuta `git add`,
    `git commit`, `git push` y PRs vía `gh`.
  - Eliminación de bypasses de escritura: `node -e *` se reemplaza por un
    helper fijo, ESM y de solo lectura (`scripts/read-json-field.mjs`) con
    allowlist cerrada de archivos/campos autorizados hardcodeada en su código,
    en `archive` y `commit`.
  - Justificación explícita documentada del alcance de `build`, `backend` y
    `frontend`, manteniendo force-push y ownership de commit denegados.
- Validador automático (REQ-008): descubre `.opencode/agents/*.md`, parsea su
  front matter YAML estructuralmente (sin grep-texto como mecanismo único),
  calcula permisos efectivos con la regla `last-match-wins`, compara contra el
  manifiesto y reporta agente/capacidad/regla causante, con exit code ≠ 0 ante
  descalces.
- Integración en `specboot.sh --ci` (REQ-009) con sección visible
  `→ Verificando contratos de permisos de agentes...`, más actualización de
  los archivos requeridos de la estructura (REQ-011).
- Distribución vía `specboot init` y `specboot update` (REQ-010) con
  **modo dual obligatorio dogfooding/consumidor**: el validador y el
  manifiesto viven solo en el paquete y se ejecutan desde el directorio real
  del framework (repo en dogfooding; `node_modules/@gabrielzavando/specboot`
  en consumidores), recibiendo el proyecto a validar vía `--root`; `js-yaml`
  es dependencia de ejecución del paquete resuelta desde el directorio del
  validador (sin depender del hoisting del consumidor); el helper
  `read-json-field.mjs` sí se copia al proyecto porque lo invocan sus agentes
  directamente. Probado en dogfooding y en consumidor temporal sin
  `js-yaml` hoisted.

Fuera de alcance (per ticket): esquemas JSON de las evidencias, estados
PASS/PARTIAL/FAIL/SHIP/NO-SHIP, gates de `/commit`, publicación de nueva
versión del paquete, proveedores/modelos de IA, rediseño del ciclo SDD y
reversión de `eedb3a9`.
