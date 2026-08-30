# Requirements: Git workflow guidelines

1. `docs/git-workflow-standards.md` MUST exist and be the source of truth for the git workflow policy, stating that it **extends** (does not replace) the basic git rules in `AGENTS.md` and that no intocable framework file is modified (REQ-1) -> Scenario 1, Scenario 7

2. The document MUST define the **branch-per-ticket** rule: every new ticket creates a branch `feature/ticket-X.Y-nombre-corto` from the current HEAD, without reusing previous tickets' branches unless intentionally accumulating a Phase (REQ-2) -> Scenario 2

3. The document MUST define the **commits local-first** rule: Conventional Commit headers, one logical change per commit, `Closes TICKET-X.Y` reference, and no mandatory push — commits may remain local (REQ-3) -> Scenario 3

4. The document MUST define the **phase closure** procedure: accumulate Phase tickets on one branch → review locally → decide push/PR → if pushing, perform a **single** `git rebase main` (conflicts resolved once) followed by `git push` and **one PR per Phase** (squash/merge of all Phase commits) (REQ-4) -> Scenario 4

5. The document MUST contain a **2×2 push/PR decision matrix** (`gh` authenticated × Phase ready for review) covering all four combinations and their actions: rebase+push+PR; local commit + ticket "en local"; manual PR on GitHub.com without forced rebase; local commit + review later (REQ-5) -> Scenario 5

6. The document MUST guarantee the **local-only mode**: the user may close a Phase/ticket as "completa en local" with commits on the feature branch, with no push/PR forced and no commits lost for lack of rebase ("no ghost branch" invariant) (REQ-6) -> Scenario 6

7. The change MUST NOT modify intocable framework files (`AGENTS.md`, `docs/base-standards.md`, `docs/framework-contract.md`, `docs/docs-standard.md`, `docs/versioning-standard.md`, `docs/specboot-json-standard.md`) nor contradict `docs/documentation-standards.md`'s "Commits y PRs" rules (REQ-7) -> Scenario 7

8. After the document is created, `bash check-refs.sh` and `bash specboot.sh --ci` MUST both exit 0 (REQ-8) -> Scenario 8