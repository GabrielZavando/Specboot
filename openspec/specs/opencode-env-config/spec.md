# opencode-env-config Specification

## Purpose
TBD - created by archiving change opencode-env-config. Update Purpose after archive.
## Requirements
### Requirement: opencode.json without literal API keys

The versioned `opencode.json` SHALL NOT contain literal API key values; every provider credential field (`provider.*.options.apiKey`) SHALL use `{env:VARIABLE}` interpolation.

#### Scenario: no literal apiKey in opencode.json
- **GIVEN** the versioned `opencode.json`
- **WHEN** any `provider.*.options.apiKey` field is inspected
- **THEN** its value uses `{env:VARIABLE}` syntax and no literal key string exists in the file

### Requirement: Copyable OpenRouter provider example

The repository SHALL ship `.opencode/providers.example.json`, a valid JSON example defining the `openrouter` provider with `apiKey` set to `{env:OPENROUTER_API_KEY}` and at least 3 specific models, intended to be copied to the user's own OpenCode config (`~/.config/opencode/opencode.json`) so the project `opencode.json` stays untouched.

#### Scenario: example copied to user config
- **GIVEN** `.opencode/providers.example.json` versioned in the repo
- **WHEN** a dev copies it to `~/.config/opencode/opencode.json` with `OPENROUTER_API_KEY` defined
- **THEN** the JSON is valid, `provider.openrouter.options.apiKey` equals `{env:OPENROUTER_API_KEY}`, `provider.openrouter.models` lists at least 3 specific models, and the project `opencode.json` was not edited

### Requirement: Provider configuration guide

The repository SHALL document the provider configuration mechanism in `docs/opencode-providers-config.md`: `{env:VARIABLE}` interpolation syntax, the rule that provider/secrets config lives in the user-level config file rather than the template's `opencode.json`, how to copy the example, and the expected behavior when an environment variable is missing.

#### Scenario: guide documents the mechanism
- **GIVEN** `docs/opencode-providers-config.md`
- **WHEN** a dev reads it
- **THEN** it covers `{env:VARIABLE}` syntax, user-level config location, the copy procedure from `.opencode/providers.example.json`, and the explicit-failure behavior when the variable is undefined

### Requirement: New variables in .env.example

`.env.example` SHALL declare `OMNIROUTE_API_KEY` and `OPENROUTER_API_KEY` (empty values) under a clearly named AI MODEL PROVIDERS section.

#### Scenario: variables present for onboarding
- **GIVEN** the versioned `.env.example`
- **WHEN** a dev prepares their environment
- **THEN** it contains `OMNIROUTE_API_KEY=` and `OPENROUTER_API_KEY=` entries under an AI MODEL PROVIDERS section

