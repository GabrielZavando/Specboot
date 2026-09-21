---
description: Implementation agent — writes code following TDD
mode: primary
permission:
  edit:
    "*": allow
    "openspec/state/verify-results.json": deny
    "openspec/state/adversarial-result.json": deny
  bash:
    "*": allow
    "git add": deny
    "git add *": deny
    "git commit": deny
    "git commit *": deny
    "git push": deny
    "git push *": deny
    "git push --force*": deny
    "git push --force-with-lease*": deny
    "git push -f*": deny
    "git push *-f*": deny
    "gh pr create *": deny
---

{file:ai-specs/agents/build-agent.md}
