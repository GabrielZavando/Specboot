# Tasks: opencode-env-config

## Mandatory Steps

> Inyectado desde `docs/openspec-tasks-mandatory-steps.md` (fuente única de verdad, leída en el momento de generación).

## Pre-implementación

Antes de escribir la primera línea de la tarea actual:

- [x] La **rama activa** sigue la convención vigente del proyecto (ej.
  `feature/*`, `fix/*`); trabajar sobre ella, nunca directamente sobre la rama
  principal.
- [x] Estado **git limpio**: sin cambios sin commitear (ni staged) antes de
  empezar; si hay trabajo en curso, resolverlo primero.

## Durante la implementación

- [x] **Test nuevo que falla antes de implementar (RED)**: escribir el test del
  escenario (`SC-NNN`) y verificar que falla antes de escribir código de
  producción.
- [x] Ejecutar los **tests unitarios del módulo** tocado mientras se itera
  (ciclo RED-GREEN-REFACTOR), no solo al final.

## Post-implementación

Antes de dar la tarea por cerrada:

- [x] **Ejecutar `verify`**: la verificación del change corre y produce
  evidencia persistente (`openspec/state/verify-results.json`).
- [x] **Ejecutar `adversarial-review`**: la auditoría adversarial corre y
  produce veredicto persistente (`openspec/state/adversarial-result.json`).

> Ambos pasos post alimentan los gates duros de `/commit` (M-901): sin
> `PASS` + `SHIP` vigentes para el change activo, el commit bloquea.

## Task 1 — Guard TDD (RED) — Prioridad: Alta — Capa: framework tooling — Estimación: S

- **Subtarea 1.1**: crear `tests/opencode-env-config-test.sh` con asserts `[SC-001]`..`[SC-006]`: ningún apiKey literal en `opencode.json` (todos `{env:...}`); `.opencode/providers.example.json` existe, JSON válido, `provider.openrouter.options.apiKey` == `{env:OPENROUTER_API_KEY}` y ≥3 modelos; `docs/opencode-providers-config.md` existe y menciona `{env:` y el archivo de ejemplo; `.env.example` contiene `OMNIROUTE_API_KEY=` y `OPENROUTER_API_KEY=`. Ejecutar y confirmar **RED**.
- Suggested Path: tests/opencode-env-config-test.sh
- Test Path: tests/opencode-env-config-test.sh (el test ES el código; dogfooding)

## Task 2 — opencode.json sin secretos (SC-001) — Prioridad: Alta — Capa: framework tooling — Estimación: XS

- **Subtarea 2.1**: en `opencode.json`, reemplazar el valor literal de `provider.omniroute.options.apiKey` por `"{env:OMNIROUTE_API_KEY}"`. No tocar nada más del archivo.
- Suggested Path: opencode.json
- Test Path: tests/opencode-env-config-test.sh

## Task 3 — Ejemplo OpenRouter + variables de entorno (SC-002, SC-004) — Prioridad: Alta — Capa: framework tooling — Estimación: S

- **Subtarea 3.1**: crear `.opencode/providers.example.json` con `$schema`, proveedor `openrouter` (`npm`: `@openrouter/ai-sdk-provider`, `baseURL`: `https://openrouter.ai/api/v1`, `apiKey`: `{env:OPENROUTER_API_KEY}`) y al menos 3 modelos específicos (`anthropic/claude-sonnet-4.5`, `moonshotai/kimi-k2-thinking`, `z-ai/glm-4.6`).
- **Subtarea 3.2**: añadir a `.env.example` una sección `AI MODEL PROVIDERS` con `OMNIROUTE_API_KEY=` y `OPENROUTER_API_KEY=` (valores vacíos, con comentario de uso).
- Suggested Path: .opencode/providers.example.json
- Test Path: tests/opencode-env-config-test.sh

## Task 4 — Guía docs/opencode-providers-config.md (SC-003, SC-005) — Prioridad: Alta — Capa: framework tooling — Estimación: S

- **Subtarea 4.1**: crear `docs/opencode-providers-config.md` en español: sintaxis `{env:VARIABLE}`; regla de que proveedores/secrets viven en la config de usuario (`~/.config/opencode/opencode.json`) y no en el `opencode.json` del template; pasos para copiar `.opencode/providers.example.json`; comportamiento ante variable ausente (el proveedor falla de forma explícita al invocarse hasta definir la variable); referencia a `.env.example`.
- Suggested Path: docs/opencode-providers-config.md
- Test Path: tests/opencode-env-config-test.sh

## Task 5 — Verificación integral read-only — Prioridad: Alta — Capa: framework tooling — Estimación: XS

- **Subtarea 5.1**: ejecutar `bash check-refs.sh`, `bash specboot.sh --ci` y `bash tests/opencode-env-config-test.sh`; confirmar 0 errores y `git diff opencode.json` limitado al cambio del apiKey. Corregir desvíos antes de dar el change por implementado.
- Suggested Path: no aplica (verificación read-only)
- Test Path: no aplica
