# Proposal: `make solid-lint` — stack guard + eslint@8 pin

## Change created from ticket

**Ticket ID**: TICKET-0.5
**Original title**: make solid-lint: stack guard + eslint@8 pin (fix CI break on framework repo)
**Tag (source)**: [fullstack] (inferred — change touches the SOLID/POO lint toolchain; loads backend+frontend SOLID standards for context)
**Derived change name**: solid-lint-stack-guard
**Change folder**: openspec/changes/solid-lint-stack-guard/
**Enriched artifact used**: no (bug report is specific enough)

### Naming rationale
- Noun/verb: `solid-lint` (the CI target) + `stack-guard` (the mechanism). Noun-led, consistent with sibling meta-doc changes (`framework-contract`, `docs-standard`, `specboot-json-schema`).

### Context loaded
- `docs/base-standards.md` (always)
- `docs/backend-standards.md` (SOLID thresholds enforced by `eslintrc.backend.js`)
- `docs/frontend-standards.md` (SOLID thresholds enforced by `eslintrc.frontend.js`/`astro.js`)
- `docs/docs-standard.md` + `docs/framework-contract.md` (templates/ci/ and Makefile are intocable framework files)
- `docs/specboot-json-standard.md` (TICKET-0.3: `.specboot.json` `stack` field is the input to the guard)
- `templates/ci/README.md`, `templates/ci/package.ci.json`, `Makefile` (current implementation)

## Why

`make solid-lint` fails on the Specboot framework repo (dogfooding CI), blocking PRs. Root cause (diagnosed):
1. `Makefile` `solid-lint` decides the stack from the **presence of `package.json`** (`STACK=node`), not from `.specboot.json` `stack`. The framework repo has `package.json` (for `npm publish`) but `stack: "framework"` and **no application code**, so the target runs NestJS ESLint over `.`.
2. `npx eslint -c templates/ci/eslintrc.backend.js` runs **without a pinned version**; with no local `node_modules` the framework repo fetches the latest ESLint (10.x, flat-config only). The shipped `eslintrc.*.js` configs are **legacy `.eslintrc` format** (`root: true`), which ESLint 10 rejects → `make solid-lint` errors.

Key evidence: `templates/ci/package.ci.json` pins `eslint: "^8.57.0"` and the configs are eslintrc format — so **consumer projects instantiate with ESLint 8 and work fine**. The breakage is isolated to the framework repo (and any project without a local ESLint install). A flat-config migration of the configs would force bumping all consumer plugin versions and is untestable here (no `node_modules`), so it is explicitly **out of scope**.

## What Changes

- **`Makefile` (`solid-lint`)**: read `stack` from `.specboot.json` (normalized string→array). Only run the Node lint family (eslint backend/frontend/astro + dependency-cruiser + madge) when `node` ∈ stack, and the Python family (ruff + import-linter) when `python` ∈ stack. When neither applies (e.g. `framework`), print a clear skip message and exit 0 — do **not** run linters and do **not** error "no SOLID config applies".
- **`Makefile` (`solid-lint`)**: pin `npx eslint@8` (instead of bare `npx eslint`) in the three ESLint invocations, so a project without a local ESLint never fetches the flat-config-only ESLint 10 and re-breaks.
- **`templates/ci/README.md`**: document the stack-aware skip behavior so the doc matches reality.
- `.specboot.json` of the framework repo already declares `stack: "framework"`, so after the guard `make solid-lint` skips cleanly (no file change needed beyond confirming).

## Overview

Make `make solid-lint` honor `.specboot.json` `stack` (the project-declared contract from TICKET-0.3) and pin ESLint to v8, fixing the framework's own CI without disturbing consumer projects that already run ESLint 8.

## Goals
- Unblock the framework repo's `make solid-lint` (exit 0, skip on `stack: "framework"`).
- Prevent `npx eslint` from silently fetching ESLint 10 (flat-config) on projects lacking a local ESLint.
- Keep consumer projects (ESLint 8 + eslintrc configs) 100% unchanged.

## Non-Goals
- Migrating `eslintrc.*.js` to ESLint flat config (would require bumping `eslint`/plugin versions in `package.ci.json`; risky, untestable here).
- Changing SOLID thresholds in `docs/backend-standards.md` or `docs/frontend-standards.md`.
- SemVer rules (TICKET-0.4) — only the `frameworkVersion` SemVer format from TICKET-0.3 is used.

## Enriched User Story
**As a** framework maintainer (Agencia Zavando)
**I want** `make solid-lint` to respect `.specboot.json` `stack` and pin ESLint 8
**So that** the framework's own CI (and any stack-only-framework project) passes instead of failing on a flat-config incompatibility.

### Context
`make solid-lint` is the stack-agnostic SOLID/POO gate invoked by `.github/workflows/ci.yml`. On the framework repo it must skip (no app code, `stack: "framework"`), but currently it runs NestJS ESLint over `.` and crashes because `npx` pulls ESLint 10. The fix makes the target declarative via `.specboot.json` and version-pins ESLint.
