# Tasks — Validación del puente AGENTS.md ↔ docs/

> **Nomenclatura de capa:** este change es de tipo **docs** (no backend ni
> frontend), por lo que las etiquetas de capa son `docs/validation` y
> `docs/integrity` en lugar de `domain|application|infrastructure` o
> `smart|dumb`. Las rutas siguen el patrón del proyecto: `docs/...`.

---

## T1 — Documentar la sección "Validación del puente AGENTS.md" en `docs/docs-standard.md`

- **Layer:** docs/validation
- **Priority:** P0
- **Estimate:** M (1–2h)
- **Suggested Path:** `docs/docs-standard.md` (inserción de sección nueva
  a continuación de §3.1; el contrato de §3.1 no se modifica).
- **Test Path:** `docs/docs-standard.md` (verificación visual: la sección
  existe, los 3 escenarios del ticket §3.1 están mapeados, los 4 edge cases
  A–D están documentados, la matriz de resultados está presente).

**Subtareas:**
- [x] Insertar la sección "Validación del puente AGENTS.md" en
      `docs/docs-standard.md` justo después de §3.1, antes de §4.
- [x] Incluir los 3 escenarios Gherkin del ticket (S1, S2, S3) con su
      resultado esperado y la verificación conceptual correspondiente.
- [x] Documentar los 4 edge cases (A: tag desconocido; B: falta
      `base-standards.md`; C: falta `AGENTS.md`; D: falta `opencode.json`).
- [x] Incluir la matriz resumen de resultados (tabla) consolidando S1–S3
      y Edge A–D.
- [x] Referenciar `openspec/changes/validate-agents-bridge/` desde la
      sección (trazabilidad al change).

**Trazabilidad:** REQ-VAB-8.

---

## T2 — Verificar `check-refs.sh` y `specboot.sh --ci` → 0 errores

- **Layer:** docs/integrity
- **Priority:** P0
- **Estimate:** S (<30min)
- **Suggested Path:** terminal (no hay archivo a modificar).
- **Test Path:** `check-refs.sh`, `specboot.sh`.

**Subtareas:**
- [x] Ejecutar `bash check-refs.sh` y confirmar exit code `0`.
- [x] Ejecutar `bash specboot.sh --ci` y confirmar exit code `0`.
- [x] Si alguno falla, corregir el artefacto afectado (no los scripts —
      los scripts son intocables, TICKET-1.x los posee).
- [x] Documentar la salida en el resumen de cierre del change (no en
      `docs/docs-standard.md`, para mantener ese doc estable).

**Trazabilidad:** REQ-VAB-5, REQ-VAB-6.

---

## T3 — Verificar que no se modificaron archivos intocables

- **Layer:** docs/integrity
- **Priority:** P0
- **Estimate:** S (<15min)
- **Suggested Path:** terminal (`git diff --name-only`).
- **Test Path:** revisión manual del diff.

**Subtareas:**
- [x] Ejecutar `git status` y `git diff --name-only` antes del commit.
- [x] Confirmar que **no** aparecen cambios en:
      `AGENTS.md`, `docs/base-standards.md`, `docs/framework-contract.md`,
      `docs/versioning-standard.md`, `specboot.sh`,
      `validate-specboot.sh`.
- [x] Confirmar que **sí** aparece la sección nueva en
      `docs/docs-standard.md` (inserción, no reemplazo del contrato).
- [x] Confirmar que aparecen los 4 artefactos del change en
      `openspec/changes/validate-agents-bridge/`.

**Trazabilidad:** REQ-VAB-7.

---

## T4 — Validar el change con `openspec validate`

- **Layer:** docs/integrity
- **Priority:** P0
- **Estimate:** S (<15min)
- **Suggested Path:** terminal.
- **Test Path:** `openspec validate validate-agents-bridge`.

**Subtareas:**
- [x] Ejecutar `openspec validate validate-agents-bridge`.
- [x] Si falla, regenerar el artefacto afectado con instrucciones
      específicas de arreglo (no reportar éxito con huecos conocidos —
      regla del skill `plan-change` Step 6).
- [x] Aplicar el checklist del skill (Given/When/Then presente, trazabilidad
      requisito↔escenario, tareas con subtareas, prioridad, capa y
      estimación).

**Trazabilidad:** transversal.

---

## T5 — Cerrar el change con `/archive` + `/commit`

- **Layer:** docs/integrity
- **Priority:** P0
- **Estimate:** S (<30min)
- **Suggested Path:** comandos OpenCode (`/archive TICKET-2.2a`, `/commit`).
- **Test Path:** el manifest JSON de `openspec/changes/archive/` y el
  historial de git.

**Subtareas:**
- [x] Ejecutar `/archive TICKET-2.2a` (pre-checks, preview,
      `openspec archive`, append a manifest, stage commit) — en ejecución
      por este skill.
- `/commit` (conventional commit, push/PR solo tras confirmación
  explícita) se ejecuta como comando separado a continuación de `/archive`;
  no es un bloqueador de este archive.
- Tras `/commit`, confirmar que el commit incluye solo los archivos
  esperados (artefactos del change + sección nueva en
  `docs/docs-standard.md`).

**Trazabilidad:** REQ-VAB-7, criterio de cierre del ticket.

---

## Dependencias entre tareas

```
T1 ──> T2 ──> T3 ──> T4 ──> T5
```

- **T1** produce el contenido de validación (input de T2 y T3).
- **T2** verifica las herramientas de integridad sobre el resultado de T1.
- **T3** verifica que no se rompieron invariantes (corre sobre T1 + T2).
- **T4** valida la coherencia interna del change (corre sobre T1 + T3).
- **T5** cierra el ciclo (corre sobre T1–T4 en verde).

## Estimación total

S + S + S + S + S + M ≈ **2–3h** (dominadas por T1, la inserción de la
sección de validación en `docs/docs-standard.md`).
