# Scenarios: Workflow de release que publica a npm tras merge a main

## Acceptance Criteria

### Scenario 1: `release.yml` triggers on push to `main`
- Given the Specboot framework repo with `.github/workflows/release.yml`
- When a commit is pushed to the `main` branch
- Then the `release` workflow is triggered
- And the `validate` job runs

### Scenario 2: `release.yml` triggers on GitHub Release published
- Given the Specboot framework repo with `.github/workflows/release.yml`
- When a GitHub Release is published (release event, `types: [published]`)
- Then the `release` workflow is triggered
- And the `validate` job runs

### Scenario 3: `validate` job runs full framework self-check
- Given the Specboot framework repo (has `tests/*-test.sh`, `check-refs.sh`, `specboot.sh`, `Makefile`, `.specboot.json` with `stack: "framework"`)
- When the `validate` job runs
- Then it executes `bash check-refs.sh`, `bash specboot.sh --ci`, `make ci`, and all `tests/*-test.sh` scripts
- And if any step fails, the job exits non-zero

### Scenario 4: `publish` job runs only after `validate` passes
- Given the `release.yml` workflow has `validate` and `publish` jobs
- When the `validate` job succeeds
- Then the `publish` job starts (via `needs: validate`)
- When the `validate` job fails
- Then the `publish` job is skipped

### Scenario 5: `publish` publishes to GitHub Packages with GITHUB_TOKEN
- Given the `publish` job runs after `validate` passes
- When `npm pack --dry-run` succeeds and `npm publish` executes
- Then it publishes to `https://npm.pkg.github.com` (from `publishConfig` in `package.json`)
- And it uses `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}` with `permissions: packages: write`

### Scenario 6: `release.yml` YAML is valid and has no job-level `hashFiles`
- Given the `release.yml` file exists
- When `python -c "import yaml; yaml.safe_load(open('.github/workflows/release.yml'))"` runs
- And `grep -nE '^\s*if:.*hashFiles' .github/workflows/release.yml` runs
- Then the YAML parses without error
- And zero job-level `if` lines contain `hashFiles`

### Scenario 7: Documentation documents the automatic release
- Given the change applied
- When `docs/versioning-standard.md` and `README.md` are inspected
- Then `docs/versioning-standard.md` has a "Release automático" section documenting: workflow triggers (push to main / Release published), validation gate (`check-refs.sh` + `specboot.sh --ci` + `make ci` + `tests/*.sh`), and that the maintainer bumps `version` in `package.json` (SemVer) before merge, with the workflow NOT doing automatic bump
- And `README.md` has a "Publicación (release automático)" section with a YAML snippet of triggers and an updated `update.sh --bump` description (maintainer convenience, not direct workflow trigger)

### Scenario 8: No regression in framework validations
- Given the change applied to the framework repo (branch based on Fase 4: 4.1 + 4.2)
- When `python -c "import yaml; yaml.safe_load(open('.github/workflows/release.yml'))"`, `bash check-refs.sh`, `bash specboot.sh --ci`, `make ci`, and all `tests/*-test.sh` run
- Then the YAML parses, `check-refs.sh` reports 0 errors, `specboot.sh --ci` reports 0 errors, `make ci` exits 0, and all tests pass

### Scenario 9 (edge): `publish` is skipped if validation fails
- Given the `release.yml` workflow
- When the `validate` job fails (e.g. a `tests/*-test.sh` script exits non-zero)
- Then the `publish` job does not run
- And the package is not published to GitHub Packages
