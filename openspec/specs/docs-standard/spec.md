# docs-standard Specification

## Purpose
TBD - created by archiving change docs-standard. Update Purpose after archive.
## Requirements
### Requirement: docs-standard.md defines the canonical docs/ tree and boundary
`docs/docs-standard.md` MUST publish the canonical `docs/` tree (folders `project/`, `api/`, `data-model/` and the standard files) and a table marking each doc file as intocable (framework) or del proyecto (project). It MUST also document the dynamic-load rule for the bridge `AGENTS.md`: `base-standards.md` is always loaded, and `docs/project/*` is read dynamically according to the active task tag.

#### Scenario: Canonical tree and boundary are documented
- **GIVEN** a Specboot project cloned from the framework
- **WHEN** a developer opens `docs/docs-standard.md`
- **THEN** it renders the canonical tree with `project/`, `api/`, `data-model/` folders and the standard files (`base-standards.md`, `backend-standards.md`, `frontend-standards.md`, `ci-standards.md`, `deploy-standards.md`, `documentation-standards.md`)
- **AND** a table labels `base-standards.md` as intocable and the remaining doc files as del proyecto

#### Scenario: Dynamic-load rule is specified
- **GIVEN** the bridge `AGENTS.md` loads `docs/base-standards.md` on every task
- **WHEN** a task of a specific tag (e.g. `[backend]`) executes
- **THEN** `AGENTS.md` reads the relevant `docs/project/*` files dynamically per tag instead of hardcoding every doc path

### Requirement: docs/ is reorganized to the standard tree
The repository's own `docs/` MUST follow the standard tree: `api-spec.yml` under `docs/api/`, `data-model.md` under `docs/data-model/`, and `project/` templates present. No project-context document remains loose in `docs/` root beyond the standard file set. Existing content is preserved by mapping to the new routes. `specboot.sh` `REQUIRED_FILES` MUST be updated to the new paths so `specboot.sh --ci` keeps 0 errors (the move must not introduce file-structure errors).

#### Scenario: API spec is relocated
- **GIVEN** `docs/api-spec.yml` exists at the `docs/` root
- **WHEN** the reorganization runs
- **THEN** `docs/api/api-spec.yml` exists with the original content and `docs/api-spec.yml` is removed

#### Scenario: Data model is relocated
- **GIVEN** `docs/data-model.md` exists at the `docs/` root
- **WHEN** the reorganization runs
- **THEN** `docs/data-model/data-model.md` exists with the original content and `docs/data-model.md` is removed

#### Scenario: Project templates are created
- **GIVEN** the standard requires `docs/project/`
- **WHEN** the reorganization runs
- **THEN** `docs/project/domain.md`, `docs/project/stack.md`, and `docs/project/client.md` exist as templates
- **AND** no project-context doc remains loose in `docs/` root

#### Scenario: Existing content is preserved
- **GIVEN** the repo already has documentation at the old flat paths
- **WHEN** files are moved to the new tree
- **THEN** content is identical (mapped 1:1), with no loss of information

### Requirement: framework-contract.md links to docs-standard.md
`docs/framework-contract.md` MUST contain a markdown link to `docs/docs-standard.md` so the doc standard is discoverable from the contract.

#### Scenario: Contract links the doc standard
- **GIVEN** `docs/framework-contract.md` defines the intocable/project frontier
- **WHEN** the change lands
- **THEN** `docs/framework-contract.md` contains a link to `docs/docs-standard.md`

### Requirement: .openspec/ references in .opencode/ and ai-specs/ are migrated to openspec/
Every occurrence of `.openspec/` inside `.opencode/` and `ai-specs/` MUST be replaced with `openspec/`, covering skills, commands, agents, and examples. After the migration `grep -R ".openspec/" .opencode/ ai-specs/` returns zero matches.

#### Scenario: No dotted openspec path remains in framework skills/commands
- **GIVEN** `grep -R ".openspec/" .opencode/ ai-specs/` returns N matches before the change
- **WHEN** the migration runs across `.opencode/commands/*`, `.opencode/agents/*`, `ai-specs/skills/*`, `ai-specs/agents/*`, `ai-specs/examples/*`
- **THEN** `grep -R ".openspec/" .opencode/ ai-specs/` returns 0 matches
- **AND** the meaning (change/ticket paths) resolves to `openspec/changes/` and `openspec/tickets/`

### Requirement: Repo-wide path references use openspec/ without regressions
`AGENTS.md`, `.gitignore`, `README.md`, and `CHANGELOG.md` MUST reference `openspec/` (not `.openspec/`) as the artifacts path. `.gitignore` MUST NOT ignore the tracked `openspec/` and MUST drop the vestigial `.openspec/` ignore. The defining prose in `docs/framework-contract.md` that mentions the deprecated path is reworded so it no longer reads as a current instruction.

#### Scenario: Bridge AGENTS.md uses openspec/
- **GIVEN** `AGENTS.md` is the framework-injected bridge
- **WHEN** the fix lands
- **THEN** `AGENTS.md` references `openspec/changes/` and `openspec/tickets/` (no `.openspec/` as a usable path)

#### Scenario: .gitignore no longer ignores the deprecated path
- **GIVEN** `.gitignore` contains an `.openspec/` ignore line
- **WHEN** the fix lands
- **THEN** the `.openspec/` ignore line is removed/replaced and the tracked `openspec/` is not ignored

#### Scenario: README and CHANGELOG use openspec/
- **GIVEN** `README.md` and `CHANGELOG.md` mention SDD artifact paths
- **WHEN** the fix lands
- **THEN** those references use `openspec/` and contain no `.openspec/` path instruction

#### Scenario: Contract prose rewords the deprecated path
- **GIVEN** `docs/framework-contract.md` explains that `.openspec/` is outdated
- **WHEN** the fix lands
- **THEN** the sentence describes the deprecated `.openspec/` path in past/explanatory tense and does not present it as the current convention

### Requirement: base-standards.md placeholder warnings are eliminated
`docs/base-standards.md` MUST NOT contain any of the 5 placeholder patterns that `specboot.sh --ci` flags (`[definir stack`, `[Clean Architecture`, `[descripción del dominio`, `[nombre del cliente`, `[definir stack del proyecto`). The SDD/TDD/SOLID principles in the file MUST remain intact.

#### Scenario: Placeholder patterns removed from base-standards.md
- **GIVEN** `specboot.sh --ci` flags 5 placeholder patterns in `docs/base-standards.md` (section 8)
- **WHEN** section 8 is rewritten
- **THEN** `specboot.sh --ci` reports 0 placeholder warnings from `docs/base-standards.md`
- **AND** the SDD/TDD/SOLID principles stay present in the file

### Requirement: SDD command flow has no regressions
After all fixes, the SDD commands (`/plan-change`, `/apply`, `/verify`, `/archive`, `/commit`) MUST continue operating on `openspec/changes/` and `openspec/tickets/`, and an active change MUST remain creatable and validatable.

#### Scenario: Active change still works on openspec/
- **GIVEN** the SDD flow uses `openspec/changes/` and `openspec/tickets/`
- **WHEN** all `.openspec/` → `openspec/` fixes land
- **THEN** a new change can be created and validated under `openspec/changes/` without error
- **AND** no command silently falls back to a `.openspec/` path

