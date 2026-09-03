# Tasks: Fase 0 — Reconciliación del plan y documentación de auth

## Task 1: Confirmar auditoría M-001
**Status**: [x]
**Domain**: Documentation / Audit
**Layer**: N/A
**Priority**: High
**Estimate**: S
**Suggested Path**: PLAN_MEJORAS_SPECBOOT.md
**Test Path**: verificación manual

**Steps**:
1. Revisar la tabla de verificación de M-001 en `PLAN_MEJORAS_SPECBOOT.md` y confirmar que
   cada ticket original (TICKET-5.1, 5.2, 8.2, 3.1, 3.2, 0.3, 9.3/M-902, 8.1/M-801) tiene
   su estado real verificado y su acción en el plan.
2. Confirmar que las acciones documentadas son correctas y consistentes (reclasificación a
   extensión, eliminación, absorción, evaluación).
3. Verificar que ningún ticket posterior del plan reclama "crear" algo verificado como
   existente en esta tabla.

**Acceptance Criteria**:
- Todos los tickets originales de la tabla tienen estado verificado y acción definida.
- No hay ticket posterior que duplique funcionalidad existente.
- (REQ-001)

## Task 2: Redactar sección "Autenticación para consumidores (CI)" en README.md
**Status**: [x]
**Domain**: Documentation
**Layer**: N/A
**Priority**: High
**Estimate**: M
**Suggested Path**: README.md
**Test Path**: `bash check-refs.sh`

**Steps**:
1. Agregar la sección "Autenticación para consumidores (CI)" dentro de la sección
   "Instalación como paquete NPM" de `README.md`, después de "Autenticación (una vez por
   máquina)".
2. Documentar el escenario **mismo owner/org con acceso concedido**: usar
   `secrets.GITHUB_TOKEN` con snippet YAML copiable:
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
3. Documentar el escenario **owner distinto o sin acceso concedido**: requerir un PAT con
   scope `read:packages` guardado como secret del repo consumidor (`NPM_TOKEN` o similar),
   como alternativa al mecanismo del paso 2 e igual al uso local documentado (`.npmrc`).
4. Agregar subsección de **troubleshooting**: causas típicas de `401` (falta
   `NODE_AUTH_TOKEN`, PAT sin scope) y `403` (repo sin acceso concedido en Package
   settings → Manage Actions access).
5. No introducir referencias `{file:...}` rotas.

**Acceptance Criteria**:
- La sección está en `README.md`, no en archivo aparte.
- Cubre los dos escenarios (mismo owner con acceso / owner distinto sin acceso).
- Incluye snippet YAML copiable y troubleshooting 401/403.
- `bash check-refs.sh` → 0 errores.
- (REQ-002, REQ-003, REQ-004, REQ-005)

## Task 3: Verificar snippet YAML en repo de prueba
**Status**: [x] (Verificado manualmente por el usuario en `OneBot-API` — workflow "Test Install Specboot" en verde; `npm install @gabrielzavando/specboot` OK con `secrets.GITHUB_TOKEN`, sin errores 401/403. Único aviso: deprecación informativa de Node 20 en `actions/checkout@v4`, no relacionado con la auth.)
**Domain**: QA
**Layer**: N/A
**Priority**: High
**Estimate**: M
**Suggested Path**: repo de prueba del mismo org (fuera del repo framework)
**Test Path**: ejecución manual del workflow

**Steps**:
1. Usar o crear un repositorio de prueba en el mismo org / owner que publica el paquete,
   con acceso concedido al paquete `@gabrielzavando/specboot` en Package settings.
2. Copiar literalmente el snippet YAML definido en Task 2 a un workflow de GitHub Actions
   del repo de prueba.
3. Ejecutar el workflow y verificar que `npm install @gabrielzavando/specboot` se completa
   sin errores `401` ni `403`.
4. Documentar el resultado de la verificación (éxito o correcciones aplicadas al snippet).

**Acceptance Criteria**:
- El snippet YAML del README funciona en un repo real del mismo org.
- No se produce error 401/403 durante `npm install`.
- Si hubo correcciones, el snippet del README queda actualizado con ellas.
- (REQ-006)

## Task 4: Marcar M-001 y M-002 como completados en PLAN_MEJORAS_SPECBOOT.md
**Status**: [x]
**Domain**: Documentation
**Layer**: N/A
**Priority**: High
**Estimate**: S
**Suggested Path**: PLAN_MEJORAS_SPECBOOT.md
**Test Path**: verificación manual

**Steps**:
1. En el encabezado de la sección M-001, anteponer el checkbox `[x]`:
   `## [x] M-001 — Auditoría de funcionalidades ya implementadas`.
2. En el encabezado de la sección M-002, anteponer el checkbox `[x]`:
   `## [x] M-002 — Documentar autenticación GitHub Packages para consumidores`.
3. Añadir una fila al "Historial de correcciones de este documento" (tabla de versiones)
   documentando que estas tareas se completaron vía el change `phase0-reconciliation`:
   `| v3.1 | M-001 y M-002 completados vía change phase0-reconciliation (marcados con [x]) |`
4. Verificar que el documento refleja el estado completado de las tareas de la Fase 0.

**Acceptance Criteria**:
- M-001 muestra `[x]` en su encabezado.
- M-002 muestra `[x]` en su encabezado.
- El historial de correcciones del documento registra el cambio.
- (REQ-007)

## Task 5: Validación final (sin regresión)
**Status**: [x]
**Domain**: QA
**Layer**: N/A
**Priority**: High
**Estimate**: S
**Suggested Path**: repo root
**Test Path**: comandos de validación

**Steps**:
1. `bash check-refs.sh` → 0 errores.
2. `bash specboot.sh --ci` → sin errores.
3. Verificar que la sección "Autenticación para consumidores (CI)" está correcta y bien
   formateada en `README.md`.
4. Verificar que `PLAN_MEJORAS_SPECBOOT.md` tiene los checkboxes `[x]` en M-001 y M-002 y
   el historial actualizado.
5. `openspec validate phase0-reconciliation` → sin errores.

**Acceptance Criteria**:
- `check-refs.sh` → 0 errores.
- `specboot.sh --ci` → sin errores.
- `openspec validate phase0-reconciliation` → sin errores.
- README y PLAN_MEJORAS_SPECBOOT.md correctamente actualizados.
- (REQ-008)

## Traceability to Requirements
| Task | Requirements |
|------|--------------|
| T1 | REQ-001 |
| T2 | REQ-002, REQ-003, REQ-004, REQ-005 |
| T3 | REQ-006 |
| T4 | REQ-007 |
| T5 | REQ-008 |
