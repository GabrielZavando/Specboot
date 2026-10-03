# Proposal: permission-baseline — Línea base y protección de permisos

- **Ticket ID**: SPECBOOT-PREC-01
- **Título original**: Línea base y protección de permisos
- **Tag**: `[docs]` (inferido desde el artefacto enriquecido, confirmado por el usuario)
- **Change name**: `permission-baseline`
- **Baseline SHA (main al iniciar el feature)**: `b252a63`
- **Branch**: `feature/specboot-prec-01-baseline`
- **Enriched artifact (fuente primaria)**: `openspec/tickets/SPECBOOT-PREC-01-enriched.md`

## Why

El ciclo SDD de Specboot es una caja negra: no hay métricas reales de tokens, tiempo, llamadas ni reintentos, y cualquier optimización futura podría alterar los permisos efectivos de los agentes sin detección. Este feature precursor (PREC-01) establece una línea base reproducible —identificada por el SHA de `main` al iniciar (b252a63)— y una prueba de regresión que fiscaliza las capacidades efectivas (edición, comandos, delegación, ownership de evidencia y Git) de los 9 agentes contra esa referencia, reutilizando el validador y las fixtures existentes sin modificarlos. Sin esta línea base, las optimizaciones (PREC-02+) no serían medibles. Métricas: solo aproximación de volumen (`aproximación_de_volumen`, bytes de prompts/respuestas); benchmark semimanual con plantilla; el orquestador automatizado queda para SPECBOOT-REL-01.

## What Changes

Incluido:

- Baseline reproducible con separación estricta de ubicación: `docs/` aloja el reporte legible por humanos (metodología, cómo reproducirlo, conclusiones de la línea base); `openspec/state/` aloja los datos crudos (JSONs con métricas, tiempos, bytes y resultados de validadores) para consumo futuro del framework.
- Prueba de regresión de capacidades efectivas (`tests/baseline-capabilities-test.sh`) contra la referencia: edición, comandos permitidos/prohibidos, delegación `task`, ownership de evidencia y Git (REQ-003).
- Fixtures negativas nuevas SOLO para casos no cubiertos (mapeo SC-011): build escribe evidencia ajena, verify/reviewer editan código, commit lanza subagentes (REQ-004, REQ-005).
- Script auxiliar sencillo en `scripts/` que ejecuta los validadores de permisos existentes + plantilla de registro semimanual (JSON/Markdown) para asentar duración, llamadas, reintentos, resultado de calidad y bytes medidos al correr `/adversarial-review` y `/archive` sobre un par de cambios representativos (REQ-006, REQ-007, REQ-009).
- Registro del entorno: versión de Specboot, versión/configuración de OpenCode/OpenSpec, modelo usado, comandos de prueba, SHA de `main` — sin credenciales (REQ-001, REQ-002).
- Métricas etiquetadas explícitamente como `aproximación_de_volumen` (bytes/caracteres de prompts y respuestas); nunca tokens calculados matemáticamente.

Fuera de alcance (per ticket): cambiar permisos, modelos, roles o etapas; optimizar prompts, contexto o salidas; implementar mejoras de velocidad; tocar staging/commit fuera de las pruebas de permisos; cambiar permission blocks ni relajar el manifiesto para que una prueba pase; ampliar indirectamente capacidades mediante scripts ya permitidos; construir un orquestador de benchmarks automatizado (corresponde a SPECBOOT-REL-01).
