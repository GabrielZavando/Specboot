# Change: agents-bridge — Puente dinámico `AGENTS.md` ↔ `docs/`

## Why

El `AGENTS.md` actual (Fase 0/1) ya actúa como puente, pero lo hace con un formato
implícito: enumera reglas de carga y herramientas sin declararse formalmente como
puente. Eso impide que `specboot update` (Fase 3/4) reemplace el `AGENTS.md` con
garantías de no romper el contexto del proyecto: hoy un dev podría asumir que el
puente contiene el dominio o el stack cuando, en realidad, esa información debe
vivir en `docs/`. TICKET-2.1 (Fase 2 — Puente Docs) cierra esa ambigüedad: el
`AGENTS.md` pasa a tener 4 secciones explícitas (Carga base / Carga dinámica /
Herramientas / Nota de puente) y los dos docs del framework
(`docs/docs-standard.md`, `docs/framework-contract.md`) documentan el contrato
del puente, de forma que `specboot update` pueda reemplazar el `AGENTS.md` sin
pérdida de contexto.

## What Changes

- `AGENTS.md` se reescribe con 4 secciones explícitas:
  1. **Carga base (intocable)** — declara que `docs/base-standards.md` se carga
     siempre vía `opencode.json` `instructions[]` y que es intocable del framework.
  2. **Carga dinámica** — instruye a leer `docs/project/domain.md` y
     `docs/project/stack.md` **si existen**, con fallback a placeholder definido
     en `docs/docs-standard.md` §3. Conserva la matriz tag→docs
     (`[backend]`, `[frontend]`, `[api]`, `[docs]`, `[deploy]`) y la regla
     "no leas por si acaso". No usa `{file:...}` para `docs/project/*` (pueden
     no existir; `check-refs.sh` fallaría).
  3. **Herramientas** — referencia `check-refs.sh` y `specboot.sh --ci` como
     puntos de validación de la integridad del puente.
  4. **Nota de puente** — explica que `AGENTS.md` es solo la interfaz, el
     contenido pesado vive en `docs/`, y `specboot update` reemplaza el puente
     sin perder contexto del proyecto.
- `docs/docs-standard.md` §3 (sin renombrar) se extiende con la regla
  condicional de `docs/project/*` y el fallback "placeholder por proyecto".
- `docs/framework-contract.md` gana una subsección "Puente AGENTS.md ↔ docs/"
  que documenta el contrato del puente y enlaza a `docs/docs-standard.md` §3.
- `check-refs.sh` y `specboot.sh --ci` siguen en 0 errores. **No** se modifican
  sus arrays `REQUIRED_FILES` ni `PLACEHOLDER_PATTERNS`.

Fuera de alcance: lógica de `specboot update` (Fase 3/4), `Makefile`/workflows
(Fase 5), `package.json`/`files` (Fase 1).

## Capabilities

### New Capabilities
- `agents-bridge`: Contrato del puente dinámico `AGENTS.md` ↔ `docs/`. Cubre
  las 4 secciones del puente, la regla condicional de `docs/project/*`, la
  nueva subsección "Puente AGENTS.md ↔ docs/" en el contrato, y la invariante
  de que `check-refs.sh` y `specboot.sh --ci` permanecen en 0 errores.

### Modified Capabilities
- (ninguno) — los cambios a `docs/docs-standard.md` y `docs/framework-contract.md`
  son de **prose/implementation** y están completamente especificados por la
  nueva capability `agents-bridge`. No modifican requisitos de las capabilities
  `docs-standard` o `framework-contract` ya consolidadas en `openspec/specs/`.

## Impact

- **Archivos modificados** (framework-intocables, editados vía dogfooding SDD):
  - `AGENTS.md`
  - `docs/docs-standard.md` (extensión de §3)
  - `docs/framework-contract.md` (nueva subsección)
- **Sin cambios** en: `opencode.json`, `package.json`, `files` allowlist,
  `check-refs.sh`, `specboot.sh`, `Makefile`, workflows, código de proyecto.
- **Validación post-cambio**: `bash check-refs.sh` → 0; `bash specboot.sh --ci` → 0.
- **Compatibilidad**: ningún breaking change para consumidores. `AGENTS.md` se
  sigue inyectando igual desde el paquete npm; lo que cambia es su estructura
  interna para ser explícitamente un puente.
