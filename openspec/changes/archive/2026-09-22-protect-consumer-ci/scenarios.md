# Scenarios — protect-consumer-ci (SPECBOOT-HARDEN-04)

> Escenarios del ticket (SC-001..SC-008) mapeados 1:1 y extendidos con los
> casos de cobertura REQ-004 no cubiertos por los SC del ticket
> (SC-009..SC-012). IDs estables `SC-{NNN}` (convención M-102).
> SC-007/SC-008 fueron re-escopados (mismo ID, alcance corregido): lo
> **verificable antes del merge** (contrato del workflow, política de tags,
> idempotencia, documentación) queda en el escenario; lo **ejecutable después
> del merge** (publicación 0.11.0, sync de `main`, tag, GitHub Release) vive
> en el `## Post-merge release runbook (non-gating)` de `tasks.md` y no es
> afirmado por `/verify`.

### SC-001: Consumidor sin ci.yml recibe la plantilla actual

- **Given** un proyecto consumidor inicializado sin `.github/workflows/ci.yml`
- **When** ejecuta `specboot update`
- **Then** se instala la plantilla CI actual
  (`templates/github/workflows/consumer-ci.yml` →
  `.github/workflows/ci.yml`) y la instalación se informa

### SC-002: Variante histórica exacta se respalda y actualiza

- **Given** un consumidor cuyo `.github/workflows/ci.yml` coincide exactamente
  (fingerprint de contenido) con una variante histórica distribuida por
  Specboot desde 0.10.0 (cada variante de la allowlist)
- **When** ejecuta `specboot update`
- **Then** el archivo se respalda en `.specboot-backup-*/` ANTES de
  modificarlo
- **And** se reemplaza por la plantilla actual y la reparación realizada se
  informa (respaldo + reemplazo)

### SC-003: ci.yml modificado permanece intacto y exige resolución explícita

- **Given** un consumidor cuyo `.github/workflows/ci.yml` fue modificado (una
  variante conocida editada manualmente ya no coincide con ningún fingerprint)
- **When** ejecuta `specboot update`
- **Then** el archivo permanece byte-for-byte intacto
- **And** se emite una advertencia clara que exige resolución explícita del
  usuario (nunca sobrescritura automática ni silenciosa)

### SC-004: Workflows personalizados no se eliminan ni sobrescriben

- **Given** un consumidor con workflows adicionales propios en
  `.github/workflows/` (p.ej. `deploy.yml`, `custom.yml` ajenos al framework)
- **When** se ejecuta `init` o `update`
- **Then** ninguno es eliminado ni sobrescrito
- **And** `.github/workflows/ci.yml` y `.github/workflows/release.yml` del repo
  Specboot permanecen internos; `templates/github/workflows/consumer-ci.yml`
  sigue siendo la única fuente distribuible; ninguna operación copia el
  directorio `.github` completo

### SC-005: El bump canónico sincroniza los tres archivos de versión

- **Given** la preparación del release 0.11.0 con la sección `## [0.11.0]` ya
  presente en `CHANGELOG.md`
- **When** se ejecuta el mecanismo canónico de bump
  (`bash release-bump.sh 0.11.0`)
- **Then** `package.json` (`version`), `package-lock.json` (versión raíz y
  entrada principal `packages[""]`) y `.specboot.json` (`frameworkVersion`)
  quedan sincronizados a `0.11.0`
- **And** un fallo durante el bump (p.ej. `package-lock.json` corrupto) no
  deja versiones parcialmente actualizadas (parse/validación de todos los
  archivos ANTES de escribir cualquiera)

### SC-006: El bump sin commit no crea tags

- **Given** cambios del bump todavía sin commit (árbol sucio)
- **When** se ejecuta `release-bump.sh`
- **Then** no se crea ningún tag Git (ni local ni remoto)
- **And** la creación del tag pertenece a la fase posterior al merge
  (proceso del mantenedor, no del script)

### SC-007: Contrato del tag post-merge (verificable antes del merge)

> Re-escopado del SC-007 del ticket: la parte ejecutable (crear/pushear el
> tag, GitHub Release) vive en el runbook post-merge non-gating de `tasks.md`
> y no es afirmada por `/verify`.

- **Given** la política de tags corregida (el bump no crea tags) y el runbook
  post-merge non-gating documentados
- **When** se verifica el contrato antes del merge (docs y asserts sobre
  `docs/versioning-standard.md`, spec `release-tagging` y tooling)
- **Then** la política declara que el tag `v0.11.0` se crea solo post-merge,
  apuntando exactamente al commit de `main` que contiene el bump, y se
  publica solo con autorización explícita
- **And** ningún script o tooling del framework crea tags durante el bump,
  `/apply`, `/archive` ni el commit de la rama
- **And** las acciones ejecutables post-merge (confirmar publicación 0.11.0,
  sincronizar `main`, crear/pushear `v0.11.0`, crear el GitHub Release)
  pertenecen al runbook non-gating y NO son afirmadas por `/verify`

### SC-008: Idempotencia del workflow Release (contrato verificable antes del merge)

> Re-escopado del SC-008 del ticket: la observación del retrigger real
> (`release: published` tras crear el GitHub Release) pertenece al runbook
> post-merge non-gating; lo verificable pre-merge es el contrato de
> idempotencia del workflow.

- **Given** `release.yml` (intocable) con la publicación gated por un check
  `npm view` que detecta la versión ya publicada
- **When** se ejecuta la verificación estructural/contractual
  (`tests/release-workflow-test.sh`, pre-merge)
- **Then** el contrato declara que ante una republicación de `0.11.0` la
  publicación se omite de manera idempotente y el workflow termina
  exitosamente sin intentar republicar la versión existente
- **And** la confirmación observacional del retrigger `release: published`
  (run real en verde tras crear el GitHub Release) es un paso del runbook
  post-merge non-gating y NO es afirmada por `/verify`

### SC-009: Ejecución repetida idempotente

- **Given** un consumidor cuyo `.github/workflows/ci.yml` coincide exactamente
  con la plantilla actual del framework (recién instalado/actualizado)
- **When** `specboot update` se ejecuta una segunda vez
- **Then** la coincidencia exacta con la plantilla actual es un no-op: el
  archivo queda byte-for-byte idéntico, sin respaldo, sin reemplazo y sin
  advertencias espurias
- **And** un tercer `update` produce el mismo resultado (idempotencia estable)

### SC-010: La política aplica desde instalación en node_modules

- **Given** un proyecto consumidor que ejecuta `specboot update` desde la
  instalación del paquete en `node_modules/@gabrielzavando/specboot` (modo
  consumidor, sin dogfooding)
- **When** el update evalúa `.github/workflows/ci.yml`
- **Then** la misma política tri-estado aplica (instalar / respaldar+reemplazar
  / preservar+advertir) usando la plantilla y la allowlist del paquete
  instalado

### SC-011: Los fingerprints tienen proveniencia histórica verificable

- **Given** el historial git del framework con todas las variantes del CI de
  consumidor efectivamente distribuidas desde 0.10.0
- **When** la suite de regresión re-deriva el content fingerprint de cada
  variante desde commits pinneados del historial git
- **Then** cada fingerprint derivado está presente en la allowlist de
  `specboot.sh`
- **And** ninguna entrada de la allowlist existe fuera de ese conjunto
  histórico (no invented hashes)
- **And** la allowlist está documentada como contenido histórico inmutable,
  nunca derivada del workflow interno mutable `.github/workflows/ci.yml`

### SC-012: ci.yml ajeno no se sobrescribe silenciosamente

- **Given** un consumidor con un `.github/workflows/ci.yml` escrito por él y
  nunca distribuido por Specboot (ajeno, sin fingerprint conocido)
- **When** ejecuta `specboot update`
- **Then** el archivo permanece byte-for-byte intacto
- **And** se emite una advertencia clara que exige resolución explícita; el
  resto del update continúa sin tocarlo (ausencia de sobrescritura silenciosa)

### SC-013: Fallo del respaldo impide el reemplazo y devuelve estado no exitoso

> Correcta post-auditoría adversarial (hallazgo WARNING refutado y
> re-escalado a fix por el orquestador): el respaldo del `ci.yml` se verifica
> explícitamente para que un fallo de respaldo nunca derive en un
> reemplazo sin copia previa.

- **Given** un consumidor cuyo `.github/workflows/ci.yml` coincide con una
  variante histórica conocida (rama 3 de la política) y el respaldo no puede
  crearse (p. ej. `mkdir -p <backup_dir>/.github/workflows` y el `cp -p`
  fallan porque el path del respaldo está bloqueado por un archivo regular)
- **When** ejecuta `specboot update`
- **Then** ci.yml NO se reemplaza y permanece byte-for-byte intacto
- **And** se emite un error claro (❌) que menciona el path del respaldo
  fallido y que el archivo no se reemplazó
- **And** la operación devuelve estado no exitoso (exit != 0); el update se
  detiene y exige resolución manual (o reintento), nunca un reemplazo
  silencioso sin respaldo previo exitoso
- **And** el respaldo, cuando tiene éxito, se crea con `cp -p` (conserva
  metadatos)

### SC-014: El reviewer persiste su veredicto aunque falten herramientas opcionales

> Correcta post-auditoría (fallo silencioso observado dos veces: la
> subejecución del reviewer moría antes de persistir, con `eslint`/
> `dependency-cruiser` ausentes en `node_modules/.bin`).

- **Given** una auditoría adversarial (`code-auditing`) sobre un cambio
  activo y herramientas opcionales ausentes (binarios no disponibles en
  `node_modules/.bin`, `npm audit` fallando o indisponible)
- **When** el reviewer ejecuta la auditoría (Paso 2)
- **Then** las herramientas opcionales ausentes se registran como **skip**
  (nunca como fallos ni hallazgos) y el auditor NO ejecuta `npx` contra
  paquetes ausentes (evita descargas/instalaciones interactivas)
- **And** la persistencia es incondicional (Paso 7):
  `openspec/state/adversarial-result.json` se persiste SIEMPRE al final de
  la auditoría — incluidos veredictos NO-SHIP y corridas con skips — y el
  JSON persistido mantiene su esquema fijo (`schema_version: 1`) sin campos
  de skip
- **And** el lente adversarial (Pasos 3–4) es manual y obligatorio,
  independiente de las herramientas opcionales

### SC-015: Fallo del reemplazo de ci.yml se detecta y no hay éxito falso

> Correcta post-auditoría (hallazgo WARNING del reviewer): el `cp` de
> reemplazo/instalación no se verificaba — un write parcial/corrupto se
> reportaba como éxito. Ahora el destino final se comprueba contra la
> plantilla esperada antes de retornar éxito.

- **Given** un consumidor cuyo `.github/workflows/ci.yml` debe instalarse
  (ausente) o reemplazarse (variante histórica conocida, rama 3) por la
  plantilla actual
- **When** ejecuta `specboot update`
- **Then** el `cp` que instala/reemplaza el `ci.yml` se verifica
  explícitamente
- **And** si el `cp` falla, o el destino final NO coincide byte-for-byte con
  la plantilla esperada (write parcial/corrupto), la operación devuelve
  estado no exitoso (`return 1` propagado a exit != 0) con un error claro y
  NUNCA se reporta una actualización exitosa de `ci.yml`
- **And** si el destino final coincide con la plantilla esperada, recién
  entonces se reporta éxito de la instalación/reparación
- **And** `--no-backup` es un opt-out explícito del respaldo (documentado),
  no una excepción silenciosa a la promesa "backup antes de reemplazo";
  con `--no-backup` la política de reemplazo verificable sigue aplicando
