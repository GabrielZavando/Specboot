# Capability: specboot-makefile

Make the framework `Makefile` (intocable) parametrizable via `.specboot.json` `services` and `stack`, so a project adapts lint/test/build/audit/install per service without editing the Makefile. `make ci` becomes the project's CI gate; `specboot.sh --ci` remains a separate framework self-check (dogfooding).

## ADDED Requirements

### Requirement: Makefile reads `.specboot.json` with `node -e` (no `jq`)
The Makefile MUST read `services` and `stack` from `.specboot.json` using `node -e` (framework convention). If `services` is missing/empty it defaults to `["."]`; if `stack` is missing or `"auto"` it auto-detects per manifest presence.

#### Scenario: services default to root when omitted
- **Given** a project with `.specboot.json` that omits `services`
- **When** `make lint` runs
- **Then** the Makefile defaults to the repository root (`["."]`) and lints it

#### Scenario: stack auto-detects from manifests
- **Given** a project with `.specboot.json` `stack: "auto"` and a `backend/` dir with `package.json` plus `data/` with `pyproject.toml`
- **When** `make lint` runs
- **Then** node commands run in `backend` and python commands run in `data`

#### Scenario: no jq dependency introduced
- **Given** the change applied
- **When** `make` evaluates `SERVICES`/`STACK`
- **Then** it uses `node -e` and never invokes `jq`

### Requirement: Per-service iteration with stack guard
The targets `install`, `lint`, `test`, `build`, `audit` and `solid-lint` MUST iterate over `SERVICES` and apply tooling only when the service's stack applies (`node`/`python`), using a shell loop (not generated pattern rules).

#### Scenario: multi-service node project lints per service
- **Given** a project with `.specboot.json` `services: ["backend","frontend"]`, `stack: ["node"]`, each with a `lint` script
- **When** `make ci` runs
- **Then** `lint`, `test` and `solid-lint` apply to both `backend` and `frontend`

#### Scenario: stack framework skips app tooling
- **Given** the Specboot repo with `.specboot.json` `services: ["."]`, `stack: "framework"`
- **When** `make ci` runs
- **Then** all app targets print a skip message and `make ci` exits 0

### Requirement: `lint` runs project lint; `solid-lint` runs framework SOLID
`make lint` MUST run the project's own lint (`npm run lint` / `ruff check .`); `make solid-lint` MUST run the framework SOLID toolchain (`eslint@8` + `dependency-cruiser` + `ruff` + `import-linter`), preserving the stack guard.

#### Scenario: lint uses project script, not framework config
- **Given** a node project with `.specboot.json` `stack: ["node"]`
- **When** `make lint` runs
- **Then** it invokes the project's `npm run lint` (not `templates/ci/eslintrc.backend.js`)

#### Scenario: solid-lint uses framework toolchain
- **Given** a node project with `.specboot.json` `stack: ["node"]`
- **When** `make solid-lint` runs
- **Then** it invokes `eslint@8` and `dependency-cruiser` from `templates/ci/`

### Requirement: Graceful skip without error
The Makefile MUST NOT error when a service does not exist, lacks the active stack, or lacks the required script; it prints a warning and continues (exit 0).

#### Scenario: nonexistent service warns and skips
- **Given** a project with `.specboot.json` `services: ["backend","ghost"]` where `ghost` does not exist
- **When** `make lint` runs
- **Then** `backend` is linted, `ghost` warns and is skipped, exit 0

#### Scenario: service without script warns and skips
- **Given** a node service with `package.json` but no `lint` script
- **When** `make lint` runs
- **Then** it prints a warning and skips (no "Missing script" error)

### Requirement: `ci` is the project gate; `specboot.sh --ci` excluded
`make ci` MUST run `refs` + `solid-lint` + `lint` + `test` + `audit`. It MUST NOT invoke `specboot.sh --ci` (framework self-check).

#### Scenario: ci runs project gate only
- **Given** any project
- **When** `make ci` runs
- **Then** it executes `refs`, `solid-lint`, `lint`, `test`, `audit` and does not call `specboot.sh --ci`

### Requirement: `validate-specboot` target provided
The Makefile MUST provide a `validate-specboot` target that runs `validate-specboot.sh` if present; if absent, it warns and exits 0.

#### Scenario: validate-specboot absent is not an error
- **Given** a project without `validate-specboot.sh`
- **When** `make validate-specboot` runs
- **Then** it prints a warning and exits 0

### Requirement: Documentation describes the parametrizable Makefile
`docs/framework-contract.md` MUST include a "Makefile del framework" section (intocable, parametrizable via `services`/`stack`, `ci` = project gate, `specboot.sh --ci` = framework self-check). `README.md` MUST show a `.specboot.json` example with `services`/`stack`.

#### Scenario: docs reflect behavior without broken refs
- **Given** the change applied
- **When** `bash check-refs.sh` runs
- **Then** it reports 0 errors (no broken `{file:...}` references introduced)

### Requirement: No regression in framework checks or existing CI
After the change, `check-refs.sh` and `specboot.sh --ci` MUST stay green, and the existing CI jobs (`make install/lint/test/build/audit/solid-lint/commitlint`) MUST keep working for single-service/root projects.

#### Scenario: framework self-check stays green
- **Given** the change applied to the framework repo
- **When** `bash check-refs.sh` and `bash specboot.sh --ci` run
- **Then** both pass with no new errors
