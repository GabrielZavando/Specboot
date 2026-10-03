# cycle-benchmark Specification

## Purpose
TBD - created by archiving change permission-baseline. Update Purpose after archive.
## Requirements
### Requirement: Metrics as volume approximation only

The benchmark registry MUST record only the volume approximation (bytes/
characters of input and output, counting prompt and response sizes), explicitly
labeled as `aproximación_de_volumen` in every artifact. Computing or estimating
tokens mathematically MUST NOT happen: the agents have no permission to query
the provider's billing/usage APIs. (REQ-006)

#### Scenario: Metrics labeled as volume approximation

- **WHEN** cycle metrics are recorded (prompt and response sizes)
- **THEN** only the volume approximation (bytes/characters) is recorded, labeled `aproximación_de_volumen`
- **AND** no mathematical token estimation is computed or presented

### Requirement: Semimanual benchmark with recording template

The initial benchmark (PREC-01) MUST be semimanual with a recording template:
a simple auxiliary script in `scripts/` that runs the existing permission
validators, plus a recording template (JSON/Markdown) in `openspec/state/`
where durations, calls, retries, quality result and measured bytes are recorded
when running `/adversarial-review` and `/archive` over a pair of representative
changes. An automated benchmark orchestrator MUST NOT be built (that
corresponds to SPECBOOT-REL-01). (REQ-007, REQ-009)

#### Scenario: Initial semimanual benchmark completes

- **WHEN** `/adversarial-review` and `/archive` run over the pair of representative changes and the results are recorded
- **THEN** the template records duration, calls, retries, quality result and measured bytes, labeled as `aproximación_de_volumen`

#### Scenario: Representative changes available

- **WHEN** the pair of representative changes is prepared as deterministic fixtures (backend, frontend, framework, documentation)
- **THEN** they include session resume, missing evidence and post-verify modification scenarios, and the recording template references them

