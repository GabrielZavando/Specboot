# adversarial-state Specification (delta — change phase10-cleanup)

## MODIFIED Requirements

### Requirement: archive MUST reference the adversarial verdict in the manifest as an informed soft gate
The `archive` skill SHALL add an optional `adversarial: {verdict, timestamp, source}` field to the manifest entry when `adversarial-result.json` exists with a matching `change` field, and SHALL omit it without blocking when the file is absent or foreign (warning and suggesting `/adversarial-review` instead). Archive SHALL read only the summary (token-light, never the findings detail). Archive remains an informed soft gate; the hard gate on evidence is already implemented by the `commit` skill per the `commit-gates` specification.

#### Scenario: Archive references the verdict in the manifest
- **GIVEN** an archived change with an existing `adversarial-result.json` whose `change` field matches
- **WHEN** archive generates the manifest entry
- **THEN** the entry includes `adversarial: {verdict, timestamp, source: "openspec/state/adversarial-result.json"}`
- **AND** archive does not read the findings detail of the JSON (token-light)

#### Scenario: Archive warns without blocking when evidence is absent or foreign
- **GIVEN** an archived change without `adversarial-result.json`, or one whose `change` field differs from the active change
- **WHEN** archive generates the manifest entry
- **THEN** the `adversarial` field is omitted, a warning is printed and running `/adversarial-review` is suggested
- **AND** the archive completes without error or block (archive is a soft gate; the hard gate is enforced by `/commit` per the `commit-gates` spec)
