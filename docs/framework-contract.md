# Contrato del Framework Specboot

## Resumen ejecutivo

Specboot es un framework de desarrollo SDD (Spec-Driven Development) que enjaula un flujo obligatorio de especificación-antes-código, estándares fijos de agentes/skills y una frontera estricta entre lo que el framework inyecta (intocable) y lo que el proyecto personaliza.

## Principios rectores

1. **Specboot es un framework / entorno de desarrollo** que provee herramientas (agentes, subagentes, skills, conexiones MCP, contexto) para desarrollar cualquier software siguiendo SDD, obligando a respetar el flujo. El contexto vive en `docs/` y cambia por proyecto; las herramientas y buenas prácticas (TDD, SOLID, pruebas) las determina el framework y mejoran por versión.
2. **El dev activa el flujo explícitamente**: ejecuta los comandos y alimenta el proyecto con archivos de contexto e MCP.
3. **La estructura del proyecto la define el dev** según su stack; Specboot no impone carpetas.
4. **Hay un estándar de versionado**; el propio desarrollo de Specboot sigue su ciclo SDD (dogfooding).
5. **`AGENTS.md` vive en la raíz de cada proyecto** pero lo provee/inyecta el framework como puente. Specboot es una dependencia de desarrollo.
6. **Agentes y skills son fijos y definidos por el framework (prefabricados)**, aportan estándares (calidad, TDD, SOLID), no código.
7. **Las MCP son del proyecto**; el framework solo declara dónde se conectan. Queda abierto un MCP transversal futuro definido por el framework.
8. **Actualización opción A**: `specboot update` reemplaza los archivos del framework sin piedad; el dev no los toca (como `node_modules`); `docs/` es la única superficie de personalización.
9. **Makefile y workflows los provee el framework (intocables)**; el proyecto los adapta vía `.specboot.json` + variables de entorno sin editarlos; los agentes los invocan según la tarea.
10. **El paquete npm `@gabrielzavando/specboot` es la única forma de distribuir**; publicación automática por release (rama por cambio → merge a main → release cuando la versión esté lista); versionado SemVer.

## Arquitectura de distribución

Specboot se distribuye como un único paquete npm: `@gabrielzavando/specboot`. Esa es la **única** forma de distribución.

- El proyecto lo instala como **dependencia de desarrollo** (`devDependency`), no como runtime.
- El paquete inyecta en el proyecto los archivos intocables (ver sección *Frontera intocable / del proyecto*): `AGENTS.md` (puente), comandos y agentes de OpenCode, skills, scripts de validación, `Makefile`, plantillas de CI y workflows.
- El proyecto no forkea ni copia el framework fuera del mecanismo de instalación/actualización; cualquier desviación es un bug, no un feature.
- La publicación es automática por release: rama por cambio → merge a main → release cuando la versión (SemVer) esté lista.

### Rutas canónicas de artefactos SDD

Los artefactos del ciclo SDD (changes, specs y tickets enriquecidos) viven en la ruta canónica **`openspec/`** (sin punto), coherente con el CLI `openspec` 1.3.1. Concretamente:

- `openspec/changes/<change-name>/` — propuesta, scenarios, requirements, tasks y `specs/<capability>/spec.md` del cambio activo.
- `openspec/tickets/<TICKET-ID>-enriched.md` — artefacto enriquecido que `/plan-change` usa como fuente primaria.
- `openspec/specs/` — especificaciones consolidadas tras `/archive`.

Cualquier documentación o skill que referencie `.openspec/` (con punto) está desactualizada y debe migrarse a `openspec/` en un ticket de framework posterior (fuera de este contrato).

## Frontera intocable / del proyecto

La siguiente tabla es la regla de verdad sobre qué puede y qué no puede editar un desarrollador en su proyecto. No es negociable ni ambigua.

| Intocable (del framework, inyectado, no editado por el dev) | Del proyecto (editado por el dev) |
| --- | --- |
| `AGENTS.md` (puente) | `docs/` (salvo `base-standards.md`) |
| `.opencode/commands/*` | `.specboot.json` |
| `.opencode/agents/*` | código del proyecto (`backend/`, `frontend/`) |
| `ai-specs/*` | variables de entorno / GitHub vars |
| `check-refs.sh` | MCP del proyecto |
| `specboot.sh` | |
| `Makefile` (genérico) | |
| `templates/ci/*` | |
| `.github/workflows/*` (del framework) | |
| `docs/base-standards.md` | |

Regla: los archivos de la columna **Intocable** son inyectados y actualizados por el framework (vía `specboot update`). Si un desarrollador necesita cambiar su comportamiento, debe proponer el cambio a través del flujo SDD del propio Specboot (dogfooding), no editarlos localmente. Los archivos de la columna **Del proyecto** son responsabilidad y propiedad del desarrollador.

## Flujo SDD obligatorio

El ciclo es obligatorio y se ejecuta en este orden:

1. `/plan-change` — genera propuestas OpenSpec validadas y enriquecidas a partir del ticket (usa el artefacto enriquecido si existe).
2. `/apply` — implementa las tareas de los artefactos OpenSpec respetando TDD y los estándares.
3. `/verify` — ejecuta las pruebas y verifica que el cambio activo funciona (trazabilidad, delta incremental).
4. `/archive` — cierra el ciclo SDD: pre-checks, `openspec archive`, manifest y staging para commit.
5. `/commit` — crea commits convencionales y el pull request.

El flujo se alimenta de contexto: `docs/` del proyecto + servidores MCP disponibles. Esta sección es autocontenida: no requiere leer `AGENTS.md` para entender el flujo.

## Modelo de actualización

Specboot sigue la **opción A**: `specboot update` reemplaza los archivos del framework **sin piedad**.

- Los archivos intocables (columna izquierda de la tabla anterior) se sobrescriben íntegramente con la versión del paquete.
- `specboot update` **nunca** toca `docs/` del desarrollador ni el código del proyecto.
- Si un desarrollador editó manualmente un archivo intocable, la edición se pierde al actualizar; el contrato del framework gana. Esta es una decisión de diseño deliberada, no un accidente.

## Dogfooding

Specboot se desarrolla con su **propio flujo SDD**. El framework no se codifica a mano fuera del ciclo: sus propias features (comandos, skills, frontera, reglas de versión) pasan por `/plan-change → /apply → /verify → /archive → /commit` exactamente como lo haría un proyecto hijo. Cualquier ampliación de la lista de archivos intocables o de los principios rectores debe modificar primero este contrato y luego implementarse, nunca al revés.
