# Proposal: Document npm distribution boundary in README and framework-contract

**Ticket ID**: TICKET-1.2
**Original title**: Documentar la frontera de distribución en el README del paquete npm
**Tag**: [docs]
**Derived change name**: npm-distribution-docs
**Depends-on**: TICKET-1.1

## Why

TICKET-1.1 restricted `package.json`'s `files` allowlist to ship **only intocable framework assets**. That make the boundary real, but it is *implicit*: a reader (consumer or dogfooding dev) cannot tell from the published package what is framework and what is project. The dev repo of Specboot itself carries a rich `docs/` tree (backend/frontend/documentation/deploy standards, `api/`, `data-model/`, `ci-standards.md`, `project/`) that is **not** published — without explicit docs this causes confusion during dogfooding ("why isn't my `docs/backend-standards.md` in the installed package?").

## What Changes

- `README.md`: new `## Qué incluye el paquete` section listing exactly the assets in the `files` allowlist, and `## Qué es del proyecto (NO se publica)` section listing project-owned assets that never ship. Placed right after the "Instalación como paquete NPM" block, before "Estructura del Proyecto".
- `docs/framework-contract.md`: new `### Distribución vía npm` subsection (under "Arquitectura de distribución") reaffirming that only intocable assets publish and that the project `docs/` is filtered out by `files`.

The source of truth for both sections is the `files` allowlist in `package.json` (result of TICKET-1.1); this ticket only *documents* it.

## Summary and Motivation

Closes **Fase 1 (Empaquetado npm)** in a documented way: the npm distribution boundary — what the package installs vs. what stays in the project — is now explicit and discoverable, preventing dogfooding confusion and setting the contract baseline for Fase 3/4 (`init`/`update`).

## Acceptance Criteria (from ticket)

1. `README.md` lists what the package includes / does not include.
2. `docs/framework-contract.md` has a "Distribución vía npm" subsection.
3. `bash check-refs.sh` → 0 and `bash specboot.sh --ci` → 0.

## Rollback Plan

- Revert `README.md` and `docs/framework-contract.md` via git. The published artifact is immutable on GitHub Packages; if a bad version shipped, `npm deprecate` and cut a patch. No `package.json` or capability-spec change is required by this ticket.
