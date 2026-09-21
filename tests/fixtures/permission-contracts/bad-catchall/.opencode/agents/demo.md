---
description: Demo agent with catch-all AFTER exceptions (violates last-match-wins semantics)
mode: primary
permission:
  edit:
    "*": deny
    "openspec/**": allow
  bash:
    "openspec *": allow
    "git status": allow
    "*": deny
    "git status *": allow
---

# demo fixture
