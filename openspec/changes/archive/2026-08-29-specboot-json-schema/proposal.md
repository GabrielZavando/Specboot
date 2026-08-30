# Proposal: Esquema y validación de `.specboot.json`

## Change created from ticket

**Ticket ID**: TICKET-0.3
**Original title**: Esquema y validación de `.specboot.json`
**Tag (source)**: [docs] (explicit)
**Derived change name**: specboot-json-schema
**Change folder**: openspec/changes/specboot-json-schema/
**Enriched artifact used**: no (the ticket is specific enough to drive the artifacts directly)

### Naming rationale
- Verb/noun: schema definition of `.specboot.json` (noun-led, consistent with sibling meta-doc changes `framework-contract` and `docs-standard`).
- Domain prefix: none (single domain: the framework itself).

### Context loaded
- `docs/base-standards.md` (always via instructions[])
- `docs/documentation-standards.md` (tag [docs])
- `docs/framework-contract.md` (dependency TICKET-0.1 — `.specboot.json` is project-owned)
- `docs/docs-standard.md` (dependency TICKET-0.2 — `extraStandards` points to `docs/`)

## Why

`.specboot.json` is the project-owned configuration file that declares to the framework which services to lint, which stack is used, and which framework version is required. Until now it has only existed as a bootstrap placeholder. Downstream phases (Fase 3 `specboot init`/`update`, Fase 4 SemVer rules via TICKET-0.4, Fase 5 Makefile reading `services`/`stack`) all depend on a frozen, authoritative schema and on a validation behavior that is predictable. Without it, those phases would each reinvent the contract. This change freezes the canonical schema and ships a standalone validation script (`validate-specboot.sh`) plus documentation, so the framework becomes self-validating.

## What Changes

- **Adds** `docs/specboot-json-standard.md` — the canonical schema document (standalone, definition-only; no implementation code).
- **Adds** `validate-specboot.sh` at repo root — standalone validation script that checks presence, JSON validity, required fields, framework-version compatibility, and `services` path existence; exits 0 on success/warnings-only and 1 on hard errors.
- **Rewrites** `.specboot.example.json` to the full schema (valid JSON, all fields incl. optional `layers`) and **adds** `.specboot.example.README.md` with per-field commentary (JSON has no comments).
- **Rewrites** the repo's own `.specboot.json` to the final schema (dogfooding: `services:["."]`, `stack:"framework"`, `frameworkVersion:"0.1.1"`).
- **Edits** `docs/framework-contract.md` and `docs/docs-standard.md` to link the new standard.
- **Evolves** `specboot.sh` (intocable for project devs, but the framework evolves it via dogfooding): adds `--version` and a tolerant `check_specboot_json` step inside `--ci`.
- **Edits** `package.json` `files` to ship `validate-specboot.sh`.

## Overview

This proposal defines the official `.specboot.json` schema and the validation contract, documents both, and wires validation into the framework's own CI so every Specboot project (and Specboot itself) can verify its configuration before linting.

## Goals
- Freeze the canonical schema (required + optional fields, including opt-in `layers`).
- Define deterministic validation behavior (missing → warn/exit0; invalid/missing-field/missing-path → error/exit1; version mismatch → warn or error).
- Ship a reusable, framework-distributed `validate-specboot.sh`.
- Document the schema as a standalone intocable framework doc.

## Non-Goals
- Implementation of `specboot init` / `specboot update` (Fase 3/4).
- SemVer bump rules (TICKET-0.4) — only the `frameworkVersion` SemVer *format* is used.
- npm packaging (Fase 1).
- Makefile consumption of `services`/`stack` (Fase 5).

## Enriched User Story
**As a** framework maintainer (Agencia Zavando)
**I want** a single authoritative `.specboot.json` schema and a validation script
**So that** every project (and Specboot itself) can declare its services/stack/version and be validated deterministically before the framework lints or updates.

### Context
`.specboot.json` is declared project-owned in `docs/framework-contract.md`. The bootstrap placeholder lacked the full schema and any validation. This change closes that gap without implementing the future commands that will consume it.
