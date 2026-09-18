# Scenarios: release-tagging

### SC-001: release-bump crea el tag local al finalizar
- Given `release-bump.sh` ejecutado con una versión válida sobre el repo
- When el bump termina sin errores
- Then existe el tag local `v{version}` creado con un mensaje consistente y el fallback sin-tag muestra warning si la creación falla

### SC-002: update.sh --bump lee la versión desde package.json
- Given un repo cuyo último tag histórico es `v0.6.3` pero `package.json` está en `0.9.0`
- When el maintainer corre `bash update.sh --bump minor`
- Then la nueva versión calculada parte de `package.json` (0.9.0 + minor = 0.10.0), no del tag histórico

### SC-003: Política documentada de tags y GitHub Releases
- Given el lector de `docs/versioning-standard.md`
- When consulta la política de releases
- Then documenta que `release-bump.sh` crea el tag local `v{version}`, que el push del tag tramsite el merge a `main`, y que el GitHub Release se crea manualmente desde la UI cuando se desea; y que `release.yml` publica el paquete npm en push a `main` con publish idempotente (no depende de tags)

### SC-004: Backfill de tags históricos
- Given los commits de bump de cada versión en el histórico (0.6.4→`a797e2e`, 0.7.0→`85d92a0`, 0.8.0→`9d44db7`, 0.8.1→`24d1dbc`, 0.9.0→`392fb2b`)
- When se ejecuta `git tag vX.Y.Z <sha>` y `git push origin --tags`
- Then los tags creados aparecen en GitHub sin disparar `release.yml` (los triggers son push:main / release published, no tags)

### SC-005: Sin regresión tras el change
- Given el change aplicado
- When se ejecuta la verificación integral (`bash tests/run-all.sh`, `check-refs.sh`, `specboot.sh --ci`, `validate-specboot.sh`)
- Then todos pasan en verde (persistence de estado en verify-results.json y adversarial-result.json vigente)
