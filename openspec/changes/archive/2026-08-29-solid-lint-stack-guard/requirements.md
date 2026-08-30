# Requirements: `make solid-lint` — stack guard + eslint@8 pin

## REQ-001: solid-lint honors `.specboot.json` stack
### Description
`make solid-lint` MUST read the `stack` field from `.specboot.json` (string or array) and only run the Node lint family when `node` is in `stack`, and the Python family when `python` is in `stack`.
### Requirements
- **REQ-001.1:** `APP_STACKS` is read from `.specboot.json` `stack`, normalized so a string becomes a single-element list.
- **REQ-001.2:** Node family (eslintrc.backend.js / frontend.js / astro.js, dependency-cruiser, madge) runs only if `node` ∈ `APP_STACKS`.
- **REQ-001.3:** Python family (ruff, import-linter) runs only if `python` ∈ `APP_STACKS`.
- **REQ-001.4:** If neither `node` nor `python` is in `stack` (e.g. `framework`), the target prints a skip message and exits 0 (no linters, no error).
### Acceptance Criteria
- [ ] `stack: "framework"` → skip + exit 0.
- [ ] `stack: ["node","python"]` → both families eligible.
- [ ] `stack: "node"` → only Node family.

---

## REQ-002: ESLint pinned to v8
### Description
The three ESLint invocations in `make solid-lint` MUST use `npx eslint@8` (pinned major), so a project without a local ESLint install never fetches ESLint 10 (flat-config only), which rejects the legacy `eslintrc.*.js` configs.
### Requirements
- **REQ-002.1:** `npx eslint -c ...` → `npx eslint@8 -c ...` in backend, frontend, and astro invocations.
- **REQ-002.2:** `npx eslint@8` resolves a flat-config-incompatible ESLint 8 that accepts the legacy `root: true` configs (matching `package.ci.json` pin).
### Acceptance Criteria
- [ ] Invocations use `eslint@8`.
- [ ] No "root key not supported in flat config" error.

---

## REQ-003: README documents the stack guard
### Description
`templates/ci/README.md` MUST state that `make solid-lint` skips app linters when `.specboot.json` `stack` does not include `node`/`python`.
### Requirements
- **REQ-003.1:** README notes the stack-aware skip behavior.
### Acceptance Criteria
- [ ] Doc reflects the new behavior.

---

## REQ-004: No regression in framework checks
### Description
After the change, `check-refs.sh` and `specboot.sh --ci` must not introduce new errors.
### Requirements
- **REQ-004.1:** `check-refs.sh` → 0 errors.
- **REQ-004.2:** `specboot.sh --ci` → no new errors/warnings vs TICKET-0.3 baseline.
### Acceptance Criteria
- [ ] Both green.

---

## Technical Constraints
| Constraint | Description |
|------------|-------------|
| Files touched | `Makefile`, `templates/ci/README.md` (both intocable framework, evolved via dogfooding) |
| Stack input | `.specboot.json` `stack` (TICKET-0.3 schema) |
| ESLint | pinned `@8`, matching consumer `package.ci.json` |
| Backward compat | projects without `.specboot.json` keep old behavior |

## Dependencies
- TICKET-0.3 (`.specboot.json` `stack` field consumed here).

## Out of Scope
- Flat-config migration of `eslintrc.*.js` (would bump consumer `eslint`/plugin versions; risky, untestable here).
- SOLID threshold changes.
- TICKET-0.4 SemVer rules.
