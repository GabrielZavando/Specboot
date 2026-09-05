# Acceptance Scenarios: enforce-commit-gates

### SC-001: Commit procede con evidencia vigente de ambos gates
- **Given** `verify-results.json` con `status: "PASS"` y `adversarial-result.json` con `verdict: "SHIP"`, ambos con campo `change` coincidente con el change activo
- **When** `/commit` ejecuta su gateway de evidencia
- **Then** omite las preguntas de verify y de auditoría adversarial, reporta ambas evidencias (status/verdict + timestamp) y continúa a la validación de rama

### SC-002: Commit bloquea con verify PARTIAL o FAIL
- **Given** `verify-results.json` con `status: "PARTIAL"` o `"FAIL"` para el change activo
- **When** `/commit` ejecuta su gateway de evidencia
- **Then** bloquea y ofrece (a) re-ejecutar `/verify`, (b) abortar o (c) usar `--force`
- **And** no continúa sin decisión explícita del usuario

### SC-003: Commit bloquea si la evidencia de verify falta, es inválida o ajena
- **Given** `verify-results.json` ausente, JSON inválido, o con campo `change` distinto al change activo
- **When** `/commit` ejecuta su gateway de evidencia
- **Then** bloquea y ofrece (a) ejecutar `/verify`, (b) abortar o (c) usar `--force`
- **And** no cae en la pregunta a ciegas previa a M-401 ("¿ejecutaste /verify?")

### SC-004: Commit bloquea con veredicto NO-SHIP
- **Given** `adversarial-result.json` con `verdict: "NO-SHIP"` para el change activo
- **When** `/commit` ejecuta su gateway de evidencia
- **Then** bloquea y ofrece (a) re-ejecutar `/adversarial-review`, (b) abortar o (c) usar `--force`
- **And** no continúa sin decisión explícita del usuario

### SC-005: Commit bloquea si el veredicto adversarial falta o es ajeno
- **Given** `adversarial-result.json` ausente, inválido, o con campo `change` distinto al change activo
- **When** `/commit` ejecuta su gateway de evidencia
- **Then** bloquea y ofrece (a) ejecutar `/adversarial-review`, (b) abortar o (c) usar `--force`
- **And** la ausencia de auditoría adversarial deja de ser tolerada como opcional (breaking change del contrato de `/commit`)

### SC-006: El bypass con --force queda registrado en el commit message
- **Given** `/commit --force` invocado con gates bloqueados o evidencia ausente
- **When** se crean los commits
- **Then** cada commit message termina con el trailer git `Gate-Bypass: --force (verify=<PASS|PARTIAL|FAIL|missing>; adversarial=<SHIP|NO-SHIP|missing>)` reflejando el estado real de ambos gates
- **And** un commit con gates verdes no lleva trailer `Gate-Bypass`

### SC-007: El staleness es warn-only
- **Given** evidencia coincidente cuyo `timestamp` es anterior al último commit que tocó código
- **When** `/commit` ejecuta su gateway de evidencia
- **Then** imprime una advertencia de posible evidencia desactualizada y continúa
- **And** el staleness no bloquea por sí solo (lo que bloquea es evidencia negativa, ausente o ajena)

### SC-008: Evaluación CI cerrada como "mantener, sin acción"
- **Given** la evaluación M-902 frente a `openspec/specs/specboot-workflows/spec.md` sin evidencia reportada de fricción de consumidores
- **When** el change documenta la decisión
- **Then** la decisión "mantener el diseño 2 jobs, 1 archivo" queda registrada y justificada en el historial v3.5 de `PLAN_MEJORAS_SPECBOOT.md` y en este change
- **And** `ci.yml` conserva sus jobs `validate` y `project-ci` y `specboot-workflows/spec.md` no se modifica

### SC-009: Deploy exige el checklist mínimo obligatorio
- **Given** una ejecución de `/deploy` con algún ítem del checklist mínimo fallando (tests rojos, lint con críticos, build roto, audit con críticos, rollback sin definir, o change sin archivar)
- **When** el pre-deploy checklist se ejecuta
- **Then** el deploy se detiene antes del version bump reportando los ítems fallidos
- **And** no procede hasta que los seis ítems pasen (tests verdes, lint sin críticos, build ok, audit sin críticos, rollback definido, change archivado)

### SC-010: La plantilla deploy-standards incluye rollback y change archivado
- **Given** la plantilla `docs/deploy-standards.md`
- **When** un maintainer la personaliza para su proyecto
- **Then** el Pre-deploy Checklist contiene "rollback procedure defined" y "OpenSpec change archived" junto a los ítems existentes
- **And** el checklist del skill `deploy` los declara obligatorios

### SC-011: Descripciones sincronizadas con el contrato del gate duro
- **Given** la documentación del framework después de este change
- **When** se revisan las descripciones de `/commit`
- **Then** `AGENTS.md` (§5.2) declara los gates duros de evidencia y el escape `--force` registrado
- **And** `verify/SKILL.md`, `archive/SKILL.md`, `code-auditing/SKILL.md` y `.opencode/commands/commit.md` ya no describen el gate duro como "M-901, futuro" (lección M-403: rol documentado ↔ contrato real nunca divergen)

### SC-012: El commit de cierre del ciclo usa el change recién archivado como referencia
- **Given** `/commit` ejecutándose tras `/archive`, sin change activo bajo `openspec/changes/` y con el change recién archivado (ej. carpeta de archive `2026-09-05-enforce-commit-gates`)
- **When** el gateway de evidencia resuelve el change de referencia
- **Then** usa el nombre derivado del change archivado (`enforce-commit-gates`), tolerando el prefijo de fecha `YYYY-MM-DD-`
- **And** la evidencia cuyo campo `change` coincide con ese nombre derivado pasa el match, de modo que el commit de cierre del ciclo procede sin `--force`
