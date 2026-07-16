---
description: Reglas globales de desarrollo para agentes IA (OpenCode, Codex, Cursor). Aplica siempre.
alwaysApply: true
---

# Base Standards — Agencia Zavando

## 1. Principios core

- **Pasos pequeños, uno a la vez**: Nunca avanzar más de un paso sin confirmar. Baby steps siempre.
- **TDD (Test-Driven Development)**: Escribir test fallido primero para cualquier funcionalidad nueva.
- **Tipado completo**: Todo el código debe estar completamente tipado (TypeScript, PHPDoc, etc.).
- **Nombres descriptivos**: Variables y funciones con nombres claros y específicos al dominio.
- **Cambios incrementales**: Preferir modificaciones pequeñas y revisables sobre cambios grandes.
- **Cuestionar supuestos**: Siempre preguntar ante ambigüedades antes de asumir.
- **Detectar patrones repetidos**: Identificar y señalar código duplicado o patrones que deben abstraerse.

## 2. Idioma del código

- **Todo en inglés**: Variables, funciones, clases, comentarios, mensajes de error, logs.
- **Documentación en español**: READMEs para el cliente, comentarios de negocio, tickets pueden ir en español.
- **Commits en inglés**: Siempre. Conventional commits format.
- **Nombres de base de datos en inglés**: Tablas, columnas, índices.

## 3. Estándares específicos por área

Para estándares detallados, leer los archivos correspondientes:

- [Backend Standards](docs/backend-standards.md) — API, base de datos, testing, seguridad
- [Frontend Standards](docs/frontend-standards.md) — Componentes, UI/UX, estado
- [Documentation Standards](docs/documentation-standards.md) — Estructura docs, OpenAPI, mantenimiento

## 4. Skills del proyecto

- Los skills viven en `ai-specs/skills/`.
- Cuando una solicitud coincida con la descripción de un skill, cargar y seguir el `SKILL.md` correspondiente automáticamente antes de continuar.
- Cargar también los archivos referenciados en la carpeta del skill cuando el skill los requiera.
- La lista canónica y actualizada de skills (con descripciones y casos de uso) se mantiene en [`ai-specs/README.md`](../ai-specs/README.md). Referenciar ese archivo en vez de duplicar la lista aquí.

## 5. Modelo de planning

Los flujos de planning se ejecutan mediante los custom commands definidos en `opencode.json`:

- `/enrich-us` — Enriquecer user story vaga antes de planificar
- `/plan-change` — Generar OpenSpec specs y tasks a partir de un ticket
- `/apply` — Implementar tareas desde los artefactos OpenSpec (TDD)
- `/verify` — Validar implementación contra escenarios OpenSpec
- `/adversarial-review` — Auditoría sistemática de calidad
- `/archive` — Archivar artefactos OpenSpec al completar
- `/commit` — Crear commits convencionales y PR

El modelo para cada agente está definido en `opencode.json`. No hardcodear modelos aquí.

## 6. Integridad de symlinks y portabilidad multi-agente

- **Fuente canónica**: Los artefactos reutilizables viven en `ai-specs/`. Los paths de agentes específicos (`.claude/`, `.cursor/`) los referencian vía symlinks.
- **Seguridad al renombrar**: Al renombrar o mover un archivo, verificar y actualizar todos los symlinks que lo apuntan antes de cerrar el cambio.
- **Nuevos artefactos**: Al crear un nuevo skill o agente en `ai-specs/`, crear los symlinks correspondientes en `.claude/` y `.cursor/`.
- **Un cambio es incompleto** si deja symlinks rotos o artefactos canónicos duplicados.

### Agnosticismo de contenido vs. de comportamiento

Los symlinks hacen que **el contenido** sea idéntico para todas las herramientas
(OpenCode, Claude Code, Cursor): todas leen desde la fuente canónica `ai-specs/`.
Sin embargo, **el comportamiento no es agnóstico**: cada herramienta consume ese
contenido de forma distinta:

- **OpenCode**: `opencode.json` define los agentes (`plan`, `build`, `reviewer`) con
  sus prompts → orquestación activa.
- **Claude Code**: `.claude/agents` y `.claude/skills` (symlinks) → skills y agentes activos.
- **Cursor**: `.cursor/rules` (symlink a `ai-specs/`) expone los mismos archivos como
  **contexto pasivo**: Cursor los ve en el contexto del proyecto, pero al no ser
  `.mdc` con front-matter no se aplican como reglas activas.

Esta asimetría es **intencional**: preserva la fuente única sin duplicar contenido.
Si se requiere que Cursor aplique reglas activas, habría que generar `.mdc` con
front-matter (lo que duplicaría el contenido o exigiría un generador en `update.sh`).

## 7. Actualización de artefactos OpenSpec ante cambios post-apply

Si aparece un fix o cambio nuevo después de `/apply` y antes de `/archive`:

1. Actualizar primero los artefactos OpenSpec afectados (scenarios, requirements, tasks.md)
2. Si se necesita regenerar artefactos, ejecutar el paso OpenSpec correspondiente antes de codear
3. Solo implementar código después de que los artefactos reflejen el nuevo requerimiento
4. Re-ejecutar verificación contra artefactos actualizados antes de archivar

**No aplicar fixes directos en código sin actualizar OpenSpec primero.**

## 8. Contexto del proyecto (personalizar por proyecto)

> ⚠️ Esta sección DEBE ser actualizada al iniciar cada proyecto nuevo.

```
Stack: [definir stack del proyecto aquí]
Arquitectura: [Clean Architecture / MVC / etc.]
Dominio: [descripción del dominio de negocio]
Cliente: [nombre del cliente]
Convenciones de commits: Conventional Commits
Lenguaje del código: English
Lenguaje de documentación cliente: Español
```
