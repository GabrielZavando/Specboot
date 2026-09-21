# Scenarios — SPECBOOT-PERM-01: agent-permission-contracts

Los escenarios mapean 1:1 los criterios de aceptación CA-001…CA-011 del
ticket. Todos se ejecutan sobre el repo del framework y, donde se indica,
sobre un proyecto consumidor temporal.

### SC-001: Contrato válido aprueba el CI

- **Given** que todos los agentes de `.opencode/agents/` cumplen el manifiesto
  de contratos
- **When** se ejecuta `bash specboot.sh --ci`
- **Then** la validación finaliza sin errores y muestra la sección
  `→ Verificando contratos de permisos de agentes...`

### SC-002: Catch-all después de un allow hace fallar el CI

- **Given** un fixture donde un agente declara `"editor/**": allow` seguido de
  `"*": deny` (orden viola `last-match-wins`)
- **When** se ejecuta el validador de contratos
- **Then** el CI falla indicando el agente, la capacidad requerida y la regla
  `"*": deny` que la anula

### SC-003: Reviewer escribe únicamente su evidencia

- **Given** el contrato efectivo del agente `reviewer`
- **When** se evalúan sus permisos de edición
- **Then** la única ruta modificable es
  `openspec/state/adversarial-result.json`
- **And** cualquier otra ruta de código, tests, documentación, specs o
  `tasks.md` resulta efectivamente `deny`

### SC-004: Verify escribe únicamente su evidencia

- **Given** el contrato efectivo del agente `verify`
- **When** se evalúan sus permisos de edición
- **Then** la única ruta modificable es `openspec/state/verify-results.json`
- **And** puede crear `openspec/state` y obtener timestamps UTC
- **And** cualquier otra ruta de código, documentación o `tasks.md` resulta
  efectivamente `deny`

### SC-005: Ownership exclusivo del commit

- **Given** cualquier agente distinto de `commit` (`build`, `backend`,
  `frontend`, `sdd-plan`, `verify`, `reviewer`, `archive`, `sync-specs`)
- **When** se evalúan los comandos `git commit` y `git push`
- **Then** el permiso efectivo es `deny` para ambos
- **And** en el agente `commit` esos comandos están permitidos

### SC-006: Force-push denegado en todas sus variantes

- **Given** cualquier agente del framework, incluyendo `commit`
- **When** se evalúan las variantes `git push --force`,
  `git push --force-with-lease`, `git push -f` y variantes con argumentos
  intermedios
- **Then** todas resultan efectivamente `deny`

### SC-007: Sin bypass de escritura vía ejecución arbitraria

- **Given** los contratos de `archive` y `commit`
- **When** se evalúan sus comandos permitidos
- **Then** no existe `node -e *`, `python -c *`, `python3 -c *`, `tee`,
  `cat >`, ni `sed -i` como vía genérica permitida
- **And** la lectura de campos JSON se realiza mediante el helper fijo y de
  solo lectura `scripts/read-json-field.mjs` con allowlist cerrada de
  archivos/campos autorizados

### SC-008: Fixture con permiso requerido ausente

- **Given** un fixture donde un agente pierde un permiso requerido por el
  manifiesto (por ejemplo `verify` pierde `bash tests/*`)
- **When** se ejecuta el validador sobre el fixture
- **Then** falla identificando el agente y la capacidad ausente

### SC-009: Fixture con alcance excedido

- **Given** un fixture donde un agente declara una ruta de edición más amplia
  que la permitida por el manifiesto
- **When** se ejecuta el validador sobre el fixture
- **Then** falla identificando el agente y el alcance excedido

### SC-010: Distribución íntegra en proyectos consumidores

- **Given** un proyecto temporal creado con `specboot init` y otro
  actualizado con `specboot update` (incluido un consumidor sin `js-yaml`
  hoisted en su propio `node_modules`)
- **When** se comparan los agentes y el helper instalados con los del
  framework, y se ejecuta el validador **desde el directorio del paquete**
  (`node_modules/@gabrielzavando/specboot/scripts/validate-agent-permissions.mjs --root <proyecto>`)
- **Then** agentes y helper coinciden con el framework, el manifiesto se lee
  desde el paquete (nunca del proyecto) y el validador pasa en ambos
  proyectos — y también en dogfooding con `--root .` desde el repo

### SC-011: Suite de guardado final del change

- **Given** la implementación completa del change
- **When** se ejecutan `git diff --check`, `bash check-refs.sh` y
  `bash specboot.sh --ci`
- **Then** los tres comandos finalizan con código 0
