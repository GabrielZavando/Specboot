# Cambio representativo: backend (NestJS/API)

> Fixture determinista del conjunto de benchmark (REQ-009, SC-010). NO es
> código de producción: es el input mínimo y controlado para medir el ciclo
> semimanual.

## Cambio

Añadir un método `findById` a un servicio NestJS existente con su test
unitario (RED→GREEN).

```typescript
// src/orders/orders.service.ts (fragmento representativo)
findById(id: string): Observable<Order> {
  return this.http.get(`/api/orders/${id}`);
}
```

```typescript
// src/orders/orders.service.spec.ts (fragmento representativo)
it("findById returns the order by id", () => {
  service.findById("o-1").subscribe((o) => expect(o.id).toBe("o-1"));
});
```
