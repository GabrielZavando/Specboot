# Tasks — SPECBOOT-HARDEN-04: protect-consumer-ci

> Rastro: REQ-### ↔ SC-### definidos en `requirements.md` / `scenarios.md`.
> Este repo usa `.specboot.json` con `services: ["."]` y sin mapa `layers`;
> los paths usan las carpetas reales del framework (raíz del repo, `tests/`,
> `docs/`). TDD: test en RED antes de cada pieza de producción.
> La ejecución post-merge (REQ-007) NO es tarea: vive en la sección
> `## Post-merge release runbook (non-gating)` al final de este archivo y no
> bloquea ni es afirmada por `/verify`, `/adversarial-review`, `/archive` ni
> `/commit`.

## Mandatory Steps

Esta checklist es **obligatoria, no sugerida**. Aplica a toda tarea de
implementación ejecutada vía `/apply`, tanto en el propio framework Specboot
(dogfooding) como en cualquier proyecto consumidor.

### Pre-implementación

Antes de escribir la primera línea de la tarea actual:

- [x] La **rama activa** sigue la convención vigente del proyecto (ej.
  `feature/*`, `fix/*`); trabajar sobre ella, nunca directamente sobre la rama
  principal.
- [x] Estado **git limpio**: sin cambios sin commitear (ni staged) antes de
  empezar; si hay trabajo en curso, resolverlo primero.
  (Verificado en el pre-flight del primer `/apply`: suciedad limitada a
  `openspec/changes/protect-consumer-ci/**` — artefactos del plan permitidos;
  marker: `openspec/state/apply-preflight-protect-consumer-ci.json`.)

### Durante la implementación

- [x] **Test nuevo que falla antes de implementar (RED)**: escribir el test del
  escenario (`SC-NNN`) y verificar que falla antes de escribir código de
  producción. (Aplicado en Tareas 1–3: RED observado y reportado en cada una.)
- [x] Ejecutar los **tests unitarios del módulo** tocado mientras se itera
  (ciclo RED-GREEN-REFACTOR), no solo al final. (Suites del módulo ejecutadas
  en cada tarea; regresión completa en Tarea 5.)

### Post-implementación

Antes de dar la tarea por cerrada:

- [x] **Ejecutar `verify`**: la verificación del change corre y produce
  evidencia persistente (`openspec/state/verify-results.json`).
- [x] **Ejecutar `adversarial-review`**: la auditoría adversarial corre y
  produce veredicto persistente (`openspec/state/adversarial-result.json`).

> Ambos pasos post alimentan los gates duros de `/commit` (M-901): sin
> `PASS` + `SHIP` vigentes para el change activo, el commit bloquea.

---

## 1. Allowlist de fingerprints históricos del CI de consumidor (REQ-001)

Prioridad: crítica | Capa: infrastructure | Estimación: media
Suggested Path: `specboot.sh` | Test Path: `tests/specboot-update-test.sh`

- [x] 1.1 **RED** — Extender `tests/specboot-update-test.sh` con la suite de
  provenancia del CI de consumidor (espejo del Test 13 de `release.yml`):
  pinneear las variantes distribuidas desde 0.10.0 (`.github/workflows/ci.yml`
  @ tag `v0.10.0`, último cambio `cf50b18`; `templates/github/workflows/consumer-ci.yml`
  @ `0c586db`), re-derivar cada fingerprint con `git show <sha>:<path> |
  git hash-object --stdin` y asertar que la allowlist de `specboot.sh` contiene
  cada uno, que ninguna entrada existe fuera del conjunto histórico (no
  invented hashes) y que está documentada como contenido inmutable nunca
  derivado del `ci.yml` interno (SC-011). **RED observado: 5 asserts SC-011 en
  fallo (67 passed / 5 failed).**
- [x] 1.2 **GREEN** — En `specboot.sh`: añadir `KNOWN_CONSUMER_CI_FINGERPRINTS=(...)`
  con comentario de proveniencia por entrada (hash + commit/Estado + motivo)
  y `is_known_consumer_ci_fingerprint()`, siguiendo el patrón de
  `KNOWN_RELEASE_FINGERPRINTS` (SPECBOOT-HARDEN-02, REQ-002). Suggested Path:
  `specboot.sh` · Test Path: `tests/specboot-update-test.sh` **Provenancia:
  v1 `99394ca6…` @ `cf50b18` (ci.yml interno copiado por update pre-aislamiento,
  distribuida en 0.10.0); v2 `a0041c33…` @ `0c586db` (plantilla consumer-ci.yml,
  primera distribución 0.11.0).**
- [x] 1.3 Ejecutar `bash tests/specboot-update-test.sh` en verde. **Verde:
  72 passed / 0 failed (Test 13 de release.yml sigue en verde).**

## 2. Política segura de actualización del ci.yml de consumidores (REQ-002, REQ-003)

Prioridad: crítica | Capa: infrastructure | Estimación: alta
Suggested Path: `specboot.sh` | Test Path: `tests/specboot-update-test.sh`

- [x] 2.1 **RED** — Tests en `tests/specboot-update-test.sh` (Test 15, sub-bloques
  15a–15g; fixtures `make_template`/`make_project`): consumidor sin `ci.yml` →
  instala la plantilla y lo informa (SC-001); cada variante histórica exacta →
  respaldo en `.specboot-backup-*/` ANTES y reemplazo por la plantilla actual con
  reporte de la reparación (SC-002); `ci.yml` modificado → byte-for-byte
  intacto + advertencia clara de resolución explícita (SC-003); `ci.yml`
  ajeno → intacto + advertencia (SC-012); workflows personalizados → intactos
  en init y update (SC-004); coincidencia exacta con la plantilla actual →
  no-op idempotente sin advertencias (SC-009); ejecución con framework en
  `node_modules` → misma política (SC-010). **RED observado: 14 asserts nuevos
  en fallo (94 passed / 14 failed) con el `cp` incondicional.**
- [x] 2.2 **GREEN** — En `specboot.sh`: nueva función de política tri-estado
  `update_consumer_ci_safely <fw_dir> <dst> <backup_dir>` (instalar si falta /
  no-op si ya es la plantilla exacta / respaldar+reemplazar si variante conocida
  / preservar+advertir si modificada o ajena; precedencia: exacto-plantilla
  ANTES de allowlist, p.ej. la variante v2 real —idéntica a la plantilla— obtiene
  no-op idempotente), reemplazando la copia incondicional de
  `update_github_artifacts()`; el respaldo ocurre antes del reemplazo (patrón
  `repair_legacy_release`); el PR template mantiene su comportamiento actual;
  `run_update_project()` (6b) cableado con `backup_dir`. Suggested Path:
  `specboot.sh` | Test Path: `tests/specboot-update-test.sh`
- [x] 2.3 Ejecutar en verde `bash tests/specboot-update-test.sh`,
  `bash tests/specboot-init-test.sh` y `bash tests/workflow-isolation-test.sh`.
  **Verde: 108/0 update · 34/0 init · 9/0 workflow-isolation (regresión extra:
  `tests/run-all.sh` 29/0).**

## 3. Contrato de release-bump.sh (REQ-006)

Prioridad: crítica | Capa: infrastructure | Estimación: media
Suggested Path: `release-bump.sh`, `update.sh`, `docs/versioning-standard.md` | Test Path: `tests/release-bump-test.sh`

- [x] 3.1 **RED** — `tests/release-bump-test.sh`: nuevo fixture git con bump
  sin commit → asertar que NO existe ningún tag (SC-006) e invertir el assert
  M-912 SC-001 (hoy exige tag tras bump); asserts de sincronía de
  `package-lock.json` (versión raíz + `packages[""]`, SC-005); fixture con
  `package-lock.json` corrupto → exit != 0 y ningún archivo escrito
  parcialmente (atomicidad, SC-005). **RED observado: release-bump-test
  23 passed / 9 failed (lock sin sync, tag creado con cambios sin commit,
  atomicidad ausente); update-test 4 passed / 1 failed (exigía tag).**
- [x] 3.2 **GREEN** — `release-bump.sh`: eliminado el bloque de creación de tag
  (M-912) y corregida la cabecera (nuevo contrato: sin tags — el tag pertenece
  a la fase post-merge); bloque atómico de node extendido: parsea/valida
  `package.json` + `.specboot.json` + `package-lock.json` (raíz +
  `packages[""].version`) ANTES de escribir cualquiera; saltado con nota
  (`package-lock.json not found — skipped`) si no existe; aborta sin escrituras
  ante lock corrupto. Misma política en `update.sh --bump`: `git tag` y
  mensajería de tags eliminados de `do_bump()`; cabecera actualizada. Suggested
  Path: `release-bump.sh`, `update.sh` | Test Path: `tests/release-bump-test.sh`
- [x] 3.3 **GREEN** — `docs/versioning-standard.md`: §6.1 (escritura de versión
  solo vía `bash release-bump.sh X.Y.Z`; bump atómico de 3 archivos, nunca
  crea tags) y §Política de tags reescrita (mantenedor crea `v{X.Y.Z}` tras el
  merge apuntando exactamente al commit del bump en `main`; push solo con
  autorización explícita; GitHub Release manual con el texto del CHANGELOG;
  `release.yml` publica idempotentemente sin depender de tags); barrido sin
  claims de tags obsoletos. Delta `specs/release-tagging/spec.md` del change
  verificado alineado (REMOVED tag-en-bump / MODIFIED política / ADDED
  no-tags + atomicidad). Suggested Path: `docs/versioning-standard.md` |
  Test Path: `tests/release-bump-test.sh` (SC-003 tokens actualizados:
  `post-merge` / `GitHub Release` / `nunca crea tags`)
- [x] 3.4 Ejecutar `bash tests/release-bump-test.sh` y
  `bash tests/update-test.sh` en verde. **Verde: 32/0 release-bump · 5/0
  update-test (SC-004 backfill intacto) · sanity `tests/specboot-update-test.sh`
  108/0.**

## 4. Preparar 0.11.0: CHANGELOG + bump canónico (REQ-005)

Prioridad: alta | Capa: documentation | Estimación: baja

- [x] 4.1 Redactar la sección `## [0.11.0] - 2026-09-22` en `CHANGELOG.md`
  (formato Keep a Changelog; `### Breaking changes: None` si no hay rupturas)
  documentando los cambios acumulados desde 0.10.0: aislamiento de workflows
  internos; reparación de `release.yml` heredados; contratos operacionales de
  agentes y comandos; pre-flight reanudable; resolución correcta del proyecto
  objetivo; historial completo en los jobs de validación; protección del CI
  personalizado de consumidores (este change). **Escrito: `## [0.11.0] -
  2026-09-22` entre Unreleased y 0.10.0; Changed (2: protección CI + contrato
  de tags del bump) / Added (5: aislamiento, reparación release.yml,
  contratos operacionales, pre-flight reanudable, FW-ENV env-config) / Fixed
  (3: resolución de target, fetch-depth 0, sync de package-lock.json
  atómico) / Breaking changes: None.** Suggested Path: `CHANGELOG.md`
  | Test Path: no aplica (contenido documental; el guard del bump valida su
  existencia)
- [x] 4.2 Ejecutar `bash release-bump.sh 0.11.0` (mecanismo canónico) y
  verificar sincronía: `package.json` `version`, `package-lock.json` (raíz +
  `packages[""]`) y `.specboot.json` `frameworkVersion` = `0.11.0`; sin tags
  creados (SC-005/SC-006). **Ejecutado: exit 0; los tres archivos → 0.11.0
  (verificado con node -p y lectura directa); `git tag -l v0.11.0` vacío
  (tags históricos intactos); `npm install` no fue ejecutado.** Suggested
  Path: `package.json`, `package-lock.json`, `.specboot.json` | Test Path:
  `tests/release-bump-test.sh`

## 5. Regresión completa y validación final (REQ-004)

Prioridad: alta | Capa: infrastructure | Estimación: baja

- [x] 5.1 `bash tests/specboot-update-test.sh` — verde (SC-001..SC-003,
  SC-009..SC-012). **108/0**
- [x] 5.2 `bash tests/specboot-init-test.sh` — verde (SC-004 en init). **34/0**
- [x] 5.3 `bash tests/release-bump-test.sh` — verde (SC-005, SC-006). **32/0**
- [x] 5.4 `bash tests/release-workflow-test.sh` — verde (intocable; cubre el
  contrato de idempotencia de SC-008 verificable pre-merge). **22/0**
- [x] 5.5 `bash tests/workflow-isolation-test.sh` — verde (SC-004; tarball sin
  `.github/**`, con plantillas de consumidor). **9/0**
- [x] 5.6 `bash tests/run-all.sh` — suite completa en verde. **29 archivos de
  test, 0 fallos**
- [x] 5.7 `bash specboot.sh --ci` — **Errores: 0, Warnings: 0** (frameworkVersion
  0.11.0 = instalada)
- [x] 5.8 `bash check-refs.sh` — **0 errores** (20 referencias verificadas, 12
  skills registrados)
- [x] 5.9 `npm pack --dry-run` — tarball `gabrielzavando-specboot-0.11.0.tgz`
  (93 archivos): sin `.github/**`, con `templates/github/**` + `release-bump.sh`.
  Suggested Path (5.1–5.9): no aplica (ejecución de verificación) | Test Path:
  no aplica

> **Regresión final: 9/9 en verde con cero ajustes** (ningún assert obsoleto,
> ningún TDD Failure Report). La fase de implementación (Tareas 1–5) está
> regression-clean.

> **Total de tareas de implementación: 1–8.** La fase de implementación
> (Tareas 1–5) quedó regression-clean en su cierre; las Tareas 6–7 corrigen
> hallazgos post-auditoría adversarial (backup verificable del `ci.yml` y
> resiliencia de la auditoría) y la Tarea 8 cierra el WARNING abierto del
> reviewer (reemplazo verificable del `ci.yml` + clarificación de
> `--no-backup`). No hay tarea 9: la ejecución post-merge vive en el runbook
> independiente de abajo y no cuenta como tarea de implementación.

## 6. Respaldo verificable del ci.yml de consumidores (REQ-002 — correcta post-auditoría, SC-013)

Prioridad: crítica | Capa: infrastructure | Estimación: baja
Suggested Path: `specboot.sh` | Test Path: `tests/specboot-update-test.sh`

- [x] 6.1 **RED** — Test 16 en `tests/specboot-update-test.sh` (SC-013):
  forzar el fallo del respaldo de forma determinista (shim de `date` con
  timestamp fijo → nombre del backup dir predecible; archivo regular
  pre-creado en `<backup_dir>/.github` → `mkdir -p .../workflows` y el `cp`
  fallan), con un `ci.yml` de variante histórica v1: asertar que el update
  sale con estado no exitoso (exit != 0), que ci.yml permanece
  byte-for-byte intacto y que se emite el error claro (❌ respaldo fallido,
  sin reemplazo). **RED observado: 108 passed / 3 failed (exit 0, ci.yml
  reemplazado, sin error).**
- [x] 6.2 **GREEN** — En `specboot.sh` (`update_consumer_ci_safely`, rama 3):
  respaldo con `cp -p` (conserva metadatos), verificación explícita del
  resultado del respaldo (`mkdir` + `cp` con chequeo de estado); si el
  respaldo falla: NO reemplazar ci.yml (conservar el original byte a
  byte), emitir error claro (❌ con el path del respaldo fallido) y
  devolver estado no exitoso (`return 1`); propagación: `update_github_artifacts`
  devuelve 1 y `run_update_project` (6b) se detiene con exit != 0 y mensaje
  claro (patrón de la validación post-update). Comportamiento sin cambio
  para `--no-backup` (sin respaldo solicitado) y para los caminos felices.
- [x] 6.3 Ejecutar `bash tests/specboot-update-test.sh` en verde y la
  regresión completa `bash tests/run-all.sh`. **Verde: 111/0 update
  (3 asserts SC-013 nuevos) · run-all 29/0.**

## 7. Resiliencia de la auditoría adversarial (REQ-008 — correcta post-auditoría, SC-014)

Prioridad: alta | Capa: documentation | Estimación: baja
Suggested Path: `ai-specs/skills/code-auditing/SKILL.md` | Test Path:
`tests/adversarial-state-test.sh`

> Directiva del orquestador (post-fallo silencioso del reviewer ×2): las
> herramientas opcionales ausentes se registran como skip y el reviewer
> persiste su veredicto igualmente. No instalar `eslint` ni
> `dependency-cruiser` solo para desbloquear la auditoría.

- [x] 7.1 **RED** — Token asserts en `tests/adversarial-state-test.sh`
  (SC-014): la skill `code-auditing` documenta que las herramientas
  opcionales ausentes (binario no disponible en `node_modules/.bin` o
  ejecución fallida) se registran como skip (nunca como fallos ni
  hallazgos; no `npx` contra paquetes ausentes) y que la persistencia
  (Paso 7) es incondicional — el veredicto se persiste SIEMPRE, incluidos
  NO-SHIP y corridas con skips; el JSON persistido mantiene su esquema fijo.
  **RED observado: 16 passed / 1 failed (token del contrato ausente).**
- [x] 7.2 **GREEN** — `ai-specs/skills/code-auditing/SKILL.md` (Paso 2):
  regla explícita de skip registrado para herramientas opcionales ausentes
  (verificación de disponibilidad de solo lectura, p. ej.
  `ls node_modules/.bin`), skip nunca bloquea la persistencia, y el lente
  adversarial (Pasos 3–4) es manual y obligatorio aunque TODAS las
  herramientas opcionales estén ausentes. El JSON persistido conserva su
  esquema `schema_version: 1` exacto (los skips viven solo en el reporte
  en pantalla).
- [x] 7.3 Ejecutar `bash tests/adversarial-state-test.sh` en verde y la
  regresión completa `bash tests/run-all.sh`. **Verde: 17/0
  adversarial-state (2 asserts SC-014 nuevos) · run-all 29/0.**

## 8. Reemplazo verificable del ci.yml + clarificación de --no-backup (REQ-002 — correcta post-auditoría, WARNING + INFO del reviewer, SC-015)

Prioridad: crítica | Capa: infrastructure | Estimación: baja
Suggested Path: `specboot.sh` | Test Path: `tests/specboot-update-test.sh`

> WARNING del reviewer (espejo del caso 3): el `cp` de reemplazo no se
> verificaba; un write parcial/corrupto se reportaba como éxito. INFO: con
> `--no-backup` (backup_dir vacío) una variante conocida se reemplaza sin
> respaldo — clarificar que es opt-out explícito, no excepción silenciosa.

- [x] 8.1 **RED** — Test 17 en `tests/specboot-update-test.sh` (SC-015):
  (a) fallo del reemplazo: shim de `cp` que falla únicamente cuando el origen
  es la plantilla del consumidor (PATH stub que delega en `/bin/cp` salvo
  cuando la fuente es `*/templates/github/workflows/consumer-ci.yml`) →
  asertar update exit != 0, error claro, sin "reparado/actualización
  exitosa" de ci.yml; (b) éxito verificado: reemplazo normal →
  verificar byte-for-byte que `ci.yml` == plantilla esperada y solo
  entonces PASS; (c) `--no-backup`: variante histórica reemplazada con
  reemplazo verificado (exit 0). **RED observado: 119 passed / 1 failed
  (SC-015a "update exits 0 despite the ci.yml replacement failure" — el
  cp de reemplazo fallido solo hacía warn y retornaba 0, éxito falso).**
- [x] 8.2 **GREEN** — En `specboot.sh` (`update_consumer_ci_safely`, rama 1
  install y rama 3 replace): verificar el `cp` (install/replace) y, tras
  copiar, comprobar que el destino final coincide byte-for-byte con la
  plantilla esperada (`cmp -s "$ci_dst" "$ci_src"`) ANTES de `pass`; si el
  `cp` falla o no coincide → error claro (❌) + `return 1` (nunca éxito
  falso ni write parcial reportado como éxito); propagación ya presente por
  `update_github_artifacts` y `run_update_project` (exit != 0).
  Comportamiento sin cambio para `--no-backup` (reemplazo verificado sin
  respaldo) y para los caminos felices.
- [x] 8.3 **Documentación** — `docs/versioning-standard.md` §5.1 (política
  tri-estado + `--no-backup` como opt-out explícito; la verificación del
  reemplazo sigue aplicando con `--no-backup`), `docs/framework-contract.md`
  paso 5 (backup; `--no-backup` explícito), help de `specboot update`
  (`--no-backup` opt-out explícito del respaldo).
- [x] 8.4 Ejecutar `bash tests/specboot-update-test.sh` en verde y la
  regresión completa `bash tests/run-all.sh`. **Verde: 120/0 update
  (3 asserts SC-015 nuevos) · run-all 29/0.**

---

## Post-merge release runbook (non-gating)

> **Esta sección NO es parte de las tareas de implementación** (no suma al
> total de tareas, no lleva prioridad/capa/estimación) y **NO bloquea ni es
> afirmada por** `/verify`, `/adversarial-review`, `/archive` ni `/commit`.
> `/verify` **no debe afirmar** que el tag, el GitHub Release o la publicación
> post-merge fueron ejecutados: la evidencia de verificación cubre solo lo
> verificable antes del merge (contrato del workflow, política de tags,
> idempotencia, documentación — SC-007/SC-008 re-escopados y REQ-007).
> Cada paso del runbook es una acción post-merge que requiere **confirmación
> explícita separada del usuario**, y nunca se ejecuta durante `/apply`,
> `/verify`, `/adversarial-review`, `/archive` ni el commit de la rama.

Pasos a ejecutar solo después de fusionar el PR (runbook operativo, sin
checkboxes deliberadamente — no son tareas de implementación):

1. Confirmar que el workflow `Release` publicó
   `@gabrielzavando/specboot@0.11.0` (run verde del push a `main`).
2. Actualizar la rama local `main` (`git checkout main && git pull`).
3. Crear el tag `v0.11.0` apuntando exactamente al commit de `main` que
   contiene el bump — solo con autorización explícita.
4. Publicar el tag (`git push origin v0.11.0`) — solo con autorización
   explícita.
5. Crear el GitHub Release `v0.11.0` con la sección `## [0.11.0]` del
   CHANGELOG como notas — solo con autorización explícita.
6. Confirmar que el retrigger `release: published` es idempotente: el run
   provocado omite la publicación (check `npm view`) y termina en verde.

Suggested Path: no aplica (proceso post-merge) | Test Path: no aplica
