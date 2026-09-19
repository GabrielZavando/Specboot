# Scenarios: opencode-env-config

## Especificación

### SC-001: opencode.json no contiene API keys literales
Given el archivo versionado `opencode.json`
When se inspeccionan los campos `provider.*.options.apiKey`
Then todo valor usa la sintaxis `{env:VARIABLE}`
And no existe ningún string literal de key en el archivo

### SC-002: Ejemplo de proveedor OpenRouter copiable y válido
Given el archivo versionado `.opencode/providers.example.json`
When un dev lo copia a su config de usuario (`~/.config/opencode/opencode.json`) con `OPENROUTER_API_KEY` definida en su entorno
Then el JSON es válido
And `provider.openrouter.options.apiKey` vale exactamente `{env:OPENROUTER_API_KEY}`
And `provider.openrouter.models` contiene al menos 3 modelos específicos
And no fue necesario editar el `opencode.json` del proyecto

### SC-003: La guía de configuración de proveedores existe y cubre el mecanismo
Given `docs/opencode-providers-config.md`
When un dev la lee
Then documenta la sintaxis `{env:VARIABLE}`
And explica que los proveedores viven en el archivo de config de usuario, no en el `opencode.json` del template
And referencia `.opencode/providers.example.json` y las variables en `.env.example`

### SC-004: .env.example declara las nuevas variables
Given el archivo `.env.example`
When un dev prepara su entorno
Then existe una entrada `OMNIROUTE_API_KEY=` y una `OPENROUTER_API_KEY=`
And ambas están bajo una sección claramente nombrada (AI MODEL PROVIDERS)

### SC-005: Variable de entorno ausente documentada (edge case)
Given un dev que NO definió `OPENROUTER_API_KEY`
When consulta `docs/opencode-providers-config.md`
Then la guía documenta el comportamiento esperado (fallo explícito del proveedor) y cómo resolverlo

### SC-006: Los checks de integridad del framework siguen en 0 errores
Given el repo con los cambios aplicados
When se ejecuta `bash check-refs.sh` y `bash specboot.sh --ci`
Then ambos terminan con exit code 0
And ningún archivo versionado introduce un secreto literal nuevo
