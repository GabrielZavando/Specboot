# specboot-json-standard Specification

## Purpose
TBD - created by archiving change specboot-json-schema. Update Purpose after archive.
## Requirements
### Requirement: Canonical schema document exists
`docs/specboot-json-standard.md` MUST exist and document the full schema (required fields `frameworkVersion`, `services`, `stack`; optional `name`, `description`, `extraStandards`, `layers`) and the validation behavior (the 6 cases). `layers` MUST be documented as optional, project-owned, opt-in metadata (service → [capas] map).

#### Scenario: Document covers schema and validation
- **Given** the Specboot repository in a clean state
- **When** a developer opens `docs/specboot-json-standard.md`
- **Then** the file documents every field and its semantics, including `layers` as optional
- **And** the six validation cases (missing file, invalid JSON, missing field, version mismatch, bad path, layers type) are described

### Requirement: Required-field validation
`validate-specboot.sh` MUST validate presence and basic type of `frameworkVersion` (non-empty string), `services` (array of strings), and `stack` (string or array). If any is missing or mistyped, the script MUST report an error and exit 1.

#### Scenario: Missing required field fails
- **Given** a `.specboot.json` lacking `services`
- **When** `validate-specboot.sh` runs
- **Then** it lists the missing field and exits 1

### Requirement: Framework-version comparison
`validate-specboot.sh` MUST compare `frameworkVersion` against the installed framework version, resolved (in order) from `specboot.sh --version`, `node_modules/@gabrielzavando/specboot/package.json`, or the repo's own `package.json`. If declared > installed → error "proyecto requiere versión más nueva del framework" + exit 1. If declared < installed → warning "framework desactualizado, corre specboot update" + exit 0. If equal → pass. Pre-release/build metadata in either version MUST be stripped before the numeric compare so it cannot cause an arithmetic error.

#### Scenario: Declared version higher than installed
- **Given** a consumer project whose `frameworkVersion` is greater than the installed framework
- **When** `validate-specboot.sh` runs
- **Then** it reports the "versión más nueva" error and exits 1

#### Scenario: Declared version lower than installed
- **Given** a project whose `frameworkVersion` is lower than the installed framework
- **When** `validate-specboot.sh` runs
- **Then** it warns "framework desactualizado" and exits 0

#### Scenario: Pre-release version compares safely
- **Given** a `frameworkVersion` with SemVer pre-release/build metadata (e.g. `1.2.3-rc.1`)
- **When** `validate-specboot.sh` normalizes and compares it
- **Then** the comparison succeeds without an arithmetic error and classifies the relationship correctly

### Requirement: Services path validation
Each entry in `services` MUST be an existing path relative to the project root; `"."` denotes the root itself. A non-existent path MUST cause an error and exit 1.

#### Scenario: services points to a missing path
- **Given** a `.specboot.json` whose `services` includes a folder that does not exist
- **When** `validate-specboot.sh` runs
- **Then** it reports the bad path and exits 1

### Requirement: Tolerant missing-file and invalid-JSON handling
If `.specboot.json` is absent, `validate-specboot.sh` MUST print the warning "⚠️ .specboot.json no encontrado. Corre 'specboot init' para crearlo." and exit 0 (non-blocking). If the file is not valid JSON, it MUST error and exit 1.

#### Scenario: Config file absent is non-blocking
- **Given** a project directory without `.specboot.json`
- **When** `validate-specboot.sh` runs
- **Then** it prints the missing-file warning and exits 0

#### Scenario: Invalid JSON fails
- **Given** a `.specboot.json` with broken JSON syntax
- **When** `validate-specboot.sh` runs
- **Then** it reports invalid JSON and exits 1

### Requirement: layers optional object
If `layers` is present in `.specboot.json`, it MUST be a JSON object (service → array of layer labels). If present and not an object, the script MUST error and exit 1. If absent, validation passes.

#### Scenario: layers present but not an object fails
- **Given** a `.specboot.json` whose `layers` is an array instead of an object
- **When** `validate-specboot.sh` runs
- **Then** it reports the `layers` type error and exits 1

#### Scenario: layers value with an apostrophe does not false-positive
- **Given** a `.specboot.json` whose `layers` map contains a string value with a single quote (e.g. a label like "O'Brien")
- **When** `validate-specboot.sh` checks `layers` by re-reading the file path (not interpolating the serialized value)
- **Then** it correctly validates the object and does not misreport a type error

### Requirement: Example reflects final schema
`.specboot.example.json` MUST be valid JSON containing all schema fields (including optional `layers`), and `.specboot.example.README.md` MUST comment each field (JSON has no comments).

#### Scenario: Example is valid and documented
- **Given** `.specboot.example.json` and `.specboot.example.README.md`
- **When** a developer parses the example and reads the README
- **Then** the example is valid JSON covering the full schema and the README explains every field

### Requirement: Repo .specboot.json conforms
The framework repo's own `.specboot.json` MUST conform to the final schema (`frameworkVersion:"0.1.1"`, `services:["."]`, `stack:"framework"`) and `validate-specboot.sh` MUST pass on it.

#### Scenario: validate passes on the Specboot repo
- **Given** the Specboot repository with its `.specboot.json`
- **When** `validate-specboot.sh` runs
- **Then** it exits 0 with no errors

### Requirement: Parent docs link the standard
`docs/framework-contract.md` and `docs/docs-standard.md` MUST each contain a Markdown link to `docs/specboot-json-standard.md`.

#### Scenario: Contract and doc standard link the schema doc
- **Given** the new standard document exists
- **When** a developer reads `docs/framework-contract.md` and `docs/docs-standard.md`
- **Then** both contain a valid link to `docs/specboot-json-standard.md`

### Requirement: specboot.sh is self-validating
`specboot.sh` MUST expose a `--version` flag printing the `package.json` version, and `specboot.sh --ci` MUST run `validate-specboot.sh` via a `check_specboot_json` step. The hook MUST be tolerant: a missing `.specboot.json` is a warning, not a CI error.

#### Scenario: specboot.sh --version prints the version
- **Given** the framework repository
- **When** `specboot.sh --version` runs
- **Then** it prints the `package.json` version (e.g. `0.1.1`)

#### Scenario: --ci runs validation tolerantly
- **Given** `specboot.sh --ci` executes
- **When** `validate-specboot.sh` is invoked through `check_specboot_json`
- **Then** a missing `.specboot.json` produces a warning and does not increment CI errors

#### Scenario: --ci fails on a hard config error
- **Given** a project whose `.specboot.json` is invalid, missing a required field, or points to a non-existent `services` path
- **When** `specboot.sh --ci` runs `check_specboot_json`
- **Then** the validator's non-zero exit is captured directly and `specboot.sh --ci` increments ERRORS and fails CI

### Requirement: validate-specboot.sh is distributed
`package.json` `files` MUST include `"validate-specboot.sh"` so the script ships with the published package.

#### Scenario: Script is in the published files
- **Given** the framework `package.json`
- **When** a consumer installs `@gabrielzavando/specboot`
- **Then** `validate-specboot.sh` is included in the installed package

### Requirement: Framework validation has no regression
After the change, `check-refs.sh` MUST report 0 errors and `specboot.sh --ci` MUST introduce no new errors or warnings compared to the TICKET-0.2 baseline.

#### Scenario: No regression in framework checks
- **Given** the change artifacts written
- **When** `check-refs.sh` and `specboot.sh --ci` run
- **Then** `check-refs.sh` exits 0 and `specboot.sh --ci` shows no new errors/warnings

