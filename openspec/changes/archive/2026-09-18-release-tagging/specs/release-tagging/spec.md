# release-tagging (delta)

## ADDED Requirements

### Requirement: release-bump.sh creates the git tag locally

`release-bump.sh` SHALL create a local git tag `v{version}` (e.g. `v0.9.0`) upon successful bump, with its announcement message including the tag name and a reminder to push it after the branch is merged to `main`. When the tag cannot be created (e.g. already exists), it SHALL print a warning, not an error — bumping remains idempotent/safe.

#### Scenario: tag created after bump
- **GIVEN** a successful `release-bump.sh <version>`
- **WHEN** it finished successfully
- **THEN** a local tag `v{version}` exists with the expected message text

### Requirement: update.sh --bump reads version from package.json

`update.sh --bump` SHALL compute the next version from `package.json` (the source of truth), not from `git describe --tags`, so the flow is independent of tag completeness.

#### Scenario: bump computes from package.json
- **GIVEN** next version computed on a repo whose tags are stale
- **WHEN** running `update.sh --bump minor`
- **THEN** the TO version derives from `package.json`'s current version (0.9.0 → 0.10.0), not from `git describe --tags`

### Requirement: Release tagging policy is documented

`docs/versioning-standard.md` SHALL document the tagging policy: tag created locally by the bump tool, pushed after merge, and GitHub Release created manually from the UI (with CHANGELOG text copied); and SHALL state that `release.yml` publishes npm idempotently regardless of tags (publish is not conditioning on the GitHub Release).

#### Scenario: policy documented
- **GIVEN** the reader of `docs/versioning-standard.md`
- **WHEN** confirming release flow
- **THEN** the section documents ptr thoroughly (tag local · push tag after merge · GitHub Release manual from UI) and notes `release.yml` does not require a tag to publish (idempotent npm publish)

### Requirement: Backfill of missing historical tags

The missing tag slots for historical versions (v0.6.4, v0.7.0, v0.8.0, v0.8.1, v0.9.0) SHALL be created pointing at their respective bump commits and pushed; they SHALL NOT trigger `release.yml` (whose triggers are `push: branches: [main]` and `release: types: [published]` only).

#### Scenario: tags created
- **GIVEN** bump commits in git history (each with its version commit message)
- **WHEN** the tags are created and pushed
- **THEN** `git tag -l 'v*'` includes all versions (including historic 0.6.4..0.9.0) and `git ls-remote --tags origin` shows them

#### Scenario: no release.yml triggered
- **GIVEN** a tag pushed (e.g. v0.9.0)
- **WHEN** it is only a tag, not a main-branch push and not a release-published
- **THEN** no publish job runs on that trigger (implicit absence by design)
