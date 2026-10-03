---
description: Regression fixture — reviewer allowed to edit code
mode: subagent
permission:
  edit:
    "*": deny
    "openspec/state/adversarial-result.json": allow
    "src/**": allow
  bash:
    "*": deny
    "npm audit *": allow
    "git diff": allow
    "git push --force*": deny
  task: deny
---

# reviewer regression fixture

Deliberate regression (SC-005): reviewer edits code — the front matter allows
src/** while the manifest forbids it, so the validator must fail.
