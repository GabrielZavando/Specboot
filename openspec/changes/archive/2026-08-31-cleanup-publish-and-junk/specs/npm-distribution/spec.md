# npm-distribution Specification

The framework SHALL be packaged and distributed as a private npm package `@gabrielzavando/specboot` via GitHub Packages, with a clean `files` allowlist, automated release via `release.yml`, and documentation for consumers.

## MODIFIED Requirements

### Requirement: Automated publication

The repository SHALL contain a GitHub Actions workflow (`release.yml`) that publishes the package to GitHub Packages when a commit is pushed to `main` or when a GitHub Release is published, using the runner-provided `GITHUB_TOKEN` with `packages: write` permissions, gated by a full framework validation (`validate` job with `check-refs.sh` + `specboot.sh --ci` + `make ci` + `tests/*-test.sh`).

`publish.yml` is **superseded** by `release.yml` and SHALL NOT exist.

#### Scenario: Publication triggered by push to main

- **Given** a commit is pushed to the `main` branch
- **When** the `release.yml` workflow is triggered
- **Then** the `validate` job runs (check-refs.sh + specboot.sh --ci + make ci + tests/*.sh)
- **And** if validation passes, the `publish` job publishes the package to GitHub Packages
- **And** the published package is visible in the GitHub Packages section of the repository owner

#### Scenario: Publication triggered by GitHub Release published

- **Given** a GitHub Release is published on the repository
- **When** the `release.yml` workflow is triggered by `release: types: [published]`
- **Then** the `validate` job runs
- **And** if validation passes, the `publish` job publishes the package to GitHub Packages
- **And** the published package is visible in the GitHub Packages section of the repository owner

#### Scenario: publish.yml is superseded and does not exist

- **Given** the `.github/workflows/publish.yml` file existed in a previous version of the framework
- **When** this change is applied
- **Then** `.github/workflows/publish.yml` does NOT exist
- **And** `release.yml` is the only publication workflow
- **And** `release.yml` uses `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}` with `permissions: packages: write`
