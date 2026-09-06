# specboot-update Specification (delta — change inject-mandatory-steps)

> Enmienda el conjunto de docs intocables de 5 a 6 (M-601 añade
> `docs/openspec-tasks-mandatory-steps.md` a `UPDATE_ITEMS[]`) y fija el fix del
> bug latente de `replace_framework_files`: el patrón `docs/*` del `case` salteaba
> **todos** los ítems `docs/` (incluidos los 5 docs estándar), contradiciendo el
> MUST-overwrite de esta spec. Solo los árboles enteros (`docs`, `.github`) quedan
> excluidos del camino genérico de reemplazo.

## MODIFIED Requirements

### Requirement: Replaces intocable files without mercy (with exclusions)
`update` MUST overwrite the `UPDATE_ITEMS[]` set: `.opencode/commands`, `.opencode/agents`, `ai-specs`, `check-refs.sh`, `specboot.sh`, `validate-specboot.sh`, `templates/ci`, the 6 framework docs (`docs/base-standards.md`, `docs/framework-contract.md`, `docs/docs-standard.md`, `docs/specboot-json-standard.md`, `docs/versioning-standard.md`, `docs/openspec-tasks-mandatory-steps.md`), `opencode.json`, `AGENTS.md`, `Makefile`, and the framework's `.github/workflows/*` (file-by-file). `README.md` and `LICENSE` MUST NOT be in `UPDATE_ITEMS[]`; `.github/` as a whole MUST NOT be deleted. The replacement loop MUST NOT skip individual framework doc items: only whole-tree `docs` / `.github` entries are excluded from the generic replacement path.

#### Scenario: Intocable set replaced
- **WHEN** `specboot update` runs
- **THEN** the listed intocable items are overwritten even if hand-edited

#### Scenario: README and LICENSE excluded
- **WHEN** `specboot update` runs
- **THEN** the project's `README.md` and `LICENSE` are left intact

#### Scenario: Framework docs are replaced (regression: docs/* skip)
- **GIVEN** a template whose `docs/` contains the 6 framework docs and a project missing them or holding outdated versions
- **WHEN** `specboot update` runs
- **THEN** all 6 framework docs are copied into the project
- **AND** project-owned docs (`docs/backend-standards.md`, `docs/project/*`, `docs/api/api-spec.yml`, `docs/data-model/*`) remain untouched

### Requirement: Never touches project docs or code
`update` MUST NOT modify any `docs/` file other than the 6 framework docs, nor any project code (`backend/`, `frontend/`, …), nor a project-authored `.github/workflows/*`.

#### Scenario: Project docs and code preserved
- **WHEN** `specboot update` runs
- **THEN** `docs/backend-standards.md`, `docs/project/*`, `docs/api/api-spec.yml`, `docs/data-model/*`, `backend/`, `frontend/`, and project workflows remain unchanged
