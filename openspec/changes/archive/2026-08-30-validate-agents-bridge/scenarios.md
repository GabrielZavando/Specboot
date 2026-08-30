# Scenarios — Validación del puente AGENTS.md ↔ docs/

Los escenarios siguientes reproducen 1:1 la §3.1 del ticket TICKET-2.2a y
operan contra la prosa del puente `AGENTS.md` (no contra código ejecutable):
la "ejecución" es la verificación de que el texto del puente declara
correctamente el comportamiento esperado, y de que las herramientas de
integridad (`check-refs.sh`, `specboot.sh --ci`) no rompen.

> **Convenciones de la matriz tag-based** (citadas en los escenarios):
> - Tag `[backend]` → `docs/backend-standards.md` + `docs/data-model/data-model.md`
> - Tag `[frontend]` → `docs/frontend-standards.md`
> - Tag `[api]` → `docs/api/api-spec.yml` + `docs/backend-standards.md`
> - Tag `[docs]` → `docs/documentation-standards.md`
> - Tag `[deploy]` → `docs/deploy-standards.md` (vía skill `deploy`)
> - Tag `[fullstack]` → filas backend + frontend

> **Carga condicional de `docs/project/*`**: el puente no usa `{file:...}` para
> estos archivos porque `check-refs.sh` fallaría si faltan. Se resuelven como
> **prosa condicional** con fallback a placeholder (`<!-- … -->`).

---

## Scenario 1 — Proyecto completo con todos los archivos esperados

**Source:** TICKET-2.2a §3.1 Escenario 1

```
Given el proyecto tiene docs/base-standards.md
  And el proyecto tiene docs/project/domain.md
  And el proyecto tiene docs/project/stack.md
  And el proyecto tiene docs/project/client.md
  And el proyecto tiene docs/backend-standards.md
  And el proyecto tiene docs/frontend-standards.md
  And el proyecto tiene docs/documentation-standards.md
When un agente usa el puente AGENTS.md
  And la tarea activa lleva el tag [docs]
Then el puente carga base-standards.md obligatoriamente
  And carga documentation-standards.md por tag
  And lee docs/project/domain.md y docs/project/stack.md como contexto del proyecto
  And el flujo SDD continúa sin errores
  And check-refs.sh devuelve 0 errores
  And specboot.sh --ci devuelve 0 errores
```

**Resultado esperado (validación conceptual):**
- `AGENTS.md` §1 ("Carga base") lista `AGENTS.md` + `docs/base-standards.md`
  como intocables → estos dos siempre se cargan, independientemente del tag.
- `AGENTS.md` §2.1 ("Tag-based loading matrix") mapea `[docs]` →
  `docs/documentation-standards.md`.
- `AGENTS.md` §2.2 ("Project context (docs/project/*) — conditional load")
  indica que si `domain.md` y `stack.md` existen, el agente los lee según
  necesite la tarea.
- `check-refs.sh` valida que todos los `{file:...}` de `opencode.json`,
  `ai-specs/**/*.md` y `.opencode/**/*.md` resuelven a archivos existentes.
- `specboot.sh --ci` valida el resto (esquema `.specboot.json`, estructura,
  placeholders, husky, CI/CD).

---

## Scenario 2 — Proyecto parcial: falta algún archivo de `docs/project/`

**Source:** TICKET-2.2a §3.1 Escenario 2

```
Given el proyecto tiene docs/base-standards.md
  And el proyecto NO tiene docs/project/domain.md
  And el proyecto tiene docs/project/stack.md
When un agente usa el puente AGENTS.md
  And la tarea activa necesita contexto de dominio
Then el puente carga base-standards.md obligatoriamente
  And carga docs/project/stack.md como contexto del proyecto
  And usa fallback placeholder para docs/project/domain.md
  And documenta que domain.md está pendiente de crear
  And el flujo SDD continúa sin errores
  And check-refs.sh devuelve 0 errores
  And specboot.sh --ci devuelve 0 errores
```

**Resultado esperado (validación conceptual):**
- `AGENTS.md` §2.2 declara explícitamente: "If they are missing → apply the
  default placeholder content described in `docs/docs-standard.md` §3".
- `docs/docs-standard.md` §3.1 ("Carga condicional de `docs/project/*` con
  fallback a placeholder") formaliza que los placeholders usan comentarios
  HTML `<!-- … -->`.
- Como `domain.md` no se referencia vía `{file:...}` en el puente, su
  ausencia no dispara error en `check-refs.sh`.
- La traza "domain.md está pendiente" queda visible para el dev (es el
  propósito del placeholder).

---

## Scenario 3 — Proyecto con `docs/` sin subcarpetas de framework

**Source:** TICKET-2.2a §3.1 Escenario 3

```
Given el proyecto tiene docs/base-standards.md
  And el proyecto tiene docs/ pero sin subcarpetas project/, api/, data-model/
When un agente usa el puente AGENTS.md
  And la tarea activa lleva el tag [docs]
Then el puente carga docs/base-standards.md obligatoriamente
  And carga docs/documentation-standards.md por tag
  And emite una advertencia sobre estructura incompleta de docs/
  And el flujo SDD no se rompe
  And check-refs.sh devuelve 0 errores
  And specboot.sh --ci devuelve 0 errores
```

**Resultado esperado (validación conceptual):**
- `AGENTS.md` §1 sigue cargando `docs/base-standards.md` (existe) — sin
  importar el resto de la estructura.
- `AGENTS.md` §2.1 carga solo lo que el tag pide; si la tarea es `[docs]`,
  solo se carga `docs/documentation-standards.md`. La ausencia de
  `docs/project/`, `docs/api/` o `docs/data-model/` no impide la carga.
- La "advertencia" se materializa porque `docs/docs-standard.md` §4
  ("Puesta en marcha de un proyecto nuevo") lista explícitamente los
  archivos que el dev debe crear: `docs/project/{domain.md, stack.md,
  client.md}`, `docs/api/api-spec.yml`, `docs/data-model/data-model.md`,
  y los estándares por stack. El agente que llegue a un proyecto en este
  estado detecta los placeholders y/o las secciones faltantes y sabe que
  el proyecto está en fase de bootstrap.
- `check-refs.sh` no falla porque los archivos no referenciados no se
  validan; los `{file:...}` apuntan solo a `AGENTS.md` y
  `docs/base-standards.md`.
- `specboot.sh --ci` puede reportar placeholders no reemplazados (esa es
  la señal de "estructura incompleta"). **No rompe el flujo SDD** porque
  el check informa, no aborta la fase de planificación.

---

## Edge cases (adicionales a los 3 escenarios del ticket)

### Edge A — Tag desconocido o ausente (no en la matriz)

```
Given la tarea activa lleva un tag no listado en la matriz (p.ej. [misc])
When el agente resuelve el contexto
Then el agente infiere el tag más probable desde el título del ticket
  And pide confirmación explícita al usuario antes de cargar cualquier estándar
  And no carga archivos "por si acaso"
```

Referencia: `AGENTS.md` §2.1 — "If the task has no tag, infer the most
likely tag from the ticket title and ask the user to confirm before
loading any standard. **No leas estos archivos 'por si acaso'**".

### Edge B — `docs/base-standards.md` ausente

```
Given el proyecto NO tiene docs/base-standards.md
When el framework intenta cargar la "Carga base" vía instructions[]
Then check-refs.sh falla con error de referencia rota
  And el proyecto debe re-aplicar el flujo specboot update antes de continuar
```

`base-standards.md` es el único archivo de `docs/` que el puente referencia
vía `instructions[]` (es intocable, inyectado por el framework). Si falta,
la integridad referencial se rompe — esto es **deseable**: el proyecto debe
ejecutar `specboot update` para restaurarlo, no editarlo a mano.

### Edge C — `AGENTS.md` ausente

```
Given el proyecto NO tiene AGENTS.md
When se intenta invocar un agente IA con el puente
Then el proyecto no arranca el flujo SDD
  And debe re-aplicar specboot update
```

Mismo razonamiento que Edge B: `AGENTS.md` es el archivo del puente; su
ausencia indica que el framework no está correctamente inicializado en el
proyecto.

### Edge D — `opencode.json` ausente

```
Given el proyecto NO tiene opencode.json
When check-refs.sh corre
Then no hay instrucciones que referenciar archivos
  And el proyecto no puede invocar agentes IA con el flujo SDD
  And debe re-aplicar specboot update
```

`opencode.json` es la fuente que `instructions[]` consume; sin él, no hay
puente que cargar.

---

## Resumen de resultados de validación

| # | Escenario | Resultado | check-refs.sh | specboot.sh --ci |
|---|-----------|-----------|---------------|------------------|
| 1 | Proyecto completo | OK | 0 errores | 0 errores |
| 2 | Proyecto parcial (falta `domain.md`) | OK con fallback placeholder | 0 errores | 0 errores (warning informativo) |
| 3 | `docs/` sin subcarpetas | OK con advertencia de bootstrap | 0 errores | 0 errores (placeholders pendientes) |
| A | Tag desconocido/ausente | OK, agente pregunta | 0 errores | 0 errores |
| B | Falta `base-standards.md` | **Rompe** (intencional) | Error de ref | n/a |
| C | Falta `AGENTS.md` | **Rompe** (intencional) | n/a | n/a |
| D | Falta `opencode.json` | **Rompe** (intencional) | 0 (no hay refs) | n/a |

Los casos B/C/D **rompen el flujo SDD a propósito**: son señales de que el
proyecto no tiene el framework correctamente inicializado. La acción
correctiva en todos ellos es ejecutar `specboot update`, nunca editar
manualmente los archivos intocables.
