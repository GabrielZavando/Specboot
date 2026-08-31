# specboot-release Specification

The framework SHALL include a GitHub Actions release workflow (`release.yml`) that validates the full framework self-check suite before publishing the npm package `@gabrielzavando/specboot` to GitHub Packages, triggered on push to `main` or on GitHub Release publication. It SHALL use `actions/checkout@v5`, `actions/setup-node@v5`, and `node-version: '24'`.

## MODIFIED Requirements

### Requirement: `release.yml` uses actions v5 and node 24

`release.yml` SHALL use `actions/checkout@v5`, `actions/setup-node@v5`, and `node-version: '24'` in all its jobs (both `validate` and `publish`). This consolidates the requirement from `workflow-node-upgrade` and ensures no Node.js 20 deprecation warnings in the release workflow.

#### Scenario: release.yml uses checkout@v5, setup-node@v5, and node 24

- **Given** the Specboot framework repo with `.github/workflows/release.yml`
- **WHEN** the workflow is inspected
- **THEN** it uses `actions/checkout@v5` (not @v4)
- **AND** it uses `actions/setup-node@v5` (not @v4)
- **AND** it uses `node-version: '24'` (not 20)
- **AND** no Node.js deprecation warnings appear in the workflow logs
