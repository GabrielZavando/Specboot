# version-bump Specification

## Purpose
TBD - created by archiving change npm-publish-bump-version. Update Purpose after archive.
## Requirements
### Requirement: Version matches git tag

The `version` field in `package.json` SHALL equal the git tag (without the leading `v`) so that `npm publish` succeeds when triggered by the tag-based workflow.

#### Scenario: Publishing v0.1.1 succeeds

- **Given** `package.json` declares `version: "0.1.1"` and tag `v0.1.1` is pushed
- **When** the publish workflow runs `npm publish`
- **Then** the package is uploaded successfully with exit code 0
- **And** `@gabrielzavando/specboot@0.1.1` appears in GitHub Packages

