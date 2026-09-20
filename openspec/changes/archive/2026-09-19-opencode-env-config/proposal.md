# Proposal: opencode-env-config

- **Ticket origen**: FW-ENV
- **Título**: [docs] Variables de entorno en opencode.json y configuración externa de proveedores
- **Tag**: [docs] (confirmado por el usuario)
- **Fecha**: 2026-09-18

## Why

Hoy `opencode.json` versiona una API key literal (`provider.omniroute.options.apiKey`), lo que expone secretos al historial de git y a cualquier consumidor del template. Además, añadir un proveedor de modelos (p.ej. OpenRouter) obliga a editar `opencode.json`, archivo que el framework trata como parte del template.

OpenCode soporta interpolación `{env:VARIABLE}` en la configuración y fusiona la config de usuario (`~/.config/opencode/opencode.json`) con la del proyecto. Esto permite mantener secretos fuera del repo y proveedores fuera del template. Adicionalmente, este change sirve de prueba de regresión del ciclo SDD completo tras la actualización a Specboot 0.10.0.

## What Changes

**Incluye:**
- Reemplazar la API key literal de `opencode.json` (proveedor `omniroute`) por `{env:OMNIROUTE_API_KEY}`.
- Añadir `OMNIROUTE_API_KEY` y `OPENROUTER_API_KEY` a `.env.example` (sección nueva "AI MODEL PROVIDERS").
- Nuevo archivo versionado `.opencode/providers.example.json`: ejemplo copiable a la config de usuario con proveedor OpenRouter y un conjunto específico de modelos, usando `{env:OPENROUTER_API_KEY}`.
- Nueva guía `docs/opencode-providers-config.md` que documenta: sintaxis `{env:VAR}`, dónde vive la config de proveedores (archivo de usuario, no el template), cómo copiar el ejemplo y comportamiento cuando la variable no existe.

**Fuera de alcance:**
- Otros proveedores distintos de OpenRouter (el ejemplo) y OmniRoute (existente).
- Cambios en `check-refs.sh`, `specboot.sh` o cualquier script intocable.
- Gestión/rotación de secretos más allá de documentar el uso de variables de entorno.
