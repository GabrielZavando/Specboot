# Escenarios de medición — fixtures de cambios representativos

> Las tres condiciones del ticket que el benchmark semimanual registra en
> `openspec/state/benchmark/registro-inicial.md`, con etiqueta
> `aproximación_de_volumen` en todos los datos. Aplican a cada fixture del
> conjunto (backend, frontend, framework, docs).

## 1. Reanudación de sesión

- Given el ciclo se interrumpió a mitad de este cambio representativo
- When se reanuda el ciclo y se registra la medición
- Then el estado de reanudación queda registrado (tareas completadas/pendientes) sin fabricar métricas

## 2. Evidencia ausente

- Given `openspec/state/verify-results.json` no existe para este cambio
- When el ciclo intenta continuar sin evidencia
- Then el ciclo falla fail-closed o registra la ausencia — no se fabrica éxito

## 3. Modificación posterior a una verificación

- Given el contenido de este cambio se modificó después de una verificación
- When se registra la medición del ciclo
- Then la evidencia desactualizada y el delta quedan detectados y registrados
