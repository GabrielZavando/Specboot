# Requirements — Validación del puente AGENTS.md ↔ docs/

Cada requisito es **trazable a al menos un escenario** de `scenarios.md`. El
formato es `REQ-VAB-N` (Validate Agents Bridge).

---

## REQ-VAB-1 — Carga obligatoria de `docs/base-standards.md`

El puente `AGENTS.md` debe garantizar que `docs/base-standards.md` se carga
**siempre**, independientemente del tag de la tarea, del estado del resto
de `docs/`, o de la presencia/ausencia de los archivos del proyecto.

**Trazabilidad:** Scenario 1, Scenario 2, Scenario 3, Edge B.

**Criterio de verificación:**
- `AGENTS.md` §1 ("Carga base") lista explícitamente `docs/base-standards.md`
  como archivo intocable y pre-cargado vía `instructions[]`.
- `opencode.json` declara `docs/base-standards.md` en `instructions[]`.
- Si el archivo falta, `check-refs.sh` falla con error de referencia rota
  (comportamiento deseable, ver Edge B).

---

## REQ-VAB-2 — Carga tag-based selectiva de estándares por stack

El puente debe cargar **solo** los archivos de estándar correspondientes al
tag activo, sin precargar "por si acaso".

**Trazabilidad:** Scenario 1, Scenario 3, Edge A.

**Criterio de verificación:**
- `AGENTS.md` §2.1 ("Tag-based loading matrix") define la matriz completa
  `[backend|frontend|api|docs|deploy|fullstack]`.
- `AGENTS.md` §2.1 declara explícitamente: "**No leas estos archivos 'por
  si acaso'**".
- Cuando el tag es `[docs]`, solo se carga
  `docs/documentation-standards.md` (verificado en este change).
- Cuando el tag es desconocido, el agente infiere y pregunta (Edge A).

---

## REQ-VAB-3 — Carga condicional de `docs/project/*` como prosa

Los archivos `docs/project/{domain,stack,client}.md` deben resolverse como
**prosa condicional** documentada en el puente, no como `{file:...}` ni como
`instructions[]`. Esto es necesario porque `check-refs.sh` falla si los
archivos referenciados no existen.

**Trazabilidad:** Scenario 1, Scenario 2, Scenario 3, Edge A.

**Criterio de verificación:**
- `AGENTS.md` §2.2 documenta la carga condicional de `docs/project/*` con
  el texto "If they exist → read them as soon as the task needs the
  domain, stack, or audience information" y "If they are missing → apply
  the default placeholder content".
- `opencode.json` **no** incluye `docs/project/*` en `instructions[]`.
- `ai-specs/**/*.md` y `.opencode/**/*.md` **no** referencian
  `docs/project/*` vía `{file:...}`.
- `check-refs.sh` → 0 errores en proyectos con y sin los archivos del
  proyecto.

---

## REQ-VAB-4 — Fallback a placeholder cuando faltan archivos del proyecto

Cuando un archivo de `docs/project/*` no existe, el agente debe aplicar el
contenido por defecto marcado como **placeholder por proyecto** (comentarios
HTML `<!-- … -->`).

**Trazabilidad:** Scenario 2, Scenario 3.

**Criterio de verificación:**
- `docs/docs-standard.md` §3.1 documenta la regla de fallback.
- Los placeholders usan sintaxis `<!-- … -->` para que el dev los identifique.
- La ausencia de los archivos del proyecto **no** aborta el flujo SDD
  (Scenario 2, Scenario 3).
- La señal "X está pendiente de crear" queda visible para el dev.

---

## REQ-VAB-5 — No-ruptura del flujo SDD ante estructura incompleta

El flujo SDD (`/plan-change` → `/apply` → `/verify` → `/archive` → `/commit`)
no debe romperse cuando la estructura de `docs/` es incompleta, siempre que
los archivos intocables del framework estén presentes.

**Trazabilidad:** Scenario 1, Scenario 2, Scenario 3, Edge A.

**Criterio de verificación:**
- `check-refs.sh` → 0 errores en los 3 escenarios del ticket.
- `specboot.sh --ci` → 0 errores en los 3 escenarios (los placeholders
  pendientes son warnings informativos, no errores fatales).
- El puente no aborta ni interrumpe la planificación por archivos
  faltantes del proyecto (solo los intocables ausentes rompen, por diseño).

---

## REQ-VAB-6 — Verificación continua con herramientas de integridad

El proyecto debe mantener `check-refs.sh` y `specboot.sh --ci` en `0` errores
como parte del cierre de este change.

**Trazabilidad:** todos los escenarios (verifican al final).

**Criterio de verificación:**
- `bash check-refs.sh` → exit 0.
- `bash specboot.sh --ci` → exit 0.
- Ambos scripts se ejecutan antes de `/archive` y `/commit`.

---

## REQ-VAB-7 — Intocabilidad de los archivos del framework

Este change **no modifica** `AGENTS.md`, `docs/base-standards.md`,
`docs/framework-contract.md`, `docs/versioning-standard.md`,
`docs/docs-standard.md` (en su parte de contrato), `specboot.sh`, ni
`validate-specboot.sh`. Sí modifica `docs/docs-standard.md` para **añadir**
la sección de validación, que es documentación de resultados (no parte del
contrato).

**Trazabilidad:** transversal al change (verificado en el cierre).

**Criterio de verificación:**
- `git diff` contra `HEAD~0` no incluye cambios en:
  - `AGENTS.md`
  - `docs/base-standards.md`
  - `docs/framework-contract.md`
  - `docs/versioning-standard.md`
  - `specboot.sh`
  - `validate-specboot.sh`
- `git diff` contra `HEAD~0` **sí** incluye la nueva sección en
  `docs/docs-standard.md` (inserción, no reemplazo del contrato).

---

## REQ-VAB-8 — Documentación de los 3 escenarios y casos límite

`docs/docs-standard.md` debe contener, a continuación de §3.1, una sección
"Validación del puente AGENTS.md" que documente los 3 escenarios Gherkin
del ticket, sus resultados, y los casos límite (Edge A–D).

**Trazabilidad:** Scenario 1, Scenario 2, Scenario 3, Edge A, B, C, D.

**Criterio de verificación:**
- `docs/docs-standard.md` contiene la sección nueva.
- Los 3 escenarios del ticket §3.1 están presentes textual o
  semánticamente.
- Los 4 edge cases (A–D) están documentados.
- Los resultados de la matriz de validación están presentes.

---

## Matriz de trazabilidad resumen

| Requisito | S1 | S2 | S3 | EA | EB | EC | ED |
|-----------|----|----|----|----|----|----|----|
| REQ-VAB-1 | ✓  | ✓  | ✓  |    | ✓  |    |    |
| REQ-VAB-2 | ✓  |    | ✓  | ✓  |    |    |    |
| REQ-VAB-3 | ✓  | ✓  | ✓  | ✓  |    |    |    |
| REQ-VAB-4 |    | ✓  | ✓  |    |    |    |    |
| REQ-VAB-5 | ✓  | ✓  | ✓  | ✓  |    |    |    |
| REQ-VAB-6 | ✓  | ✓  | ✓  |    |    |    |    |
| REQ-VAB-7 | transversal |  |  |  |  |  |  |
| REQ-VAB-8 | ✓  | ✓  | ✓  | ✓  | ✓  | ✓  | ✓  |
