# Data Model

> Actualizar con las entidades reales del proyecto.

## Entidades del dominio

### Ejemplo: User

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | UUID (PK) | Identificador único |
| email | VARCHAR(255) UNIQUE | Email del usuario |
| name | VARCHAR(100) | Nombre completo |
| created_at | TIMESTAMP | Fecha de creación |
| updated_at | TIMESTAMP | Última modificación |

### Relaciones

```
User 1--N Order
Order N--N Product (via OrderItem)
```

## Reglas de negocio del dominio

> Documentar aquí las reglas que el agente debe respetar al generar código:

- Un usuario puede tener múltiples órdenes
- Una orden no puede modificarse una vez en estado `completed`
- ...

## Convenciones de nombres

- Tablas: plural, snake_case, inglés (`users`, `order_items`)
- Campos FK: `{tabla_referenciada_singular}_id` (`user_id`, `product_id`)
- Timestamps: siempre `created_at` y `updated_at`
- Soft delete: campo `deleted_at` nullable
