# Proposal: Proteger el CI de consumidores y preparar release 0.11.0

- **Ticket ID**: SPECBOOT-HARDEN-04
- **Título original**: [tooling] Proteger el CI de consumidores y preparar release 0.11.0
- **Tag**: `[tooling]` — sin fila en la matriz de estándares (framework tooling);
  no carga estándares de stack, solo docs del propio framework
  (`docs/versioning-standard.md`, `docs/git-workflow-standards.md`)
- **Change name**: `protect-consumer-ci`
- **Change type**: tooling/framework — automatización de `specboot update`,
  contrato de release y bump de versión del propio framework

## Why

La auditoría adversarial de SPECBOOT-HARDEN-02 dejó un WARNING pendiente: `update_github_artifacts()` (specboot.sh) sobrescribe incondicionalmente `.github/workflows/ci.yml` del consumidor. Aunque es un archivo administrado por Specboot, un consumidor puede haberlo personalizado: la sobrescritura destruye su configuración en silencio. `release-bump.sh`, además, declara en su cabecera que nunca crea tags, pero crea `vX.Y.Z` al final del bump mientras los cambios siguen sin commitear: el tag puede acabar apuntando al commit anterior al bump. Y el bump no sincroniza `package-lock.json`. Finalmente, los cambios acumulados desde 0.10.0 (aislamiento de workflows, contratos operacionales, pre-flight reanudable, resolución de target, historial completo en validación) siguen sin publicarse: los consumidores no pueden actualizar al paquete 0.11.0.

## What Changes

Incluido:

- **REQ-001 — Allowlist de variantes históricas del CI de consumidor**: identify
  via git history every distributed variant of the consumer CI since 0.10.0
  (pre-isolation `.github/workflows/ci.yml` @ tag `v0.10.0` — last touched by
  `cf50b18`, distributed by the pre-isolation update mechanism; and
  `templates/github/workflows/consumer-ci.yml` @ `0c586db`, distributed from
  0.11.0 onward). Explicit immutable fingerprint allowlist
  (`KNOWN_CONSUMER_CI_FINGERPRINTS`), each entry with verifiable git
  provenance, never derived from the mutable internal `.github/workflows/ci.yml`.
- **REQ-002 — Actualización segura del CI de consumidores**: `specboot update`
  applies a tri-state policy on `.github/workflows/ci.yml`: install the current
  template when missing; backup + replace + report repair when it exactly
  matches a known distributed variant; preserve byte-for-byte + clear warning +
  explicit resolution when modified or foreign (never silent overwrite). Exact
  match with the current template is an idempotent no-op. Other custom
  workflows always remain untouched.
- **REQ-003 — Preservar la separación de workflows**: `.github/workflows/ci.yml`
  and `.github/workflows/release.yml` remain internal to the Specboot repo;
  `templates/github/workflows/consumer-ci.yml` remains the only distributable
  consumer CI source; no operation ever copies the whole `.github` directory.
- **REQ-004 — Pruebas de regresión**: TDD coverage for the ten cases listed in
  the ticket (missing file, each historical variant, backup-before-replace,
  modified file, foreign file, custom workflow preservation, idempotent
  re-run, node_modules install execution, fingerprint provenance, no silent
  overwrite).
- **REQ-005 — Preparar versión 0.11.0**: `## [0.11.0]` section in CHANGELOG.md
  documenting the accumulated changes since 0.10.0; version 0.11.0 synced
  through the canonical bump mechanism (`release-bump.sh`) across package.json,
  package-lock.json (root + main entry) and `.specboot.json` (`frameworkVersion`).
- **REQ-006 — Corregir el contrato de release-bump.sh**: the bump atomically
  updates ALL version files (adding package-lock.json), MUST NOT create any git
  tag while the bump changes are uncommitted, and tag creation moves to the
  post-merge phase; `update.sh --bump` aligned; tests and
  `docs/versioning-standard.md` updated (spec `release-tagging` amended).
- **REQ-007 — Publicación y tag posteriores al merge (contrato pre-merge +
  ejecución post-merge)**: REQ-007 se divide en el merge del PR. Antes del
  merge (verificable, entra en la evidencia de `/verify`): contrato del
  workflow `Release` (publicación idempotente vía check `npm view`),
  política de tags corregida (bump sin tags; tag `v{X.Y.Z}` solo post-merge
  apuntando exactamente al commit del bump en `main`), idempotencia
  estructural cubierta por tests y documentación actualizada (runbook
  post-merge incluido). Después del merge (runbook **non-gating** en
  `tasks.md`, requiere confirmación explícita separada y nunca se ejecuta
  durante `/apply`, `/verify`, `/adversarial-review`, `/archive` ni el commit
  de la rama): confirmar la publicación de `@gabrielzavando/specboot@0.11.0`,
  actualizar `main` local, crear/pushear el tag `v0.11.0`, crear el GitHub
  Release desde la sección del CHANGELOG y observar el retrigger
  `release: published` idempotente. Estas acciones no cuentan en el total de
  tareas de implementación ni bloquean `/verify`, `/adversarial-review`,
  `/archive` ni `/commit`; `/verify` no afirma que fueron ejecutadas.

Fuera de alcance (per ticket): publicar en npmjs.org; cambiar el nombre o scope
del paquete; modificar la lógica funcional de los workflows internos;
sobrescribir automáticamente CI personalizados; cambios incompatibles que
requieran 1.0.0; crear o publicar tags antes de fusionar el PR. El PR no debe
incluir `Closes #SPECBOOT-HARDEN-04` (el identificador es un ticket de
Specboot, no un issue real de GitHub).
