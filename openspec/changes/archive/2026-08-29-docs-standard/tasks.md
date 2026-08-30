# Tasks — docs-standard (TICKET-0.2)

## 1. Define the docs/ standard document
- [x] 1.1 Create `docs/docs-standard.md` with the canonical tree (`project/`, `api/`, `data-model/` folders + the standard files) — **layer: docs**, priority: P0, estimate: 0.5h, Suggested Path: `docs/docs-standard.md`, Test Path: `specboot.sh --ci`
- [x] 1.2 Add the intocable/del-proyecto table marking `base-standards.md` as intocable and the other doc files as del proyecto — **layer: docs**, priority: P0, estimate: 0.25h, Suggested Path: `docs/docs-standard.md`
- [x] 1.3 Document the dynamic-load rule for the bridge `AGENTS.md` (`base-standards.md` always + `docs/project/*` read per task tag) — **layer: docs**, priority: P1, estimate: 0.25h, Suggested Path: `docs/docs-standard.md`
- [x] 1.4 Link `docs/docs-standard.md` from `docs/framework-contract.md` — **layer: docs**, priority: P1, estimate: 0.1h, Suggested Path: `docs/framework-contract.md`

## 2. Reorganize docs/ to the standard tree
- [x] 2.1 Move `docs/api-spec.yml` → `docs/api/api-spec.yml` (preserve content) — **layer: docs**, priority: P0, estimate: 0.1h, Suggested Path: `docs/api/api-spec.yml`, Test Path: `check-refs.sh`
- [x] 2.2 Move `docs/data-model.md` → `docs/data-model/data-model.md` (preserve content) — **layer: docs**, priority: P0, estimate: 0.1h, Suggested Path: `docs/data-model/data-model.md`, Test Path: `check-refs.sh`
- [x] 2.3 Create `docs/project/{domain.md, stack.md, client.md}` templates — **layer: docs**, priority: P0, estimate: 0.25h, Suggested Path: `docs/project/`
- [x] 2.4 Update `specboot.sh` `REQUIRED_FILES` to `docs/api/api-spec.yml` and `docs/data-model/data-model.md` so `specboot.sh --ci` keeps 0 errors after the move — **layer: framework**, priority: P0, estimate: 0.1h, Suggested Path: `specboot.sh`, Test Path: `specboot.sh --ci`
- [x] 2.5 Verify no project-context doc remains loose in `docs/` root (only the standard file set) — **layer: docs**, priority: P1, estimate: 0.1h, Test Path: `find docs -maxdepth 1 -type f`

## 3. Migrate `.openspec/` → `openspec/` in `.opencode/` and `ai-specs/`
- [x] 3.1 Replace every `.openspec/` occurrence with `openspec/` across `.opencode/commands/*`, `.opencode/agents/*`, `ai-specs/skills/*`, `ai-specs/agents/*`, `ai-specs/examples/*` — **layer: framework**, priority: P0, estimate: 0.5h, Suggested Path: `.opencode/ commands & ai-specs/`, Test Path: `grep -R ".openspec/" .opencode/ ai-specs/`
- [x] 3.2 Confirm `grep -R ".openspec/" .opencode/ ai-specs/` returns 0 matches — **layer: framework**, priority: P0, estimate: 0.05h, Test Path: `grep -R ".openspec/" .opencode/ ai-specs/`

## 4. Repo-wide path consistency (avoid regressions)
- [x] 4.1 Update `AGENTS.md` path references to `openspec/` — **layer: framework**, priority: P0, estimate: 0.15h, Suggested Path: `AGENTS.md`, Test Path: `grep -R ".openspec/" AGENTS.md`
- [x] 4.2 Update `.gitignore`: remove the vestigial `.openspec/` ignore line, keep `openspec/` tracked — **layer: framework**, priority: P1, estimate: 0.1h, Suggested Path: `.gitignore`
- [x] 4.3 Update `README.md` and `CHANGELOG.md` path references to `openspec/` — **layer: framework**, priority: P1, estimate: 0.15h, Suggested Path: `README.md`, Test Path: `grep -R ".openspec/" README.md CHANGELOG.md`
- [x] 4.4 Reword the deprecated-path prose in `docs/framework-contract.md` (explanatory tense, not current instruction) — **layer: docs**, priority: P2, estimate: 0.1h, Suggested Path: `docs/framework-contract.md`

## 5. Eliminate `base-standards.md` placeholder warnings
- [x] 5.1 Rewrite `docs/base-standards.md` section 8 to remove the 5 placeholder patterns, preserving SDD/TDD/SOLID principles — **layer: docs**, priority: P0, estimate: 0.25h, Suggested Path: `docs/base-standards.md`, Test Path: `specboot.sh --ci`
- [x] 5.2 Run `specboot.sh --ci` and confirm 0 placeholder warnings (or document any justified remaining warning) — **layer: docs**, priority: P0, estimate: 0.1h, Test Path: `specboot.sh --ci`

## 6. Validate the change
- [x] 6.1 Run `openspec validate docs-standard` — **layer: docs**, priority: P0, estimate: 0.1h, Test Path: `openspec validate docs-standard`
- [x] 6.2 Run `check-refs.sh` → 0 errors — **layer: docs**, priority: P0, estimate: 0.1h, Test Path: `check-refs.sh`
- [x] 6.3 Run `specboot.sh --ci` and confirm warning count is below the TICKET-0.1 baseline (target: 0) — **layer: docs**, priority: P0, estimate: 0.1h, Test Path: `specboot.sh --ci`

## 7. Address adversarial-review findings (SHIP blockers, cheap fixes)
- [x] 7.1 Fix typo `INOCABLE` → `INTOCABLE` in `docs/docs-standard.md` (line 12) — **layer: docs**, priority: P1, estimate: 0.05h, Suggested Path: `docs/docs-standard.md`
- [x] 7.2 Update `ai-specs/skills/onboarding/SKILL.md` project tree: `api-spec.yml` → `docs/api/api-spec.yml`, `data-model.md` → `docs/data-model/data-model.md` (nested) — **layer: framework**, priority: P1, estimate: 0.1h, Suggested Path: `ai-specs/skills/onboarding/SKILL.md`
- [x] 7.3 Update `README.md` project tree (lines ~116-117) to canonical nested paths — **layer: framework**, priority: P1, estimate: 0.1h, Suggested Path: `README.md`
- [x] 7.4 Update loose `api-spec.yml`/`data-model.md` refs in `ai-specs/skills/plan-change/SKILL.md` (lines 49, 95, 120-121) and `ai-specs/skills/verify/SKILL.md` (line 55) to canonical paths — **layer: framework**, priority: P2, estimate: 0.1h, Suggested Path: `ai-specs/skills/`
- [x] 7.5 Update example templates (`ai-specs/examples/ticket-ejemplo.md`, `enrich-us-auth-reset.md`, `scenarios-example.md`) and `CHANGELOG.md` (line 51) to canonical paths — **layer: framework**, priority: P2, estimate: 0.1h, Suggested Path: `ai-specs/examples/`, `CHANGELOG.md`
- [x] 7.6 Clarify in `docs/docs-standard.md` that `framework-contract.md` and `docs-standard.md` are also framework-injected docs (updated via the framework SDD flow, not by the project dev) — **layer: docs**, priority: P2, estimate: 0.1h, Suggested Path: `docs/docs-standard.md`
