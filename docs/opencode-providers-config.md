# Configuración de proveedores IA en OpenCode

Esta guía explica cómo configurar proveedores de modelos de IA (OpenRouter,
Omniroute, etc.) para OpenCode sin exponer secretos en el repositorio.

## 1. Interpolación `{env:VARIABLE}` en opencode.json

OpenCode admite referenciar variables de entorno dentro de `opencode.json`
(y de cualquier archivo de configuración de proveedor) mediante la sintaxis
`{env:NOMBRE_VARIABLE}`. Al iniciar la sesión, OpenCode sustituye ese
placeholder por el valor actual de la variable de entorno.

Ejemplo:

```json
{
  "provider": {
    "omniroute": {
      "options": {
        "apiKey": "{env:OMNIROUTE_API_KEY}"
      }
    }
  }
}
```

Regla de oro del proyecto: **ninguna API key literal se commitea**. Todo
`apiKey` en archivos versionados usa `{env:...}`.

## 2. Dónde viven los proveedores y los secretos

- El `opencode.json` **del template/repo** se limita a la configuración
  mínima del framework (instrucciones, permisos, agentes) y, como mucho,
  referencia proveedores usando `{env:...}` — nunca claves literales.
- Los proveedores concretos que cada desarrollador usa (con sus modelos y
  endpoints) viven en la **configuración de usuario**:
  `~/.config/opencode/opencode.json`, que no se versiona.
- Los valores de las variables de entorno (las claves reales) viven en el
  `.env` local de cada máquina, tampoco versionado.

## 3. Configurar un proveedor (paso a paso)

1. Copia el ejemplo del repo a tu configuración de usuario:

   ```bash
   mkdir -p ~/.config/opencode
   cp .opencode/providers.example.json ~/.config/opencode/opencode.json
   ```

   Si ya tienes un `~/.config/opencode/opencode.json`, fusiona el bloque
   `provider` del ejemplo con el tuyo (no lo sobrescribas a ciegas).

2. Define las variables de entorno requeridas. Toma como referencia la
   sección `AI MODEL PROVIDERS` de `.env.example`:

   ```bash
   OMNIROUTE_API_KEY=   # clave de tu instancia Omniroute
   OPENROUTER_API_KEY=  # clave de tu cuenta OpenRouter
   ```

   Añade los valores reales a tu `.env` local (o a tu gestor de secretos /
   export de shell).

3. Reinicia la sesión de OpenCode para que la interpolación `{env:...}`
   tome los valores nuevos.

## 4. Comportamiento cuando la variable no está definida

Si una variable referenciada con `{env:VARIABLE}` **no está definida** en el
entorno, la interpolación no puede resolverse y **el proveedor falta de forma
explícita al invocarse**: la primera llamada al modelo falla con un error de
autenticación/configuración. No hay fallback silencioso ni clave por defecto.

Para resolverlo: define la variable ausente en tu `.env` (o expórtala en el
shell) y **reinicia la sesión de OpenCode**. Hasta que la variable exista, el
proveedor seguirá fallando — esto es intencional: un fallo visible ante una
variable ausente es preferible a una clave hardcodeada en el repo.

## 5. Añadir más proveedores

1. Replica la estructura de `.opencode/providers.example.json` con el nuevo
   proveedor: bloque `provider.<nombre>` con `npm` (paquete del adaptador),
   `options.baseURL` y `options.apiKey` con `{env:...}`.
2. Declara la nueva variable en la sección `AI MODEL PROVIDERS` de
   `.env.example` (con el valor vacío, como placeholder documentado).
3. Fusiona el proveedor en tu `~/.config/opencode/opencode.json` y define la
   variable en tu `.env` local.
4. Reinicia la sesión de OpenCode.

Recuerda: el ejemplo del repo es la plantilla; la configuración efectiva es
siempre la de usuario.

## Referencias

- `.opencode/providers.example.json` — proveedor OpenRouter de ejemplo con
  tres modelos preconfigurados.
- `docs/opencode-providers-config.md` (este archivo) — convención del
  proyecto.
- Documentación oficial: https://opencode.ai/docs/
