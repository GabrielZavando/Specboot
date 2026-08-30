# Capability: solid-lint

Make `make solid-lint` honor the project-declared `.specboot.json` `stack` and pin ESLint to v8, so the framework's own CI (and any stack-only-framework project) passes instead of crashing on an ESLint 10 flat-config incompatibility. Preserves consumer projects that instantiate `templates/ci/eslintrc.*.js` with ESLint 8.

## ADDED Requirements

### Requirement: solid-lint honors .specboot.json stack
`make solid-lint` MUST read the `stack` field from `.specboot.json` (string or array) and only run the Node lint family when `node` is in `stack`, and the Python family when `python` is in `stack`. When neither applies (e.g. `framework`), it MUST print a skip message and exit 0 — no linters, no error.

#### Scenario: Framework repo (stack framework) skips cleanly
- **Given** the Specboot repo with `.specboot.json` declaring `stack: "framework"` and no application code
- **When** `make solid-lint` runs
- **Then** it prints that `stack` does not include node/python and skips the app linters, exiting 0

#### Scenario: Node project runs the node family
- **Given** a project with `.specboot.json` `stack: ["node"]`
- **When** `make solid-lint` runs
- **Then** the Node lint family (eslint backend/frontend/astro, dependency-cruiser, madge) is eligible and the Python family is skipped

#### Scenario: Python project runs the python family
- **Given** a project with `.specboot.json` `stack: ["python"]`
- **When** `make solid-lint` runs
- **Then** the Python family (ruff, import-linter) runs and the Node family is skipped

#### Scenario: Legacy project without .specboot.json keeps old behavior
- **Given** a project with `package.json` but no `.specboot.json`
- **When** `make solid-lint` runs
- **Then** it behaves as before (node family from `package.json` presence)

### Requirement: ESLint pinned to v8
The three ESLint invocations in `make solid-lint` MUST use `npx eslint@8` (pinned major), so a project without a local ESLint install never fetches ESLint 10 (flat-config only), which rejects the legacy `eslintrc.*.js` configs (`root: true`).

#### Scenario: Node project invokes eslint@8 without flat-config crash
- **Given** a project with `.specboot.json` `stack: ["node"]` and TypeScript sources
- **When** `make solid-lint` runs
- **Then** it invokes `npx eslint@8` against the sources and does NOT fail with "root key not supported in flat config"

### Requirement: README documents the stack guard
`templates/ci/README.md` MUST state that `make solid-lint` skips app linters when `.specboot.json` `stack` does not include `node`/`python`.

#### Scenario: README reflects stack-aware skip
- **Given** the change lands
- **When** a developer reads `templates/ci/README.md`
- **Then** it notes the stack-aware skip behavior

### Requirement: No regression in framework checks
After the change, `check-refs.sh` MUST report 0 errors and `specboot.sh --ci` MUST show no new errors/warnings.

#### Scenario: Framework validation green
- **Given** the change applied
- **When** `check-refs.sh` and `specboot.sh --ci` run
- **Then** both pass with no new errors
