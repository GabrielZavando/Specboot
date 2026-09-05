# Implementation Tasks: persist-adversarial-verdict

## 1. Persistir el veredicto adversarial (M-502 — TDD primero)

- [x] 1.1 Crear self-test del esquema `tests/adversarial-state-test.sh` (RED): valida claves requeridas (`schema_version`, `change`, `ticket_id`, `verdict`, `confidence`, `timestamp`, `findings`), enums (`SHIP|NO-SHIP`), rango de `confidence` (0.0–1.0), timestamp ISO-8601, contadores enteros no negativos y el invariante `total = critical + warnings + info` con `critical ≤ total`. Incluir tests negativos (veredicto inválido, confidence fuera de rango, contadores inconsistentes, timestamp no ISO). Debe fallar (RED) antes de crear el fixture. Asserts con prefijo `[SC-NNN]`.
  - **Priority**: High
  - **Layer**: tests
  - **Estimate**: S
  - **Suggested Path**: tests/adversarial-state-test.sh
  - **Test Path**: tests/adversarial-state-test.sh

- [x] 1.2 Crear fixture canónico del esquema `ai-specs/examples/adversarial-results-example.json` (lo valida 1.1 → GREEN)
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/examples/adversarial-results-example.json
  - **Test Path**: tests/adversarial-state-test.sh

- [x] 1.3 Añadir paso "Persistencia del veredicto" al SKILL de `code-auditing`: escribir `openspec/state/adversarial-result.json` tras cada auditoría (incluido NO-SHIP, last-run-wins) con el esquema `schema_version=1`; eliminar "solo pantalla, no persistido" del Paso 5
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: M
  - **Suggested Path**: ai-specs/skills/code-auditing/SKILL.md
  - **Test Path**: tests/adversarial-state-test.sh

- [x] 1.4 Sincronizar rol↔permisos del subagente `reviewer` (patrón M-403): añadir `"mkdir -p openspec/*": allow` al permission block de `.opencode/agents/reviewer.md` (escritura de evidencia vía `cat` por redirección, patrón verify; `edit` permanece deny), actualizar descripciones en `.opencode/commands/adversarial-review.md`, `AGENTS.md` (§5.3) y `ai-specs/README.md` ("read-only sobre código, persiste evidencia en `openspec/state/`"), y auditar brechas rol↔permisos existentes (ej. `ls` del Paso 1 sin patrón allow)
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: M
  - **Suggested Path**: .opencode/agents/reviewer.md
  - **Test Path**: no aplica

- [x] 1.5 Añadir al Step 5 del SKILL `archive` el campo opcional `adversarial: {verdict, timestamp, source}` en la entrada del manifest: incluir si `adversarial-result.json` existe con `change` coincidente (lectura token-light de 3 campos, nunca el detalle de hallazgos); si falta o es ajeno → advertir y sugerir `/adversarial-review`, nunca bloquear
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/skills/archive/SKILL.md
  - **Test Path**: no aplica

- [x] 1.6 Actualizar Step 2 del SKILL `commit` con la lectura informada del veredicto: `SHIP` vigente para el change activo omite la confirmación y reporta evidencia · `NO-SHIP` advierte y ofrece re-auditar o abortar sin continuar en silencio · ausente o ajeno mantiene el flujo actual · staleness warn-only · reemplazar la nota "Su veredicto persistido como gate es M-502, futuro"
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: M
  - **Suggested Path**: ai-specs/skills/commit/SKILL.md
  - **Test Path**: no aplica

## 2. Auto-refutación estructurada (M-501)

- [x] 2.1 Formalizar el protocolo de 4 pasos en `code-auditing/SKILL.md` (reemplazando la línea 34 actual): hallazgo CRITICAL → ¿puede ser falso positivo? → buscar evidencia contradictoria en código/tests → decisión final mantener/descartar con motivo. Solo los hallazgos que sobreviven aparecen en el veredicto.
  - **Priority**: High
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/skills/code-auditing/SKILL.md
  - **Test Path**: no aplica

- [x] 2.2 Actualizar la plantilla del Paso 5 con el anexo "Descartados" (hallazgo original + refutación + motivo por cada hallazgo crítico refutado) y vincular su conteo a `findings.discarded` del JSON persistido
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: ai-specs/skills/code-auditing/SKILL.md
  - **Test Path**: tests/adversarial-state-test.sh

## 3. Cierre del change

- [x] 3.1 Bump de versión `0.3.0` → `0.4.0` (minor) y entrada `## [0.4.0]` en CHANGELOG con los cambios de Fase 5
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: package.json
  - **Test Path**: no aplica

- [x] 3.2 Marcar `[x]` M-501 y M-502 en `PLAN_MEJORAS_SPECBOOT.md` y añadir fila v3.4 al historial de correcciones
  - **Priority**: Medium
  - **Layer**: docs
  - **Estimate**: S
  - **Suggested Path**: PLAN_MEJORAS_SPECBOOT.md
  - **Test Path**: no aplica
