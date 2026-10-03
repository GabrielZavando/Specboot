---
description: Regression fixture — commit agent allowed to spawn subagents
mode: primary
permission:
  edit: deny
  bash:
    "*": deny
    "git status": allow
    "git diff": allow
    "git log": allow
    "git add *": allow
    "git commit *": allow
    "git push *": allow
    "node -e *": deny
    "python -c *": deny
    "python3 -c *": deny
  task:
    "*": deny
    backend: allow
    frontend: allow
---

# commit regression fixture

Deliberate regression (SC-007): commit spawns subagents — the front matter
task block allows backend/frontend while can_spawn_subagents=false in the
manifest, so the validator must fail.
