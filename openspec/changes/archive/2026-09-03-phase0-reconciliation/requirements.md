# Requirements: Fase 0 — Reconciliación del plan y documentación de auth

## REQ-001: Auditoría M-001 verificada y registrada
La tabla de verificación de M-001 en `PLAN_MEJORAS_SPECBOOT.md` debe reflejar el estado
real de cada ticket original (existe / no existe / parcial), con su acción en el plan.
Ningún ticket posterior debe reclamar "crear" algo verificado como existente.
- Traceable to: SC-001

## REQ-002: Sección de autenticación en README.md
La sección **"Autenticación para consumidores (CI)"** debe estar en `README.md`, no en un
archivo aparte, para no fragmentar la documentación de instalación que ya vive ahí.
- Traceable to: SC-002

## REQ-003: Snippet YAML del mismo owner/org
La sección debe incluir un snippet YAML de workflow copiable usando
`secrets.GITHUB_TOKEN` con permisos `packages: read` y `registry-url:
https://npm.pkg.github.com`, para el caso de repo consumidor con acceso concedido.
- Traceable to: SC-002, SC-004

## REQ-004: Alternativa para owner distinto (PAT)
La sección debe explicar que, para owner distinto o sin acceso concedido, se requiere un
PAT con scope `read:packages` guardado como secret del repo consumidor, equivalente al
uso local documentado (`.npmrc`).
- Traceable to: SC-002

## REQ-005: Troubleshooting 401/403
La sección debe incluir troubleshooting de causas típicas de `401` (falta
`NODE_AUTH_TOKEN` o PAT sin scope) y `403` (repo sin acceso concedido en Package
settings).
- Traceable to: SC-003

## REQ-006: Verificación real del snippet
El snippet YAML debe verificarse instalando el paquete en un repositorio de prueba del
mismo org, confirmando que no se produce error 401/403.
- Traceable to: SC-004

## REQ-007: Marcado de completado en el plan
Las tareas M-001 y M-002 deben marcarse como completadas en
`PLAN_MEJORAS_SPECBOOT.md` usando checkbox `[x]` en el encabezado de cada ticket, y debe
añadirse una entrada al historial de correcciones del documento.
- Traceable to: SC-005

## REQ-008: Integridad del framework
El change no debe romper las validaciones del framework: `bash check-refs.sh` → 0 errores
y `bash specboot.sh --ci` → sin errores.
- Traceable to: SC-001, SC-005
