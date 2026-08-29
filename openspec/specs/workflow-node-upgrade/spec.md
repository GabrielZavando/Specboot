# workflow-node-upgrade Specification

## Purpose
TBD - created by archiving change npm-publish-node-upgrade. Update Purpose after archive.
## Requirements
### Requirement: Use current action versions

The `publish.yml` workflow SHALL use `actions/checkout@v5` and `actions/setup-node@v5` with `node-version: '24'` to avoid the Node.js 20 deprecation warning emitted by GitHub Actions runners.

#### Scenario: Workflow runs without deprecation warning

- **Given** the `publish.yml` workflow uses `actions/checkout@v5` and `actions/setup-node@v5` with `node-version: '24'`
- **When** a new tag `v0.1.1` is pushed to the repository
- **Then** the `Publish to GitHub Packages` workflow runs successfully
- **And** no Node.js deprecation warnings appear in the workflow logs

