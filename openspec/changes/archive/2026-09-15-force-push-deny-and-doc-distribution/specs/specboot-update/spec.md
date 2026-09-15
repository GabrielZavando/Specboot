# specboot-update Delta

## MODIFIED Requirements

### Requirement: Replaces intocable files without mercy (with exclusions)

`update` MUST overwrite the `UPDATE_ITEMS[]` set, which now includes **7**
intocable framework docs (adding `docs/tdd-failure-protocol.md` to the 6
previously listed). `init` MUST copy it as part of `FRAMEWORK_ITEMS`.
`README.md` and consumer project docs MUST NOT be touched.

#### Scenario: update propagates the TDD protocol doc

- **WHEN** a consumer project runs `specboot update`
- **THEN** `docs/tdd-failure-protocol.md` is created or replaced with the
  framework version

#### Scenario: init copies the TDD protocol doc

- **WHEN** `specboot init` runs on an empty project
- **THEN** `docs/tdd-failure-protocol.md` exists in the target project
