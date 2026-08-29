# Tasks: Specboot NPM Publication

## Phase 1: Package Configuration
- [x] Create `package.json` with scope, version, and `files` allowlist (High | Infrastructure | 1h)
    - Suggested Path: `package.json`
- [x] Create `.npmignore` as a safety fallback (Medium | Infrastructure | 0.5h)
    - Suggested Path: `.npmignore`

## Phase 2: Automation & Distribution
- [x] Create GitHub Actions workflow `publish.yml` for tag-based publication (High | Infrastructure | 1h)
    - Suggested Path: `.github/workflows/publish.yml`

## Phase 3: Documentation
- [x] Update `README.md` with "Instalación como paquete NPM" section (High | Docs | 1h)
    - Suggested Path: `README.md`

## Phase 4: Verification
- [x] Verify package contents using `npm pack --dry-run` (High | Infrastructure | 0.5h)
- [x] Execute test publication (manual or via tag) and verify visibility in GitHub Packages (High | Infrastructure | 1h)
