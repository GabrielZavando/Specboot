# Scenarios: force-push-deny-and-doc-distribution

### SC-001: el doc canónico se publica en el paquete
- Given el package.json del framework
- When se inspecciona la allowlist `files`
- Then `docs/tdd-failure-protocol.md` está listado (7 docs intocables)

### SC-002: init copia el doc canónico
- Given un proyecto vacío donde corre `specboot init`
- When finaliza la instalación
- Then `docs/tdd-failure-protocol.md` existe en el proyecto destino

### SC-003: update propaga el doc canónico
- Given un proyecto consumidor con una versión anterior del framework
- When corre `specboot update`
- Then `docs/tdd-failure-protocol.md` es creado/actualizado por el reemplazo de UPDATE_ITEMS

### SC-004: specs y docs de distribución sincronizados
- Given los artefactos de distribución
- When se leen `docs/docs-standard.md`, `docs/framework-contract.md` (si lista docs) y las specs `npm-distribution`/`specboot-update`
- Then el conjunto de docs intocables dice 7 (no 6) en todos ellos

### SC-005: force-push denegado en todas sus variantes
- Given el permission block del agente commit
- When se evalúan los comandos `git push --force`, `git push -f`, `git push origin <branch> --force` y `git push origin <branch> -f`
- Then todos caen en un pattern deny y ninguno en el allow genérico `git push *`

### SC-006: rol espejo de los permisos (M-403)
- Given el rol del agente commit
- When se compara con su permission block
- Then todo deny/allow documentado en el rol tiene su pattern correspondiente y viceversa

### SC-007: guards verdes y versionado patch
- Given todos los cambios aplicados
- When corren los guards, `check-refs.sh` y `specboot.sh --ci`
- Then todo pasa, con CHANGELOG y bump patch `0.8.0 → 0.8.1`
