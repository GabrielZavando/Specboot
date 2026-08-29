# Proposal: npm-publish-node-upgrade

## Why

The current `publish.yml` workflow triggers a non-blocking deprecation warning because it uses `actions/checkout@v4` and `actions/setup-node@v4`, both of which target Node.js 20 while GitHub Actions now runs on Node.js 24. Eliminating the warning improves CI/UX hygiene and aligns the workflow with current best practices.

## What Changes

- Bump `actions/checkout` from `v4` to `v5`.
- Bump `actions/setup-node` from `v4` to `v5`.
- Bump `node-version` in `setup-node` from `'20'` to `'24'`.

## Summary and Motivation

GitHub has deprecated Node.js 20 as a target runtime for actions. The publish workflow, while functional, emits a warning on every run. This change silences that warning and ensures forward-compatibility with the runner’s default environment.

## Acceptance Criteria

1. `publish.yml` references `actions/checkout@v5` and `actions/setup-node@v5`.
2. `node-version` in `setup-node` is set to `'24'`.
3. A `v0.1.1` tag is cut and pushed, triggering a clean workflow run with no deprecation warnings.

## Rollback Plan

- If the upgrade causes issues, revert the workflow file to `v4` of the actions and tag a new release. The rollback impact is limited to the CI workflow definition only.
