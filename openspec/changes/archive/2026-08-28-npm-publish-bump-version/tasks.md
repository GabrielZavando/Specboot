# Tasks: npm-publish-bump-version

## Phase 1: Version Bump
- [ ] Bump `package.json` version from `0.1.0` to `0.1.1` (High | Infrastructure | 0.25h)
    - Suggested Path: `package.json`

## Phase 2: Verification & Release
- [x] Verify `npm pack --dry-run` succeeds after version bump (Medium | Infrastructure | 0.5h)
- [x] Force-push tag `v0.1.1` and confirm clean workflow run (Medium | Infrastructure | 0.5h)
