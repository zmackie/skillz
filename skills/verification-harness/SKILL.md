---
name: verification-harness
description: >
  Set up automated verification and back-pressure for coding agents: hooks,
  linters, test runners, CI checks, and custom validators. Use when agent
  output has quality issues that automated checks could catch, when setting up
  a new agent workflow, or when you want agents to self-correct based on
  feedback. Use this skill whenever the user mentions agent verification,
  hooks, back-pressure, agent quality checks, or automated feedback loops
  for agents.
---

# Verification Harness

Set up automated checks that give coding agents feedback on their work, creating a self-correction loop.

## Overview

1. Identify what verification already exists (tests, linters, CI)
2. Determine which agent mistakes could be caught automatically
3. Configure verification to run at the right points with context-efficient output
4. Add custom validators for domain-specific constraints

## Core Principle

Verification creates back-pressure: automated signals that push the agent toward correct output. Effective back-pressure is silent on success and loud on failure, giving the agent only the information it needs to fix the problem.

## Verification Layers

Set up checks from fastest to slowest. Fast checks catch common mistakes before slow checks run.

### Layer 1: Inline Checks (< 1 second)

Run after every file save or edit. Catch syntax and type errors immediately.

| Check | What It Catches | Setup |
|---|---|---|
| Type checker | Type errors, missing imports | `mypy`, `tsc`, `pyright` |
| Syntax linter | Syntax errors, basic style | `ruff`, `eslint`, `rustfmt` |
| Format check | Formatting inconsistencies | `black`, `prettier`, `gofmt` |

**Hook configuration (Claude Code):**

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "ruff check --fix $FILE && mypy $FILE --no-error-summary 2>&1 | head -20"
      }
    ]
  }
}
```

**Key: context-efficient output.** Show only errors, limited to 20 lines. Don't dump full lint reports into the agent's context.

### Layer 2: Test Suite (seconds to minutes)

Run after completing a logical unit of work (a function, a module, a feature).

Configure test commands to:
- Run only relevant tests, not the full suite: `pytest tests/test_payments.py -x`
- Stop on first failure (`-x` flag) — the agent should fix one thing at a time
- Suppress passing test output — only show failures
- Include enough context to diagnose: file, line, assertion, and a few lines of context

**Hook configuration (Claude Code):**

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash(pytest*|npm test*|cargo test*)",
        "command": "echo 'Tests completed'"
      }
    ]
  }
}
```

### Layer 3: Custom Validators (seconds)

Domain-specific checks that standard tools don't cover. These encode "taste" — project-specific decisions that should apply to every change.

**Examples:**

```bash
# Check file size limits
find src/ -name "*.py" -size +300l | while read f; do
  echo "WARNING: $f exceeds 300 lines, consider splitting"
done

# Check dependency direction
grep -r "from src.api" src/payments/ && echo "ERROR: payments must not import from api"

# Check for common mistakes
grep -rn "print(" src/ --include="*.py" | grep -v "# noqa" | head -5 && \
  echo "ERROR: Use logging, not print()"
```

Package these as scripts in the repo and reference from hooks or CI.

### Layer 4: CI Pipeline (minutes)

Run on PR creation or push. Catches integration issues the agent's local checks miss.

Essential CI checks for agent-generated code:
- Full test suite (not just relevant tests)
- Type checking across the entire codebase
- Dependency validation (no circular imports, correct dependency direction)
- Security scanning (secrets detection, dependency vulnerabilities)
- Build verification (the project actually builds)

## Designing Custom Linters

Custom linters are the highest-leverage verification tool. They encode decisions once and enforce them on every change.

### What to Lint

Look at recent code review feedback. Anything a human reviewer catches repeatedly should be a lint rule:

| Review Comment Pattern | Lint Rule |
|---|---|
| "Use structured logging, not f-strings in log calls" | Flag `logger.info(f"...")` |
| "Keep files under 300 lines" | Flag files exceeding threshold |
| "Don't import from internal modules outside their parent" | Check import graph |
| "All API endpoints need auth middleware" | Check route definitions |
| "Use constants, not magic numbers" | Flag numeric literals in business logic |

### Implementation

Start simple. A shell script with `grep` catches most things:

```bash
#!/bin/bash
# custom-lint.sh — project-specific checks
EXIT=0

# No print statements in src/
if grep -rn "print(" src/ --include="*.py" | grep -v "# noqa" | head -5; then
  echo "ERROR: Use logging module, not print()" >&2
  EXIT=1
fi

# Files under 300 lines
for f in $(find src/ -name "*.py"); do
  lines=$(wc -l < "$f")
  if [ "$lines" -gt 300 ]; then
    echo "WARNING: $f has $lines lines (limit: 300)" >&2
  fi
done

# No cross-domain imports
if grep -rn "from src.api" src/payments/ 2>/dev/null; then
  echo "ERROR: payments must not import from api" >&2
  EXIT=1
fi

exit $EXIT
```

Graduate to AST-based linting (custom `ruff` rules, `eslint` plugins, `semgrep`) when `grep` patterns produce too many false positives.

## Context-Efficient Output

The single most important design decision for agent verification: **what the agent sees when something fails.**

### Principles

- **Silent on success.** A passing test suite should produce zero output, not "42 tests passed."
- **Failures only.** Show what broke, where, and enough context to fix it.
- **Truncate long output.** Cap at 20-30 lines. If there are 50 errors, the agent should fix the first few and re-run.
- **Structured format.** `file:line: message` is universally parseable. Prefer it over prose.

### Bad vs. Good Output

```
Bad (verbose):
  Running 47 tests...
  test_user_create PASSED
  test_user_update PASSED
  test_user_delete PASSED
  ... (40 more passing tests) ...
  test_payment_refund FAILED
    AssertionError: expected 200, got 500
    ... (full stack trace) ...

Good (context-efficient):
  tests/test_payments.py:42: test_payment_refund FAILED
    AssertionError: expected 200, got 500
    > response = client.post("/refunds", json=payload)
```

## Agent System Specifics

### Claude Code
- Hooks in `.claude/settings.json` or per-skill hook configs
- `PostToolUse` hooks run after edits, providing immediate feedback
- Skills can specify `allowed-tools` to auto-approve verification commands

### Codex
- Runs in sandboxed environments — verification must be self-contained
- Include test commands in AGENTS.md so Codex runs them automatically
- Use `setup` scripts to install verification dependencies

### Cursor / Windsurf
- Limited hook support — rely on terminal commands and CI
- Include verification commands in instruction files as explicit steps
- "After making changes, run: `./scripts/verify.sh`"

## Rollout Order

1. **Type checking** — catches the most errors with zero configuration
2. **Existing test suite** — configure to run relevant tests, not all tests
3. **Output formatting** — make existing checks context-efficient
4. **Custom lint script** — encode the top 3-5 recurring review comments
5. **CI pipeline** — catch integration issues on PR

Don't set up everything at once. Add one layer, verify it helps, then add the next.

## Anti-Patterns

- Verbose test output that floods the agent's context with passing tests
- Running the full test suite after every small edit instead of targeted tests
- Custom linters that produce false positives — agents can't distinguish false positives from real errors
- Verification that only runs in CI, giving agents no feedback during development
- Checks that block without providing enough information to fix the issue
