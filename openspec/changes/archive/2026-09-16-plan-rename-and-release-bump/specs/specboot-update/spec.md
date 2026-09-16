# specboot-update Delta

## MODIFIED Requirements

### Requirement: Replaces intocable files without mercy (with exclusions)

`update` MUST overwrite the `UPDATE_ITEMS[]` set, which now includes
`release-bump.sh` (root script, same criterion as `check-refs.sh`) alongside
the 7 intocable framework docs. Because `.opencode/agents` is replaced
whole-tree, a consumer's stale `plan.md` MUST disappear after updating to the
framework version that renamed the agent to `sdd-plan`.

#### Scenario: update propagates release-bump.sh

- **WHEN** a consumer project runs `specboot update`
- **THEN** `release-bump.sh` exists in the project root

#### Scenario: stale plan.md agent is wiped on update

- **WHEN** a consumer project containing a legacy `.opencode/agents/plan.md` runs `specboot update`
- **THEN** the file no longer exists and `.opencode/agents/sdd-plan.md` is present
