---
description: Demo agent with edit scope wider than the manifest allows
mode: primary
permission:
  edit:
    "*": deny
    "openspec/state/verify-results.json": allow
    "openspec/state/adversarial-result.json": allow
  bash:
    "*": deny
---

# demo fixture
