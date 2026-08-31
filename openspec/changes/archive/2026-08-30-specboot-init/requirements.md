# Requirements: specboot init

1. `specboot.sh` MUST expose an `init` subcommand (distinct from `--init`) that bootstraps a new project (REQ-1) -> Scenario 1, Scenario 7

2. `init` MUST abort (warning + exit 0) if `.specboot.json` already exists in the target directory, advising `specboot update` instead (REQ-2) -> Scenario 2

3. `init` MUST resolve the framework source directory, preferring `node_modules/@gabrielzavando/specboot` when present and falling back to the script's own directory (REQ-3) -> Scenario 1, Scenario 4

4. `init` MUST copy the framework's intocable files (the `package.json` `files` allowlist) from the resolved source into the target directory (REQ-4) -> Scenario 1

5. `init` MUST create `.specboot.json` in the target directory with default values (`frameworkVersion` from the framework, `services: ["."]`, `stack: "framework"`) or, when `--interactive` is passed, with values collected from the user (REQ-5) -> Scenario 1, Scenario 3

6. `init` MUST create the project-owned `docs/` skeleton (placeholder templates for backend/frontend/ci/deploy/documentation standards, `project/{domain,stack,client}.md`, `api/api-spec.yml`, `data-model/data-model.md`) when `docs/` is missing (REQ-6) -> Scenario 6

7. `init` MUST NOT overwrite files already present in the target directory; existing files are skipped with a warning (REQ-7) -> Scenario 5

8. `init` MUST support a `--template <dir>` flag that overrides the resolved framework source (REQ-8) -> Scenario 4

9. The existing `specboot.sh --init` verification command MUST remain functional and unchanged in behavior (REQ-9) -> Scenario 7

10. `docs/framework-contract.md` MUST contain a section documenting "Inicialización con `specboot init`" (REQ-10) -> Scenario 8

11. `README.md` MUST include a usage example of `specboot init` (REQ-11) -> Scenario 8

12. After the change, `bash check-refs.sh` and `bash specboot.sh --ci` MUST both exit 0, and `openspec validate specboot-init` MUST pass (REQ-12) -> Scenario 8
