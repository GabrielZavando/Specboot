# Skill: commit

## Descripción

Crear commits semánticos siguiendo Conventional Commits y gestionar Pull Requests al finalizar un cambio OpenSpec.

## Cuándo usar

- Al ejecutar `/commit` en el flujo SSD
- Después de `/verify` y `/adversarial-review` exitosos

## Formato de commits

```
<tipo>(<scope>): <descripción corta en inglés>

[cuerpo opcional — qué y por qué, no el cómo]

[footer opcional — BREAKING CHANGE, Closes #ticket]
```

### Tipos permitidos

| Tipo | Cuándo usar |
|------|-------------|
| `feat` | Nueva funcionalidad para el usuario |
| `fix` | Corrección de bug |
| `docs` | Solo documentación |
| `refactor` | Refactor sin cambio de comportamiento |
| `test` | Agregar o corregir tests |
| `chore` | Build, dependencias, config |
| `perf` | Mejora de performance |

### Ejemplos

```
feat(auth): add JWT refresh token endpoint

fix(orders): prevent duplicate submission on slow connections
Closes #SCRUM-42

docs(api): update payment endpoint spec with new error codes

refactor(user): extract email validation to shared util
```

## Proceso

1. Verificar que todos los tests pasen
2. Revisar el diff completo del cambio
3. Agrupar en commits lógicos (un commit = un cambio lógico)
4. Si hay cambios en `docs/api-spec.yml` o specs → commit separado de tipo `docs`
5. Si hay cambios en artefactos OpenSpec (`.openspec/`) → commit separado de tipo `docs`
6. Crear PR con descripción: qué cambia, por qué, cómo probar
7. Referenciar el ticket OpenSpec en el PR body

## PR Template

El template de PR está en `.github/pull_request_template.md`. Usar ese formato al crear el PR.
