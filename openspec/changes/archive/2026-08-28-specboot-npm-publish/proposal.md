# Proposal: Specboot NPM Publication

**Ticket ID**: NPM-PUBLISH-01
**Original title**: Configurar Specboot como paquete NPM privado en GitHub Packages
**Tag**: [docs]
**Derived change name**: specboot-npm-publish

## Why

Propagation of Specboot updates to consumer applications is currently manual and error-prone, requiring `git clone` or `update.sh` sync. This creates friction when on-boarding new projects and increases the risk of divergence across installations.

## What Changes

- Adds `package.json` declaring `@gabrielzavando/specboot` v0.1.0 with a `files` allowlist that ships only framework assets.
- Adds `.npmignore` as defense-in-depth to exclude internal repo state.
- Adds GitHub Actions `publish.yml` to automate publication on `v*.*.*` tags.
- Updates `README.md` with authentication and installation instructions for the NPM package.

## Summary and Motivation
Currently, propagating updates from the Specboot framework to consumer applications is a manual and complex process. Transforming Specboot into a private NPM package hosted on GitHub Packages allows consumer apps to treat it as a standard dependency, facilitating installation and updates via `npm install` and `npm update`.

## Acceptance Criteria
1. **Package Configuration**: `package.json` with name `@gabrielzavando/specboot`, version `0.1.0`, and correct `files` allowlist.
2. **Publication**: Ability to publish to GitHub Packages using a PAT with `write:packages` or GITHUB_TOKEN in CI.
3. **Automation**: GitHub Actions workflow to publish automatically on `v*.*.*` tags.
4. **Consumption Documentation**: Updated `README.md` with authentication and installation instructions.

## Rollback Plan
- In case of failure or incorrect publication: 
  1. Deprecate the faulty version via `npm deprecate @gabrielzavando/specboot@<version>`.
  2. Correct the configuration and publish a new patch version.
  3. If the package must be removed entirely, delete the package from the GitHub "Packages" tab.
