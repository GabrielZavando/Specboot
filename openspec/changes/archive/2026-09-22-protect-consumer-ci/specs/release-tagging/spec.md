# release-tagging Specification Delta

## REMOVED Requirements

### Requirement: release-bump.sh creates the git tag locally

**Reason**: The tag creation happened while the bump changes were still
uncommitted, so the tag could point at the commit BEFORE the bump. Tag
creation moves to the maintainer's post-merge phase (REQ-006 / SC-006); the
replacement requirements below define the corrected contract.

## MODIFIED Requirements

### Requirement: Release tagging policy is documented

`docs/versioning-standard.md` SHALL document the tagging policy: the version
bump NEVER creates git tags; the maintainer creates the local tag `v{X.Y.Z}`
after merging to `main`, pointing exactly at the commit on `main` that
contains the bump, and pushes it only with explicit authorization; the GitHub
Release is created manually from the UI with the matching `## [X.Y.Z]`
CHANGELOG section as notes; and `release.yml` publishes npm idempotently
regardless of tags (publish is not conditioned on the GitHub Release).

#### Scenario: policy documented

- **GIVEN** the reader of `docs/versioning-standard.md`
- **WHEN** confirming the release flow
- **THEN** the sections document the corrected policy: the bump updates all
  version files and creates NO tag; tag creation belongs to the post-merge
  phase pointing exactly at the bump commit on `main`; the GitHub Release is
  manual from the UI; and `release.yml` publishes idempotently without
  requiring a tag

## ADDED Requirements

### Requirement: The version bump never creates git tags

`release-bump.sh` and `update.sh --bump` MUST NOT create any git tag. Tag
creation belongs to the maintainer's post-merge phase: after the PR is merged
and local `main` is updated, the tag `v{X.Y.Z}` is created pointing exactly at
the `main` commit containing the bump, and is published only with explicit
authorization. Running the bump with uncommitted changes MUST leave the
repository with no new tags.

#### Scenario: bump with uncommitted changes creates no tag

- **GIVEN** a git repository where the bump changes are not yet committed
- **WHEN** `release-bump.sh <version>` runs successfully
- **THEN** no git tag exists afterwards (no `v{version}` locally)

### Requirement: release-bump.sh updates all version files atomically

`release-bump.sh` SHALL update ALL version sources in one atomic operation —
`package.json` (`version`), `package-lock.json` (root `version` AND the main
entry `packages[""].version`), and `.specboot.json` (`frameworkVersion`) —
parsing and validating every file BEFORE writing any of them, so a failure
(e.g. a corrupted `package-lock.json`) leaves no partially updated versions.
`package-lock.json` is skipped with a note only when it does not exist; when
it exists and cannot be parsed, the bump aborts without writing anything.

#### Scenario: all version files synced by the canonical bump

- **GIVEN** the target `## [X.Y.Z]` section exists in `CHANGELOG.md`
- **WHEN** `bash release-bump.sh X.Y.Z` runs
- **THEN** `package.json`, `package-lock.json` (root and main entry) and
  `.specboot.json` all report `X.Y.Z`

#### Scenario: failure leaves no partial versions

- **GIVEN** a corrupted `package-lock.json` in the repo
- **WHEN** the bump runs
- **THEN** it exits non-zero and neither `package.json` nor `.specboot.json`
  was modified
