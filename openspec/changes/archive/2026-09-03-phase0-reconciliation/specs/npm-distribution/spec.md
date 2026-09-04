# npm-distribution Specification (change delta)

## MODIFIED Requirements

### Requirement: Consumption documentation

`README.md` SHALL document how consumers authenticate against GitHub Packages — both for
local installs (`npm login` with a PAT holding `read:packages`, or an `.npmrc` entry) and
for **CI installs** — and how to install the package with standard NPM commands.

For CI installs, `README.md` SHALL include a section **"Autenticación para consumidores
(CI)"** covering two scenarios:

1. **Same owner/org with granted access**: a consumer repository with access granted in
   Package settings → Manage Actions access can use the runner-provided `secrets.GITHUB_TOKEN`
   with `permissions: packages: read` and `registry-url: https://npm.pkg.github.com`.
2. **Different owner / no granted access**: requires a PAT with scope `read:packages`
   saved as a repository secret (e.g. `NPM_TOKEN`), equivalent to the local `.npmrc` /
   `npm login` mechanism.

Additionally, the section SHALL include troubleshooting for common `401` (missing
`NODE_AUTH_TOKEN`, or PAT without `read:packages`) and `403` (repository without access
granted in Package settings) errors.

#### Scenario: Consumer installs the package locally

- **Given** a consumer project configured with a valid GitHub PAT (`read:packages`) in `.npmrc` for the `@gabrielzavando` scope
- **When** running `npm install --save-dev @gabrielzavando/specboot`
- **Then** the package is installed in `node_modules/@gabrielzavando/specboot`
- **And** the consumer can execute `bash node_modules/@gabrielzavando/specboot/specboot.sh --init`

#### Scenario: Consumer installs the package in CI (same owner with granted access)

- **Given** a consumer repository with access granted to the package in Package settings
- **When** the CI workflow uses a step with `registry-url: https://npm.pkg.github.com`,
  `permissions: packages: read`, and `NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}`
- **Then** `npm install` runs without a `401`/`403` error

#### Scenario: Consumer installs the package in CI (different owner / no granted access)

- **Given** a consumer repository without granted access to the package
- **When** the CI workflow is configured with a secret holding a PAT scoped with `read:packages`
- **Then** `npm install` authenticates using that secret instead of `GITHUB_TOKEN`

#### Scenario: Troubleshooting 401/403 in CI

- **Given** a consumer CI install fails
- **When** the failure is a `401`
- **Then** `README.md` explains the likely causes: missing `NODE_AUTH_TOKEN`, or a PAT without `read:packages` scope
- **And** when the failure is a `403`, `README.md` explains the repository lacks access granted in Package settings → Manage Actions access
