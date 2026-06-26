# Backend Standards

> Personalizar este archivo con el stack backend real del proyecto.

## API Development

- RESTful o GraphQL según arquitectura del proyecto
- Versioning explícito en la URL: `/api/v1/`
- Respuestas consistentes: `{ data, error, meta }`
- HTTP status codes correctos (200, 201, 400, 401, 403, 404, 422, 500)
- Validación de inputs en la capa de presentación
- Nunca exponer stacktraces en producción

## Base de datos

- Migraciones versionadas y reversibles
- Nunca modificar migraciones ya ejecutadas en producción
- Índices en campos usados en WHERE frecuentes
- Transacciones para operaciones multi-tabla
- Nombres de tablas en plural, snake_case, inglés

## Testing backend

- Unit tests para lógica de dominio y servicios
- Integration tests para repositorios y adapters
- E2E tests para flujos críticos de negocio
- Mocks solo para servicios externos (no para el propio código)
- Cobertura mínima: 90%

## Seguridad

- Nunca loguear datos sensibles (passwords, tokens, PII)
- Sanitizar todos los inputs antes de persistir
- Rate limiting en endpoints públicos
- CORS configurado explícitamente
- Variables de entorno para credenciales, nunca hardcodeadas

## Logging y errores

- Structured logging (JSON) con nivel: debug/info/warn/error
- Errors con contexto: qué ocurrió, dónde, con qué datos
- Health check endpoint: `/health`

## Stack específico del proyecto

> Reemplazar con el stack real:

```
Runtime: Node.js 20 / PHP 8.2 / Python 3.11
Framework: Express / Laravel / FastAPI
ORM: Prisma / Eloquent / SQLAlchemy
Base de datos: PostgreSQL / MySQL
Cache: Redis
Tests: Jest / PHPUnit / pytest
```
