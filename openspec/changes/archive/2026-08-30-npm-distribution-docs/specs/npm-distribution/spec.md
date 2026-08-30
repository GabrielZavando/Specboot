# npm-distribution Specification (change delta)

## ADDED Requirements

### Requirement: Distribution boundary documentation

`README.md` and `docs/framework-contract.md` SHALL explicitly document the npm distribution boundary: what the package includes (the `files` allowlist of intocable framework assets) and what stays in the project (application code, project `docs/` except the 5 standards, `.specboot.json`, project MCP, env/GitHub vars), including a note that the Specboot development repository's own `docs/` are not published because they are filtered out by `files`.

#### Scenario: README documents the boundary
- **Given** `package.json` declares a `files` allowlist shipping only intocable framework assets
- **When** a reader opens `README.md`
- **Then** a "Qué incluye el paquete" section lists the allowlisted assets
- **And** a "Qué es del proyecto" section lists the NOT-shipped assets (app code, project `docs/` minus 5 standards, `.specboot.json`, project MCP, env/GitHub vars)

#### Scenario: framework-contract reaffirms intocable-only
- **Given** `docs/framework-contract.md` describes the distribution architecture
- **When** a reader opens the document
- **Then** a "Distribución vía npm" subsection states `files` is the source of truth and project `docs/` is filtered out by the allowlist
