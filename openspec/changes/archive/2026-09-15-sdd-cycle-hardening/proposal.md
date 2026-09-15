# Proposal: sdd-cycle-hardening

Ticket ID: TICKET-AUDIT-1
Title: [docs] Hardening del ciclo SDD: permisos, rama en plan-change, TDD protocol canónico, limpieza de skills
Tag (source): [docs] (explicit)
Change type: tooling/framework (specs delta apply)

## Why

The audit verified each cycle step against its declared contract and found:
plan-change silently skips branch creation (breaking git workflow standards
§1/§6), /commit can edit anything and force-push (gates are only procedural),
enrich-us promises a Jira/curl fetch that permissions rightly deny, and the
TDD Failure Protocol is duplicated in three places against the framework's
own single-source-of-truth pattern.

## What Changes

Close the gaps found in the full SDD cycle audit (enrich-us → commit): one
functional gap (plan-change never instructs branch creation despite standards
and permissions allowing it), one structural permissions gap (`/commit` runs
under the fully-permissive `build` agent with an irrelevant role loaded),
and nine synchronization/cleanup fixes across skills, agents, commands and
guards, preserving the M-403 invariant (SKILL.md is source of truth;
permission blocks mirror it exactly).

## Source

Enriched ticket: `openspec/tickets/TICKET-AUDIT-1-enriched.md` (primary
source). Full audit rationale recorded in session; 11 scenarios SC-001 to
SC-011 map 1:1 to the artifact's Acceptance Criteria.
