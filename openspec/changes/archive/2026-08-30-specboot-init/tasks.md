# Tasks: specboot init

## 1. Implementation — specboot.sh init subcommand

- [x] 1.1 Add `init` case to the `specboot.sh` argument parser (distinct from `--init`), wiring it to a `run_init_project` function (High | backend | 0.5h)
    - Suggested Path: `specboot.sh`
    - Test Path: `bash tests/specboot-init-test.sh`
- [x] 1.2 Implement `determine_framework_dir` — resolves source from `node_modules/@gabrielzavando/specboot` else script dir, overridable by `--template` (High | backend | 0.5h)
    - Suggested Path: `specboot.sh`
- [x] 1.3 Implement `copy_framework_files` — copies the `package.json` `files` allowlist into the target, skipping existing files with a warning (High | backend | 1h)
    - Suggested Path: `specboot.sh`
- [x] 1.4 Implement `create_initial_specboot_json` — writes `.specboot.json` with defaults, or interactive values when `--interactive` is set (High | backend | 0.5h)
    - Suggested Path: `specboot.sh`
- [x] 1.5 Implement `create_docs_skeleton_if_missing` — scaffolds project-owned `docs/` placeholder templates when `docs/` is absent (High | backend | 0.5h)
    - Suggested Path: `specboot.sh`
- [x] 1.6 Add guard: if `.specboot.json` exists, warn and exit 0 advising `specboot update` (High | backend | 0.25h)
    - Suggested Path: `specboot.sh`

## 2. Tests (TDD)

- [x] 2.1 Create `tests/specboot-init-test.sh` with RED tests: init in empty dir, guard on existing config, no-overwrite, docs skeleton, --template override (High | backend | 1h)
    - Test Path: `bash tests/specboot-init-test.sh`
- [x] 2.2 Make the RED tests pass by completing the `init` implementation (High | backend | 1h)
    - Test Path: `bash tests/specboot-init-test.sh`

## 3. Documentation

- [x] 3.1 Add "Inicialización con `specboot init`" section to `docs/framework-contract.md` (High | docs | 0.5h)
    - Suggested Path: `docs/framework-contract.md`
- [x] 3.2 Add `specboot init` usage example to `README.md` (Medium | docs | 0.25h)
    - Suggested Path: `README.md`

## 4. Verification

- [x] 4.1 `bash check-refs.sh` exits 0 (High | backend | 0.25h)
    - Test Path: `bash check-refs.sh`
- [x] 4.2 `bash specboot.sh --ci` exits 0 (High | backend | 0.25h)
    - Test Path: `bash specboot.sh --ci`
- [x] 4.3 `openspec validate specboot-init` passes (High | backend | 0.25h)
    - Test Path: `openspec validate specboot-init`
- [x] 4.4 Manual smoke test: run `specboot init` in a temp empty directory and verify files are created (High | backend | 0.25h)
