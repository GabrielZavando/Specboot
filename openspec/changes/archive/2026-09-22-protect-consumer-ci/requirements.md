# Requirements — protect-consumer-ci (SPECBOOT-HARDEN-04)

> Trazabilidad: cada REQ referencia al menos un SC de `scenarios.md`.

### REQ-001 — Detectar variantes conocidas del CI de consumidores

- **Descripción**: El framework MUST mantener una allowlist explícita
  (`KNOWN_CONSUMER_CI_FINGERPRINTS` en `specboot.sh`) con los content
  fingerprints (git blob hash) inmutables de TODAS las variantes del CI de
  consumidor efectivamente distribuidas desde la versión 0.10.0, identificadas
  mediante el historial Git. Cada fingerprint debe tener proveniencia
  verificable en el historial (commits pinneados: `.github/workflows/ci.yml`
  @ tag `v0.10.0` vía `cf50b18`, distribuida por el mecanismo pre-aislamiento;
  y `templates/github/workflows/consumer-ci.yml` @ `0c586db`, distribuida desde
  0.11.0). La detección NO debe derivarse del workflow interno mutable
  `.github/workflows/ci.yml`; la allowlist es contenido histórico inmutable y
  la suite de regresión re-deriva cada variante desde git y falla ante drift.
- **Escenarios**: SC-002, SC-011

### REQ-002 — Actualizar el CI de consumidores de forma segura

- **Descripción**: `specboot update` MUST aplicar sobre
  `.github/workflows/ci.yml` esta política: (1) si no existe, instalar la
  plantilla actual; (2) si coincide exactamente con una variante conocida
  distribuida por Specboot, crear respaldo antes de modificarla, reemplazarla
  por la plantilla actual e informar la reparación; (3) si existe pero fue
  modificada o no coincide con una variante conocida, conservarla intacta,
  emitir una advertencia clara, exigir resolución explícita del usuario y
  nunca sobrescribirla automáticamente; (4) los demás workflows personalizados
  MUST permanecer intactos. La coincidencia exacta con la plantilla actual es
  un no-op idempotente (sin respaldo ni advertencia).
- **Respaldo verificable** (correcta post-auditoría adversarial): el respaldo
  del `ci.yml` MUST crearse con `cp -p` (conserva metadatos para su
  restauración) y MUST verificarse explícitamente. Si el respaldo falla:
  ci.yml NO se reemplaza, permanece byte-for-byte intacto, se emite un error
  claro (❌ con el path del respaldo fallido) y la operación devuelve estado
  no exitoso (el update se detiene con exit != 0); nunca un reemplazo sin
  respaldo previo exitoso.
- **Reemplazo verificable** (correcta post-auditoría adversarial, WARNING del
  reviewer): el `cp` que instala (`ci.yml` ausente) o reemplaza (variante
  histórica) por la plantilla actual MUST verificarse explícitamente. Si el
  `cp` falla, o si el destino final NO coincide byte-for-byte con la plantilla
  esperada (write parcial/corrupto), la operación devuelve estado no exitoso
  (`return 1`) con un error claro; NUNCA se reporta una actualización exitosa
  de `ci.yml` sin verificar el resultado final. El destino final debe
  comprobarse contra la plantilla esperada antes de retornar éxito.
- **`--no-backup` como opt-out explícito** (correcta post-auditoría
  adversarial, INFO del reviewer): `--no-backup` oculta la creación del
  backup_dir (`backup_dir` vacío). Es un **opt-out deliberado** del respaldo
  por parte del usuario, NO una excepción silenciosa a la promesa
  "backup antes de reemplazo" de REQ-002: cuando el respaldo se solicita
  (por defecto) aplica la verificación íntegra de SC-013; con `--no-backup`
  se omite el respaldo por decisión explícita y la política de reemplazo
  verificable sigue aplicando. Debe documentarse en
  `docs/versioning-standard.md` y en la ayuda de `specboot update`.
- **Escenarios**: SC-001, SC-002, SC-003, SC-004, SC-009, SC-010, SC-012, SC-013, SC-015

### REQ-003 — Preservar la separación entre workflows

- **Descripción**: `.github/workflows/ci.yml` y `.github/workflows/release.yml`
  del repositorio Specboot continúan siendo internos;
  `templates/github/workflows/consumer-ci.yml` continúa siendo la única fuente
  distribuible para el CI del consumidor; ninguna operación (`init`, `update`,
  empaquetado npm) puede copiar el directorio `.github` completo.
- **Escenarios**: SC-004

### REQ-004 — Pruebas de regresión

- **Descripción**: Cobertura TDD (test en RED antes de la implementación) para:
  consumidor sin `ci.yml`; consumidor con cada variante histórica conocida;
  respaldo antes del reemplazo; consumidor con `ci.yml` modificado; consumidor
  con `ci.yml` ajeno; conservación de workflows personalizados; ejecución
  repetida idempotente; ejecución desde instalación en `node_modules`;
  fingerprints con proveniencia histórica; ausencia de sobrescritura
  silenciosa. Al cierre, todas las suites del ticket deben pasar:
  `tests/specboot-update-test.sh`, `tests/specboot-init-test.sh`,
  `tests/release-bump-test.sh`, `tests/release-workflow-test.sh`,
  `tests/workflow-isolation-test.sh`, `tests/run-all.sh`,
  `bash specboot.sh --ci`, `bash check-refs.sh`, `npm pack --dry-run`.
- **Escenarios**: SC-001..SC-015

### REQ-008 — Resiliencia de la auditoría adversarial

- **Descripción**: La skill `code-auditing` (Paso 2) MUST registrar las
  herramientas opcionales ausentes como **skip** y no como fallos: si una
  herramienta opcional no está disponible (el binario no existe en
  `node_modules/.bin`, p. ej. `eslint` o `dependency-cruiser`, o `npm audit`
  falla/está indisponible), el auditor NO la ejecuta con `npx` (evita
  descargas/instalaciones interactivas que bloquean la subejecución) y la
  registra como skip en el reporte (Paso 5, anexo; nunca en el JSON
  persistido, cuyo esquema permanece fijo). La persistencia (Paso 7) es
  incondicional: el veredicto `openspec/state/adversarial-result.json` se
  persiste SIEMPRE al final de cada auditoría — incluidos veredictos
  NO-SHIP y corridas con skips — para que el gate M-901 de `/commit` lea
  siempre la corrida más reciente. El lente adversarial (Pasos 3–4) es
  manual y obligatorio, independiente de las herramientas opcionales.
- **Escenarios**: SC-014

### REQ-005 — Preparar versión 0.11.0

- **Descripción**: Crear la sección `## [0.11.0]` en `CHANGELOG.md`
  documentando los cambios acumulados desde 0.10.0 (aislamiento de workflows
  internos; reparación de `release.yml` heredados; contratos operacionales de
  agentes y comandos; pre-flight reanudable; resolución correcta del proyecto
  objetivo; historial completo en los jobs de validación; protección del CI
  personalizado de consumidores). Sincronizar la versión `0.11.0` en
  `package.json`, `package-lock.json` (versión raíz y entrada principal) y
  `.specboot.json` (`frameworkVersion`) mediante el mecanismo canónico de bump
  (`bash release-bump.sh 0.11.0`), nunca mediante ediciones manuales
  independientes.
- **Escenarios**: SC-005

### REQ-006 — Corregir el contrato de release-bump.sh

- **Descripción**: `release-bump.sh` MUST actualizar atómicamente todos los
  archivos de versión (`package.json`, `package-lock.json`, `.specboot.json`);
  MUST NOT crear tags mientras los cambios del bump no estén confirmados; la
  creación del tag pertenece a la fase posterior al merge. Actualizar las
  pruebas (`tests/release-bump-test.sh`, invirtiendo el assert M-912 SC-001)
  y `docs/versioning-standard.md` (§6.1 y §Política de tags; delta en la spec
  `release-tagging`) para reflejar el contrato. Alinear `update.sh --bump`
  (que crea tags con el mismo defecto). Verificar que un fallo durante el bump
  no deje versiones parcialmente actualizadas.
- **Escenarios**: SC-005, SC-006

### REQ-007 — Publicación y tag posteriores al merge (contrato pre-merge + ejecución post-merge)

- **Descripción**: REQ-007 se divide en dos mitades con frontera explícita
  (el merge del PR):

  **Verificable antes del merge** (entra en la evidencia de `/verify`):
  - Contrato del workflow `Release`: publicación idempotente (check `npm
    view` previo a `npm publish`; el retrigger `release: published` omite la
    versión ya publicada y termina en verde) — `release.yml` intocable.
  - Política de tags: el bump no crea tags; el tag `v{X.Y.Z}` se crea solo
    post-merge apuntando exactamente al commit del bump en `main`, y se
    publica solo con autorización explícita (documentado en
    `docs/versioning-standard.md` y la spec `release-tagging` actualizada).
  - Idempotencia estructural: `tests/release-workflow-test.sh` en verde.
  - Documentación: runbook post-merge (non-gating) presente en `tasks.md` y
    política actualizada en `docs/versioning-standard.md`.

  **Ejecutable después del merge** (runbook non-gating de `tasks.md`,
  requiere confirmación explícita separada; NUNCA durante `/apply`,
  `/verify`, `/adversarial-review`, `/archive` ni el commit de la rama):
  1. Confirmar que el workflow `Release` publicó
     `@gabrielzavando/specboot@0.11.0`.
  2. Actualizar la rama local `main`.
  3. Crear el tag `v0.11.0` apuntando exactamente al commit de `main` que
     contiene el bump (solo con autorización explícita).
  4. Publicar el tag `v0.11.0` (solo con autorización explícita).
  5. Crear el GitHub Release `v0.11.0` con la sección `## [0.11.0]` del
     CHANGELOG (solo con autorización explícita).
  6. Observar que el retrigger `release: published` es idempotente y verde.

  `/verify` **no debe afirmar** que el tag, el GitHub Release o la publicación
  post-merge fueron ejecutados: sus acciones no cuentan en el total de tareas
  ni bloquean `/verify`, `/adversarial-review`, `/archive` o `/commit`.
- **Escenarios**: SC-007, SC-008
