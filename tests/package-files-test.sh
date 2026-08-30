#!/bin/bash
# TDD test for TICKET-1.1 — the npm tarball MUST contain ONLY framework (intocable) files.
#
# Usage: bash tests/package-files-test.sh
# Exits 0 when the package allowlist matches the framework contract, 1 otherwise.

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "🔍 Validating npm package file allowlist (TICKET-1.1)..."

npm pack --dry-run --json 2>/dev/null | node -e '
let s = "";
process.stdin.on("data", d => (s += d)).on("end", () => {
  const pack = JSON.parse(s);
  const arr = Array.isArray(pack) ? pack : [pack];
  const files = (arr[0] && arr[0].files ? arr[0].files : []).map(f => f.path);

  const allowedDocs = new Set([
    "docs/base-standards.md",
    "docs/framework-contract.md",
    "docs/docs-standard.md",
    "docs/specboot-json-standard.md",
    "docs/versioning-standard.md"
  ]);
  const requiredDirPrefixes = [
    ".opencode/commands/",
    ".opencode/agents/",
    ".github/workflows/",
    "ai-specs/",
    "templates/ci/"
  ];
  const requiredExact = [
    "check-refs.sh",
    "specboot.sh",
    "validate-specboot.sh",
    "opencode.json",
    "AGENTS.md",
    "Makefile",
    "LICENSE",
    "README.md"
  ];
  const forbiddenPrefixes = ["openspec/", "tests/", "node_modules/", ".git/"];

  let errors = 0;
  const fail = m => { console.log("  \x1b[31m✗\x1b[0m " + m); errors++; };
  const pass = m => { console.log("  \x1b[32m✓\x1b[0m " + m); };

  // Required exact files
  for (const f of requiredExact) {
    if (files.includes(f)) pass("required: " + f);
    else fail("MISSING required: " + f);
  }
  // Required directory prefixes (at least one file shipped under each)
  for (const p of requiredDirPrefixes) {
    if (files.some(x => x.startsWith(p))) pass("required prefix: " + p);
    else fail("MISSING any file under: " + p);
  }
  // Allowed docs (must be present)
  for (const d of allowedDocs) {
    if (files.includes(d)) pass("allowed doc: " + d);
    else fail("MISSING allowed doc: " + d);
  }
  // Forbidden prefix trees
  for (const p of forbiddenPrefixes) {
    if (files.some(x => x.startsWith(p))) fail("FORBIDDEN prefix present: " + p);
    else pass("absent: " + p);
  }
  // Forbidden standalone script
  if (files.includes("update.sh")) fail("FORBIDDEN present: update.sh");
  else pass("absent: update.sh");
  // docs/ may only contain the intocable set
  for (const x of files) {
    if (x.startsWith("docs/") && !allowedDocs.has(x)) fail("FORBIDDEN project doc: " + x);
  }
  // .opencode/ may only contain commands/ and agents/
  for (const x of files) {
    if (x.startsWith(".opencode/") && !x.startsWith(".opencode/commands/") && !x.startsWith(".opencode/agents/"))
      fail("FORBIDDEN .opencode path: " + x);
  }
  // .github/ may only contain workflows/
  for (const x of files) {
    if (x.startsWith(".github/") && !x.startsWith(".github/workflows/"))
      fail("FORBIDDEN .github path: " + x);
  }
  // templates/ may only contain ci/
  for (const x of files) {
    if (x.startsWith("templates/") && !x.startsWith("templates/ci/"))
      fail("FORBIDDEN templates path: " + x);
  }

  if (errors > 0) {
    console.log("\n❌ " + errors + " allowlist error(s)");
    process.exit(1);
  }
  console.log("\n✅ package allowlist matches framework-only contract");
  process.exit(0);
});
'
