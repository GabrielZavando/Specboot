# Requirements: Restrict package.json to framework-only distribution

1. `package.json` MUST declare the package `@gabrielzavando/specboot` with a `files` allowlist shipping only intocable framework assets (REQ-1) -> Scenario 1, Scenario 4
2. The `files` allowlist MUST exclude project/repo state: project `docs/` (whole tree), `openspec/`, `node_modules/`, `tests/`, `.git/`, and the standalone `update.sh` (REQ-2) -> Scenario 1, Scenario 4
3. `package.json` MUST declare `bin.specboot` -> `./specboot.sh`, plus `scripts` (check/validate/ci), a `description` without the word "template", and framework `keywords` (REQ-3) -> Scenario 1
4. `.npmignore` MUST be reconciled so it does not block any allowlisted path and still excludes internal state (REQ-4) -> Scenario 2
5. `specboot.sh` REQUIRED_FILES MUST NOT list `update.sh` (REQ-5) -> Scenario 3
6. `npm pack --dry-run` MUST produce a tarball matching Scenarios 1-4, and `check-refs.sh` and `specboot.sh --ci` MUST exit 0 (REQ-6) -> Scenario 1, Scenario 3
7. The `npm-distribution` capability spec MUST be updated to the new allowlist/exclusions (REQ-7) -> Scenario 1, Scenario 4
