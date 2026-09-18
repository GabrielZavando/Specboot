# Requirements: release-tagging

1. **REQ-001**: `release-bump.sh` SHALL create a **git tag** `v{version}` upon a successful bump (documented in its output message, consistent with the existing `update.sh --bump` behavior).
2. **REQ-002**: `update.sh --bump` SHALL compute the current version from `package.json` (not `git describe --tags`), so the flow works regardless of tag completeness.
3. **REQ-003**: `docs/versioning-standard.md` SHALL document the tagging policy: local tag creation on bump, tag push after merging to `main`, and GitHub Releases created from the UI with the CHANGELOG section.
4. **REQ-004**: The backfill of missing historical tags (v0.6.4, v0.7.0, v0.8.0, v0.8.1, v0.9.0) SHALL be executed (commit-SHA pointers), pushed (`git push origin --tags`), and SHALL NOT trigger `release.yml`.
5. **REQ-005**: `tests/release-bump-test.sh` SHALL assert tag creation from the bump script; `check-refs.sh`, `specboot.sh --ci`, `validate-specboot.sh` and all `tests/*-test.sh` SHALL pass (no regression).

| Hallazgo (§1) | Fase | REQ | Verificación clave |
|---|---|---|---|
| F1 Tags faltantes v0.6.4..v0.9.0 | Tooling+docs | REQ-001/REQ-002/REQ-003/REQ-004 | `git tag -l 'v*'` incluye todos y `git push origin --tags` no dispara release.yml |
| F2 release-bump no crea tag | Tooling | REQ-001/REQ-005 | exit code 0, tag local aparece en git log/tags |
| F3 update.sh --bump usa describe sobre tags viejos | Tooling | REQ-002 | resultado semver correcto desde package.json (independiente de tags) |
| F4 Política no documentada | Docs | REQ-003 | `docs/versioning-standard.md` snake flow documentado |
| — No regression | — | REQ-005 | verificación integral en verde |
