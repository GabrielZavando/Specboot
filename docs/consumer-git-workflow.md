# Git Workflow — Recomendación para Proyectos Consumidores

> **Nota de alcance**: este documento es una **recomendación opcional** para
> proyectos que consumen `@gabrielzavando/specboot`. El equipo consumidor puede
> adaptarla libremente. **No aplica al desarrollo del propio Specboot**, que
> sigue su propio estándar en
> [`docs/git-workflow-standards.md`](git-workflow-standards.md) (rama por
> ticket, commits local-first, cierre por fase).

## Estrategia: GitHub Flow

Modelo simple de rama única persistente (`main`) con ramas de trabajo cortas:

- **Ramas de trabajo**: `feature/*`, `fix/*`, `chore/*`, `docs/*` — siempre
  desde el HEAD de `main`, una por ticket/change.
- **Nombrado**: kebab-case descriptivo, ej. `feature/auth-reset`,
  `fix/orders-dup-submit`.

## Pull Requests

- Título en formato **Conventional Commits** (`feat:`, `fix:`, `docs:`,
  `chore:`, `refactor:`, `test:`).
- **CI obligatoria antes del merge** (tests + lint del proyecto consumidor).
- Un PR = un cambio lógico (un ticket o change OpenSpec).

## Versionado y release

- **SemVer**: `MAJOR.MINOR.PATCH`.
- Cada merge a `main` puede generar release si el mantenedor lo decide; el
  changelog (`CHANGELOG.md`) se actualiza por change.
- Tag de git por release (`vX.Y.Z`) para trazabilidad entre el código
  publicado y la página de Releases de GitHub.

## Hotfixes

1. Rama `fix/...` desde el tag de la versión afectada (o desde `main` si no hay
   tag aplicable).
2. Fix + bump de versión `patch` + PR con CI verde.
3. Merge a `main` y tag de la nueva versión patch.

## Qué NO cambia de este framework

El framework Specboot **no inyecta** este workflow en tu proyecto: es
documentación de recomendación. Tu `ci.yml`/`deploy.yml` propios y tu proceso de
revisión son tuyos; este doc solo establece una base sugerida para equipos que
no tengan una estrategia Git definida.
