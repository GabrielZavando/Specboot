---
description: Frontend implementation subagent — Angular/Astro/UI, applies docs/frontend-standards.md
mode: subagent
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

{file:ai-specs/agents/frontend-developer.md}

You are the frontend specialist. Before implementing, read `docs/frontend-standards.md`
and, when the task touches the API contract, `docs/api/api-spec.yml`. Follow TDD and the
SOLID/accessibility rules declared there.
