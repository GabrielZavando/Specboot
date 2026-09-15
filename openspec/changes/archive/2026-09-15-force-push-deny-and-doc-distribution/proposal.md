# Proposal: force-push-deny-and-doc-distribution

Ticket ID: TICKET-AUDIT-2
Title: [docs] Cobertura de force-push en commit agent + distribución del protocolo TDD canónico
Tag (source): [docs] (explicit)
Change type: tooling/framework (specs delta apply)

## Why

Two follow-ups from the archived `sdd-cycle-hardening` change:

1. **Distribution bug**: `docs/tdd-failure-protocol.md` was made the canonical
   TDD failure protocol and is referenced by `apply.md`, `build-agent.md` and
   `examples/tasks.md`, but it is NOT in `package.json` `files`, nor in
   `specboot.sh` `FRAMEWORK_ITEMS`/`UPDATE_ITEMS`. Consumer projects install a
   reference to a document that never arrives (broken canonical reference).
2. **Force-push deny coverage gap** (adversarial WARNING): the commit agent's
   `"git push --force*": deny` only blocks the flag as second token;
   `git push origin <branch> --force` and `git push -f` fall through to the
   generic `git push *` allow and execute.

## What Changes

- Ship `docs/tdd-failure-protocol.md` in the package: package.json files,
  FRAMEWORK_ITEMS and UPDATE_ITEMS in specboot.sh, docs-standard tree, and
  the npm-distribution / specboot-update specs (6 → 7 intocable docs).
- Harden the commit agent permission block so all common force-push variants
  (`--force`, `-f`, flag after remote/branch) hit a deny pattern, keeping the
  role mirror (M-403). Spike first: if the permission engine does not support
  mid-command wildcards, fall back to closing the push allow to explicit forms
  and documenting any residual variant.

## Source

Enriched ticket: `openspec/tickets/TICKET-AUDIT-2-enriched.md`
(Event: TICKET-AUDIT-1 adversarial review WARNING + post-merge packaging audit.)
