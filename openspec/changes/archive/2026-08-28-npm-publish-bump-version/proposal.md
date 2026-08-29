# Proposal: npm-publish-bump-version

## Why

The `v0.1.1` release failed because `package.json` still declared `version: "0.1.0"`, which had already been published. npm rejects overwrites, breaking idempotent CI workflows for bug-fix releases. This change aligns the package version with the tag.

## What Changes

- Bump `version` in `package.json` from `"0.1.0"` to `"0.1.1"`.

## Summary and Motivation

The `npm-publish-node-upgrade` change bumped the workflow actions but did **not** update the package version, causing the `v0.1.1` tag to attempt republishing an already-existing version. This is a one-line fix to restore correct release semantics.

## Acceptance Criteria

1. `package.json` declares `version: "0.1.1"`.
2. Tag `v0.1.1` publishes successfully to GH Packages.
3. Package `@gabrielzavando/specboot@0.1.1` is listed in the Packages tab.

## Rollback Plan

- If the publish fails for another reason, revert `package.json` version to `0.1.0`. The rollback impact is limited to the version string only.
