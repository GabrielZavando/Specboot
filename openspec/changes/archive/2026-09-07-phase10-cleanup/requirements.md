# Requirements: phase10-cleanup

## REQ-1: Nota de reconciliación SemVer en M-901 (M-906)

La sección `[x] M-901` de `PLAN_MEJORAS_SPECBOOT.md` SHALL incluir una nota de
reconciliación que declare que el roadmap clasificó M-901 como `major`, que el
release real fue `minor` `0.5.0` con `### Breaking changes`, y que esto es
válido durante 0.x según `docs/versioning-standard.md` §2.

_Traza a SC-001._

## REQ-2: Regla de "majors durante 0.x" en versioning-standard (M-906)

`docs/versioning-standard.md` §2 SHALL declarar que, mientras el framework esté
en 0.x, un cambio clasificado `major` en el roadmap se releasa como `minor`
con `### Breaking changes` (y `### Migration` si aplica, §6.1), y que el
`major` estricto solo existe desde `1.0.0`, con el ejemplo M-901 → `0.5.0`.

_Traza a SC-002._

## REQ-3: Wording post-gate-duro en spec adversarial-state (M-907)

`openspec/specs/adversarial-state/spec.md` SHALL dejar de describir el hard
gate como pendiente (`the hard gate remains M-901`, `the hard gate is M-901`);
la requirement afectada SHALL describir archive como soft gate / warn-only y el
hard gate como el contrato ya implementado por el skill `commit` (spec
`commit-gates`), sin tocar el resto de la spec.

_Traza a SC-003._

## REQ-4: Guard anti-regresión (M-907)

`tests/commit-gate-test.sh` SHALL incluir asserts que fallen si
`openspec/specs/adversarial-state/spec.md` contiene
`the hard gate remains M-901` o `the hard gate is M-901`.

_Traza a SC-004._

## REQ-5: Cierre administrativo de Fase 10

`PLAN_MEJORAS_SPECBOOT.md` SHALL marcar `[x]` M-906 y M-907, añadir la fila de
historial v3.9 y registrar el backlog de Fase 11 (sin implementarlo). El
release SHALL ser `0.6.3` (patch): `package.json`, `CHANGELOG.md` y el pin de
`tests/mandatory-steps-test.sh`.

_Traza a SC-005._
