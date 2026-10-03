---
description: Regression fixture — build allowed to write foreign evidence
mode: primary
permission:
  edit:
    "**": allow
    "openspec/state/verify-results.json": allow
    "openspec/state/adversarial-result.json": allow
  bash:
    "*": deny
    "npm test": allow
    "git push --force*": deny
  task: deny
---

# build regression fixture

Deliberate regression (SC-004): build writes foreign evidence — the front
matter allows the verify/adversarial evidence files while the manifest
forbids them, so the validator must fail.
