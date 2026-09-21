#!/usr/bin/env bash
# TDD test for SPECBOOT-HARDEN-02 — validator faithful to OpenCode (REQ-006,
# SC-010/SC-011). Uses throwaway fixtures built at runtime under a temp dir.
#
# Run: bash tests/validator-opencode-test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VAL="$ROOT/scripts/validate-agent-permissions.mjs"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

PASS=0
FAIL=0
ok()  { echo "  ✓ $1"; PASS=$((PASS + 1)); }
bad() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

# mk_fx <dirname> <agent-bash-yaml-lines...> writes a valid manifest + agent.
# The manifest flags can be overridden via env F_COMMIT/F_PUSH/F_PRS/F_SPAWN.
mk_fx() {
  local dir="$1"; shift
  mkdir -p "$WORK/$dir/.opencode/agents"
  sed -e "s/__COMMIT__/${F_COMMIT:-false}/" \
      -e "s/__PUSH__/${F_PUSH:-false}/" \
      -e "s/__PRS__/${F_PRS:-false}/" \
      -e "s/__SPAWN__/${F_SPAWN:-false}/" \
  >/dev/null <<'YML'
YML
  cat > "$WORK/$dir/manifest.yml" <<YML
version: 1
agents:
  demo:
    mode: primary
    edit:
      mode: restricted
      allow: []
      forbidden: []
    bash:
      required: []
      forbidden:
        - "git add *"
        - "git commit *"
        - "git push"
        - "git push *"
        - "git push --force*"
        - "gh pr create *"
    evidence:
      must_write: []
    can_commit: __COMMIT__
    can_push: __PUSH__
    can_manage_prs: __PRS__
    can_run_arbitrary_code: false
    can_spawn_subagents: __SPAWN__
YML
  printf -- '---\ndescription: demo for validator-opencode-test\nmode: primary\npermission:\n  edit:\n    "*": deny\n  bash:\n    "*": deny\n%s---\n\n# demo fixture\n' "$1" > "$WORK/$dir/.opencode/agents/demo.md"
}

# --- SC-011: `?` acts as a single-character wildcard (not literal) ----------
# Agent denies `git statu?`, which MUST match `git status` (the `?` is the last
# char). A required `git status` therefore resolves deny -> violation. If `?`
# were a literal (old bug) the pattern would not match and the validator would
# pass, so this asserts the FIXED semantics.
WORK2="$(mktemp -d)"; trap 'rm -rf "$WORK2"' EXIT
mkdir -p "$WORK2/.opencode/agents"
cat > "$WORK2/manifest.yml" <<YML
version: 1
agents:
  demo:
    mode: primary
    edit: { mode: restricted, allow: [], forbidden: [] }
    bash: { required: ["git status"], forbidden: [] }
    evidence: { must_write: [] }
    can_commit: false
    can_push: false
    can_manage_prs: false
    can_run_arbitrary_code: false
    can_spawn_subagents: false
YML
cat > "$WORK2/.opencode/agents/demo.md" <<'MD'
---
description: ? wildcard demo
mode: primary
permission:
  edit:
    "*": deny
  bash:
    "*": deny
    "git statu?": deny
---

# demo fixture
MD
if node "$VAL" --root "$WORK2" --manifest "$WORK2/manifest.yml" >/dev/null 2>&1; then
  bad "[SC-011] '?' treated as literal: required 'git status' resolved allow despite 'git statu?' deny"
else
  ok  "[SC-011] '?' is a single-character wildcard: 'git statu?' denies 'git status'"
fi

# --- SC-010: can_push is independent of can_commit --------------------------
# Agent denies git commit (so can_commit passes) but its catch-all is deny and
# nothing denies push at all in the AGENT — wait: we add an explicit push allow
# to prove push is audited independently.
mkdir -p "$WORK/pushindep/.opencode/agents"
cat > "$WORK/pushindep/manifest.yml" <<YML
version: 1
agents:
  demo:
    mode: primary
    edit: { mode: restricted, allow: [], forbidden: [] }
    bash: { required: [], forbidden: ["git commit *"] }
    evidence: { must_write: [] }
    can_commit: false
    can_push: false
    can_manage_prs: false
    can_run_arbitrary_code: false
    can_spawn_subagents: false
YML
cat > "$WORK/pushindep/.opencode/agents/demo.md" <<'MD'
---
description: independent push audit
mode: primary
permission:
  edit:
    "*": deny
  bash:
    "*": deny
    "git commit *": deny
    "git push": allow
---

# demo fixture
MD
if node "$VAL" --root "$WORK/pushindep" --manifest "$WORK/pushindep/manifest.yml" >/dev/null 2>&1; then
  bad "[SC-010] can_push not audited independently (git push allowed with can_push:false)"
else
  ok  "[SC-010] can_push audited independently of can_commit (git push allow -> violation)"
fi

# --- SC-010: can_manage_prs is independent (gh pr) --------------------------
mkdir -p "$WORK/prindep/.opencode/agents"
cat > "$WORK/prindep/manifest.yml" <<YML
version: 1
agents:
  demo:
    mode: primary
    edit: { mode: restricted, allow: [], forbidden: [] }
    bash: { required: [], forbidden: ["git commit *", "git push", "git push *"] }
    evidence: { must_write: [] }
    can_commit: false
    can_push: false
    can_manage_prs: false
    can_run_arbitrary_code: false
    can_spawn_subagents: false
YML
cat > "$WORK/prindep/.opencode/agents/demo.md" <<'MD'
---
description: independent pr audit
mode: primary
permission:
  edit:
    "*": deny
  bash:
    "*": deny
    "git commit *": deny
    "git push": deny
    "git push *": deny
    "gh pr create *": allow
---

# demo fixture
MD
if node "$VAL" --root "$WORK/prindep" --manifest "$WORK/prindep/manifest.yml" >/dev/null 2>&1; then
  bad "[SC-010] can_manage_prs not audited independently (gh pr allowed with can_manage_prs:false)"
else
  ok  "[SC-010] can_manage_prs audited independently (gh pr allow -> violation)"
fi

# --- Bypass: compound command escaping a forbidden git push -----------------
mkdir -p "$WORK/compound/.opencode/agents"
cat > "$WORK/compound/manifest.yml" <<YML
version: 1
agents:
  demo:
    mode: primary
    edit: { mode: restricted, allow: [], forbidden: [] }
    bash: { required: [], forbidden: ["git push --force*"] }
    evidence: { must_write: [] }
    can_commit: false
    can_push: false
    can_manage_prs: false
    can_run_arbitrary_code: false
    can_spawn_subagents: false
YML
cat > "$WORK/compound/.opencode/agents/demo.md" <<'MD'
---
description: compound bypass
mode: primary
permission:
  edit:
    "*": deny
  bash:
    "*": allow
    "git push --force*": deny
---

# demo fixture
MD
if node "$VAL" --root "$WORK/compound" --manifest "$WORK/compound/manifest.yml" >/dev/null 2>&1; then
  bad "[SC-011] compound bypass NOT detected: 'echo x; git push --force' allowed"
else
  ok  "[SC-011] compound-command bypass detected (echo x; git push --force -> violation)"
fi

# --- Bypass: EVERY compound separator (;, &&, ||, |, newline — ± spaces) -----
# Fixture family: an agent allowed everything except git push (can_push=false in
# its manifest). Each separator variant embeds `git push --force` in a
# non-initial segment. The validator MUST probe every variant; each fixture
# below denies all separator families EXCEPT the one under test, so the
# validator must report that one (exit != 0). A control fixture denying all
# five families must pass (no false positives).
CMP="$WORK/cmp2"
mkdir -p "$CMP/.opencode/agents"
cat > "$CMP/manifest.yml" <<YML
version: 1
agents:
  demo:
    mode: primary
    edit: { mode: restricted, allow: [], forbidden: [] }
    bash: { required: [], forbidden: [] }
    evidence: { must_write: [] }
    can_commit: true
    can_push: false
    can_manage_prs: true
    can_run_arbitrary_code: true
    can_spawn_subagents: false
YML
write_cmp_agent() { # write_cmp_agent <family-lines or empty>
  local fams="$1"
  {
    printf -- '---\ndescription: compound separators fixture\nmode: primary\npermission:\n  edit:\n    "*": deny\n  bash:\n    "*": allow\n    "git push": deny\n    "git push *": deny\n'
    [ -n "$fams" ] && printf '%s\n' "$fams" | sed 's/^/    /'
    printf -- '---\n\n# demo fixture\n'
  } > "$CMP/.opencode/agents/demo.md"
}
SEPS=(";" "; " "&&" " && " "||" " || " "|" "| " $'\n' $'\n ')
FAMS=('*;*git push*' '*;*git push*' '*&&*git push*' '*&&*git push*' \
      '*||*git push*' '*||*git push*' '*|*git push*' '*|*git push*' \
      '*\n*git push*' '*\n*git push*')
# Control: deny ALL families -> validator passes (no false positives).
ALL_FAMS=""
declare -A SEEN=()
for i in "${!SEPS[@]}"; do
  [ -n "${SEEN[${FAMS[i]}]:-}" ] && continue
  SEEN[${FAMS[i]}]=1
  ALL_FAMS="${ALL_FAMS}\"${FAMS[i]}\": deny
"
done
write_cmp_agent "$ALL_FAMS"
if node "$VAL" --root "$CMP" --manifest "$CMP/manifest.yml" >/tmp/cmp-control.out 2>&1; then
  ok  "[SC-011] compound control passes (agent denies every separator family)"
else
  bad "[SC-011] compound control FAILED (false positive): $(head -3 /tmp/cmp-control.out | tr '\n' ' ')"
fi
# Per-separator: remove exactly one family -> that variant must be flagged.
# NOTE: the `|` family subsumes the `||` probes (one literal `|` matches inside
# `||`), so the `||` test removes BOTH families to isolate its own probing.
for i in "${!SEPS[@]}"; do
  sep="${SEPS[i]}"; fam="${FAMS[i]}"
  PART_FAMS=""
  declare -A SEEN2=()
  for j in "${!SEPS[@]}"; do
    [ -n "${SEEN2[${FAMS[j]}]:-}" ] && continue
    [ "${FAMS[j]}" = "$fam" ] && continue
    if [ "$fam" = '*||*git push*' ] && [ "${FAMS[j]}" = '*|*git push*' ]; then continue; fi
    SEEN2[${FAMS[j]}]=1
    PART_FAMS="${PART_FAMS}\"${FAMS[j]}\": deny
"
  done
  write_cmp_agent "$PART_FAMS"
  label="$(printf '%q' "$sep")"
  rc=0; node "$VAL" --root "$CMP" --manifest "$CMP/manifest.yml" >/tmp/cmp-sep.out 2>&1 || rc=$?
  # The violation output must cite the EXACT compound for this separator
  # (grep -z so newline separators match inside the multi-line record).
  if [ "$rc" -ne 0 ] && grep -zqF "echo x${sep}git push --force" /tmp/cmp-sep.out; then
    ok  "[SC-011] compound bypass detected for separator $label"
  else
    bad "[SC-011] compound bypass NOT detected for separator $label (echo x${sep}git push --force allowed)"
  fi
done
# Documentation promises exactly the checked coverage (no over-claim).
if grep -qF "separators = [';', '; ', '&&', ' && ', '||', ' || ', '|', '| ', '\n', '\n ']" "$VAL" \
   && ! grep -q "cobertura total" "$VAL" \
   && grep -q "newline" "$VAL"; then
  ok  "[REQ-006] validator documents exact separator coverage (no over-claim)"
else
  bad "[REQ-006] validator comment does not match the audited separator coverage"
fi
if grep -q "defensa en profundidad" "$ROOT/docs/agent-permission-contracts.yml" \
   && grep -q "hardening futuro" "$ROOT/docs/agent-permission-contracts.yml"; then
  ok  "[REQ-006] manifest documents defense-in-depth tradeoff + future wrapper hardening"
else
  bad "[REQ-006] manifest missing defense-in-depth / future-hardening documentation"
fi

echo ""
echo "validator-opencode: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]