# Proposal: commit-gate-semantics

- **Ticket ID**: M-904-M-905
- **Título original**: [docs] Semántica de staleness y gramática del trailer Gate-Bypass
- **Tag**: `[docs]` (explícito)
- **SemVer esperado**: `patch` (`0.6.2` — `0.6.1` ya lo ocupó M-403) — semántica/documentación formal sin romper el contrato vigente: los enums no cambian, solo se fijan formalmente; el staleness sigue warn-only.

## Contexto

El change `enforce-commit-gates` (M-901, archivado 2026-09-05) endureció los
gates de `/commit`: verify `PASS` + adversarial `SHIP` con evidencia vigente
son gates duros, `--force` se registra como trailer `Gate-Bypass`, y el
staleness quedó como warn-only. La auditoría adversarial de ese change dejó
dos follow-ups (Fase 10 del roadmap), que este change resuelve:

- **M-904 (W1)** — El chequeo de staleness compara el `timestamp` de la
  evidencia contra `git log -1 --format=%cI` (fecha del último commit, de
  cualquier tipo), sin semántica formal: no hay definición de qué invalida la
  evidencia (¿cualquier commit?, ¿solo commits de código?), ni regla de qué
  corrida prevalece cuando la herramienta se ejecuta varias veces para el
  mismo change, y el warning resulta genérico.
- **M-905 (W2)** — El trailer `Gate-Bypass: --force (verify=<estado>;
  adversarial=<veredicto>)` usa un vocabulario ad-hoc: sin gramática formal
  (tokens, orden, enums cerrados) ni validación parseable, herramientas de
  auditoría externas no pueden consumirlo de forma estable.

## Alcance

1. **Semántica de staleness (M-904)**:
   - Definición git-based: la evidencia es **stale** cuando existe al menos un
     commit posterior a su `timestamp` que toca **rutas de código**
     (`src/`, `app/`, `tests/`, `ai-specs/`, `.opencode/`). Los commits que
     solo tocan `docs/`, `openspec/` u otras rutas no-code **no** ensucian la
     evidencia.
   - Sigue **warn-only** (no bloquea): el warning se vuelve preciso — anuncia
     la regla aplicada y sugiere re-ejecutar la herramienta correspondiente.
   - **Prevalencia last-write-wins**: cada ejecución de `/verify` o
     `/adversarial-review` sobrescribe su archivo de estado
     (`openspec/state/verify-results.json` / `adversarial-result.json`); el
     gate siempre lee la corrida más reciente. Se documenta en los skills
     `commit`, `verify` y `code-auditing`.

2. **Gramática del trailer `Gate-Bypass` (M-905)**:
   - EBNF formal en el skill `commit` (Step 6), con orden fijo `verify`
     primero y `adversarial` segundo, separador exacto `; ` y enums cerrados:
     - `verify=` → `PASS | PARTIAL | FAIL | missing`
     - `adversarial=` → `SHIP | NO-SHIP | missing`
   - **Regex canónica** de parseo documentada para tooling externo.
   - Asserts nuevos en `tests/commit-gate-test.sh`: la regex matchea el
     ejemplo canónico del skill y **rechaza** counter-examples (orden
     invertido, valor fuera del enum).

## Decisiones de diseño (confirmadas)

- Staleness **por git y solo commits de código** (sin umbral temporal de
  reloj): reproducible y no depende de la hora del sistema.
- Stale **nunca bloquea** (se reafirma M-901); solo mejora la precisión del
  mensaje.
- **Last-write-wins** documentado: no se cambia `schema_version: 1` ni se
  introduce historial append-only (eso sería otro change).
- La gramática es **estricta**: el orden y el enum son parte del contrato; un
  emisor conforme y un parser conforme usan exactamente la misma forma.

## Archivos afectados

- `ai-specs/skills/commit/SKILL.md` — Step 2 (semántica de staleness) y
  Step 6 (gramática EBNF + regex canónica del trailer).
- `ai-specs/skills/verify/SKILL.md` y `ai-specs/skills/code-auditing/SKILL.md`
  — nota de prevalencia last-write-wins.
- `tests/commit-gate-test.sh` — asserts `[SC-001..005]` de la nueva semántica.
- `openspec/specs/commit-gates/spec.md` — delta `## MODIFIED` (staleness y
  trailer) + `## ADDED` (prevalencia).
- `PLAN_MEJORAS_SPECBOOT.md` — marcar `[x]` M-904 y M-905, fila de historial
  v3.8 (v3.7 la ocupó M-403).

## Fuera de alcance

- M-906 (reconciliar SemVer declarado de M-901) y M-907 (frase residual en
  spec archivada): tickets propios, no se tocan aquí.
- Cualquier cambio en los writers del estado (`schema_version`):
  last-write-wins ya es el comportamiento vigente; solo se formaliza.
- Bloqueo por staleness: rechazado explícitamente (ver Decisiones).
