# Tasks — agents-bridge

> Source ticket: TICKET-2.1. Each task lists subtasks, priority, layer, and
> estimate. Layer labels follow the project's docs convention. The change is a
> documentation-only dogfooding change applied to framework-intocable files
> (`AGENTS.md`, `docs/docs-standard.md`, `docs/framework-contract.md`) via the
> Specboot SDD flow itself. No product code is modified.

> Note on layer: this change touches only framework documentation. We use the
> `docs` layer label. The `domain | application | infrastructure` (backend) and
> `smart | dumb` (frontend) labels do not apply.

---

## TASK-1 — Reescribir `AGENTS.md` como puente explícito (4 secciones)

- **Priority**: high
- **Layer**: docs
- **Estimate**: M (medium)
- **File to modify**: `AGENTS.md` (framework-intocable, edited via dogfooding SDD)
- **Traces**: REQ-1, REQ-2, REQ-3, REQ-4

### Subtasks

- [x] T1.1 — Redactar la nueva sección "Carga base (intocable)" que declare que
  `docs/base-standards.md` se carga siempre vía `opencode.json` `instructions[]`
  y que es intocable del framework.
- [x] T1.2 — Redactar la nueva sección "Carga dinámica": prose that instructs
  the agent to read `docs/project/domain.md` and `docs/project/stack.md` if they
  exist, else use the placeholder defined in `docs/docs-standard.md` §3. Do
  **not** use `{file:...}` for `docs/project/*` (project-owned files may be
  absent). Preserve the existing tag-based loading matrix
  (`[backend]`, `[frontend]`, `[api]`, `[docs]`, `[deploy]`) and the
  "no leas por si acaso" note.
- [x] T1.3 — Redactar la nueva sección "Herramientas" que referencia
  `check-refs.sh` y `specboot.sh --ci` como puntos de validación de la
  integridad del puente.
- [x] T1.4 — Redactar la "Nota de puente" explicando que el `AGENTS.md` es
  solo la interfaz, el contenido real vive en `docs/`, y `specboot update`
  reemplaza el puente sin perder contexto del proyecto.
- [x] T1.5 — Verificar que AGENTS.md conserva todas las menciones a los
  nombres de skills presentes en `ai-specs/skills/*/` (paso 3 de
  `check-refs.sh`): `archive`, `code-auditing`, `commit`, `deploy`,
  `enrich-us`, `explain`, `onboarding`, `plan-change`, `show-spec-working`,
  `using-git-worktrees`, `verify`.
- [x] T1.6 — Verificar que las referencias `{file:...}` en el cuerpo (subagents
  y skill del puente) siguen resolviendo a archivos existentes. Si alguna ruta
  deja de existir, corregirla o reescribirla para que apunte a un archivo
  presente.

### Suggested Path
- `AGENTS.md`

### Test Path
- No hay test automatizado nuevo. Verificación manual:
  - `bash check-refs.sh` → 0 errores.
  - Inspección visual: las 4 secciones están presentes y el registro de skills
    no se rompe.

---

## TASK-2 — Extender `docs/docs-standard.md` §3 con la regla condicional de placeholder

- **Priority**: high
- **Layer**: docs
- **Estimate**: S (small)
- **File to modify**: `docs/docs-standard.md` (framework-intocable, editado vía
  dogfooding SDD)
- **Traces**: REQ-6

### Subtasks

- [x] T2.1 — Mantener el título de la sección §3 tal como está ("Regla de
  carga dinámica del puente AGENTS.md") — **no renombrar**.
- [x] T2.2 — Añadir al final de §3 (o crear una sub-sección explícita) la regla
  condicional para `docs/project/*`:
  - `docs/base-standards.md` siempre se carga vía `instructions[]`.
  - Si `docs/project/domain.md` y `docs/project/stack.md` existen → el agente
    los lee.
  - Si faltan → el agente aplica el contenido por defecto marcado como
    "placeholder por proyecto" (lo que el dev debe sustituir).
- [x] T2.3 — Confirmar que la matriz tag → documento (`[backend]`,
  `[frontend]`, etc.) sigue presente en §3.

### Suggested Path
- `docs/docs-standard.md`

### Test Path
- No hay test automatizado nuevo. Verificación:
  - `bash specboot.sh --ci` → 0 errores.
  - `grep` confirma que el título §3 no cambió y que la nueva regla está
    presente.

---

## TASK-3 — Añadir subsección "Puente AGENTS.md ↔ docs/" en `docs/framework-contract.md`

- **Priority**: high
- **Layer**: docs
- **Estimate**: S (small)
- **File to modify**: `docs/framework-contract.md` (framework-intocable,
  editado vía dogfooding SDD)
- **Traces**: REQ-7

### Subtasks

- [x] T3.1 — Crear una subsección con el título exacto "Puente AGENTS.md ↔
  docs/" en una posición lógica del documento (después de la tabla de frontera
  intocable/del proyecto o en la sección de Arquitectura de distribución, donde
  ya se menciona `AGENTS.md` como puente).
- [x] T3.2 — Documentar el contrato del puente: `AGENTS.md` es inyectado por el
  framework (intocable); carga `docs/base-standards.md` siempre; lee
  `docs/project/*` dinámicamente; nunca hardcodea dominio/stack del proyecto
  (viven en `docs/`).
- [x] T3.3 — Mencionar que el contrato detallado de la carga dinámica vive en
  `docs/docs-standard.md` §3, enlazándolo con un link markdown.

### Suggested Path
- `docs/framework-contract.md`

### Test Path
- No hay test automatizado nuevo. Verificación:
  - `bash specboot.sh --ci` → 0 errores.
  - `grep -n "Puente AGENTS.md" docs/framework-contract.md` devuelve al menos
    una coincidencia.

---

## TASK-4 — Validar la integridad del puente

- **Priority**: high
- **Layer**: docs
- **Estimate**: S (small)
- **Traces**: REQ-5

### Subtasks

- [x] T4.1 — Ejecutar `bash check-refs.sh` desde la raíz del proyecto y
  confirmar 0 errores.
- [x] T4.2 — Ejecutar `bash specboot.sh --ci` desde la raíz del proyecto y
  confirmar 0 errores.
- [x] T4.3 — Si T4.1 o T4.2 fallan, ajustar la implementación de T1–T3 sin
  actualizar los scripts (los scripts están fuera de alcance: TICKET-1.x).
  Actualizar primero los artefactos OpenSpec y luego re-aplicar.

### Suggested Path
- N/A (validación; toca ejecutar comandos en raíz).

### Test Path
- N/A (validación manual contra scripts existentes).

---

## Dependencias

- TICKET-0.1 (contrato de frontera intocable/del proyecto) — **ya merged**.
- TICKET-0.2 (estándar `docs/` intocable/del proyecto) — **ya merged**.
- TICKET-1.1 (`package.json` allowlist) — **ya merged**.
- TICKET-1.2 (frontera de distribución npm) — **ya merged**.

## Out of scope (recordatorio)

- Lógica de `specboot update` (Fase 3/4).
- Reestructurar `Makefile` o workflows (Fase 5).
- Cambiar `package.json` o `files` (Fase 1).
