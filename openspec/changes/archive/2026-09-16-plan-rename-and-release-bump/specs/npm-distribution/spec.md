# npm-distribution Delta

## MODIFIED Requirements

### Requirement: Package configuration

The package `files` allowlist MUST include the framework assets, the 7
intocable framework docs (including `docs/tdd-failure-protocol.md`), and the
new root script `release-bump.sh`, which performs atomic version bumps across
`package.json` and `.specboot.json` (same distribution criterion as
`check-refs.sh`).

#### Scenario: release-bump.sh is published

- **WHEN** `npm pack` runs on the framework repository
- **THEN** the tarball contains `release-bump.sh`
