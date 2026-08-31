# Plan de Implementación — Reconciliación del framework Specboot (post-fases 0–6)

> Estado: **plan aprobado pendiente de ejecución**.
> Modalidad: SDD (Spec-Driven Development) — todo cambio actualiza primero artefactos
> OpenSpec, luego código. El propio framework se desarrolla con su flujo (dogfooding).
> Alcance: cerrar la **Fase 6 a medio ejecutar** + limpiar clutter de paths + reconciliar
> documentación y specs activas. **No es un rediseño**: es una pasada de cierre.

---

## 0. Resumen ejecutivo

El plan de fases 0–6 de Specboot está **sustancialmente cumplido** y el dogfooding funciona,
pero la **Fase 6 quedó a medio ejecutar**: `release.yml` se añadió sin eliminar el
`publish.yml` que sustituía, y dos specs activas (`npm-distribution`, `workflow-node-upgrade`)
siguen apuntando al modelo obsoleto. Sumado al clutter `Digital/` + `.openspec/` (paths no
versionados pero presentes en disco) y a inconsistencias del README/contrato, el repo
necesita **una pasada de reconciliación** estructurada en las fases de abajo.

El plan se ejecuta como **un único change OpenSpec** (`cleanup-publish-and-junk`) que agrupa
todas las correcciones, porque son correcciones interdependientes del mismo problema de
cierre (Fase 6 inconclusa + residuos). Las "fases" de este documento son **grupos lógicos
de tareas dentro del change**, no changes separados.

### Propiedades rectoras — estado de cumplimiento

| # | Propiedad | Estado | Evidencia |
|---|-----------|--------|-----------|
| 1 | Stack-agnostic y mono/multi-repo agnostic | ✅ Cumple | `Makefile` lee `services`/`stack` de `.specboot.json`; `stack: "framework"` skip limpio de app-lint; `templates/ci/` cubre node+python+angular+astro |
| 2 | Distribuido solo como npm `@gabrielzavando/specboot` | ✅ Cumple | `package.json` `files` allowlist restrictiva; `framework-contract.md` §"Arquitectura de distribución": "única forma de distribución" |
| 3 | `specboot update` sin piedad | ✅ Cumple | `specboot.sh` `run_update_project` con `UPDATE_ITEMS`, backup, semver jump, post-validación; opción A documentada |
| 4 | Dogfooding real | ✅ Cumple | `scripts/dogfood-check.sh`, `tests/*-test.sh` (9), `openspec/state/manifest.json` con 12 changes archivados |

### Fases 0–6 — estado

| Fase | Estado | Nota |
|---|---|---|
| 0 — Contrato + estándar docs + esquema + SemVer | ✅ Cumple | `framework-contract.md`, `docs-standard.md`, `specboot-json-standard.md`, `versioning-standard.md` coherentes |
| 1 — Empaquetado npm limpio | ✅ Cumple | `files` solo framework; `.npmignore` excluye `openspec/`, `tests/`, `node_modules/`, legacy `.openspec/` |
| 2 — `AGENTS.md` puente dinámico | ✅ Cumple | Carga base + carga dinámica por tag + `docs/project/*` condicional sin `{file:}` (no rompe `check-refs.sh`) |
| 3 — `specboot init` + `specboot update` + git por fase | ✅ Cumple | Ambos modos implementados; guard de `.specboot.json`; semver jump |
| 4 — `Makefile` + `ci.yml`/`deploy.yml` parametrizados | ✅ Cumple | `Makefile` lee config con `node -e`; `deploy.yml` gated por `vars.DEPLOY_ENABLED` + `vars.*`/`secrets.*` |
| 5 — Dogfooding real | ✅ Cumple | `dogfood-check.sh` corre `check-refs.sh` + `specboot.sh --ci`; `release.yml`/`ci.yml` corren self-tests |
| 6 — `release.yml` publica a npm tras merge a main | ⚠️ **A medio completar** | `release.yml` existe y cumple, **pero coexiste con `publish.yml`** que la propia spec `specboot-release` marca como superseded |

---

## 1. Hallazgos de la auditoría (priorizados)

### P0 — Basura estructural en el árbol de trabajo

1. **`Digital/` es carpeta basura.** Contiene `Digital/Desarrollo/zavando-specboot/openspec/changes/specboot-makefile/` (vacío). Es un fragmento de la ruta absoluta `/home/gabriel/Agencia Digital/Desarrollo/zavando-specboot/` recreado como path relativo por un script (probablemente `openspec archive` o un `mkdir -p` con cwd erróneo durante el archivado de `specboot-makefile`). Git no trackea directorios vacíos → clutter no versionado en disco. **Eliminar.**

2. **`.openspec/` es leftover vacío.** Contiene `changes/` y `tickets/` vacíos. La ruta canónica es `openspec/` (sin punto) desde TICKET-0.2, confirmado por `framework-contract.md` §"Rutas canónicas" y `docs-standard.md`. La migración `.openspec/`→`openspec/` en `.opencode/` y `ai-specs/` está completa (`grep -R ".openspec/" .opencode/ ai-specs/` = 0 coincidencias). El `.npmignore` aún lista `.openspec/` como safety (correcto, **no se toca**). **Eliminar la carpeta vacía del árbol.**

### P1 — Conflicto de publicación (Fase 6 inconclusa)

3. **`publish.yml` + `release.yml` coexisten y colisionan.** Ambos se disparan al pushear un tag `v*.*.*` sobre `main`: `release.yml` por `push: branches: [main]` y `publish.yml` por `push: tags: [v*.*.*]` → **doble publish / race en GitHub Packages**. La spec `specboot-release` (TICKET-6.1, archivada) dice literalmente: *"Replace the obsolete `publish.yml`-on-tag concept from TICKET-1.1 with a robust `release.yml`"* y *"Does NOT create `publish.yml` from TICKET-1.1 — `release.yml` replaces that concept."* — pero el archivo `publish.yml` **no se eliminó**. Migración a medio ejecutar.

4. **Specs activas contradicen el estado real.** `openspec/specs/npm-distribution/spec.md` (línea 38) aún exige `publish.yml` tag-based; `openspec/specs/workflow-node-upgrade/spec.md` exige `publish.yml` con `checkout@v5`/Node 24. Ambas conviven con `specboot-release/spec.md` que exige `release.yml`. Un consumidor que corra `openspec validate` tendría specs mutuamente contradictorias. **Reconciliar specs activas** con el modelo `release.yml`.

### P2 — Hygiene de workflows (decidido: bump)

5. **`release.yml` y `ci.yml` usan `actions/checkout@v4` + `setup-node@v4` + Node 20.** `workflow-node-upgrade` ya quiso v5+Node24 (para `publish.yml`) por el aviso de deprecation de GitHub. **Bump `release.yml` + `ci.yml`** a `actions/checkout@v5`, `actions/setup-node@v5`, `node-version: '24'`. `deploy.yml` ya usa `@v4` (no fue parte del decision, se deja).

### P3 — Documentación inconsistente con el estado realizado

6. **`README.md`** tres inconsistencias:
   - Línea 8: *"Template boilerplate"* — el objetivo del plan es **framework**, no template.
   - Quick Start (líneas 27–31): *"Copia el template / `git clone`"* contradice el modelo npm (`npm install @gabrielzavando/specboot` + `specboot init`).
   - "Versionado y actualización" (líneas 504–521): recomienda `bash update.sh --template` a **consumidores**, pero `update.sh` **no está en `files`** (no se publica) → consumidor no lo tiene. El flujo correcto es `specboot update`.

7. **`docs/framework-contract.md` §"Workflows del framework"** (líneas 260–287) lista `ci.yml` + `deploy.yml` pero **omite `release.yml`**, aunque §"Arquitectura de distribución" (líneas 18, 27) sí lo menciona. Inconsistencia interna del contrato.

### P4 — Menores

8. **`ci.yml` corre solo 3 self-tests** (`check-refs-test`, `solid-templates-test`, `update-test`) mientras `release.yml` corre **todos** `tests/*-test.sh` (9 scripts). Desviación sin justificación documentada.

9. **`tests/update-test.sh`** prueba el modo de sincronización de `update.sh` que está deprecado. Confirmar si sigue aportando valor o si conviene repuntarlo al modo `--bump`.

---

## 2. Change OpenSpec — `cleanup-publish-and-junk`

**Un único change** que agrupa todas las correcciones. Se crea con:

```bash
openspec change create cleanup-publish-and-junk \
  --ticket-id TICKET-CLEANUP \
  --description "Cierre de Fase 6: eliminar publish.yml, bump a node 24, limpiar clutter de paths, reconciliar docs"
```

Artefactos a producir bajo `openspec/changes/cleanup-publish-and-junk/`:

- `proposal.md` — por qué y qué (resumen de §1 + §2).
- `scenarios.md` — escenarios Gherkin por requisito (ver §2.1).
- `requirements.md` — lista numerada de requisitos (ver §2.2).
- `tasks.md` — tareas ejecutables agrupadas por fase (ver §3).

### 2.1 Escenarios Gherkin (extracto)

```gherkin
# Req: publish.yml eliminado
Scenario: publish.yml no existe tras el change
  GIVEN el repo con .github/workflows/publish.yml + release.yml
  WHEN se aplica el change
  THEN .github/workflows/publish.yml NO existe
  AND release.yml es el único workflow de publicación
  AND release.yml dispara en push: branches: [main] y release: types: [published]

# Req: release.yml y ci.yml en node 24 + actions v5
Scenario: release.yml y ci.yml usan actions v5 y node 24
  GIVEN el repo con release.yml y ci.yml en checkout@v4/setup-node@v4/node 20
  WHEN se aplica el change
  THEN release.yml usa actions/checkout@v5 y actions/setup-node@v5 con node-version: '24'
  AND ci.yml usa actions/checkout@v5 y actions/setup-node@v5 con node-version: '24'

# Req: clutter de paths eliminado
Scenario: Digital/ y .openspec/ no existen en el árbol
  GIVEN el repo con Digital/ y .openspec/ como directorios vacíos no trackeados
  WHEN se aplica el change
  THEN el directorio Digital/ NO existe
  AND el directorio .openspec/ NO existe
  AND git ls-files .openspec/ Digital/ retorna vacío
  AND .npmignore conserva la línea .openspec/ (safety, no se toca)

# Req: specs activas reconciliadas
Scenario: npm-distribution y workflow-node-upgrade apuntan a release.yml
  GIVEN las specs activas openspec/specs/npm-distribution/spec.md y workflow-node-upgrade/spec.md
  WHEN se aplica el change
  THEN npm-distribution/spec.md exige release.yml (no publish.yml)
  AND workflow-node-upgrade/spec.md exige release.yml y ci.yml con @v5 + node 24
  AND specboot-release/spec.md añade el requisito de node 24 consolidando workflow-node-upgrade

# Req: README y contrato reconciliados
Scenario: README lead con specboot init, no git clone
  GIVEN README.md Quick Start recomienda git clone a consumidores
  WHEN se aplica el change
  THEN README lead con npm install --save-dev @gabrielzavando/specboot + specboot init
  AND el git clone se mueve a una nota secundaria "desarrollo del framework"
  AND update.sh se documenta como --bump maintainer-only (no se publica)

# Req: framework-contract lista release.yml
Scenario: framework-contract documenta los tres workflows
  GIVEN docs/framework-contract.md §"Workflows del framework" omite release.yml
  WHEN se aplica el change
  THEN la sección lista ci.yml + deploy.yml + release.yml
  AND describe los triggers de release.yml (push: branches: [main] + release: types: [published])
```

### 2.2 Requisitos (lista canónica)

1. **REQ-001**: `.github/workflows/publish.yml` SHALL NOT exist; `release.yml` SHALL be the
   only publication workflow, triggered by `push: branches: [main]` and
   `release: types: [published]`.
2. **REQ-002**: `release.yml` and `ci.yml` SHALL use `actions/checkout@v5`,
   `actions/setup-node@v5`, and `node-version: '24'` (eliminate Node 20 deprecation warning).
3. **REQ-003**: The working tree SHALL NOT contain `Digital/` or `.openspec/`; `.npmignore`
   SHALL retain the legacy `.openspec/` exclusion as a safety net (unchanged).
4. **REQ-004**: `openspec/specs/npm-distribution/spec.md` SHALL require `release.yml`
   (not `publish.yml`); `openspec/specs/workflow-node-upgrade/spec.md` SHALL require
   `release.yml` and `ci.yml` at `@v5`/node24; `openspec/specs/specboot-release/spec.md`
   SHALL add a requirement consolidating `workflow-node-upgrade` (node 24).
5. **REQ-005**: `README.md` SHALL lead the Quick Start with `npm install --save-dev
   @gabrielzavando/specboot` + `specboot init`; the `git clone` flow SHALL be moved to a
   secondary "framework development" note; `update.sh` SHALL be documented as
   `--bump` maintainer-only and **not published** (consumer flow is `specboot update`).
6. **REQ-006**: `docs/framework-contract.md` §"Workflows del framework" SHALL list
   `ci.yml`, `deploy.yml`, **and `release.yml`** with their triggers, and SHALL state that
   `release.yml` does not invoke `update.sh --bump`.
7. **REQ-007**: No regression — `check-refs.sh`, `specboot.sh --ci`, `validate-specboot.sh`,
   `make ci`, `bash scripts/dogfood-check.sh`, and all `tests/*-test.sh` SHALL pass after
   the change.

---

## 3. Plan de ejecución por fases

> **Regla SDD (no negociable):** en cada fase, **primero artefactos OpenSpec**, luego código.
> Las fases son grupos lógicos de tareas dentro del único change `cleanup-publish-and-junk`.

### Fase A — Apertura del change OpenSpec

**Objetivo:** dejar el change `cleanup-publish-and-junk` creado con sus artefactos vacíos
pero estructurados, listo para llenar en las fases B–F.

**Cambios:**
- `openspec change create cleanup-publish-and-junk --ticket-id TICKET-CLEANUP`
- Escribir `openspec/changes/cleanup-publish-and-junk/proposal.md` (resumen de §1 + §2).
- Escribir `openspec/changes/cleanup-publish-and-junk/scenarios.md` (§2.1).
- Escribir `openspec/changes/cleanup-publish-and-junk/requirements.md` (§2.2).
- Escribir `openspec/changes/cleanup-publish-and-junk/tasks.md` (todas las tareas de
  Fases B–F, cada una con `Suggested Path` y `Test Path`).

**Verificación:**
```bash
test -f openspec/changes/cleanup-publish-and-junk/proposal.md
test -f openspec/changes/cleanup-publish-and-junk/scenarios.md
test -f openspec/changes/cleanup-publish-and-junk/requirements.md
test -f openspec/changes/cleanup-publish-and-junk/tasks.md
```

### Fase B — Reconciliar specs activas (antes de tocar código)

**Objetivo:** que las specs activas dejen de contradecir el estado real del repo. Es la
fase que más justifica el change: las specs son la fuente de verdad y ahora mienten.

**Cambios:**
- **`openspec/specs/npm-distribution/spec.md`**: reescribir el requisito `publish.yml` →
  `release.yml` (trigger `push: branches: [main]` + `release: types: [published]`,
  `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}`, `permissions: packages: write`, gate
  `needs: validate`). Añadir escenario: *"publish.yml is superseded by release.yml"*.
- **`openspec/specs/workflow-node-upgrade/spec.md`**: repuntar de `publish.yml` a
  `release.yml` **y** `ci.yml` con `actions/checkout@v5` + `setup-node@v5` +
  `node-version: '24'`. Actualizar escenario Gherkin.
- **`openspec/specs/specboot-release/spec.md`**: añadir un requisito nuevo que consolide
  `workflow-node-upgrade` — "`release.yml` SHALL use `actions/checkout@v5`,
  `actions/setup-node@v5`, `node-version: '24'`" — con escenario Gherkin.
- **`openspec/state/manifest.json`**: **no se toca** en esta fase (se actualiza al
  `/archive`).

**Verificación:**
```bash
grep -n "publish\.yml" openspec/specs/npm-distribution/spec.md       # 0 (o solo en pasado)
grep -n "release\.yml" openspec/specs/npm-distribution/spec.md       # ≥1
grep -n "release\.yml" openspec/specs/workflow-node-upgrade/spec.md  # ≥1
grep -n "node-version.*24" openspec/specs/specboot-release/spec.md   # ≥1
```

### Fase C — Eliminar clutter de paths (P0)

**Objetivo:** limpiar el árbol de trabajo de paths basura no versionados.

**Cambios:**
1. Verificar que `Digital/` y `.openspec/` son no-trackeados y están vacíos:
   ```bash
   git ls-files Digital/ .openspec/           # debe retornar vacío
   find Digital/ .openspec/ -type f            # debe retornar vacío o solo vacíos
   ```
2. Eliminar:
   ```bash
   rm -rf Digital/
   rm -rf .openspec/
   ```
3. **No tocar** `.npmignore` (la línea `.openspec/` se conserva como safety net).

**Verificación:**
```bash
test ! -e Digital/
test ! -e .openspec/
grep -n ".openspec/" .npmignore   # sigue presente (safety)
```

### Fase D — Resolver conflicto de publicación (P1)

**Objetivo:** dejar `release.yml` como único workflow de publicación.

**Cambios:**
1. Eliminar `publish.yml`:
   ```bash
   git rm .github/workflows/publish.yml
   ```
2. Confirmar que `package.json` `files` incluye `.github/workflows` (✓ ya lo tiene) → el
   paquete sigue publicando `release.yml` + `ci.yml` + `deploy.yml`.
3. Confirmar que `release.yml` cumple la spec `specboot-release`:
   - `on: push: branches: [main]` + `on: release: types: [published]` ✓
   - `permissions: packages: write` ✓
   - `publish` job con `needs: validate` ✓
   - `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}` ✓
   - No invoca `update.sh --bump` ✓ (verificado por `grep -n "update\.sh\|--bump" .github/workflows/release.yml` = 0)

**Verificación:**
```bash
test ! -f .github/workflows/publish.yml
test -f .github/workflows/release.yml
ls .github/workflows/    # ci.yml, deploy.yml, release.yml (3)
python -c "import yaml; yaml.safe_load(open('.github/workflows/release.yml'))" && echo OK
grep -nE '^\s*if:.*hashFiles' .github/workflows/release.yml   # 0 job-level (solo step-level)
grep -n "update\.sh\|--bump" .github/workflows/release.yml     # 0
```

### Fase E — Bump de workflows a Node 24 + actions v5 (P2)

**Objetivo:** alinear `release.yml` y `ci.yml` con `workflow-node-upgrade` y eliminar el
aviso de deprecation de Node 20 en los runners.

**Cambios:**
1. **`.github/workflows/release.yml`** (ambos jobs `validate` y `publish`):
   - `actions/checkout@v4` → `actions/checkout@v5`
   - `actions/setup-node@v4` → `actions/setup-node@v5`
   - `node-version: 20` → `node-version: '24'`
2. **`.github/workflows/ci.yml`** (jobs `validate` y `project-ci`):
   - `actions/checkout@v4` → `actions/checkout@v5`
   - `actions/setup-node@v4` → `actions/setup-node@v5`
   - `node-version: 20` → `node-version: '24'`
3. **`.github/workflows/deploy.yml`**: **no se toca** (fuera del decision; ya usa `@v4`).
4. Añadir/actualizar un caso en `tests/release-workflow-test.sh` que verifique:
   - `release.yml` parsea como YAML válido.
   - `release.yml` no invoca `update.sh` ni `--bump`.
   - `release.yml` y `ci.yml` referencian `actions/checkout@v5` y `node-version: '24'`.

**Verificación:**
```bash
python -c "import yaml; yaml.safe_load(open('.github/workflows/release.yml'))" && echo OK
python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))" && echo OK
grep -n "checkout@v5\|setup-node@v5\|node-version: '24'" .github/workflows/release.yml
grep -n "checkout@v5\|setup-node@v5\|node-version: '24'" .github/workflows/ci.yml
bash tests/release-workflow-test.sh
```

### Fase F — Reconciliar documentación (P3)

**Objetivo:** que `README.md` y `docs/framework-contract.md` reflejen el modelo npm +
`specboot init` / `specboot update` + `release.yml`, no el template-boilerplate + git clone.

**Cambios:**

1. **`README.md`**:
   - Línea 8: `Template boilerplate for Spec-Driven Development` →
     `SDD framework for Spec-Driven Development` (alinea con el objetivo del plan:
     framework, no template).
   - **Quick Start** (líneas 27–31): reescribir el lead a:
     ```bash
     # 1. Instala el framework como devDependency
     npm install --save-dev @gabrielzavando/specboot

     # 2. Inicializa tu proyecto (inyecta archivos del framework + .specboot.json + docs/)
     bash node_modules/@gabrielzavando/specboot/specboot.sh init

     # 3. Inicializa OpenSpec
     openspec init

     # 4. Personaliza docs/ (OBLIGATORIO) ...
     # 5. Verifica: bash specboot.sh --init
     # 6. Abre OpenCode: opencode
     # 7. Ciclo SDD: /enrich-us → /plan-change → /apply → /verify → /archive → /commit
     ```
     Mover el `git clone` actual a una **nota secundaria** titulada
     "Desarrollo del framework (maintainers)" con el flujo `git clone` + rama feature.
   - **"Versionado y actualización"** (líneas 504–521): eliminar la recomendación de
     `bash update.sh --template` a consumidores. Reemplazar por:
     ```bash
     # Actualizar un proyecto ya inicializado (reemplaza archivos intocables, no toca docs/)
     bash node_modules/@gabrielzavando/specboot/specboot.sh update
     ```
     Y aclarar que `update.sh --bump` es **conveniencia de maintainer** del repo del
     framework, **no se publica** (`update.sh` no está en `files`), y los consumidores
     no lo reciben.

2. **`docs/framework-contract.md` §"Workflows del framework"** (líneas 260–287):
   - Añadir `release.yml` a la lista de workflows intocables del framework, junto a
     `ci.yml` y `deploy.yml`.
   - Describir triggers: `push: branches: [main]` + `release: types: [published]`, gate
     `needs: validate`, `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}`,
     `permissions: packages: write`.
   - Aclarar que `release.yml` **no invoca** `update.sh --bump` (este es maintainer-only).

3. **`docs/versioning-standard.md`** §"Release automático" (líneas 104–137): ya describe
   `release.yml` correctamente; **revisar** que no quede ninguna referencia residual a
   `publish.yml` como modelo vigente (solo como histórico superseded).

**Verificación:**
```bash
grep -n "Template boilerplate" README.md                    # 0
grep -n "git clone.*Specboot" README.md | head -1           # solo en nota de maintainers
grep -n "release\.yml" docs/framework-contract.md           # ≥1 en §Workflows
grep -n "update\.sh --template" README.md                   # 0 (deprecado)
grep -n "specboot update" README.md                         # ≥1 (flujo consumidor)
```

### Fase G — Menores (P4, opcional en esta pasada)

**Objetivo:** cerrar desviaciones menores de CI/tests.

**Cambios:**
1. **`ci.yml`**: alinear el bloque de self-tests con `release.yml`. Opción recomendada:
   correr **todos** `tests/*-test.sh` (como hace `release.yml`), en lugar del subconjunto
   actual de 3. Alternativa: documentar por qué `ci.yml` corre solo 3 y `release.yml`
   corre 9. **Decisión:** alinear (correr los 9 en ambos) para consistencia.
2. **`tests/update-test.sh`**: revisar si prueba el modo `--bump` o solo el modo
   sincronización (deprecado). Si solo prueba sincronización, **repuntar** a `--bump` o
   marcar el test como `SKIP` con justificación. **Decisión:** repuntar a `--bump`
   (modo vigente) + mantener una aserción de que el modo sincronización imprime el
   aviso de deprecation.

**Verificación:**
```bash
diff <(grep -A4 "tests/\*-test.sh" .github/workflows/ci.yml) \
     <(grep -A4 "tests/\*-test.sh" .github/workflows/release.yml)   # idéntico
bash tests/update-test.sh                                          # pasa
```

### Fase H — Verificación integral (read-only, pre-commit)

**Objetivo:** confirmar que el change no rompe nada antes de archivar.

**Comandos:**
```bash
# Integridad referencial (file refs + skill registration)
bash check-refs.sh                                            # exit 0

# Framework self-check (estructura + placeholders + skills + ci/cd + .specboot.json)
bash specboot.sh --ci                                          # exit 0

# .specboot.json schema
bash validate-specboot.sh                                      # exit 0

# CI gate del proyecto (refs + solid-lint + lint + test + audit)
make ci                                                        # exit 0

# Dogfooding (check-refs + specboot --ci)
bash scripts/dogfood-check.sh                                  # exit 0

# Migración .openspec -> openspec íntegra en .opencode/ y ai-specs/
grep -R ".openspec/" .opencode/ ai-specs/                      # 0 coincidencias

# Confirmar clutter eliminado y no trackeado
git ls-files .openspec/ Digital/                              # vacío
test ! -e Digital/ && test ! -e .openspec/ && echo "clutter gone"

# YAML de workflows válido
python -c "import yaml; yaml.safe_load(open('.github/workflows/release.yml'))"
python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"
python -c "import yaml; yaml.safe_load(open('.github/workflows/deploy.yml'))"

# No regression en self-tests
for t in tests/*-test.sh; do bash "$t"; done
```

**Criterio de salida:** todos los comandos anteriores en verde. Si alguno falla, **no
archivar**: diagnosticar y volver a la fase correspondiente.

### Fase I — Cerrar ciclo SDD (archive + commit)

**Objetivo:** archivar el change, actualizar el manifiesto y crear el commit convencional.

**Comandos:**
```bash
# Archivar el change (actualiza openspec/specs/ + manifest)
openspec archive cleanup-publish-and-junk

# Confirmar que el manifest tiene la nueva entrada
grep -n "cleanup-publish-and-junk" openspec/state/manifest.json

# Stage + commit convencional (un solo commit lógico)
git add -A
git commit -m "fix(ci): remove orphan publish.yml and bump release/ci to node 24

- Remove .github/workflows/publish.yml (superseded by release.yml per specboot-release)
- Bump release.yml and ci.yml to actions/checkout@v5 + setup-node@v5 + node 24
- Remove orphan Digital/ and .openspec/ working-tree clutter
- Reconcile openspec/specs/{npm-distribution,workflow-node-upgrade,specboot-release}
  with the release.yml model
- README: lead with npm install + specboot init; move git clone to maintainer note;
  document update.sh as --bump maintainer-only (not published)
- framework-contract: list release.yml in 'Workflows del framework' section

Refs: TICKET-CLEANUP"
```

> **Nota sobre el commit message:** el tipo `fix(ci)` es apropiado porque corrige la
> Fase 6 inconclusa (un bug de migración: `publish.yml` no se eliminó). Alternativas
> válidas: `chore(ci)` si se prefiere framed como hygiene. **No** `feat` porque no añade
> funcionalidad nueva; `release.yml` ya existía.

---

## 4. Matriz de trazabilidad (hallazgo → fase → requisito → verificación)

| Hallazgo (§1) | Fase | REQ | Verificación clave |
|---|---|---|---|
| P0-1 `Digital/` basura | C | REQ-003 | `test ! -e Digital/` |
| P0-2 `.openspec/` leftover | C | REQ-003 | `test ! -e .openspec/` |
| P1-3 `publish.yml` + `release.yml` coexisten | D | REQ-001 | `test ! -f .github/workflows/publish.yml` |
| P1-4 specs activas contradicen | B | REQ-004 | `grep release\.yml openspec/specs/npm-distribution/spec.md` |
| P2-5 `release.yml`/`ci.yml` en Node 20/v4 | E | REQ-002 | `grep node-version.*24 .github/workflows/{release,ci}.yml` |
| P3-6 `README.md` inconsistente | F | REQ-005 | `grep -n "Template boilerplate" README.md` = 0 |
| P3-7 `framework-contract` omite `release.yml` | F | REQ-006 | `grep release\.yml docs/framework-contract.md` ≥1 |
| P4-8 `ci.yml` 3 vs 9 self-tests | G | REQ-007 | diff de bloques `tests/*-test.sh` |
| P4-9 `update-test.sh` modo deprecado | G | REQ-007 | `bash tests/update-test.sh` pasa |
| — no regression | H | REQ-007 | todos los comandos de Fase H en verde |

---

## 5. Orden de ejecución recomendado

1. **Fase A** — abrir change OpenSpec (`openspec change create`).
2. **Fase B** — reconciliar specs activas (npm-distribution, workflow-node-upgrade,
   specboot-release). **Primero specs, siempre.**
3. **Fase C** — eliminar `Digital/` + `.openspec/` (clutter).
4. **Fase D** — `git rm publish.yml`.
5. **Fase E** — bump `release.yml` + `ci.yml` a v5 + Node 24; actualizar `release-workflow-test.sh`.
6. **Fase F** — reconciliar `README.md` + `docs/framework-contract.md` (+ revisar
   `versioning-standard.md`).
7. **Fase G** — alinear self-tests de `ci.yml` + repuntar `update-test.sh`.
8. **Fase H** — verificación integral (todos los comandos en verde).
9. **Fase I** — `openspec archive` + commit convencional + (opcional) PR.

> Las fases C, D, E, F, G son **conmutativas entre sí** (no dependen una de otra); el
> orden de arriba es por legibilidad. La **única dependencia dura** es: Fase B
> (specs) **antes** de Fase I (archive), y Fase H **antes** de Fase I.

---

## 6. Fuera de alcance (explícito)

- **No** se rediseña el framework. El plan de fases 0–6 original está sustancialmente
  cumplido; este plan solo **cierra** la Fase 6 y limpia residuos.
- **No** se toca `deploy.yml` (fuera del decision de bump; ya usa `@v4`).
- **No** se elimina `update.sh` (decision: mantener `--bump` maintainer + corregir README).
- **No** se elimina la línea `.openspec/` de `.npmignore` (safety net, correcta).
- **No** se cambian los 5 documentos intocables de `docs/` (`base-standards.md`,
  `framework-contract.md`, `docs-standard.md`, `specboot-json-standard.md`,
  `versioning-standard.md`) **salvo** `framework-contract.md` §Workflows (P3-7) y una
  revisión de `versioning-standard.md` por residuos de `publish.yml` (P3-7).
- **No** se bumpa `package.json` `version` en este change (es un `fix`, no un release;
  el bump lo hace el maintainer con `update.sh --bump` antes del merge a `main`).

---

## 7. Post-condición (estado objetivo tras el plan)

- ✅ `release.yml` es el **único** workflow de publicación; `publish.yml` no existe.
- ✅ `release.yml` y `ci.yml` corren en Node 24 + `actions/*@v5` (sin aviso de deprecation).
- ✅ El árbol de trabajo no tiene `Digital/` ni `.openspec/`.
- ✅ Las specs activas (`npm-distribution`, `workflow-node-upgrade`, `specboot-release`)
  apuntan al modelo `release.yml` + node 24, sin contradicciones.
- ✅ `README.md` lead con `npm install` + `specboot init`; `update.sh` documentado como
  `--bump` maintainer-only no publicado.
- ✅ `docs/framework-contract.md` lista los tres workflows del framework
  (`ci.yml`, `deploy.yml`, `release.yml`).
- ✅ `check-refs.sh`, `specboot.sh --ci`, `validate-specboot.sh`, `make ci`,
  `dogfood-check.sh` y todos los `tests/*-test.sh` pasan en verde.
- ✅ `openspec/state/manifest.json` tiene la entrada `cleanup-publish-and-junk`.

**Visión de extremo a extremo (la que este plan deja funcionando):**

```
Dev hace cambio en rama feature/cleanup-publish-and-junk
   ↓  /plan-change → /apply → /verify → /archive → /commit
CI (ci.yml) valida con make ci + specboot.sh --ci
   ↓  merge a main
release.yml valida (check-refs + specboot --ci + make ci + tests)
   ↓  npm publish a https://npm.pkg.github.com
Proyecto consumidor
   ↓  specboot update  (reemplaza archivos intocables, respeta docs/)
```

---

*Documento generado como salida de la auditoría estructural del repositorio Specboot.
Base: inspección de `openspec/`, `.openspec/`, `Digital/`, `.opencode/`, `ai-specs/`,
`docs/`, `.github/workflows/`, `templates/ci/`, `scripts/`, `tests/`, `Makefile`,
`specboot.sh`, `check-refs.sh`, `validate-specboot.sh`, `update.sh`, `package.json`,
`.specboot.json`, `.npmignore`, `.gitignore`, `opencode.json`, `README.md`,
`CHANGELOG.md`, y `openspec/state/manifest.json`.*
