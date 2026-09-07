# Acceptance Scenarios: phase10-cleanup

### SC-001: Nota de reconciliación SemVer en M-901
- **Given** la sección `[x] M-901` de `PLAN_MEJORAS_SPECBOOT.md`, que declara nivel `major`
- **When** este change se aplica
- **Then** la sección contiene una nota de reconciliación que declara: el roadmap clasificó M-901 como `major`, el release real fue `minor` `0.5.0` con `### Breaking changes`, y esto es válido durante 0.x según `docs/versioning-standard.md` §2
- **And** la nota referencia explícitamente `0.5.0` y la sección §2 del estándar

### SC-002: Regla de "majors durante 0.x" documentada en el estándar de versionado
- **Given** `docs/versioning-standard.md` §2 (reglas SemVer)
- **When** este change se aplica
- **Then** §2 declara que, mientras el framework esté en 0.x, un cambio clasificado `major` en el roadmap se releasa como `minor` con `### Breaking changes` (y `### Migration` si aplica, §6.1), y que el `major` estricto solo existe desde `1.0.0`
- **And** la regla incluye el ejemplo de referencia M-901 → `0.5.0`

### SC-003: Spec adversarial-state sin wording pre-gate-duro
- **Given** `openspec/specs/adversarial-state/spec.md` (spec viva consolidada)
- **When** este change se aplica
- **Then** ninguna requirement describe el hard gate como pendiente o futuro: desaparecen `the hard gate remains M-901 (out of scope)` y `the hard gate is M-901`
- **And** la requirement reescrita declara que archive permanece soft gate / warn-only y que el hard gate es el contrato vigente implementado por el skill `commit` (spec `commit-gates`)
- **And** el resto de la spec (escenarios, permisos, requirements no relacionadas) permanece sin cambios

### SC-004: Guard anti-regresión sobre la frase residual
- **Given** `tests/commit-gate-test.sh` extendido por este change
- **When** el guard se ejecuta
- **Then** falla si `openspec/specs/adversarial-state/spec.md` contiene `the hard gate remains M-901` o `the hard gate is M-901`
- **And** pasa con la spec corregida (SC-003)

### SC-005: Cierre administrativo de la Fase 10
- **Given** `PLAN_MEJORAS_SPECBOOT.md` con M-906 y M-907 pendientes
- **When** este change se aplica
- **Then** M-906 y M-907 aparecen marcados `[x]` con su change referenciado
- **And** existe una fila de historial v3.9 que resume el change y registra `0.6.2` → `0.6.3` (patch)
- **And** los candidatos surgidos en la sesión M-904/M-905 (allowlist de staleness configurable, pin dinámico de versión en tests, formato `## Why` del template de plan-change, cómputo git canónico del staleness) quedan registrados como backlog de Fase 11, sin implementar
- **And** `package.json` declara `0.6.3`, `CHANGELOG.md` contiene `## [0.6.3]` y el pin de versión de `tests/mandatory-steps-test.sh` apunta a `0.6.3`
