# Scenarios: Specboot NPM Publication

## Scenario 1: Package Content Validation (Happy Path)
**Given** the `package.json` is configured with a `files` allowlist
**When** running `npm pack --dry-run`
**Then** only the specified framework files (docs, ai-specs, templates, scripts, etc.) are included
**And** internal repo files (.git, .github, tests, openspec) are excluded

## Scenario 2: Automated Publication via Tag (Happy Path)
**Given** a git tag `v0.1.0` is pushed to the repository
**When** the `publish.yml` workflow is triggered
**Then** the package is successfully uploaded to GitHub Packages
**And** the version in the registry matches the tag version

## Scenario 3: Manual Consumption (Happy Path)
**Given** a consumer project with a valid GitHub PAT configured in `.npmrc`
**When** running `npm install --save-dev @gabrielzavando/specboot`
**Then** the package is installed in `node_modules/@gabrielzavando/specboot`
**And** the user can execute `bash node_modules/@gabrielzavando/specboot/specboot.sh --init`
