# Requirements: opencode-env-config

| ID | Requirement | Escenarios |
|---|---|---|
| REQ-01 | `opencode.json` no debe contener API keys literales; todo secreto usa interpolación `{env:VARIABLE}` | SC-001 |
| REQ-02 | Debe existir `.opencode/providers.example.json`, JSON válido, con proveedor OpenRouter (`{env:OPENROUTER_API_KEY}`) y al menos 3 modelos específicos | SC-002 |
| REQ-03 | Debe existir la guía `docs/opencode-providers-config.md` documentando sintaxis, ubicación de la config de proveedores y comportamiento ante variable ausente | SC-003, SC-005 |
| REQ-04 | `.env.example` debe declarar `OMNIROUTE_API_KEY` y `OPENROUTER_API_KEY` en una sección AI MODEL PROVIDERS | SC-004 |
| REQ-05 | `bash check-refs.sh` y `bash specboot.sh --ci` deben terminar con 0 errores tras el change | SC-006 |
