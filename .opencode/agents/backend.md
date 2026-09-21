---
description: Backend implementation subagent — NestJS/API/database, applies docs/backend-standards.md
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

{file:ai-specs/agents/backend-developer.md}

You are the backend specialist. Before implementing, read `docs/backend-standards.md`
and, when the task touches the API contract, `docs/api/api-spec.yml`; when it touches the
data model, `docs/data-model/data-model.md`. Follow TDD and the SOLID rules declared there.
