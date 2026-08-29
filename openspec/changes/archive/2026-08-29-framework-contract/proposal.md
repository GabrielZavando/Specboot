# Proposal: Contrato del Framework Specboot

## Change created from ticket

**Ticket ID**: TICKET-0.1
**Original title**: Contrato del Framework Specboot (modelo consolidado)
**Tag (source)**: [docs] (explicit)
**Derived change name**: framework-contract
**Change folder**: openspec/changes/archive/2026-08-29-framework-contract/
**Enriched artifact used**: yes (openspec/tickets/TICKET-0.1-enriched.md; removed after archive)

### Naming rationale
- Verb: define/consolidate (el entregable es un documento de contrato)
- Noun/entity: framework contract
- Domain prefix: none (single domain: the framework itself)

### Context loaded
- `docs/base-standards.md` (always via instructions[])
- `docs/documentation-standards.md` (tag [docs])
- `.openspec/tickets/TICKET-0.1-enriched.md` (primary source)

## Why

The Specboot model was defined across 10 design questions but remains scattered across chat history and implicit in existing repo files (`AGENTS.md`, `opencode.json`, `ai-specs/`, `docs/base-standards.md`). Downstream tickets (TICKET-0.2 docs layout, TICKET-0.3 `.specboot.json` schema, TICKET-0.4 SemVer rules) all depend on a frozen, authoritative contract. Without it, those tickets would re-litigate fundamentals instead of building on them. This change freezes the consolidated model into a single source of truth before any implementation phase.

## What Changes

- **Adds** `docs/framework-contract.md` — the framework contract, with 7 sections: executive summary, governing principles (the canonical 10), distribution architecture, untouchable/project frontier, mandatory SDD flow, update model ("option A"), and dogfooding. Includes the "Rutas canónicas de artefactos SDD" subsection declaring `openspec/` as the canonical artifacts root.
- **Adds** the `framework-contract` OpenSpec capability consolidating the requirements and scenarios.
- **Does NOT** add code, scripts, or JSON schema. It only *declares* the frontier and the update model; the actual tooling/distribution is later phases (Fase 1+) and later tickets (0.2/0.3/0.4).

## Overview

This proposal outlines the creation of a foundational document, `docs/framework-contract.md`, within the Specboot repository. This document will serve as the single authoritative source for defining the Specboot framework, its architecture, the explicit boundary between untouchable framework files and project-specific customizable areas, the mandatory SDD workflow, the update model, and the principle of dogfooding.

## Goals

- **Consolidate** the Specboot model derived from 10 design questions into a single, authoritative document.
- **Clarify** the definition of Specboot as an SDD framework/development environment.
- **Define** the distribution architecture (npm package).
- **Establish** a strict boundary between untouchable framework files and customizable project surface.
- **Document** the mandatory SDD workflow.
- **Detail** the framework's update model ("option A").
- **Affirm** the dogfooding principle.
- **Ensure** that any developer reading the document understands what can and cannot be edited in their project.

## Non-Goals

- Concrete definition of `docs/` folder layouts (TICKET-0.2).
- JSON schema for `.specboot.json` (TICKET-0.3).
- SemVer rules (TICKET-0.4).
- Any code implementation or scripts (Phase 1+).

## Enriched User Story

**As a** framework maintainer (Gabriel / Agencia Zavando)
**I want** a single authoritative document `docs/framework-contract.md` in the Specboot repo
**So that** every downstream phase and every project consumer knows what Specboot is, what it provides, what is untouchable, and what is the project's own responsibility.

### Context

The Specboot framework has been modeled across 10 design questions answered in a working session with the user. The resulting model is currently scattered across chat history and implicit in existing repo files (`AGENTS.md`, `opencode.json`, `.specboot.example.json`, `ai-specs/`, `docs/base-standards.md`). Before proceeding to define the `docs/` folder layout (TICKET-0.2), the `.specboot.json` schema (TICKET-0.3), or the SemVer rules (TICKET-0.4), the consolidated model must be frozen into a single contract document that:

- Acts as the **single source of truth** for "what is Specboot".
- Defines the **untouchable / project-owned frontier** explicitly.
- Is referenceable by every future spec, ticket, and contributor.

This is a pure documentation deliverable. No code, no scripts, no schema definitions.
