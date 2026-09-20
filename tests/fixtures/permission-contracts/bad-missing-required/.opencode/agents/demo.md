---
description: Demo agent missing a required permission (npm test *)
mode: primary
permission:
  edit:
    "*": deny
    "openspec/**": allow
  bash:
    "*": deny
    "openspec *": allow
---

# demo fixture
