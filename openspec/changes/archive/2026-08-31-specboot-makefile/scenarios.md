# Scenarios: `Makefile` del framework parametrizado por `.specboot.json`

## Acceptance Criteria

### Scenario 1: Proyecto multi-servicio node aplica lint/test por servicio
- Given a project with `.specboot.json` declaring `services: ["backend", "frontend"]` and `stack: ["node"]`, each service having a `package.json` with `lint`/`test` scripts
- When `make ci` runs
- Then `lint`, `test` and `solid-lint` are applied to **both** `backend` and `frontend`, and `refs` passes

### Scenario 2: Sin `services` declarados usa default `["."]`
- Given a project with `.specboot.json` that declares `stack` but omits `services` (or has an empty/missing array)
- When `make lint` runs
- Then the Makefile defaults to the repository root (`["."]`) and lints the root

### Scenario 3: `stack: ["node"]` pero un servicio no tiene `package.json`
- Given a project with `.specboot.json` `services: ["api", "legacy"]`, `stack: ["node"]`, where `legacy` has no `package.json`
- When `make lint` runs
- Then `api` is linted and `legacy` prints a warning and is **skipped**; the Makefile exits 0 (no error)

### Scenario 4: `stack: "framework"` (repo del framework) salta limpio
- Given the Specboot repo with `.specboot.json` declaring `services: ["."]` and `stack: "framework"`
- When `make ci` runs
- Then `refs` passes, all app targets (`lint`/`test`/`build`/`audit`/`solid-lint`) print a skip message, and `make ci` exits 0

### Scenario 5: Servicio declarado inexistente → advertencia, no error
- Given a project with `.specboot.json` `services: ["backend", "ghost"]` where `ghost` does not exist on disk
- When `make lint` runs
- Then `backend` is linted, `ghost` prints a warning (`servicio no existe, saltando`) and is skipped; exit 0

### Scenario 6: `stack: "auto"` autodetecta por manifiestos
- Given a project with `.specboot.json` declaring `stack: "auto"` (or omitting `stack`) and a `backend/` dir with `package.json` plus a `data/` dir with `pyproject.toml`
- When `make lint` runs
- Then node commands run in `backend` and python commands run in `data` (auto-detected)

### Scenario 7: `lint` usa el lint propio del proyecto; `solid-lint` usa el SOLID del framework
- Given a node project with `.specboot.json` `stack: ["node"]`
- When `make lint` runs
- Then it invokes the project's own `npm run lint` (not the framework's `eslintrc.backend.js`)
- When `make solid-lint` runs
- Then it invokes the framework's SOLID toolchain (`eslint@8` + `dependency-cruiser`)

### Scenario 8: `ci` es gate del proyecto; `specboot.sh --ci` queda fuera
- Given any project
- When `make ci` runs
- Then it executes `refs` + `solid-lint` + `lint` + `test` + `audit` and does **not** invoke `specboot.sh --ci` (framework self-check)
- And `specboot.sh --ci` remains a separate command run only by the framework developer (dogfooding)

### Scenario 9: Sin regresión en validaciones del framework
- Given the change applied to the framework repo
- When `bash check-refs.sh` and `bash specboot.sh --ci` run
- Then `check-refs.sh` reports 0 errors and `specboot.sh --ci` reports no new errors/warnings
