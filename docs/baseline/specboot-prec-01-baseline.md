# Línea base de Specboot — SPECBOOT-PREC-01 (permission-baseline)

> Reporte legible por humanos. Los datos crudos (JSONs con métricas, tiempos,
> bytes y resultados de validadores) viven en `openspec/state/baseline/`
> (separación estricta de ubicación). Este reporte documenta la metodología,
> cómo reproducir la línea base y sus conclusiones.

## Metodología

- **Rama del feature**: `feature/specboot-prec-01-baseline`, creada desde el estado más reciente de `main`.
- **SHA de baseline (main al iniciar el feature)**: `b252a63` — "Merge pull request #41 from GabrielZavando/feature/specboot-hotfix-01-ci-yaml-fix".
- **Entorno registrado** (sin credenciales): Specboot 0.11.1 (`package.json` = `.specboot.json#frameworkVersion`); OpenSpec CLI 1.3.1; OpenCode CLI 1.18.34; Node v22.23.3; configuración de OpenCode desde `opencode.json` (provider OmniRoute vía `@ai-sdk/openai-compatible`, `baseURL http://localhost:20128/v1`, `apiKey` por referencia `{env:OMNIROUTE_API_KEY}` — el valor nunca se registra; modelos `auto/*`; sin campo `model` — configuración agnóstica al modelo, gestión externa).
- **Modelo usado** (sesión activa): `z-ai/glm-5.3-flash` (id `nvidia/z-ai/glm-5.3-flash`, según lo reportado por la sesión).
- **Validadores ejecutados** (resultados reales conservados en `openspec/state/baseline/`):
  1. `node scripts/validate-agent-permissions.mjs --root .`
  2. `node scripts/validate-command-contracts.mjs --root .`
  3. `bash specboot.sh --ci`
  4. `bash tests/run-all.sh`
- **Prueba de regresión**: `bash tests/baseline-capabilities-test.sh` — comparación de capacidades efectivas contra la referencia + fixtures negativas (SC-001…SC-008).
- **Política de métricas**: solo `aproximación_de_volumen` (bytes/caracteres de entrada y salida, contando el tamaño de prompts y respuestas). Los agentes no tienen permisos para consultar APIs de billing/usage del proveedor; prohibido calcular o estimar tokens matemáticamente.

## Cómo reproducirlo

Desde la raíz del repositorio, sobre la referencia (o la rama del feature):

```bash
# 1. Referencia
git rev-parse main                       # SHA de la referencia (b252a63 al iniciar)

# 2. Validadores existentes (resultados reales)
node scripts/validate-agent-permissions.mjs --root .
node scripts/validate-command-contracts.mjs --root .
bash specboot.sh --ci
bash tests/run-all.sh

# 3. Prueba de regresión de capacidades efectivas
bash tests/baseline-capabilities-test.sh

# 4. Benchmark semimanual (plantilla en openspec/state/benchmark/)
bash scripts/benchmark-permissions.mjs
```

Los datos crudos del baseline están en `openspec/state/baseline/*.json`; este reporte resume los resultados. Cualquier optimización futura (PREC-02+) debe compararse contra esta referencia.

## Conclusiones

- `validate-agent-permissions.mjs`: **OK** — 9 agentes validados contra el manifiesto, exit 0. La matriz de permisos no presenta diferencias respecto a la referencia: 0 deltas en edición, comandos, delegación, ownership de evidencia y Git.
- `validate-command-contracts.mjs`: **OK** — 11 comandos validados desde el front matter, exit 0.
- `bash specboot.sh --ci`: **0 errores, 0 warnings**, exit 0 — check-refs (20 referencias, 0 errores), `.specboot.json` válido (0.11.1 = instalada), estructura, placeholders, opencode.json, skills, ejemplos, CI/CD y contratos de permisos/comandos conformes. Husky no instalado (opcional, info).
- `bash tests/run-all.sh`: **31 passed, 0 failed**, exit 0 — incluye el nuevo `tests/baseline-capabilities-test.sh`. Primera ejecución: 30 passed, 1 failed (bug de mayúsculas en una aserción del propio test nuevo, `Reproduc` vs `reproducirlo` — corregido en el ciclo RED→GREEN).
- Prueba de regresión `baseline-capabilities-test.sh`: ciclo RED→GREEN documentado — RED con 15 fallas esperadas (snapshot ausente, SC-001/SC-002) y 1 pase (guardia SC-003); GREEN tras registrar el snapshot.

## Benchmark inicial (semimanual)

- **Par** (confirmado por el usuario: framework + docs): cambio de framework = las partes framework de este ciclo (`tests/baseline-capabilities-test.sh`, `tests/benchmark-recorder-test.sh`, `scripts/benchmark-permissions.mjs`, fixtures); cambio de documentación = `docs/baseline/specboot-prec-01-baseline.md`. Fallback documentado: fixtures de `tests/fixtures/benchmark-changes/{framework,docs}/` (sin código nuevo de aplicación).
- **Validadores medidos** (reales, `scripts/benchmark-permissions.mjs`, 2026-10-02T22:54:50Z): `validate-agent-permissions` 200.9 ms (exit 0); `validate-command-contracts` 235.5 ms (exit 0).
- **Comandos del ciclo** (`/adversarial-review`, `/archive`): se asientan en `openspec/state/benchmark/registro-inicial.md` cuando se ejecuten (duración, llamadas, reintentos, resultado de calidad y bytes como `aproximación_de_volumen`). Los invoca el usuario: despachan a `reviewer`/`archive` y el contrato de subagentes del build lo prohíbe (ownership protegido por este baseline).
- **Baseline only**: sin optimizaciones ni conclusiones de mejora en este registro (corresponden a PREC-02+).

(Actualizado junto con el código del change, no después.)
