# Tasks — fix-consumer-ci-yaml

Nomenclatura de rutas: `.specboot.json` declara `services: ["."]` y
`stack: "framework"` (sin `layers` map) — rutas relativas a la raíz; capa
`infrastructure` para este change de CI/release.

## Task 1 — RED: prueba de regresión de sintaxis YAML de la plantilla

**Priority**: P0 · **Layer**: infrastructure · **Estimate**: ~30 min

- [x] **Subtarea 1.1**: crear `tests/consumer-ci-yaml-test.sh` siguiendo el
  patrón de casa de `tests/consumer-ci-auth-test.sh` (contadores pass/fail,
  precondition de existencia, salida `0` si todo pasa / `1` si no): validación
  `python3 -c "import yaml; yaml.safe_load(open('templates/github/workflows/consumer-ci.yml'))"`
  (SC-001) + check dedicado que falla si un valor `name` no entrecomillado
  contiene `: ` — regex sobre líneas `- name: ...` que excluya valores
  entrecomillados (SC-002)
- [x] **Subtarea 1.2**: verificar RED — el test falla (exit 1) contra la
  plantilla 0.11.0 actual ANTES de tocarla (la línea 42 contiene `make ci: `
  sin comillas)
- [x] **Subtarea 1.3**: confirmar que `tests/run-all.sh` auto-descubre el test
  nuevo (glob `tests/*-test.sh`, sin registro manual; `.npmignore` excluye
  `tests/` del tarball)

**Suggested Path**: `tests/consumer-ci-yaml-test.sh`
**Test Path**: `tests/consumer-ci-yaml-test.sh`

## Task 2 — Fix: YAML válido en la plantilla consumer-ci

**Priority**: P0 · **Layer**: infrastructure · **Estimate**: ~15 min

- [x] **Subtarea 2.1**: corregir la línea 42 de
  `templates/github/workflows/consumer-ci.yml` — reformular el `name` del step
  sin `: ` (estilo de casa del workflow interno: `Project gate (make ci + refs
  + solid-lint + lint + test + audit)`) o entrecomillar el valor completo;
  ningún otro cambio en el workflow (REQ-005)
- [x] **Subtarea 2.2**: verificar GREEN — `tests/consumer-ci-yaml-test.sh`
  pasa (exit 0) y el diff de la plantilla muestra solo el cambio del `name`
  (job `ci`, steps y wiring de consumidor intactos — REQ-005)

**Suggested Path**: `templates/github/workflows/consumer-ci.yml`
**Test Path**: `tests/consumer-ci-yaml-test.sh`

## Task 3 — Release patch 0.11.1

**Priority**: P1 · **Layer**: infrastructure · **Estimate**: ~20 min

- [x] **Subtarea 3.1**: escribir la entrada `## [0.11.1] - <fecha del release>`
  en `CHANGELOG.md` (bajo `## [Unreleased]`, formato Keep a Changelog): sección
  `### Fixed` con el fix de la plantilla + guard nuevo; `### Breaking changes`
  con `None` (matriz §3 de `docs/versioning-standard.md`: fix de bug sin cambio
  de interfaz → patch)
- [x] **Subtarea 3.2**: ejecutar `bash release-bump.sh 0.11.1` — bump canónico
  atómico de `package.json`, `package-lock.json` y `.specboot.json` (nunca a
  mano ni con `npm version`; sin tags, sin commit — `docs/versioning-standard.md` §6.1)
- [x] **Subtarea 3.3**: verificar la sincronía de versión — los tres archivos
  en 0.11.1

**Suggested Path**: `package.json` (junto a `package-lock.json`, `.specboot.json` y `CHANGELOG.md`)
**Test Path**: `tests/release-bump-test.sh` + `tests/package-files-test.sh` + `tests/version-resolution-test.sh`

## Task 4 — Verificación integral post-implementación

**Priority**: P1 · **Layer**: infrastructure · **Estimate**: ~15 min

- [x] **Subtarea 4.1**: `bash tests/run-all.sh` — suite completa en verde
  (incluye el test nuevo de sintaxis YAML)
- [x] **Subtarea 4.2**: `bash specboot.sh --ci` (0 errores) y
  `bash check-refs.sh` (0 errores)
- [x] **Subtarea 4.3**: `npm pack --dry-run` — el tarball incluye
  `templates/github/workflows/consumer-ci.yml` corregida (sin workflows internos)

**Suggested Path**: no aplica (solo verificación)
**Test Path**: no aplica (solo verificación)

## Task 5 — Cobertura de asserts SC-003/SC-004 (resuelve el PARTIAL de /verify)

**Priority**: P0 · **Layer**: infrastructure · **Estimate**: ~30 min

- [x] **Subtarea 5.1**: extender `tests/consumer-ci-yaml-test.sh` con el assert
  funcional `[SC-003]` (según el texto real del escenario: consumidor con el
  workflow de Specboot 0.11.0 recibe vía `specboot update` la plantilla
  corregida y el YAML resultante es válido) — simulación de consumidor en
  fixture temporal (`.specboot.json` con frameworkVersion 0.11.0 y el
  `.github/workflows/ci.yml` ROTO derivado de git history:
  `git show v0.11.0:templates/github/workflows/consumer-ci.yml`) +
  `specboot update --template "$ROOT"` → asserts: exit 0; el YAML resultante
  es válido (`yaml.safe_load`); el contenido resultante es la plantilla
  corregida actual; la variante rota quedó respaldada en `.specboot-backup-*/`
  antes del reemplazo (política tri-estado, `docs/versioning-standard.md` §5.1);
  y la variante fixture derivada de git es la rota (detección de regresión real)
- [x] **Subtarea 5.2**: extender el mismo test con el assert `[SC-004]` de la
  restricción de alcance (según el texto real del escenario: solo cambian la
  plantilla, el test nuevo, los archivos de versión, el CHANGELOG y los
  artefactos OpenSpec): (1) working-tree scope — todo path en
  `git status --porcelain` debe estar dentro del alcance permitido del change;
  cualquier path fuera → FAIL listándolo; (2) workflows internos sin cambios
  desde el baseline v0.11.0 (`git diff --quiet v0.11.0 HEAD -- .github/workflows/`)
- [x] **Subtarea 5.3**: demostración RED segura — revertir la plantilla del
  working tree a la variante 0.11.0 (backup previo del fix en /tmp), ejecutar
  el test (RED: los asserts detectan la regresión real — el YAML resultante
  deja de ser válido), restaurar el fix y verificar GREEN
- [x] **Subtarea 5.4**: ejecutar el test del change y la suite completa
  (`bash tests/run-all.sh`)

## Task 6 — Refinamiento post-auditoría: distinguir restricción transitoria de contrato permanente

**Priority**: P0 · **Layer**: infrastructure · **Estimate**: ~15 min

Origen: WARNING de `/adversarial-review` (SHIP, 2026-09-24) — los asserts
SC-004 del test permanente inspeccionan el working tree y comparan los
workflows internos contra v0.11.0: restricciones TRANSITORIAS de este change
que, tras el archive, dispararían falsos "scope violation" recurrentes en
cambios futuros.

- [x] **Subtarea 6.1**: actualizar `scenarios.md` SC-004 y `requirements.md`
  REQ-005 para documentar la distinción: la restricción de alcance es
  transitoria de este change, su verificación es la revisión del diff actual
  (evidencia documentada por `/verify`), no un contrato permanente del test
- [x] **Subtarea 6.2**: eliminar del test permanente
  `tests/consumer-ci-yaml-test.sh` los 2 asserts `[SC-004]` (working-tree
  scope + baseline v0.11.0), conservando `[SC-001]`, `[SC-002]` y los 5 asserts
  funcionales `[SC-003]`; actualizar el header del test con el rationale
- [x] **Subtarea 6.3**: ejecutar `bash tests/consumer-ci-yaml-test.sh` (7/7) y
  `bash tests/run-all.sh` (30/30)

**Suggested Path**: `tests/consumer-ci-yaml-test.sh`
**Test Path**: `tests/consumer-ci-yaml-test.sh`

## Task 7 — Verificación transitoria de SC-004 (script propio del change)

**Priority**: P0 · **Layer**: infrastructure · **Estimate**: ~15 min

Origen: estado `PARTIAL` de `/verify` (SC-004 con evidencia débil tras retirar
los asserts del test permanente) — resuelto SIN Gate-Bypass y SIN volver a
incorporar asserts a `tests/run-all.sh`.

- [x] **Subtarea 7.1**: crear
  `openspec/changes/fix-consumer-ci-yaml/verification/sc-004-scope-test.sh` —
  script ejecutable DENTRO del change folder (fuera de `tests/`, así
  `tests/run-all.sh` — glob `tests/*-test.sh` — nunca lo ejecuta: la
  restricción sigue transitoria y se archiva junto con el change, evitando
  contratos permanentes sobre tickets futuros) que produce evidencia fuerte
  `[SC-004]`: (1) working-tree scope — fallar si `git status --porcelain`
  (staged y unstaged) contiene archivos modificados o nuevos fuera del alcance
  permitido del change, listando cada path inesperado; (2) `.github/workflows/`
  sin cambios vs v0.11.0 incluyendo staged y unstaged (diff committed + estado
  del working tree); (3) exit 0 con salida explícita `[SC-004]` cuando ambas
  comprobaciones pasen
- [x] **Subtarea 7.2**: ejecutar el script (`bash
  openspec/changes/fix-consumer-ci-yaml/verification/sc-004-scope-test.sh`),
  `bash tests/consumer-ci-yaml-test.sh`, `bash tests/run-all.sh` y
  `openspec validate fix-consumer-ci-yaml`

**Suggested Path**: `openspec/changes/fix-consumer-ci-yaml/verification/sc-004-scope-test.sh`
**Test Path**: `openspec/changes/fix-consumer-ci-yaml/verification/sc-004-scope-test.sh`

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

### Durante la implementación

- [x] **Test nuevo que falla antes de implementar (RED)**: escribir el test del
  escenario (`SC-NNN`) y verificar que falla antes de escribir código de
  producción.
- [x] Ejecutar los **tests unitarios del módulo** tocado mientras se itera
  (ciclo RED-GREEN-REFACTOR), no solo al final.

### Post-implementación

Antes de dar la tarea por cerrada:

- [x] **Ejecutar `verify`**: la verificación del change corre y produce
  evidencia persistente (`openspec/state/verify-results.json`).
- [x] **Ejecutar `adversarial-review`**: la auditoría adversarial corre y
  produce veredicto persistente (`openspec/state/adversarial-result.json`).

> Ambos pasos post alimentan los gates duros de `/commit` (M-901): sin
> `PASS` + `SHIP` vigentes para el change activo, el commit bloquea.
