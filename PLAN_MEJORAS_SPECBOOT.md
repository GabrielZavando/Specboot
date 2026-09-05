# Plan de Mejoras Specboot (v3 — Reconciliado y corregido)

## Objetivo

Roadmap de evolución de Specboot para mejorar robustez, verificabilidad y autonomía,
partiendo de una auditoría real del repositorio (`GabrielZavando/Specboot`, rama `main`)
y evitando redundancias, colisiones de ID o contradicciones con specs ya archivadas.

Cada ticket sigue estructura SDD: **propuesta → requisitos → tareas → criterios de
aceptación**, identificado con el esquema `M-###` (no colisiona con `TICKET-###`,
usado por el manifest histórico en `openspec/state/manifest.json`).

Cada ticket declara además:
- **Nivel SemVer estimado** (`patch` / `minor` / `major`), según la matriz de
  `docs/versioning-standard.md`, para que quien ejecute `/plan-change` lo tenga en cuenta
  desde el inicio y no lo determine ad-hoc al final.
- **Dependencias** (si las tiene), en vez de asumir un orden implícito.

**Historial de correcciones de este documento:**

| Versión | Corrección aplicada |
|---|---|
| v2 | Renumeración `TICKET-*` → `M-*` para evitar colisión con el manifest |
| v2 | Reescritura de la premisa de autenticación GitHub Packages (M-T0.2) |
| v2 | Reclasificación de tickets ya existentes como "Extensión" en vez de "Crear" |
| v3 | Fusión de "Fase T0" y "Fase 0" en una sola fase de reconciliación |
| v3 | Corrección de errores en la tabla de mapeo de IDs (TICKET-0.3, TICKET-5.2) |
| v3 | M-001 reescrito con estructura SDD completa |
| v3 | M-801 reescrito sin condicional "si existe": reconcilia explícitamente con `openspec/specs/git-workflow/spec.md` |
| v3 | M-902 reescrito como ticket de **evaluación**, no de arquitectura decidida, frente a `openspec/specs/specboot-workflows/spec.md` |
| v3 | M-302 acotado a lo que no existe aún, igual que se hizo con M-301 |
| v3 | Añadida clasificación SemVer y dependencias explícitas a cada ticket |
| v3.1 | M-001 y M-002 completados vía change `phase0-reconciliation` (marcados con `[x]`); sección "Autenticación para consumidores (CI)" documentada en `README.md` |
| v3.2 | M-101 y M-102 completados vía change `plan-traceability` (marcados con `[x]`); plantillas y skills de `enrich-us`, `plan-change` y `verify` actualizados con metadatos y IDs `SC-{NNN}` |
| v3.3 | M-401 y M-402 completados vía change `persist-verify-results` (marcados con `[x]`); `verify` persiste `openspec/state/verify-results.json` (esquema versionado, autovalidado por `tests/verify-state-test.sh`); `/commit` usa gate informado suave y `archive` referencia la verificación en el manifest; convención de tests `SC-NNN` en agentes generadores; registrado M-403 (permisos pytest del subagente verify) |
| v3.4 | M-501 y M-502 completados vía change `persist-adversarial-verdict` (marcados con `[x]`); `adversarial-review` formaliza la auto-refutación en protocolo de 4 pasos con anexo "Descartados" y persiste `openspec/state/adversarial-result.json` (esquema versionado, autovalidado por `tests/adversarial-state-test.sh`); `archive` referencia el veredicto en el manifest y `/commit` lo usa como gate informado suave (el gate duro sigue siendo M-901); permisos del subagente reviewer sincronizados con su rol (patrón M-403) |

> **⚠️ Estrategia de rama — decisión del mantenedor (2026-09-05):** todas las fases
> restantes de este plan se implementan en la **rama única**
> `feature/plan-mejoras-specboot` (renombrada desde
> `feature/m-201-202-path-design-validation`, que era herencia de la fase anterior).
> **No crear una rama nueva por ticket ni por fase**: continuar fase tras fase sobre
> esta misma rama. Push + PR + merge + tag y release con el paquete actualizado
> **una sola vez**, cuando el plan completo esté implementado. Excepción: si se
> detecta un fix urgente independiente del plan, evaluar rama aparte en ese momento.

---

# FASE 0 — Reconciliación del plan y del framework

**Objetivo:** Corregir premisas desactualizadas del roadmap y evitar duplicar
funcionalidad ya existente, antes de planificar trabajo nuevo.

---

## [x] M-001 — Auditoría de funcionalidades ya implementadas

**Nivel SemVer:** n/a (ticket de auditoría, no modifica el framework)
**Dependencias:** ninguna — es el punto de partida del roadmap

**Problema:** El plan original (`TICKET-*`) se escribió sobre una foto desactualizada
del repositorio. Varios tickets proponían "crear" funcionalidad que ya existe, parcial
o totalmente.

**Propuesta:** Dejar registrada la verificación real, para que ningún ticket posterior
reabra trabajo ya hecho.

**Verificación (repo `GabrielZavando/Specboot`, rama `main`):**

| Ticket original | Estado real verificado | Acción en este plan |
|---|---|---|
| TICKET-5.1 (`adversarial-review`) | Existe: `.opencode/commands/adversarial-review.md`, agente `reviewer`, skill `ai-specs/skills/code-auditing/SKILL.md` con veredicto `SHIP/NO-SHIP` | → M-501, reclasificado "Extensión" |
| TICKET-5.2 (auto-refutación) | Existe literalmente: `code-auditing/SKILL.md` línea 34, "Auto-refutación: por cada hallazgo crítico, intentar refutarlo..." | → M-501 (mismo ticket que 5.1, no uno separado — ver nota abajo) |
| TICKET-8.2 (worktrees) | Existe: skill `using-git-worktrees`, listada en `README.md` | Eliminado del roadmap |
| TICKET-3.1 (protocolo TDD) | Existe parcialmente: `ai-specs/agents/build-agent.md` ya define RED-GREEN-REFACTOR como "regla no negociable". Falta: límite de intentos y reporte de fallo | → M-301, acotado a "protocolo de fallo" |
| TICKET-3.2 (una sola tarea por `/apply`) | Existe parcialmente: `build-agent.md` ya dice *"identificar la tarea actual (una sola)"* y *"nunca implementar más de lo que pide la tarea actual"*. Falta: detenerse y esperar confirmación explícita del usuario tras completarla | → M-302, acotado a "detención explícita" |
| TICKET-0.3 (`specboot --ci` valida auth) | No existe. Premisa de TICKET-0.1 (`ci.yml` inyectado con 401) era incorrecta — no hay `ci.yml` inyectado a consumidores; la auth real usa `.npmrc`/PAT documentado en `README.md` | Idea absorbida en M-T0.1 (ver abajo), no como validación automática sino como documentación |
| TICKET-9.3 / M-902 (CI en dos workflows) | El framework ya implementa la separación framework-vs-proyecto, pero como **dos jobs en un solo `ci.yml`** (`validate` + `project-ci`), documentado y testeado en `openspec/specs/specboot-workflows/spec.md` | → M-902 reescrito como ticket de **evaluación** frente a este spec, no como migración decidida |
| TICKET-8.1 (estrategia Git) | `docs/git-workflow-standards.md` ya existe, con spec archivada `openspec/specs/git-workflow/spec.md` (modelo: rama por ticket desde HEAD, commits local-first, cierre por fase, matriz push/PR, modo local-only) — modelo **distinto** al "GitHub Flow" genérico propuesto | → M-801 reescrito para reconciliar ambos, no ignorar el existente |

**Nota sobre 5.1/5.2:** en v2 se numeraron como tickets separados (`M-501`, `M-502`),
pero la auto-refutación es una sub-mejora del mismo skill que 5.1 evoluciona — se
fusionan en un único ticket `M-501` para evitar fragmentar una misma pieza de trabajo.
`M-502` se reutiliza para una idea distinta y genuinamente nueva (persistir el veredicto
como gate), ver Fase 5.

**Criterios de aceptación:**
- Ningún ticket de este plan reclama "crear" algo verificado como existente en esta tabla.
- Todo ticket que extiende algo existente referencia el archivo real que modifica.

---

## [x] M-002 — Documentar autenticación GitHub Packages para consumidores

**Nivel SemVer:** `patch` (solo documentación, no cambia contratos del framework)
**Dependencias:** ninguna

**Problema:** La autenticación del framework hacia GitHub Packages (publicación) ya
está resuelta (`release.yml`, spec `npm-distribution`). Lo que falta es una guía para
**consumidores** (ej. WebAppRiff) sobre cómo autenticar su propio CI al instalar
`@gabrielzavando/specboot`. El plan original (`TICKET-0.1`) asumía incorrectamente que
Specboot inyecta un `ci.yml` a los consumidores — no existe tal inyección.

**Propuesta:** Sección nueva en `README.md`: *"Autenticación para consumidores (CI)"*.

**Contenido:**

1. **Mismo owner / org con acceso concedido:** `secrets.GITHUB_TOKEN` funciona si el
   repo consumidor tiene acceso concedido explícitamente en *Package settings → Manage
   Actions access* del repo Specboot. Ejemplo de workflow:
   ```yaml
   permissions:
     contents: read
     packages: read
   steps:
     - uses: actions/setup-node@v5
       with:
         node-version: '24'
         registry-url: https://npm.pkg.github.com
     - run: npm install
       env:
         NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
   ```
2. **Owner distinto / sin acceso concedido:** requiere un PAT con scope `read:packages`
   guardado como secret del repo consumidor (`NPM_TOKEN` o similar), igual que ya
   documenta `README.md` para uso local (`npm login` / `.npmrc`).
3. **Troubleshooting:** causas típicas de `401` (falta `NODE_AUTH_TOKEN`, PAT sin scope
   `read:packages`) y `403` (repo sin acceso concedido en Package settings).

**Requisitos:**
- Sección nueva en `README.md`, no un archivo aparte (evita fragmentar la documentación
  de instalación, que ya vive ahí).
- Snippet de workflow copiable y verificado contra el mecanismo real de GitHub Packages.

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Redactar sección "Autenticación para consumidores (CI)" en `README.md` | Alta |
| 2 | Verificar el snippet YAML instalando el paquete en un repo de prueba del mismo org | Alta |

**Criterios de aceptación:**
- Un consumidor nuevo puede configurar `npm install` en su CI sin preguntar, siguiendo
  solo el README.

---

# FASE 1 — Fortalecer planificación y trazabilidad

## [x] M-101 — Enriquecer `enrich-us` con estimación, riesgo y dependencias

**Nivel SemVer:** `minor` (nueva capacidad, no rompe artefactos existentes)
**Dependencias:** ninguna

**Estado:** `enrich-us` existe (`ai-specs/skills/enrich-us/SKILL.md`).

**Problema:** Falta información estratégica para que `plan-change` dimensione
correctamente las tareas.

**Propuesta:** Extender el template de salida del skill existente.

**Implementación:**

```markdown
## Estimación
Complejidad: XS | S | M | L | XL
Justificación:

## Riesgo
Nivel: Bajo | Medio | Alto | Crítico
Motivo:

## Dependencias
Tickets relacionados:

## Alternativas descartadas
Alternativa:
Motivo del descarte:
```

**Requisitos:**
- Todo ticket enriquecido incluye las 4 secciones nuevas.
- `plan-change` puede leer la información de riesgo/estimación para priorizar.

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Agregar las 4 secciones al template de `enrich-us/SKILL.md` | Alta |
| 2 | Actualizar ejemplo en `ai-specs/examples/enrich-us-auth-reset.md` | Media |

**Criterios de aceptación:**
- Los campos nuevos aparecen en todo artefacto enriquecido generado después del cambio.

---

## [x] M-102 — Añadir IDs estables a escenarios Gherkin

**Nivel SemVer:** `minor`
**Dependencias:** ninguna (pero M-402 depende de este)

**Problema:** Los escenarios Gherkin no tienen identificador único, lo que impide
trazabilidad entre escenario, test y reporte.

**Propuesta:** Convención `SC-{NNN}: Nombre del escenario`.

**Ejemplo:**

```markdown
### SC-001: Usuario recupera contraseña con email válido

Given usuario registrado con email activo
When solicita recuperación de contraseña
Then recibe email con token válido
```

**Requisitos:**
- Todo escenario generado por `enrich-us` o `plan-change` tiene ID `SC-{NNN}` único
  dentro del change.
- `verify` puede buscar evidencia de tests usando el ID.

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Actualizar plantilla de `enrich-us` para generar IDs `SC-NNN` | Alta |
| 2 | Actualizar plantilla de `plan-change` para preservar IDs | Alta |
| 3 | Actualizar skill `verify` para buscar tests por patrón `SC-{NNN}` | Alta |

**Criterios de aceptación:**
- `verify` puede establecer trazabilidad `SC-NNN → test → PASS/FAIL`.

---

# FASE 2 — Mejorar generación de cambios OpenSpec

## M-201 — Definir convención de `Suggested Path` y `Test Path`

**Nivel SemVer:** `minor`
**Dependencias:** ninguna

**Estado:** `plan-change` existe (`ai-specs/skills/plan-change/SKILL.md`).

**Problema:** `verify` depende de rutas sugeridas por `plan-change`, pero no existe
convención estricta, lo que fuerza un fallback estático frágil.

**Propuesta:** Reglas explícitas en el skill `plan-change`.

**Convención:**

```yaml
Suggested Path: src/{domain}/{entity}.{ext}
Test Path:     tests/{domain}/{entity}.{test-ext}
```

**Requisitos:**
- Toda tarea en `tasks.md` incluye `Suggested Path` y `Test Path` (o "no aplica"
  explícito).
- Las rutas son coherentes con el stack declarado en `.specboot.json`.

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Agregar reglas de rutas al skill `plan-change` | Alta |
| 2 | Actualizar plantilla de `tasks.md` con los campos | Alta |
| 3 | Actualizar `verify` para leer los campos directamente, sin fallback por nombre | Media |

**Criterios de aceptación:**
- `verify` puede ejecutar tests sin fallback estático cuando las rutas son correctas.

---

## M-202 — Validación de coherencia de diseño antes de generar tareas

**Nivel SemVer:** `minor`
**Dependencias:** ninguna

**Problema:** `plan-change` puede generar tareas que contradigan la arquitectura
existente (`docs/data-model/data-model.md`, `docs/api/api-spec.yml`).

**Propuesta:** Paso de validación antes de crear `tasks.md`. Conflictos críticos
detienen la generación; conflictos menores se documentan en una sección
`Design Validation`.

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Agregar paso de validación de diseño al skill `plan-change` | Alta |
| 2 | Crear sección `Design Validation` en la plantilla de outputs | Media |

**Criterios de aceptación:**
- No se generan tareas con conflictos arquitectónicos críticos sin reportarlo primero.

---

# FASE 3 — Fortalecer implementación TDD

## M-301 — Protocolo de fallo TDD (límite de intentos + reporte)

**Nivel SemVer:** `minor`
**Dependencias:** ninguna

**Estado:** `apply` existe. `build-agent.md` ya define el ciclo RED-GREEN-REFACTOR
como regla no negociable — **no se reescribe ese ciclo aquí**, solo se añade lo que
falta: qué pasa cuando falla repetidamente.

**Problema:** No hay un límite de intentos ni un formato de reporte cuando una tarea
no logra pasar TDD.

**Propuesta:**

```
Límite: 3 intentos.
Si falla el 3º intento → generar TDD Failure Report y detenerse (no marcar la tarea
como completa, no continuar con la siguiente).
```

**Formato del reporte:**

```
Task:
Attempt:
Error:
Suggested investigation:
```

**Requisitos:**
- `build-agent.md` referencia este límite como extensión de su ciclo TDD existente.
- Ninguna tarea se marca completa sin evidencia TDD tras 3 intentos fallidos.

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Agregar sección "Límite de intentos" a `build-agent.md`, referenciando el ciclo ya definido | Alta |
| 2 | Definir plantilla de `TDD Failure Report` | Media |

**Criterios de aceptación:**
- Al 3er intento fallido consecutivo, se genera el reporte y el agente se detiene.

---

## M-302 — Detención explícita tras completar una tarea

**Nivel SemVer:** `patch` (formaliza un comportamiento ya casi-implementado)
**Dependencias:** M-301 (comparten el mismo punto de parada en `build-agent.md`)

**Estado:** `build-agent.md` **ya restringe** el trabajo a una sola tarea por
ejecución ("identificar la tarea actual (una sola)", "nunca implementar más de lo que
pide la tarea actual"). Lo que falta es que, tras completarla, el agente se detenga y
espere instrucción explícita del usuario en vez de continuar automáticamente con la
siguiente tarea pendiente.

**Problema:** No está escrito explícitamente que el agente deba parar y reportar tras
cada tarea — depende de que nadie le pida "seguí con la próxima" en el mismo turno.

**Propuesta:** Añadir un paso final explícito al flujo de `build-agent.md`: al marcar
la tarea como completada, reportar resultado y esperar nueva instrucción.

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Agregar paso "detener y reportar" al final del flujo de `build-agent.md` | Alta |

**Criterios de aceptación:**
- Tras completar una tarea, el agente no continúa automáticamente con la siguiente.

---

# FASE 4 — Mejorar verificación y calidad

## [x] M-401 — Persistir resultados de verificación

**Nivel SemVer:** `minor`
**Dependencias:** M-102 (usa los IDs `SC-NNN` en el formato de salida)

**Problema:** Los resultados de `verify` son temporales (solo pantalla). No hay estado
que `/commit` pueda usar como gate.

**Propuesta:** Archivo persistente `openspec/state/verify-results.json`.

**Formato:**

```json
{
  "change": "add-auth",
  "status": "passed",
  "timestamp": "2026-09-01T14:30:00Z",
  "tasks_total": 5,
  "tasks_passed": 5,
  "tasks_failed": 0,
  "scenarios": [
    {"id": "SC-001", "test": "test_auth_reset", "status": "passed"}
  ]
}
```

**Requisitos:**
- `verify` escribe el archivo después de cada ejecución.
- `/commit` puede leerlo sin re-ejecutar `verify`.
- `archive` puede referenciarlo en el manifiesto.

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Actualizar skill `verify` para escribir `verify-results.json` | Alta |
| 2 | Actualizar `archive` para incluir referencia en el manifiesto | Media |

**Criterios de aceptación:**
- Tras `verify`, existe el archivo con resultados legibles por `/commit`.

---

## [x] M-402 — Mapeo explícito Scenario → Test

**Nivel SemVer:** `minor`
**Dependencias:** M-102

**Problema:** La cobertura Gherkin se valida por coincidencia textual frágil.

**Propuesta:** Convención de nombre de test con prefijo `SC-{NNN}`.

```typescript
test("[SC-001] user password reset with valid email", () => { /* ... */ });
```
```python
def test_sc001_user_password_reset():
    ...
```

**Requisitos:**
- Los tests generados por `/apply` incluyen el prefijo `SC-{NNN}`.
- `verify` mapea `SC-NNN → test → PASS/FAIL` explícitamente en su reporte.

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Documentar la convención en `docs/base-standards.md` | Alta |
| 2 | Actualizar subagentes (`backend`, `frontend`) para generar tests con el prefijo | Media |

**Criterios de aceptación:**
- Cobertura de escenarios medible y auditable vía el prefijo.

---

## M-403 — Sincronizar permisos bash del subagente verify con su documentación

**Nivel SemVer:** `patch`
**Dependencias:** M-401 (la excepción de escritura de evidencia documentada ahí
comparte la misma superficie de permisos que este fix)

**Estado:** Descubierto durante la implementación de M-401 (tarea 1.6 del change
`persist-verify-results`): `ai-specs/agents/verify-agent.md` documenta `pytest`
como bash permitido, pero el permission block de `.opencode/agents/verify.md` no
incluye el patrón `"pytest *"` → cae en `"*": deny` y el subagente `verify` no
puede ejecutar tests Python (Step 5b del skill `verify`) en proyectos Python.

**Problema:** El rol documentado del subagente y su permission block están
desincronizados: la documentación promete capacidades que los permisos niegan.

**Propuesta:** Sincronizar ambos archivos y auditar el mismo patrón en los demás
agentes con permission block (backend, frontend, reviewer, archive): todo comando
documentado en la lista "Bash permitido" del rol debe existir como patrón allow en
el permission block del agente, y viceversa.

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Añadir `"pytest *": allow` al permission block de `.opencode/agents/verify.md` | Alta |
| 2 | Auditar sincronización rol↔permisos en los demás agentes y corregir las brechas encontradas | Media |

**Criterios de aceptación:**
- Verify puede ejecutar `pytest` en un proyecto Python vía el subagente.
- Ninguna entrada de "Bash permitido" en un rol carece de su patrón allow en el
  permission block correspondiente (y viceversa).

---

# FASE 5 — Auditoría adversarial (extensión)

## [x] M-501 — Evolución de `adversarial-review` con auto-refutación estructurada

**Nivel SemVer:** `minor`
**Dependencias:** ninguna

**Estado:** Existe: comando `.opencode/commands/adversarial-review.md`, skill
`ai-specs/skills/code-auditing/SKILL.md`. La auto-refutación **ya existe como
instrucción de una línea** ("Auto-refutación: por cada hallazgo crítico, intentar
refutarlo... Eliminar los que no sobrevivan"). Esta mejora la convierte en un
protocolo estructurado y trazable, no la crea desde cero.

**Problema:** La auto-refutación actual es una heurística implícita — no deja rastro
de qué evidencia se buscó ni por qué se descartó un hallazgo.

**Propuesta:** Formalizar el protocolo y que el reporte final muestre ambos lados
(hallazgo + refutación), no solo el veredicto.

**Protocolo:**

```
Hallazgo (severidad CRITICAL)
  → ¿Puede ser falso positivo?
  → Buscar evidencia contradictoria en el código/tests
  → Decisión final: mantener / descartar (con motivo)
  → Reporte incluye ambos: hallazgo original + refutación
```

**Requisitos:**
- Todo hallazgo `CRITICAL` pasa por el protocolo antes de aparecer en el veredicto final.
- Hallazgos descartados no aparecen en el veredicto, pero sí en un anexo "Descartados"
  con su motivo (para auditar el propio proceso de refutación).

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Formalizar el protocolo de 4 pasos en `code-auditing/SKILL.md`, reemplazando la línea actual | Alta |
| 2 | Actualizar plantilla de reporte para incluir sección "Descartados" | Media |

**Criterios de aceptación:**
- El reporte final muestra el razonamiento de refutación, no solo el veredicto.

---

## [x] M-502 — Persistir el veredicto de `adversarial-review` como gate

**Nivel SemVer:** `minor`
**Dependencias:** M-501 (usa el formato de veredicto que ahí se formaliza), y es
dependencia directa de **M-901** (que lo consume como gate de `/commit`)

**Problema:** El veredicto `SHIP`/`NO-SHIP` de `adversarial-review` es efímero —
existe en la respuesta del agente, pero no hay un archivo que `/commit` pueda
verificar sin volver a ejecutar la auditoría completa.

**Propuesta:** Archivo persistente `openspec/state/adversarial-result.json`.

**Formato:**

```json
{
  "change": "add-auth",
  "verdict": "SHIP",
  "confidence": 0.9,
  "timestamp": "2026-09-01T15:00:00Z",
  "findings_kept": 0,
  "findings_discarded": 2
}
```

**Requisitos:**
- `adversarial-review` escribe este archivo al finalizar.
- `/commit` (ver M-901) lo lee como gate duro.

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Actualizar `adversarial-review` para escribir `adversarial-result.json` | Alta |

**Criterios de aceptación:**
- Tras ejecutar `/adversarial-review`, existe el archivo con el veredicto.

---

# FASE 6 — Pasos obligatorios de calidad

## M-601 — Mandatory steps document

**Nivel SemVer:** `minor`
**Dependencias:** ninguna

**Problema:** Los agentes pueden omitir pasos importantes (tests, verificación manual)
porque no están explícitamente obligados.

**Propuesta:** Documento `docs/openspec-tasks-mandatory-steps.md`, inyectado
automáticamente por `plan-change` en todo `tasks.md` generado.

**Contenido mínimo:**
- Pre-implementación: rama activa sigue convención, estado git limpio.
- Durante: tests unitarios del módulo, test nuevo falla antes de implementar (RED).
- Post: ejecutar `verify`, ejecutar `adversarial-review`.

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Crear `docs/openspec-tasks-mandatory-steps.md` | Alta |
| 2 | Actualizar `plan-change` para inyectar estos pasos en todo `tasks.md` | Alta |
| 3 | Referenciar el documento desde `AGENTS.md` | Media |

**Criterios de aceptación:**
- Todo `tasks.md` generado después del cambio incluye los mandatory steps.

---

# FASE 7 — Sincronización de especificaciones

## M-701 — Implementar `/sync-specs`

**Nivel SemVer:** `minor`
**Dependencias:** ninguna

**Problema:** Las specs principales (`openspec/specs/`) solo se actualizan al
archivar un cambio. Si el cambio es largo, quedan desactualizadas mientras tanto.

**Propuesta:** Comando que sincroniza el delta de specs de un change activo con las
specs principales, sin archivar el cambio.

**Flujo:**

```
/sync-specs
  → Leer openspec/changes/<change>/specs/
  → Leer openspec/specs/
  → Aplicar diferencias (Added/Modified/Removed/Renamed)
  → Reportar cambios aplicados
```

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Crear `ai-specs/skills/sync-specs/SKILL.md` | Media |
| 2 | Crear `.opencode/commands/sync-specs.md` | Media |
| 3 | Registrar el comando en `opencode.json` | Media |

**Criterios de aceptación:**
- `/sync-specs` actualiza specs principales sin archivar, reportando qué cambió.

---

# FASE 8 — Estrategia Git

## M-801 — Reconciliar y documentar la estrategia Git para consumidores

**Nivel SemVer:** `minor` (no toca el flujo Git interno de Specboot, solo añade
recomendación documental para proyectos consumidores)
**Dependencias:** ninguna

**Estado real verificado:** `openspec/specs/git-workflow/spec.md` **ya existe y está
archivada**, respaldando `docs/git-workflow-standards.md`. Ese documento gobierna
cómo se desarrolla **el propio framework Specboot**: rama por ticket creada desde el
HEAD actual, commits Conventional Commits "local-first", cierre por fase, una matriz
de decisión push/PR, y modo local-only. Es un modelo pensado para el ciclo SDD interno
del framework (ticket → change OpenSpec → commits), no para proyectos consumidores
en general.

**Problema real (acotado):** Ese documento define cómo Specboot desarrolla *a sí
mismo*. No dice nada sobre qué estrategia Git recomendar a un **proyecto consumidor**
(ej. WebAppRiff), que no necesariamente sigue el ciclo ticket-por-ticket de Specboot.

**Propuesta:** No reemplazar ni modificar `docs/git-workflow-standards.md` (es
intocable y ya gobierna el propio framework). En su lugar, documentar **GitHub Flow
como recomendación para consumidores**, dejando explícito que son dos documentos con
alcances distintos:

| Documento | Alcance | Modelo |
|---|---|---|
| `docs/git-workflow-standards.md` (ya existe) | Desarrollo del framework Specboot mismo | Rama por ticket, local-first, cierre por fase |
| `docs/consumer-git-workflow.md` (nuevo) | Recomendación para proyectos consumidores | GitHub Flow (`feature/*`, `fix/*`, PR obligatorio, CI en PR y en `main`) |

**Contenido de `docs/consumer-git-workflow.md`:**
- Estrategia de ramas (GitHub Flow): `feature/*`, `fix/*`, `chore/*`, `docs/*`.
- Reglas de PR: título Conventional Commits, CI obligatorio antes de merge.
- Versionado semver, proceso de release y hotfix.
- Nota explícita: "Es una recomendación, no obligatoria — el consumidor puede
  adaptarla. No aplica al desarrollo del propio Specboot, que sigue
  `docs/git-workflow-standards.md`."

**Requisitos:**
1. `docs/consumer-git-workflow.md` creado, sin tocar `docs/git-workflow-standards.md`.
2. Referenciado desde `docs/framework-contract.md` como "recomendación para
   consumidores", distinguiéndolo del estándar interno.
3. `README.md` lo referencia en la sección de personalización.

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Crear `docs/consumer-git-workflow.md` con el contenido de GitHub Flow | Alta |
| 2 | Referenciar desde `docs/framework-contract.md`, distinguiéndolo del estándar interno | Media |
| 3 | Referenciar desde `README.md` | Baja |

**Criterios de aceptación:**
- `docs/git-workflow-standards.md` permanece sin modificaciones.
- `docs/consumer-git-workflow.md` existe y se distingue explícitamente como
  recomendación opcional para consumidores.

---

# FASE 9 — Commit, release y arquitectura CI

## M-901 — Gate duro de commit basado en evidencia

**Nivel SemVer:** `major` (cambia el contrato de `/commit`: de gate blando a gate
duro, puede bloquear flujos que hoy pasan)
**Dependencias:** M-401 (`verify-results.json`), M-502 (`adversarial-result.json`)

**Problema:** `/commit` usa un gate suave (pregunta al usuario si ejecutó verify).
Depende de la honestidad del usuario.

**Propuesta:** `/commit` lee `verify-results.json` y `adversarial-result.json` como
gates duros antes de permitir el commit.

**Requisitos:**
1. `/commit` verifica que `openspec/state/verify-results.json` existe con
   `status: "passed"`.
2. `/commit` verifica que `openspec/state/adversarial-result.json` tiene
   `verdict: "SHIP"`.
3. Si falta alguno → informa y ofrece ejecutarlo antes de continuar.
4. Flag `--force` como escape hatch de emergencia (queda registrado en el commit
   message que se usó `--force`, para auditar su uso).

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Actualizar skill `commit` para leer `verify-results.json` | Alta |
| 2 | Actualizar skill `commit` para leer `adversarial-result.json` | Alta |
| 3 | Agregar flag `--force` con registro en el mensaje de commit | Baja |

**Criterios de aceptación:**
- No se puede hacer commit sin verify passing y adversarial review `SHIP`, salvo
  `--force` explícito y registrado.

---

## M-902 — Evaluar arquitectura CI: ¿un workflow con dos jobs, o dos workflows?

**Nivel SemVer:** `major` si se decide migrar (cambia contrato de `specboot-workflows`);
`n/a` si la evaluación concluye mantener el diseño actual.
**Dependencias:** ninguna

**Estado real verificado:** El framework **ya separa** la validación del framework de
la del proyecto — pero como **dos jobs dentro de un mismo `ci.yml`** (`validate` +
`project-ci`), documentado y testeado en `openspec/specs/specboot-workflows/spec.md`,
con reglas ya probadas (`hashFiles()` solo a nivel de step, no de job; self-tests
condicionados a la presencia de `tests/`). Este diseño ya está implementado, no es
una propuesta.

**Problema real (redefinido):** El plan original asumía que el `ci.yml` actual es
"monolítico" y proponía migrar a dos archivos separados. Esa migración **contradice
directamente** los requisitos ya archivados en `specboot-workflows`, que exigen que
`ci.yml` incluya ambos jobs. No hay evidencia en este audit de que el diseño actual
(2 jobs, 1 archivo) cause un problema real a los consumidores — es la razón por la que
este ticket se convierte en una **evaluación**, no en una migración decidida.

**Propuesta:** Antes de tocar código, responder explícitamente:
1. ¿Qué problema concreto tiene hoy el modelo "2 jobs, 1 archivo" que dos workflows
   separados resolverían? (ej.: ¿un consumidor necesita que el gate del framework
   bloquee su merge de forma distinta a como bloquea su propio CI? ¿necesita ejecutar
   uno sin el otro en algún escenario real?)
2. Si existe un problema real, ¿se resuelve modificando `specboot-workflows` (con su
   propio ciclo `/plan-change` → `/apply` → `/verify` → `/archive`, como cualquier
   otro cambio al framework) o hay una alternativa menor (ej. permisos por job) que
   no requiera romper el contrato?
3. Si NO hay problema real reportado por consumidores, cerrar este ticket como "no
   accionable" y documentar la decisión en `openspec/specs/specboot-workflows/spec.md`
   para que no se reabra sin evidencia nueva.

**Requisitos:**
- Esta evaluación se documenta como un change OpenSpec normal (no se edita `ci.yml`
  directamente) si concluye que sí conviene migrar.
- Cualquier migración debe actualizar `specboot-workflows/spec.md` primero, y ajustar
  `tests/*-test.sh` en el mismo change.

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Recopilar evidencia de consumidores reales sobre fricción con el modelo actual | Media |
| 2 | Documentar la decisión (migrar o mantener) con su justificación | Media |
| 3 | Si se decide migrar: `/plan-change` sobre `specboot-workflows` como change independiente | Baja (condicional) |

**Criterios de aceptación:**
- Existe una decisión documentada y justificada, no un cambio de arquitectura sin
  evidencia.
- Si se mantiene el diseño actual, `specboot-workflows/spec.md` no se modifica y este
  ticket se cierra explícitamente como "evaluado, sin acción".

---

## M-903 — Mejorar checklist de deploy

**Nivel SemVer:** `minor`
**Dependencias:** ninguna

**Problema:** El skill `deploy` es genérico y delega todo a `deploy-standards.md` sin
validaciones mínimas propias.

**Propuesta:** Checklist mínimo obligatorio, independiente del proyecto: tests verdes,
lint sin errores críticos, build exitoso, auditoría de seguridad sin críticos
(`npm audit`/`pip-audit`), rollback definido, change archivado.

**Tareas:**

| # | Tarea | Prioridad |
|---|-------|-----------|
| 1 | Actualizar skill `deploy` con el checklist mínimo | Media |
| 2 | Actualizar plantilla `deploy-standards.md` para incluir rollback | Media |

**Criterios de aceptación:**
- Deploy no se ejecuta sin pasar el checklist mínimo.

---

# Orden de implementación

```
FASE 0 — Reconciliación (base para todo lo demás)
   M-001  Auditoría de funcionalidades existentes (sin código, solo registro)
   M-002  Documentar auth GitHub Packages para consumidores

FASE 4 — Verificación persistente (habilita los gates de Fase 9)
   M-401  Persistir verify-results
   M-402  Mapeo Scenario → Test
   M-403  Permisos bash del subagente verify sincronizados (patch)

FASE 1 — Planificación precisa
   M-101  Enriquecer enrich-us
   M-102  IDs estables SC-NNN (requerido por M-401/M-402)

FASE 5 — Auditoría adversarial (habilita M-901)
   M-501  Auto-refutación estructurada
   M-502  Persistir veredicto como gate

FASE 9 — Commit y CI
   M-901  Gate duro de commit (depende de M-401 + M-502)
   M-902  Evaluación de arquitectura CI (no bloquea el resto)
   M-903  Checklist de deploy

FASE 3 — TDD
   M-301  Protocolo de fallo
   M-302  Detención explícita

FASE 2 — Generación OpenSpec
   M-201  Suggested Path / Test Path
   M-202  Validación de coherencia de diseño

FASE 6 — Pasos obligatorios
   M-601  Mandatory steps document

FASE 7 — Sync specs
   M-701  /sync-specs

FASE 8 — Git para consumidores
   M-801  docs/consumer-git-workflow.md (sin tocar el estándar interno)
```

Nota: el orden respeta las dependencias declaradas en cada ticket (M-102 antes de
M-401/M-402; M-401+M-502 antes de M-901). Fases 3, 2, 6, 7 y 8 no tienen dependencias
cruzadas con el resto, por lo que su orden relativo es flexible.

---

# Resultado esperado

Después de implementar este roadmap, Specboot tendrá:

- **Reconciliado:** ningún ticket duplica funcionalidad existente ni colisiona con IDs
  o specs ya archivadas.
- **Planificatorio:** tickets con estimación, riesgo, dependencias y nivel SemVer
  declarados desde `enrich-us`.
- **Verificable:** `verify` produce evidencia persistente con mapeo scenario→test.
- **Seguro:** auditoría adversarial con auto-refutación estructurada y veredicto
  persistente antes de archivar.
- **Disciplinado:** mandatory steps evitan omisiones; `/commit` tiene gates duros
  basados en evidencia, no en honestidad.
- **CI evaluado, no re-arquitecturado sin evidencia:** la separación framework/proyecto
  se revisa con datos reales antes de romper el contrato ya probado.
- **Git documentado en dos niveles:** el estándar interno del framework
  (`git-workflow-standards.md`) permanece intocado; los consumidores reciben una
  recomendación separada y explícitamente opcional.
