# Requirements: force-push-deny-and-doc-distribution

1. **REQ-001 — Canonical doc ships.** `docs/tdd-failure-protocol.md` MUST appear in `package.json` `files`, in `FRAMEWORK_ITEMS` (init copies it) and in `UPDATE_ITEMS` (update replaces it) of `specboot.sh`. → SC-001, SC-002, SC-003

2. **REQ-002 — Distribution docs/specs in sync.** The intocable docs set MUST read as 7 (not 6) in `docs/docs-standard.md`, `docs/framework-contract.md` (if it lists them), and the delta specs for `npm-distribution` / `specboot-update` must reflect the change. → SC-004

3. **REQ-003 — Force-push fully denied.** The commit agent permission block MUST deny every common force-push variant (`git push --force`, `git push -f`, `git push origin <branch> --force`, `git push origin <branch> -f`); no variant may fall into the generic `git push *` allow. The resolution approach depends on a spike: mid-command wildcard patterns if supported, otherwise close the push allow to explicit forms (`git push`, `git push -u origin *`, `git push origin *`) and document any residual. → SC-005

4. **REQ-004 — Role mirror (M-403).** The commit agent role MUST document the new deny set, and the permission block MUST mirror it exactly (guards assert both directions). → SC-006

5. **REQ-005 — TDD guards first.** Guards (`package-files-test.sh`, `specboot-init-test.sh`, `specboot-update-test.sh`, `agent-permissions-test.sh`) MUST be extended and observed failing before implementation; at completion all guards, `check-refs.sh` and `specboot.sh --ci` MUST pass, with CHANGELOG entry and patch bump 0.8.0 → 0.8.1. → SC-007
