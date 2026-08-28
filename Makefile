# Makefile — Stack-agnostic CI interface for Zavando Specboot projects
#
# Each stack implements the same set of targets (install, lint, test, build,
# audit, commitlint). CI (.github/workflows/ci.yml) only invokes these targets,
# never the underlying commands, so the pipeline stays identical across projects.
#
# To customize for your stack, adjust the commands inside each target or add a
# new branch to the STACK detection below.

.PHONY: help install lint test build audit commitlint refs solid-lint

# Detect the active stack from its manifest file.
STACK := $(shell \
  if [ -f package.json ]; then echo node; \
  elif [ -f composer.json ]; then echo php; \
  elif [ -f pyproject.toml ] || [ -f requirements.txt ]; then echo python; \
  elif [ -f go.mod ]; then echo go; \
  elif [ -f Cargo.toml ]; then echo rust; \
  else echo unknown; fi)

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'

install: ## Install dependencies (stack-specific)
	@case "$(STACK)" in \
	  node) \
	    if node -e "const p=require('./package.json');process.exit((p.dependencies||p.devDependencies)?0:1)" 2>/dev/null; then \
	      if [ -f package-lock.json ] || [ -f npm-shrinkwrap.json ]; then npm ci; \
	      else npm install; fi; \
	    else \
	      echo "→ install: package.json has no dependencies (Metadoc template for npm publish) — skipping"; \
	    fi ;; \
	  php)    composer install --no-interaction ;; \
	  python) pip install -r requirements.txt ;; \
	  go)     go mod download ;; \
	  rust)   cargo fetch ;; \
	  *)      echo "install: no stack detected — personalize the project and add install steps" ;; \
	esac

# If a node project does not define a given script, skip it gracefully (the
# Metadoc template carries a root package.json only for `npm publish` and has no
# lint/test/build/audit scripts, so CI must not fail when they are absent).
node_has_script = $(shell node -e "try{process.exit(Object.keys(require('./package.json').scripts||{}).includes('$(1)')?0:1)}catch(e){process.exit(1)}" 2>/dev/null && echo yes || echo no)

lint: ## Lint and static analysis (stack-specific)
	@case "$(STACK)" in \
	  node)   if [ "$(call node_has_script,lint)" = "yes" ]; then npm run lint; else echo "→ lint: no lint script in package.json — skipping (Metadoc template)"; fi ;; \
	  php)    composer lint ;; \
	  python) ruff check . ;; \
	  go)     go vet ./... ;; \
	  rust)   cargo clippy -- -D warnings ;; \
	  *)      bash specboot.sh --ci ;; \
	esac
	@$(MAKE) refs

test: ## Run the test suite (stack-specific)
	@case "$(STACK)" in \
	  node)   if [ "$(call node_has_script,test)" = "yes" ]; then npm test; else echo "→ test: no test script in package.json — skipping (Metadoc template)"; fi ;; \
	  php)    composer test ;; \
	  python) pytest ;; \
	  go)     go test ./... ;; \
	  rust)   cargo test ;; \
	  *)      echo "test: no stack detected — add your test command" ;; \
	esac
	@$(MAKE) refs

build: ## Build the project (stack-specific)
	@case "$(STACK)" in \
	  node)   if [ "$(call node_has_script,build)" = "yes" ]; then npm run build; else echo "→ build: no build script in package.json — skipping (Metadoc template)"; fi ;; \
	  php)    composer install --no-dev --optimize-autoloader ;; \
	  python) pip install -e . ;; \
	  go)     go build ./... ;; \
	  rust)   cargo build --release ;; \
	  *)      echo "build: no stack detected — add your build command" ;; \
	esac

audit: ## Security audit (stack-specific)
	@case "$(STACK)" in \
	  node)   if [ "$(call node_has_script,audit)" = "yes" ]; then npm audit --audit-level=high; else echo "→ audit: no audit script in package.json — skipping (Metadoc template)"; fi ;; \
	  php)    composer audit ;; \
	  python) pip-audit ;; \
	  go)     go list -m -u ;; \
	  rust)   cargo audit ;; \
	  *)      echo "audit: no stack detected — add your audit command" ;; \
	esac

commitlint: ## Lint commit messages (stack-independent)
	npx -p @commitlint/cli -p @commitlint/config-conventional commitlint --from HEAD~1 --to HEAD --verbose

refs: ## Check referential integrity of {file:...} references
	bash check-refs.sh

solid-lint: ## Run SOLID/POO static analysis (Ticket 4). Stack-agnostic: detects Node or Python and fails loudly if code exists but no config applies.
	@# Resolve the source root(s). Prefer an explicit .specboot.json "services"
	# glob when present (set by TICKET-C); otherwise fall back to src/ / app/.
	ROOT_DIRS="$$(node -e "try{const s=require('./.specboot.json').services;s&&s.length&&process.stdout.write(s.join(' '))}catch(e){}" 2>/dev/null)"; \
	if [ -z "$$ROOT_DIRS" ]; then \
	  if [ -d src ]; then ROOT_DIRS="src"; \
	  elif [ -d app ]; then ROOT_DIRS="app"; fi; \
	fi; \
	if [ -z "$$ROOT_DIRS" ]; then \
	  echo "→ solid-lint: no application code (src/ or app/) found — skipping (Metadoc template)"; \
	  exit 0; \
	fi; \
	echo "→ SOLID/POO static analysis (stack-agnostic) on: $$ROOT_DIRS"; \
	ran_any=0; \
	if [ -f package.json ]; then \
	  ran_any=1; \
	  if [ -f templates/ci/eslintrc.backend.js ] && [ -d src ]; then \
	    echo "  → Backend ESLint (NestJS)"; \
	    npx eslint -c templates/ci/eslintrc.backend.js 'src/**/*.{ts,tsx}' || exit 1; \
	  fi; \
	  if [ -f templates/ci/eslintrc.frontend.js ] && [ -d src ] && [ -f angular.json ]; then \
	    echo "  → Frontend ESLint (Angular)"; \
	    npx eslint -c templates/ci/eslintrc.frontend.js 'src/**/*.{ts,tsx}' || exit 1; \
	    echo "  → madge circular deps (Angular)"; \
	    npx madge --Circular --extensions ts --exclude '\.spec\.ts$$' src/ || exit 1; \
	  fi; \
	  if [ -f templates/ci/eslintrc.astro.js ] && [ -d src ]; then \
	    echo "  → Astro ESLint"; \
	    npx eslint -c templates/ci/eslintrc.astro.js 'src/**/*.{ts,astro}' || exit 1; \
	  fi; \
	  if [ -f templates/ci/.dependency-cruiser.js ] && [ -d src ]; then \
	    echo "  → dependency-cruiser (DIP enforcement)"; \
	    npx dependency-cruiser --config templates/ci/.dependency-cruiser.js src/ || exit 1; \
	  fi; \
	elif [ -f pyproject.toml ] || [ -f requirements.txt ]; then \
	  ran_any=1; \
	  if [ -f templates/ci/ruff.toml ]; then \
	    echo "  → Ruff (Python lint, complexity 10 / line 100)"; \
	    ruff check --config templates/ci/ruff.toml . || exit 1; \
	  fi; \
	  if [ -f templates/ci/.importlinter ]; then \
	    echo "  → import-linter (DIP enforcement)"; \
	    lint-imports --config-file templates/ci/.importlinter || exit 1; \
	  fi; \
	fi; \
	if [ "$$ran_any" = "0" ]; then \
	  echo "❌ solid-lint: application code found ($$ROOT_DIRS) but no SOLID config applies."; \
	  echo "   Add templates/ci/*.js (Node) or templates/ci/ruff.toml + .importlinter (Python) to your project."; \
	  exit 1; \
	fi; \
	echo "→ SOLID/POO static analysis: PASS"
