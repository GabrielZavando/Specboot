# version-bump Specification

## MODIFIED Requirements

### Requirement: Version matches git tag

The `version` field in `package.json` SHALL equal the git tag (without the leading `v`) so that `npm publish` succeeds when triggered by the tag-based workflow. A `minor` framework change (added capability, no contract break) SHALL increment the MINOR component (`0.x.y` → `0.(x+1).0`), and the tagging/publish step MUST not attempt to republish an already-published version.

#### Scenario: Publishing v0.2.0 succeeds

- **Given** `package.json` declares `version: "0.2.0"` and tag `v0.2.0` is pushed following a minor change
- **When** the publish workflow runs `npm publish`
- **Then** the package is uploaded successfully with exit code 0
- **And** `@gabrielzavando/specboot@0.2.0` appears in GitHub Packages

#### Scenario: Republishing an existing version is rejected

- **Given** a version already present in GitHub Packages (e.g. `0.1.3`)
- **When** a push to `main` triggers `npm publish` without a version bump
- **Then** the publish fails with "You cannot publish over the previously published versions"
- **And** the maintainer must bump MINOR for added-capability changes before merge
