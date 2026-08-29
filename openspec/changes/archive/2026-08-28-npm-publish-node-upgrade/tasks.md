# Tasks: npm-publish-node-upgrade

## Phase 1: Workflow Configuration
- [ ] Bump `actions/checkout` to `v5` in `publish.yml` (Low | Infrastructure | 0.25h)
    - Suggested Path: `.github/workflows/publish.yml`
- [ ] Bump `actions/setup-node` to `v5` and `node-version` to `'24'` in `publish.yml` (Low | Infrastructure | 0.25h)
    - Suggested Path: `.github/workflows/publish.yml`

## Phase 2: Verification & Release
- [x] Verify `npm pack --dry-run` still passes after changes (Medium | Infrastructure | 0.5h)
- [x] Cut `v0.1.1` tag and confirm clean workflow run without warnings (Medium | Infrastructure | 0.5h)
