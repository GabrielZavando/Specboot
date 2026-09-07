# Acceptance Scenarios: commit-gate-semantics

### SC-001: Staleness definido por commits de código posteriores a la evidencia
- **Given** evidencia utilizable (`change` coincidente) con `timestamp` T
- **When** `/commit` ejecuta su chequeo de staleness
- **Then** la evidencia es **stale** únicamente si existe al menos un commit posterior a T que toca alguna ruta de código (`src/`, `app/`, `tests/`, `ai-specs/`, `.opencode/`)
- **And** un commit posterior a T que solo toca `docs/`, `openspec/` u otras rutas no-code **no** marca la evidencia como stale

### SC-002: El staleness sigue siendo warn-only con mensaje preciso
- **Given** evidencia utilizable marcada como stale según SC-001
- **When** `/commit` ejecuta su gateway de evidencia
- **Then** imprime una advertencia precisa que declara la regla aplicada (commit de código posterior al timestamp de la evidencia) y sugiere re-ejecutar la herramienta, y **continúa**
- **And** el staleness nunca bloquea por sí solo (lo que bloquea es evidencia negativa, ausente, inválida o ajena — contrato M-901 intacto)

### SC-003: Prevalencia last-write-wins documentada
- **Given** múltiples ejecuciones de `/verify` o `/adversarial-review` para el mismo change
- **When** cada ejecución persiste su archivo de estado
- **Then** cada ejecución **sobrescribe** el archivo anterior (last-write-wins) y el gate de `/commit` siempre lee la corrida más reciente
- **And** esta regla queda documentada en los skills `commit`, `verify` y `code-auditing`

### SC-004: Gramática formal del trailer Gate-Bypass
- **Given** la documentación del skill `commit` (Step 6)
- **When** se revisa la definición del trailer `Gate-Bypass`
- **Then** existe una gramática EBNF con orden fijo (`verify=` primero, `adversarial=` segundo, separador exacto `; `) y enums cerrados (`verify=` ∈ {`PASS`, `PARTIAL`, `FAIL`, `missing`}; `adversarial=` ∈ {`SHIP`, `NO-SHIP`, `missing`})
- **And** existe una regex canónica documentada que tooling externo puede usar para parsear el trailer

### SC-005: El guard valida la gramática y la semántica documentadas
- **Given** `tests/commit-gate-test.sh` extendido por este change
- **When** el guard se ejecuta
- **Then** aserta que la regex canónica matchea el ejemplo del skill y rechaza counter-examples (orden invertido `adversarial=…; verify=…`, valor fuera del enum)
- **And** aserta los marcadores documentales de la semántica de staleness (commits de código, warn-only, mensaje preciso) y de last-write-wins en los tres skills afectados
