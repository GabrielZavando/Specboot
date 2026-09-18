# Scenarios: cycle-hygiene

### SC-001: /apply marca las checkboxes del Mandatory Steps al cumplirlas
- Given un change con `## Mandatory Steps` en su `tasks.md` siendo ejecutado vía `/apply`
- When el agente build satisface cada paso (rama correcta, RED, tests iterados, verify, adversarial)
- Then la checkbox correspondiente queda marcada `[x]` vía edit tool en el mismo momento, y al finalizar `/apply` la sección Mandatory Steps no tiene checkboxes abiertas

### SC-002: /archive ya no depende de --yes por checkboxes sin marcar
- Given un change cuyo `/apply` marcó sus Mandatory Steps (SC-001)
- When `/archive` parsea `tasks.md`
- Then no hay `- [ ]` de Mandatory Steps pendientes y archive procede sin `--yes`; si quedara algún resto satisfecho sin marcar, archive lo cubre vía edit tool (nunca `sed -i`); ante tareas de implementación genuinas pendientes sigue abortando

### SC-003: El roadmap refleja M-701 y M-908 como completados
- Given `PLAN_MEJORAS_SPECBOOT.md` con M-701 (Fase 7) sin marcar y M-908 sin registrar
- When se aplica el change
- Then M-701 está marcado `## [x]`, M-908 está registrado como ticket completado `## [x] M-908` (patrón M-403) y existe la fila de historial del ciclo (M-701 + M-908 + M-909)

### SC-004: El template de proposal incluye Why y What Changes
- Given el skill `plan-change` generando `proposal.md` sin las secciones exigidas por `openspec archive`
- When se aplica el change
- Then el template incluye `## Why` y `## What Changes`, el checklist del Step 6 lo valida, y un proposal generado por el template no produce el warning de archive

### SC-005: Guards del contrato de higiene
- Given los cambios anteriores aplicados
- When se ejecutan los guards
- Then `tests/mandatory-steps-test.sh` valida el tick en `/apply` + registro del roadmap, y el nuevo `tests/plan-proposal-test.sh` valida el template de proposal; todos en verde

### SC-006: Sin regresión tras el change
- Given el change aplicado
- When se ejecuta la verificación integral del framework
- Then `bash check-refs.sh`, `bash specboot.sh --ci`, `bash validate-specboot.sh` y todos los `tests/*-test.sh` pasan en verde
