# Skill: using-git-worktrees

## Descripción

Configura un workspace Git aislado para trabajar en un feature o cambio, sin afectar la rama principal. Usar al inicio de cualquier cambio OpenSpec.

## Cuándo usar

- Antes de ejecutar `/plan-change` en un cambio nuevo
- Para trabajar en features en paralelo
- Cuando se quiere un entorno limpio de experimentación

## Proceso de setup

```bash
# 1. Asegurarse de estar en main/develop actualizado
git checkout main
git pull origin main

# 2. Crear worktree para el feature
git worktree add ../[proyecto]-[ticket-id] -b feature/[ticket-id]

# 3. Ir al worktree
cd ../[proyecto]-[ticket-id]

# 4. Copiar configuración local si existe
cp -n ../.claude/settings.json .claude/settings.json 2>/dev/null || true

# 5. Instalar dependencias si aplica
npm install  # o composer install, pip install, etc.
```

## Proceso de cleanup al terminar

```bash
# Desde el directorio principal del proyecto
git worktree remove ../[proyecto]-[ticket-id]
git branch -d feature/[ticket-id]  # si ya fue mergeada al PR
```

## Notas

- El worktree comparte el historial Git con el repo principal
- Cada worktree tiene su propio working directory y staging area
- Las ramas no se pueden compartir entre worktrees simultáneamente
