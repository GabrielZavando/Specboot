# Cambio representativo: framework (Specboot)

> Fixture determinista del conjunto de benchmark (REQ-009, SC-010). NO es
> código de producción: representa un cambio típico del propio framework
> (dogfooding).

## Cambio

Añadir un aserto a un test bash del framework (RED→GREEN).

```bash
# tests/framework-example-test.sh (fragmento representativo — ilustrativo)
ok "framework example assertion: specboot.sh exists"
test -f "$ROOT/specboot.sh"
```
