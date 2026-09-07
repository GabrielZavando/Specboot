# Requirements: commit-gate-semantics

Todos los requisitos aplican al framework Specboot (dogfooding) y a los
skills distribuidos por él. Trazables a los escenarios `SC-001..SC-005`.

## R1 — Semántica formal de staleness (M-904) — SC-001, SC-002

El skill `commit` SHALL definir staleness por git: la evidencia
(`verify-results.json` / `adversarial-result.json`) es stale cuando existe al
menos un commit posterior a su `timestamp` que toca alguna ruta de código
(`src/`, `app/`, `tests/`, `ai-specs/`, `.opencode/`). Commits que solo tocan
`docs/`, `openspec/` u otras rutas no-code SHALL NOT marcar la evidencia como
stale. El staleness SHALL permanecer warn-only: el warning declara la regla
aplicada y sugiere re-ejecutar la herramienta; NEVER bloquea el commit por sí
solo.

- **Escenarios**: SC-001, SC-002
- **Archivos**: `ai-specs/skills/commit/SKILL.md` (Step 2), `openspec/specs/commit-gates/spec.md` (delta MODIFIED)

## R2 — Prevalencia last-write-wins (M-904) — SC-003

Cada ejecución de `/verify` SHALL sobrescribir `openspec/state/verify-results.json`
y cada ejecución de `/adversarial-review` SHALL sobrescribir
`openspec/state/adversarial-result.json`; el gate de `/commit` SHALL leer
siempre la corrida más reciente (last-write-wins). Esta regla SHALL estar
documentada en los skills `commit`, `verify` y `code-auditing`.

- **Escenarios**: SC-003
- **Archivos**: `ai-specs/skills/{commit,verify,code-auditing}/SKILL.md`

## R3 — Gramática formal del trailer Gate-Bypass (M-905) — SC-004

El skill `commit` SHALL fijar la gramática del trailer en EBNF:

```
gate-bypass       = "Gate-Bypass: --force (" verify-state "; " adversarial-state ")"
verify-state      = "verify=" ("PASS" | "PARTIAL" | "FAIL" | "missing")
adversarial-state = "adversarial=" ("SHIP" | "NO-SHIP" | "missing")
```

con orden fijo (`verify` antes de `adversarial`), separador exacto `; ` y
enums cerrados, y SHALL documentar la regex canónica de parseo:

```
^Gate-Bypass: --force \(verify=(PASS|PARTIAL|FAIL|missing); adversarial=(SHIP|NO-SHIP|missing)\)$
```

- **Escenarios**: SC-004
- **Archivos**: `ai-specs/skills/commit/SKILL.md` (Step 6), `openspec/specs/commit-gates/spec.md` (delta MODIFIED)

## R4 — Guard actualizado (M-904 + M-905) — SC-005

`tests/commit-gate-test.sh` SHALL extenderse con asserts `[SC-001..SC-005]`
que validen: (a) la regex canónica matchea el ejemplo del skill y rechaza
counter-examples (orden invertido, valor fuera del enum); (b) los marcadores
documentales de staleness por commits de código, warn-only con mensaje
preciso y last-write-wins en los tres skills. El guard no SHALL debilitar
ningún assert vigente de M-901.

- **Escenarios**: SC-001..SC-005
- **Archivos**: `tests/commit-gate-test.sh`

## R5 — Cierre del roadmap — SC-001..SC-005 (registro)

`PLAN_MEJORAS_SPECBOOT.md` SHALL marcar M-904 y M-905 como `[x]` y añadir la
fila de historial v3.8 describiendo lo entregado por este change.

- **Archivos**: `PLAN_MEJORAS_SPECBOOT.md`
