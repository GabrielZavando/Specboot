# Scenarios: plan-rename-and-release-bump

### SC-001: ningún comando referencia el agente reservado `plan`
- Given los archivos de `.opencode/commands/`
- When se inspeccionan sus frontmatter
- Then ninguno declara `agent: plan`; `plan-change.md`, `enrich-us.md` y `explain.md` declaran `agent: sdd-plan`

### SC-002: el agente renombrado conserva su contrato de permisos
- Given `.opencode/agents/sdd-plan.md`
- When se compara con el rol `ai-specs/agents/plan-agent.md` (espejo M-403)
- Then conserva `mode: primary`, edit solo `openspec/**`, bash acotado (openspec CLI, git de ramas/lectura), `git commit`/`git push` deny, y el contenido del rol

### SC-003: /plan-change no activa el modo plan del editor
- Given una sesión en build mode
- When se ejecuta `/plan-change`
- Then la sesión permanece en build mode (el agente `sdd-plan` no es un nombre reservado)

### SC-004: release-bump sincroniza ambos archivos
- Given `release-bump.sh 0.9.0` con CHANGELOG que contiene `## [0.9.0]`
- When se ejecuta
- Then `package.json → version` y `.specboot.json → frameworkVersion` quedan en `0.9.0` en una sola operación

### SC-005: release-bump valida precondiciones
- Given versiones inválidas (no semver) o CHANGELOG sin la sección destino
- When se ejecuta el script
- Then aborta con error claro sin tocar ningún archivo

### SC-006: el script viaja en el paquete
- Given `package.json → files` y los guards de distribución
- When se publica/init/update
- Then `release-bump.sh` está incluido (mismo criterio que `check-refs.sh`)

### SC-007: rename registrado como breaking change
- Given el CHANGELOG 0.9.0
- When se lee su sección
- Then documenta el rename `plan → sdd-plan` como breaking change con instrucción de migración

### SC-008: guards verdes
- Given todos los cambios
- When corren los guards + `check-refs.sh` + `specboot.sh --ci`
- Then todo pasa, bump minor 0.8.1 → 0.9.0

### SC-009: bump realmente atómico (parse-before-write)
- Given un `.specboot.json` corrupto o ausente y un `package.json` válido
- When se ejecuta `release-bump.sh 0.9.1`
- Then aborta con error y `package.json` NO fue modificado (ninguna escritura antes de validar ambos archivos)

### SC-010: release-bump rechaza downgrades
- Given versión actual 0.9.0 y objetivo 0.8.0 (o igual)
- When se ejecuta `release-bump.sh 0.8.0`
- Then aborta con error claro sin tocar ningún archivo (solo se permiten bumps crecientes)
