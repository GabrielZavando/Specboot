# Documentation Standards

## Principios

- La documentación se actualiza junto con el código, no después
- El README del proyecto debe funcionar como onboarding completo para un dev nuevo
- Los comentarios en código explican el **por qué**, no el qué (el qué lo dice el código)
- Las specs (OpenSpec) son la fuente de verdad antes de implementar

## Estructura de READMEs

Cada servicio o módulo relevante debe tener un README con:

1. Descripción en una línea (qué hace)
2. Requisitos y dependencias
3. Setup en 3 pasos o menos
4. Variables de entorno requeridas
5. Comandos clave (dev, test, build, deploy)
6. Arquitectura resumida si es complejo

## API Documentation

- OpenAPI 3.0 en `docs/api-spec.yml`
- Cada endpoint documentado: descripción, params, request body, responses (incluyendo errores)
- Actualizar el spec antes de implementar cambios en la API (SDD)
- Ejemplos reales en el spec, no placeholders

## Data Model

- `docs/data-model.md` documenta todas las entidades del dominio
- Incluir: campos, tipos, relaciones, índices, constraints
- Mantener sincronizado con migraciones de base de datos

## Comentarios en código

```typescript
// BIEN: explica por qué
// El timeout es 5s porque el proveedor externo tiene latencia alta en peak hours
const PAYMENT_TIMEOUT_MS = 5000;

// MAL: repite lo que dice el código
// Set timeout to 5000
const PAYMENT_TIMEOUT_MS = 5000;
```

## Commits y PRs

- Conventional Commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
- Un commit = un cambio lógico
- PR description: qué cambia, por qué, cómo probar, screenshots si hay UI

## Semver y Versionado

### Cómo los Types Mapean a Bumping de Versión

| Type | Bump de Versión | Ejemplo |
|------|-----------------|---------|
| `feat` | Minor | 1.0.0 → 1.1.0 |
| `fix` | Patch | 1.0.0 → 1.0.1 |
| `feat` + `BREAKING CHANGE` | Major | 1.0.0 → 2.0.0 |
| `refactor` (sin cambio de feature) | None | No version bump |

### Comandos de Bumping de Versión

```bash
# Automático (crea commit + tag)
npm version patch  # 1.0.0 → 1.0.1
npm version minor  # 1.0.0 → 1.1.0
npm version major  # 1.0.0 → 2.0.0

# Manual con mensaje
git tag v1.2.3 -m "Release v1.2.3"
```

### Generación Automática de CHANGELOG

Para generación automática de changelog, usar `standard-version`:

```bash
# Instalar
npm install --save-dev standard-version

# Generar CHANGELOG.md y hacer bump de versión
npm run release -- --release-as minor

# O manual
npx standard-version --release-as minor
```

### Formato CHANGELOG.md (keep-a-changelog)

```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2024-01-15

### Features
- **auth**: add password reset endpoint ([#42](link))

### Bug Fixes
- **orders**: prevent duplicate submission on slow connections

### Documentation
- **api**: update payment endpoint spec
```
```

### commitlint Configuration

Para enforced conventional commits, usar `commitlint` con `@commitlint/config-conventional`:

```bash
npm install --save-dev @commitlint/config-conventional @commitlint/cli
```

### .commitlintrc.json

```json
{
  "extends": ["@commitlint/config-conventional"],
  "rules": {
    "type-enum": [
      2,
      "always",
      ["feat", "fix", "docs", "refactor", "test", "chore", "perf", "ci", "revert"]
    ],
    "subject-case": [
      2,
      "never",
      ["sentence-case", "start-case", "pascal-case", "upper-case"]
    ]
  }
}
```

### Git Hook (husky)

```bash
npm install --save-dev husky
npx husky init

# Add commitlint to commit-msg hook
echo 'npx --no -- commitlint --edit $1' > .husky/commit-msg
```
