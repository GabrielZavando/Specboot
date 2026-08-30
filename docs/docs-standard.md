# docs/ Standard — Estructura canónica de documentación (Specboot)

Este documento define el esqueleto estándar de la carpeta `docs/` que todo proyecto
SDD generado por Specboot debe tener, y marca qué archivos son intocables del
framework y cuáles son del proyecto. Amplía `docs/framework-contract.md`, que define
la frontera global intocable/del proyecto.

## 1. Árbol estándar de `docs/`

```
docs/
├── base-standards.md          # INTOCABLE (framework) — principios SDD/TDD/SOLID
├── project/                   # DEL PROYECTO
│   ├── domain.md              # descripción del dominio
│   ├── stack.md               # stack técnico
│   └── client.md              # cliente / audiencia
├── api/                       # DEL PROYECTO
│   └── api-spec.yml           # contratos de API (OpenAPI 3.0)
├── data-model/                # DEL PROYECTO
│   └── data-model.md          # modelo de datos
├── backend-standards.md       # DEL PROYECTO (usa base)
├── frontend-standards.md      # DEL PROYECTO (usa base)
├── ci-standards.md            # DEL PROYECTO
├── deploy-standards.md        # DEL PROYECTO
└── documentation-standards.md# DEL PROYECTO
```

> `base-standards.md` es el único archivo intocable de `docs/`: el framework lo inyecta
> y el proyecto no debe editarlo. El resto es del proyecto y se personaliza por stack.

## 2. Frontera intocable / del proyecto (para `docs/`)

| Intocable (framework, inyectado) | Del proyecto (editado por el dev) |
| --- | --- |
| `docs/base-standards.md` | `docs/backend-standards.md` |
| | `docs/frontend-standards.md` |
| | `docs/ci-standards.md` |
| | `docs/deploy-standards.md` |
| | `docs/documentation-standards.md` |
| | `docs/project/domain.md` |
| | `docs/project/stack.md` |
| | `docs/project/client.md` |
| | `docs/api/api-spec.yml` |
| | `docs/data-model/data-model.md` |

**Regla**: `base-standards.md` es inyectado por el framework (vía `specboot update`) y no
debe ser editado localmente por el dev. Si se necesita cambiar su comportamiento, proponerlo
a través del flujo SDD del propio Specboot (dogfooding), no editarlo a mano. Los demás
archivos son propiedad y responsabilidad del proyecto.

El esquema de `.specboot.json` (incluido el campo `extraStandards` que apunta a `docs/`)
se documenta en [`docs/specboot-json-standard.md`](specboot-json-standard.md).

> **Nota de alcance**: `docs/framework-contract.md` y este `docs/docs-standard.md` también son documentos inyectados por el framework (se distribuyen con él y se actualizan vía el flujo SDD del propio Specboot, no por el dev del proyecto). En la frontera de `docs/` se marca `base-standards.md` como intocable porque es la plantilla de principios que el dev no debe alterar; `framework-contract.md` y `docs-standard.md` se consideran parte del framework y se tratan como tales.

## 3. Regla de carga dinámica del puente `AGENTS.md`

El `AGENTS.md` raíz (inyectado por el framework) carga **siempre** `docs/base-standards.md`
vía `instructions[]`. Para el resto del contexto de `docs/`, el agente activo lo resuelve
**dinámicamente según la tarea**, no mediante una lista fija de rutas:

- Tarea backend detectada → carga `docs/backend-standards.md` y `docs/data-model/data-model.md`.
- Tarea frontend detectada → carga `docs/frontend-standards.md`.
- Tarea que modifica la API → carga `docs/api/api-spec.yml`.
- Tarea de deploy → carga `docs/deploy-standards.md` (vía skill `deploy`).
- Tarea de docs → carga `docs/documentation-standards.md`.
- El contenido de `docs/project/*` se considera contexto siempre disponible y se lee según haga falta (dominio, stack, cliente).

Esto evita que `AGENTS.md` deba enumerar cada archivo de `docs/` y permite que el estándar
crezca sin tocar el puente.

## 4. Puesta en marcha de un proyecto nuevo

1. El framework inyecta `docs/base-standards.md` (intocable).
2. El dev crea/completa `docs/project/{domain.md, stack.md, client.md}` con el contexto real.
3. El dev edita `docs/backend-standards.md`, `docs/frontend-standards.md`, `docs/ci-standards.md`,
   `docs/deploy-standards.md` y `docs/documentation-standards.md` según su stack.
4. El dev coloca `docs/api/api-spec.yml` y `docs/data-model/data-model.md`.

## 5. Relación con el contrato del framework

Este estándar concreta, para la carpeta `docs/`, la frontera global intocable/del proyecto
declarada en `docs/framework-contract.md`. Allí se define además la ruta canónica de
artefactos SDD: `openspec/` (sin punto).
