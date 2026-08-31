# workflow-node-upgrade Specification

The framework GitHub Actions workflows (`release.yml` and `ci.yml`) SHALL use current action versions (`actions/checkout@v5` and `actions/setup-node@v5`) with `node-version: '24'` to avoid Node.js 20 deprecation warnings in GitHub Actions runners.

## MODIFIED Requirements

### Requirement: Use current action versions

Both `release.yml` and `ci.yml` SHALL use `actions/checkout@v5` and `actions/setup-node@v5` with `node-version: '24'` to avoid the Node.js 20 deprecation warning emitted by GitHub Actions runners. This applies to all jobs within both workflow files.

`publish.yml` is **superseded** by `release.yml` and is no longer used.

#### Scenario: release.yml runs without deprecation warning

- **Given** the `release.yml` workflow uses `actions/checkout@v5` and `actions/setup-node@v5` with `node-version: '24'`
- **When** the workflow is triggered on push to `main` or on GitHub Release published
- **Then** the workflow runs successfully
- **And** no Node.js deprecation warnings appear in the workflow logs

#### Scenario: ci.yml runs without deprecation warning

- **Given** the `ci.yml` workflow uses `actions/checkout@v5` and `actions/setup-node@v5` with `node-version: '24'`
- **When** the workflow is triggered on push to `main` or on a pull request
- **Then** the workflow runs successfully
- **And** no Node.js deprecation warnings appear in the workflow logs
