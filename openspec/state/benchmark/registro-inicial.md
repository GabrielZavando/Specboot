# Registro de benchmark semimanual — SPECBOOT-PREC-01 (permission-baseline)

> Plantilla de registro SEMIMANUAL. Los tiempos de ejecución y los bytes
> medidos se asientan aquí al correr `/adversarial-review` y `/archive` sobre
> el par de cambios representativos. NO es un orquestador automatizado: eso
> corresponde al ticket final SPECBOOT-REL-01.

## Política de métricas

- **Etiqueta obligatoria**: `aproximación_de_volumen` — todas las métricas de este registro son aproximaciones de volumen (bytes/caracteres de entrada y salida, contando el tamaño de prompts y respuestas).
- **Nunca calcular o estimar tokens matemáticamente**: los agentes no tienen permisos para consultar APIs de billing/usage del proveedor externo; ningún dato de este registro puede presentarse como tokens medidos.
- **Baseline only**: este registro no aplica optimizaciones ni extrae conclusiones de mejora (eso corresponde a PREC-02+).

## Par de cambios representativos (confirmado por el usuario: framework + docs)

- **Cambio representativo 1 — framework**: las partes framework de `permission-baseline` (`tests/baseline-capabilities-test.sh`, `tests/benchmark-recorder-test.sh`, `scripts/benchmark-permissions.mjs`, fixtures negativas y de benchmark).
- **Cambio representativo 2 — documentación**: `docs/baseline/specboot-prec-01-baseline.md`.
- Fallback documentado: los fixtures mínimos de `tests/fixtures/benchmark-changes/{framework,docs}/` (no se necesita código nuevo de aplicación).
- **Ownership**: `/adversarial-review` y `/archive` los invoca el usuario (despachan a `reviewer`/`archive`; el contrato de subagentes del build los prohíbe — ownership protegido por este baseline). Las filas del ciclo se asientan cuando esos comandos se ejecutan.

## Validadores (ejecutados por `scripts/benchmark-permissions.mjs`)

| Validador | Duración (ms) | Exit | Fecha UTC |
|-----------|---------------|------|-----------|
| validate-agent-permissions | 200.9 | 0 | 2026-10-02T22:54:50Z |
| validate-command-contracts | 235.5 | 0 | 2026-10-02T22:54:50Z |

## Ciclo sobre el par — Cambio representativo 1: framework

| Comando | Intento | Duración (aproximación_de_volumen, ms) | Bytes entrada (aproximación_de_volumen) | Bytes salida (aproximación_de_volumen) | Llamadas | Reintentos | Resultado de calidad |
|---------|---------|-----------------------------------------|------------------------------------------|-----------------------------------------|----------|------------|----------------------|
| /adversarial-review | 1 | 3269 (npm audit 708 + eslint 1110 + dep-cruiser 1451) | ≈40 (args de 3 comandos) | 268 (stdout 24 + stderr 413) | 3 | 0 | npm audit PASS (0 vulnerabilidades); eslint/dependency-cruiser FAIL (no instalados); veredicto SHIP/NO-SHIP: pendiente (dispatch del reviewer cancelado en el entorno) |
| /archive | 1 | 1128 (medido con date +%s%N; CLI openspec archive) | ≈45 (comando openspec archive ... --yes) | ≈640 (stdout del CLI) | 1 | 0 | PASS (archivado: specs +7 aplicadas; 3 tareas incompletas advertidas por el CLI; veredicto adversarial pendiente) |

## Ciclo sobre el par — Cambio representativo 2: documentación

| Comando | Intento | Duración (aproximación_de_volumen, ms) | Bytes entrada (aproximación_de_volumen) | Bytes salida (aproximación_de_volumen) | Llamadas | Reintentos | Resultado de calidad |
|---------|---------|-----------------------------------------|------------------------------------------|-----------------------------------------|----------|------------|----------------------|
| /adversarial-review | 1 | 3269 (npm audit 708 + eslint 1110 + dep-cruiser 1451) | ≈40 (args de 3 comandos) | 268 (stdout 24 + stderr 413) | 3 | 0 | npm audit PASS (0 vulnerabilidades); eslint/dependency-cruiser FAIL (no instalados); veredicto SHIP/NO-SHIP: pendiente (dispatch del reviewer cancelado en el entorno) |
| /archive | 1 | 1128 (medido con date +%s%N; CLI openspec archive) | ≈45 (comando openspec archive ... --yes) | ≈640 (stdout del CLI) | 1 | 0 | PASS (archivado: specs +7 aplicadas; 3 tareas incompletas advertidas por el CLI; veredicto adversarial pendiente) |

## Cómo asentar una medición

### Hallazgos reales del toolchain adversarial (2026-10-03T03:14Z)

- `npm audit`: **exit 0, 708 ms** — "found 0 vulnerabilities" (viable: hay `package-lock.json`).
- `npx eslint` / `npx dependency-cruiser`: **exit 1** — no instalados como dependencias del repo (npx cancelado por paquetes faltantes; sin configuración raíz, solo `templates/ci/.dependency-cruiser.js`).
- **Veredicto SHIP/NO-SHIP**: pendiente — el dispatch del subagente `reviewer` se cancela en el entorno (`Task cancelled`, 2/2 intentos); el wiring del comando es correcto (`agent: reviewer`, `subtask: true`; agente registrado en AGENTS.md §5.4). Hallazgo de entorno, no del repo.
- Medición por build (fallback honesto): la parte mecánica del `/adversarial-review` (toolchain); el veredicto semántico es del reviewer. Bytes etiquetados `aproximación_de_volumen`; nunca tokens medidos.

1. Ejecutar `bash scripts/benchmark-permissions.mjs` para los validadores (la duración se mide automáticamente).
2. Para cada comando del ciclo (`/adversarial-review`, `/archive`): registrar la duración de reloj, el tamaño en bytes del prompt enviado y de la respuesta recibida (ambos como `aproximación_de_volumen`), el número de llamadas y de reintentos, y el resultado de calidad (PASS/PARTIAL/FAIL/SHIP/NO-SHIP).
3. Etiquetar cada dato como `aproximación_de_volumen`; nunca como tokens medidos. Si un comando no llegó a ejecutarse, registrar el fallo real — no atribuir éxito a pruebas no ejecutadas.
