# npm-distribution Delta

## MODIFIED Requirements

### Requirement: Package configuration

The package `files` allowlist MUST include the framework assets plus the
**7 intocable framework docs**, adding `docs/tdd-failure-protocol.md` —
the canonical TDD Failure Protocol referenced by `.opencode/commands/apply.md`,
`ai-specs/agents/build-agent.md` and `ai-specs/examples/tasks.md`. A doc that
is referenced as canonical by shipped framework files MUST be shipped.

#### Scenario: tdd-failure-protocol.md is published

- **WHEN** `npm pack` is run on the framework repository
- **THEN** the tarball contains `docs/tdd-failure-protocol.md`

#### Scenario: No dangling canonical references

- **WHEN** a shipped file (commands, agents, examples) references
  `docs/tdd-failure-protocol.md` as canonical source
- **THEN** that document MUST be present in the shipped package
