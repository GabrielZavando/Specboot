# Proposal: phase10-cleanup

- **Ticket ID**: M-906-M-907
- **Título original**: [docs] Cierre Fase 10: reconciliación SemVer M-901 + frase residual en spec viva
- **Tag**: `[docs]` (explícito)
- **SemVer esperado**: `patch` (`0.6.3`) — documentación y un guard de no-regresión; no cambia ningún contrato de comportamiento del framework.

## Contexto

La Fase 10 del roadmap (`PLAN_MEJORAS_SPECBOOT.md`) quedó con dos follow-ups
pendientes tras archivar `commit-gate-semantics` (M-904/M-905, release 0.6.2):

- **M-906 (W3) — Reconciliar el nivel SemVer declarado de M-901.** El plan
  declara M-901 como `major` ("cambia el contrato de `/commit`"), pero su
  release se materializó como `minor` `0.5.0` con sección `### Breaking changes`
  — válido durante 0.x según `docs/versioning-standard.md` §2 ("API no
  estable"). El desfase entre la clasificación del plan y el release real
  confunde futuras lecturas del roadmap y no está documentado cómo se registran
  los "majors" mientras el framework siga en 0.x.
- **M-907 (W4) — Frase residual pre-gate-duro.** La spec **viva**
  `openspec/specs/adversarial-state/spec.md` conserva wording previo a M-901:
  - Línea 43: `The hard gate remains M-901 (out of scope).`
  - Línea 55: `...without error or block (the hard gate is M-901)`

  M-901 ya se implementó (change `enforce-commit-gates`, release 0.5.0): el gate
  duro **existe** y vive en el skill `commit`. La frase residual contradice el
  contrato vigente en la fuente de verdad consolidada.

## Alcance

1. **M-906**:
   - Nota de reconciliación en la sección `[x] M-901` de
     `PLAN_MEJORAS_SPECBOOT.md`: declara que el roadmap lo clasificó `major`,
     que el release real fue `minor` 0.5.0 con `### Breaking changes`, y que
     esto es válido en 0.x según `docs/versioning-standard.md` §2.
   - Precisión en `docs/versioning-standard.md` §2: mientras el framework esté
     en 0.x, un cambio clasificado `major` en el roadmap se **releasa como
     `minor` con `### Breaking changes`** (y `### Migration` si aplica, §6.1);
     el `major` estricto solo existe desde 1.0.0. Ejemplo referenciado:
     M-901 → 0.5.0.

2. **M-907**:
   - Reescritura de las líneas 43 y 55 de
     `openspec/specs/adversarial-state/spec.md` para describir el gate duro como
     contrato **ya implementado** por `/commit` (ver spec `commit-gates`),
     manteniendo el alcance de la requirement (archive = soft gate / warn-only).
   - Guard anti-regresión en `tests/commit-gate-test.sh` (sección nueva):
     falla si `openspec/specs/adversarial-state/spec.md` vuelve a contener
     `the hard gate remains M-901` o `the hard gate is M-901`.

3. **Cierre administrativo**:
   - `PLAN_MEJORAS_SPECBOOT.md`: marcar `[x]` M-906 y M-907, corregir la mención
     residual de la fila v3.4 (`el gate duro sigue siendo M-901` → nota de
     reconciliación), añadir fila de historial v3.9, y registrar los candidatos
     surgidos en la sesión M-904/M-905 como backlog de una posible Fase 11.
   - Bump `package.json` → `0.6.3`, `CHANGELOG.md` `## [0.6.3]`, pin de versión
     en `tests/mandatory-steps-test.sh`.

## Decisiones de diseño (confirmadas)

- **Un solo change combinado** para M-906+M-907: ambos son `patch`, docs-only en
  lo funcional, sin dependencias entre sí ni con otros tickets.
- El guard nuevo vive en `tests/commit-gate-test.sh` (ya contiene la sección C
  de "stale soft-gate wording must be gone"; la frase de M-907 es la misma
  categoría de residual). No se crea un test nuevo.
- **No se tocan** los proposals archivados (`persist-adversarial-verdict`,
  `persist-verify-results`): son histórico inmutable. Tampoco la línea 76 de
  `openspec/specs/commit-gates/spec.md` (menciona la frase solo para
  prohibirla).
- Los candidatos W5 (allowlist de staleness configurable), pin dinámico de
  versión, template `## Why` de plan-change y cómputo git canónico del staleness
  **no se implementan** aquí: solo se registran como backlog Fase 11 en el plan.

## Archivos afectados

- `openspec/specs/adversarial-state/spec.md` — líneas 43 y 55 (M-907).
- `openspec/changes/phase10-cleanup/specs/adversarial-state/spec.md` — delta
  `## MODIFIED`.
- `tests/commit-gate-test.sh` — asserts anti-regresión nuevos (M-907).
- `docs/versioning-standard.md` — precisión §2 "majors durante 0.x" (M-906).
- `PLAN_MEJORAS_SPECBOOT.md` — nota en M-901, `[x]` M-906/M-907, fila v3.9,
  backlog Fase 11.
- `package.json`, `CHANGELOG.md`, `tests/mandatory-steps-test.sh` — bump 0.6.3.

## Fuera de alcance

- Implementar W5 u otros candidatos de Fase 11.
- Reclasificar retroactivamente el número de versión 0.5.0 (la historia de
  releases publicada no se reescribe; se documenta la regla).
