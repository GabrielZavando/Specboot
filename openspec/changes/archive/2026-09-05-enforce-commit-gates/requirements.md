# Change Requirements: enforce-commit-gates

## REQ-001: Gate duro de verify en commit
- **Descripción**: El skill `commit` SHALL tratar `openspec/state/verify-results.json` como gate duro: solo `status: "PASS"` con campo `change` coincidente con el change activo permite continuar (omitiendo la pregunta de verify y reportando la evidencia). Con `PARTIAL` o `FAIL` SHALL bloquear ofreciendo re-ejecutar `/verify`, abortar o usar `--force`. Si el archivo falta, es JSON inválido o su `change` no coincide SHALL bloquear ofreciendo ejecutar `/verify`, abortar o usar `--force`, sin caer en la pregunta a ciegas previa a M-401.
- **Trazabilidad**: SC-001, SC-002, SC-003

## REQ-002: Gate duro del veredicto adversarial en commit
- **Descripción**: El skill `commit` SHALL tratar `openspec/state/adversarial-result.json` como gate duro: solo `verdict: "SHIP"` con campo `change` coincidente permite continuar (omitiendo la confirmación manual y reportando la evidencia). Con `NO-SHIP` SHALL bloquear ofreciendo re-auditar, abortar o usar `--force`. Si el archivo falta, es inválido o es ajeno SHALL bloquear ofreciendo ejecutar `/adversarial-review`, abortar o usar `--force` — la ausencia de auditoría deja de ser opcional en `/commit`.
- **Trazabilidad**: SC-004, SC-005

## REQ-003: Flag --force con bypass registrado
- **Descripción**: El skill `commit` SHALL soportar el flag `--force` como única vía para saltarse un gate bloqueado. Al usarlo, el commit message SHALL incluir el trailer git `Gate-Bypass: --force (verify=<PASS|PARTIAL|FAIL|missing>; adversarial=<SHIP|NO-SHIP|missing>)` con el estado real de ambos gates. Sin bypass, el trailer SHALL NOT emitirse.
- **Trazabilidad**: SC-006

## REQ-004: Lectura token-light, change de referencia y staleness warn-only
- **Descripción**: El gateway de evidencia SHALL leer solo los campos resumen de ambos JSON (token-light; `node -e`, nunca `jq`), SHALL validar el match del campo `change` contra el **change de referencia** — el change activo; si el commit corre tras `/archive` (sin change activo), el change recién archivado, emparejado por su nombre derivado y tolerando el prefijo de fecha `YYYY-MM-DD-` que añade el CLI a la carpeta de archive —, y SHALL mantener el chequeo de staleness (timestamp anterior al último commit que tocó código) como warn-only: la advertencia no bloquea por sí sola.
- **Trazabilidad**: SC-001, SC-007, SC-012

## REQ-005: Evaluación CI documentada como "mantener, sin acción"
- **Descripción**: La evaluación M-902 SHALL concluir "mantener el diseño 2 jobs, 1 archivo de `ci.yml`" ante la ausencia de evidencia de fricción de consumidores, documentando la decisión y su justificación en el historial v3.5 de `PLAN_MEJORAS_SPECBOOT.md` y en este change. `ci.yml` (jobs `validate` + `project-ci`) y `openspec/specs/specboot-workflows/spec.md` SHALL permanecer sin modificaciones. Si apareciera evidencia real, la migración se trataría en un change independiente sobre `specboot-workflows`.
- **Trazabilidad**: SC-008

## REQ-006: Checklist mínimo obligatorio en deploy
- **Descripción**: El skill `deploy` SHALL definir un checklist mínimo obligatorio, independiente del proyecto, que `/deploy` MUST pasar antes de cualquier paso de release: tests verdes, lint sin errores críticos, build exitoso, auditoría de seguridad sin vulnerabilidades críticas (`npm audit` / `pip-audit`), procedimiento de rollback definido y change OpenSpec archivado. Si algún ítem falla, el deploy SHALL detenerse antes del version bump reportando los ítems fallidos.
- **Trazabilidad**: SC-009

## REQ-007: Plantilla deploy-standards con rollback y change archivado
- **Descripción**: La plantilla `docs/deploy-standards.md` SHALL incluir en su Pre-deploy Checklist al menos "rollback procedure defined" y "OpenSpec change archived", junto a los ítems existentes (tests, lint/typecheck, build, security audit), en coherencia con el checklist obligatorio del skill `deploy`.
- **Trazabilidad**: SC-010

## REQ-008: Descripciones sincronizadas con el contrato del gate duro
- **Descripción**: Las descripciones de `/commit` en `AGENTS.md` (§5.2), `.opencode/commands/commit.md`, la nota de consumidor en `ai-specs/skills/verify/SKILL.md` y las referencias al gate duro en `ai-specs/skills/archive/SKILL.md` y `ai-specs/skills/code-auditing/SKILL.md` SHALL declarar el contrato del gate duro (verify `PASS` + adversarial `SHIP`, `--force` registrado) y SHALL NOT describirlo como trabajo futuro (lección M-403: rol documentado ↔ contrato real nunca divergen).
- **Trazabilidad**: SC-011
