# Proposal: permissions-cycle-completion

**Ticket ID**: M-911
**Título original**: [docs] Completar permisos del ciclo SDD (W5 + inconsistencias)
**Tag**: docs (framework tooling: config, schema, skills, tests)
**Origen**: Plan aprobado por el mantenedor ("resolver todo lo pendiente y de una buena vez todas las inconsistencias entre permisos y tareas del ciclo SDD")

## Why

Tras la auditoría de permisos (M-908) y la higiene del ciclo (M-909), quedan cinco inconsistencias entre los permisos y las tareas que cada paso del ciclo SDD debe ejecutar, más el backlog W5:

1. **`archive` sin `mkdir`**: el agente archive no tiene `"mkdir -p openspec/*": allow` (verify y commit sí); si `openspec/state/` no existe, el Step 5 del skill cae en deny.
2. **Patrón `for` loop**: la verificación integral (`for t in tests/*-test.sh; do bash "$t"; done`) arranca con `for` → `ask` en el primario en cada sesión. Falta un runner canónico cubierto por `"bash tests/*"`.
3. **W5 (backlog Fase 11, ítem 1)**: la lista de rutas de código para el staleness está hardcodeada en `commit/SKILL.md` (`src/`, `app/`, `tests/`, `ai-specs/`, `.opencode/`); proyectos consumidores con `lib/`, `server/`, etc. nunca reciben staleness (falso negativo). Debe ser configurable vía `.specboot.json`.
4. **Backlog ítem 4**: no hay comando canónico documentado para el cómputo git del staleness — el guard aserta marcadores documentales, no la ejecución real.
5. **Trust model sin documentar** (hallazgo warning de M-908): `node *`/`python3 *` en allow son ejecución de código arbitrario, consistentes con `npm *`/`npx *`; hay que documentar la decisión.
6. **`bash check-refs.sh` sin wildcard** (hallazgo info de M-908): invocación con args cae en `ask`.

## What Changes

- `.opencode/agents/archive.md`: añadir `"mkdir -p openspec/*": allow`.
- Nuevo `tests/run-all.sh`: runner canónico (loop de `tests/*-test.sh`), invocable como `bash tests/run-all.sh` (cubierto por `"bash tests/*"`); referenciado como la forma canónica de verificación integral.
- `.specboot.json` + `docs/specboot-json-standard.md` + `validate-specboot.sh`: campo opcional `"stalenessPaths"` (array de strings) con default `["src", "app", "tests", "ai-specs", ".opencode"]`.
- `ai-specs/skills/commit/SKILL.md`: el staleness lee `stalenessPaths` token-light (`node -e`) con fallback al default; documentar el comando canónico git del cómputo (`git log --format="%H %ad" --date=iso -5 -- <paths>`).
- `docs/framework-contract.md`: trust model `node *`/`python3 *` documentado.
- `opencode.json`: añadir `"bash check-refs.sh *"` allow.
- Guards: `tests/agent-permissions-test.sh` extendido + `tests/commit-gate-test.sh` (staleness configurable) + fixture actualizado.

## Fuera de alcance

- Tags/backfill de releases: change `release-tagging` (siguiente, aprobado).
- F-harness: ya documentado (sin acción).
- Bump de versión: `release-bump` del mantenedor.

## Nivel SemVer

`minor` (W5 añade capacidad configurable; el resto es consistencia patch).
