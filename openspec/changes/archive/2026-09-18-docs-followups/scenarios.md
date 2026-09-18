# Scenarios: docs-followups

### SC-001: GitHub Flow documentado para consumidores
- Given un proyecto consumidor que instala el framework
- When consulta la estrategia Git recomendada
- Then `docs/consumer-git-workflow.md` existe (GitHub Flow: ramas `feature/*`/`fix/*`/`chore/*`/`docs/*`, PR con CI, semver, hotfixes), se declara explícitamente como recomendación opcional, y `docs/git-workflow-standards.md` permanece **sin modificaciones**

### SC-002: Referencias desde el contrato y el README
- Given el contrato del framework y el README
- When se consultan las secciones de personalización/workflows
- Then ambas referencian `docs/consumer-git-workflow.md` distinguiéndolo del estándar interno

### SC-003: Handoff del tick documentado en verify y code-auditing
- Given un change con Mandatory Steps cuyo paso post es `verify` o `adversarial-review`
- When el subagente (read-only) produce su evidencia
- Then el skill correspondiente documenta que la checkbox del Mandatory Steps se marca al obtener la evidencia por el agente orquestador (el subagente es read-only y no la marca)

### SC-004: F-harness registrado como evaluado
- Given la sesión M-701/M-908/M-909 con incidentes de entorno (write rechazado, subagentes cancelados, bucles read)
- When el roadmap registra la investigación
- Then `PLAN_MEJORAS_SPECBOOT.md` documenta F-harness como evaluado-sin-acción-en-el-repo con sus mitigaciones operativas

### SC-005: Roadmap reconciliado
- Given `PLAN_MEJORAS_SPECBOOT.md` con M-801 sin marcar y M-910 sin registrar
- When se aplica el change
- Then M-801 está `## [x]`, M-910 está `## [x] M-910` (patrón M-403) y existe la fila de historial

### SC-006: Sin regresión tras el change
- Given el change aplicado
- When se ejecuta la verificación integral
- Then `bash check-refs.sh`, `bash specboot.sh --ci`, `bash validate-specboot.sh` y todos los `tests/*-test.sh` pasan en verde, y `docs/git-workflow-standards.md` está sin modificar respecto a `origin/main`
