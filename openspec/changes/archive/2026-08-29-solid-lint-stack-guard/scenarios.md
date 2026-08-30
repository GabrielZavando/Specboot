# Scenarios: `make solid-lint` — stack guard + eslint@8 pin

## Acceptance Criteria

### Scenario 1: Framework repo (stack "framework") skips cleanly
- Given the Specboot repo with `.specboot.json` declaring `stack: "framework"` and no application code
- When `make solid-lint` runs
- Then it prints a message that `stack` does not include node/python and **skips** the app linters, exiting 0 (no error)

### Scenario 2: Node project runs ESLint 8 (no flat-config crash)
- Given a project with `.specboot.json` `stack: ["node"]` and TypeScript sources
- When `make solid-lint` runs
- Then it invokes `npx eslint@8` (pinned) against the sources and does **not** fail with the "root key not supported in flat config" error

### Scenario 3: Python project runs ruff/import-linter
- Given a project with `.specboot.json` `stack: ["python"]`
- When `make solid-lint` runs
- Then it runs the Python family (ruff, import-linter) and skips the Node family

### Scenario 4: Legacy project without `.specboot.json` keeps old behavior
- Given a project with `package.json` but no `.specboot.json`
- When `make solid-lint` runs
- Then it behaves as before (node family from `package.json` presence), preserving backward compatibility

### Scenario 5: Node declared but no ESLint config fails loudly
- Given a project with `.specboot.json` `stack: ["node"]` but `templates/ci/eslintrc.backend.js` absent
- When `make solid-lint` runs
- Then it still reports "application code found but no SOLID config applies" and exits 1 (preserves the loud failure)

### Scenario 6: Framework validation shows no regression
- Given the change applied
- When `bash check-refs.sh` and `bash specboot.sh --ci` run
- Then `check-refs.sh` reports 0 errors and `specboot.sh --ci` reports no new errors/warnings
