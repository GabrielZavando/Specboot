# Cambio representativo: frontend (Angular/UI)

> Fixture determinista del conjunto de benchmark (REQ-009, SC-010). NO es
> código de producción.

## Cambio

Añadir un badge de estado a un componente Angular con su test (RED→GREEN).

```typescript
// src/app/catalog/status-badge.component.ts (fragmento representativo)
export class StatusBadgeComponent {
  @Input() label = "";
  @Input() active = false;
}
```

```typescript
// src/app/catalog/status-badge.component.spec.ts (fragmento representativo)
it("renders the label with the active state", () => {
  fixture.componentInstance.label = "ok";
  expect(fixture.componentInstance.active).toBe(false);
});
```
