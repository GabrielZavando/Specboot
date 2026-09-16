# Proposal: plan-rename-and-release-bump

Ticket ID: TICKET-AUDIT-3
Title: [docs] plan→sdd-plan rename + release-bump script
Tag (source): [docs] (explicit)
Change type: tooling/framework (specs delta apply)

## Why

1. **Reserved-name collision**: `/plan-change`, `/enrich-us` and `/explain`
   declare `agent: plan`. OpenCode reserves `plan` (and `build`) as built-in
   primary agents; the `plan` name triggers the editor's read-only plan mode,
   breaking the command mid-cycle (observed repeatedly during TICKET-AUDIT-1/2
   sessions: /verify could not run write/bash after a planning command).
2. **Non-atomic version bump**: `package.json → version` and
   `.specboot.json → frameworkVersion` are two sources of truth updated by
   hand; TICKET-AUDIT-1 shipped with them out of sync (caught by a guard).

## What Changes

- Rename `.opencode/agents/plan.md` → `.opencode/agents/sdd-plan.md`
  (hard rename, documented as breaking for consumers with direct `@plan`
  mentions; `specboot update` wipes the stale file automatically since it
  replaces the whole `.opencode/agents` directory).
- Point the three commands at `agent: sdd-plan`.
- New root script `release-bump.sh`: atomic semver bump across
  `package.json` + `.specboot.json`, requires the CHANGELOG section to
  exist, no git tag. Shipped in the package like `check-refs.sh`.
- Bump minor 0.8.1 → 0.9.0 with a `### Breaking changes` entry.

## Source

Enriched ticket: `openspec/tickets/TICKET-AUDIT-3-enriched.md`
(open question resolved: consumer's stale plan.md is wiped by update).
