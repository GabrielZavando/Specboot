---
description: Valid demo agent matching its manifest contract exactly
mode: primary
permission:
  edit:
    "*": deny
    "openspec/state/verify-results.json": allow
  bash:
    "*": deny
    "npm test": allow
    "date *": allow
    "git push --force*": deny
---

# demo fixture
