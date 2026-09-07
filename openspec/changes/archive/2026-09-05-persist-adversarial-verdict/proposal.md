# Change Proposal: persist-adversarial-verdict

- **Ticket ID**: M-501-502
- **Original Title**: [docs] Fase 5: auto-refutación estructurada y veredicto adversarial persistente como gate
- **Tag (source)**: [docs] (explicit)
- **Derived change name**: `persist-adversarial-verdict`
- **Change folder**: `openspec/changes/persist-adversarial-verdict/`
- **Enriched artifact used**: no (ticket de PLAN_MEJORAS_SPECBOOT.md + propuesta validada en sesión)
- **SemVer Impact**: minor

## Summary

Este cambio implementa la **Fase 5** del plan de mejoras de Specboot
(`PLAN_MEJORAS_SPECBOOT.md`), abordando los tickets **M-501** y **M-502** en un
solo change (convención de batch por fase del repo; el esquema JSON de M-502
depende del formato de veredicto que M-501 formaliza):

1. **M-501 (Auto-refutación estructurada)**: la auto-refutación de hallazgos
   críticos de `adversarial-review` —hoy una heurística de una línea en
   `code-auditing/SKILL.md`— se formaliza como protocolo de 4 pasos
   (hallazgo → ¿falso positivo? → evidencia contradictoria → decisión con
   motivo), y el reporte final incluye un anexo "Descartados" que audita el
   propio proceso de refutación.

2. **M-502 (Persistir el veredicto como gate)**: `/adversarial-review` escribe
   `openspec/state/adversarial-result.json` tras cada ejecución (incluida
   NO-SHIP), con esquema versionado (`schema_version: 1`) y self-test
   ejecutable. El skill `archive` referencia el veredicto en la entrada del
   manifiesto (advierte sin bloquear si falta) y el skill `commit` lo usa como
   **gate informado suave**.

## Motivation

- Hoy el veredicto `SHIP`/`NO-SHIP` es **efímero**: el Paso 5 de
  `code-auditing/SKILL.md` dice explícitamente "solo pantalla, no persistido".
  No existe archivo que `/commit` o `/archive` puedan consultar sin re-ejecutar
  la auditoría completa.
- La auto-refutación actual no deja rastro de qué evidencia se buscó ni por qué
  se descartó un hallazgo: imposible auditar el proceso de refutación.
- **M-901** (gate duro de commit, futuro) depende de esta evidencia persistente;
  este change entrega el estado + gates suaves; M-901 los endurecerá después
  (con `--force` registrado). El skill `commit` ya anticipa este trabajo:
  "Su veredicto persistido como gate es M-502, futuro."
- La Fase 5 completa queda así alineada con lo que M-401 hizo por `/verify`
  (Fase 4): estado persistente, esquema versionado autovalidado, gate suave en
  `commit` y referencia en el manifest de `archive`.

## What Changes

- **M-502**:
  - `code-auditing` (skill del reviewer, nuevo paso de persistencia): escribe
    `openspec/state/adversarial-result.json` tras cada auditoría con el esquema
    `schema_version=1`, `verdict` (`SHIP|NO-SHIP`), `confidence`, `timestamp`
    ISO-8601 y contadores `findings` (`total`, `critical`, `warnings`, `info`,
    `discarded`). Last-run-wins; trackeado en git.
  - Self-test ejecutable del esquema: `tests/adversarial-state-test.sh`
    validando el fixture canónico `ai-specs/examples/adversarial-results-example.json`
    (patrón `tests/verify-state-test.sh`: `node -e`, nunca `jq`).
  - `archive` (Step 5): campo opcional `adversarial: {verdict, timestamp, source}`
    en la entrada del `manifest.json`; si el archivo falta o corresponde a otro
    change → advierte y sugiere ejecutar `/adversarial-review`, **nunca
    bloquea**. Token-light: nunca lee el detalle de hallazgos.
  - `commit` (Step 2): lectura informada del veredicto — `SHIP` vigente para el
    change activo → reporta y continúa; `NO-SHIP` → advierte y exige decisión
    explícita del usuario; ausente o de otro change → mantiene el flujo actual;
    staleness warn-only.
  - Sincronización rol↔permisos del subagente `reviewer` (lección M-403): la
    escritura de la evidencia exige una excepción acotada (patrón `verify`:
    `cat` por redirección + `mkdir -p openspec/*`), y todas las descripciones
    ("read-only") se actualizan con la excepción documentada.
- **M-501**:
  - Protocolo de auto-refutación de 4 pasos formalizado en
    `code-auditing/SKILL.md`, reemplazando la línea-heurística actual.
  - Plantilla de reporte con anexo "Descartados" (hallazgo + refutación +
    motivo), alimentando el contador `findings.discarded` del JSON.
- **Cierre**:
  - Bump de versión `0.3.0` → `0.4.0` (minor) + entrada CHANGELOG (spec
    `version-bump`: el mantenedor bumpa antes del merge para no bloquear
    `release.yml`).
  - `PLAN_MEJORAS_SPECBOOT.md`: marcar `[x]` M-501/M-502 + fila de historial
    v3.4.

## Decisions

- **Batch M-501+M-502 en un change**: el esquema JSON de M-502 usa
  `findings.discarded`, que solo tiene sentido con el anexo "Descartados" que
  M-501 formaliza. Separarlos obligaría a revisar el esquema dos veces.
- **Gates suaves informados (decisión del mantenedor, 2026-09-05)**: `archive`
  nunca bloquea por falta de evidencia adversarial (diseño M-401 preservado) y
  `commit` advierte con NO-SHIP pero no bloquea de forma dura. El gate duro del
  veredicto es **M-901**, fuera de alcance aquí. `/adversarial-review` sigue
  siendo un paso opcional del ciclo.
- **Esquema fusionado plan+propuesta**: contadores del `summary` YAML que el
  skill ya emite (`total/critical/warnings/info`) + `discarded` de M-501, en un
  objeto `findings`; `schema_version` y `ticket_id` como `verify-results.json`
  (el match por `change` evita usar evidencia ajena como gate).
- **Excepción de escritura acotada**: el reviewer permanece read-only sobre
  código y specs; su única escritura permitida es la evidencia en
  `openspec/state/` (mismo patrón que el agente `verify` desde M-401/M-403).
- **`adversarial-result.json` trackeado en git**: evidencia auditable en PRs;
  `openspec/state/` ya está excluido de los warnings de `archive` Step 2.

## Acceptance Criteria

- [ ] Tras `/adversarial-review` existe `openspec/state/adversarial-result.json`
      con el esquema versionado (también cuando el veredicto es NO-SHIP)
- [ ] El reporte final muestra hallazgo + refutación; los descartados quedan en
      el anexo "Descartados" con su motivo y alimentan `findings.discarded`
- [ ] Todo hallazgo CRITICAL pasa por el protocolo de 4 pasos antes del veredicto
- [ ] `/archive` añade `adversarial: {verdict, timestamp, source}` a la entrada
      del manifest cuando hay archivo, advierte sin bloquear cuando falta o es de
      otro change, y nunca lee el detalle de hallazgos
- [ ] `/commit` reporta el veredicto: omite la pregunta con SHIP vigente para el
      change activo; advierte con NO-SHIP sin continuar en silencio; mantiene el
      flujo actual si falta o es ajeno; staleness warn-only
- [ ] `tests/adversarial-state-test.sh` valida el esquema y pasa (evidencia
      ejecutable, asserts con prefijo `[SC-NNN]`)
- [ ] Ninguna descripción del reviewer declara "read-only" absoluto sin la
      excepción de la evidencia
- [ ] `bash check-refs.sh` y `bash specboot.sh --ci` reportan 0 errores
