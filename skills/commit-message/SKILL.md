---
name: commit-message
category: general-dev
description: Generate a conventional-commit message from staged changes. Use when asked to write a commit message or describe staged changes.
disable-model-invocation: true
---

# Commit Message Generator

Generate a commit message for the currently staged changes.

## Steps

1. Run `git diff --cached` to see staged changes
2. Run `git diff --cached --stat` for a file-level summary
3. If nothing is staged, check `git diff` for unstaged changes and let the user know they need to stage first

## Message Format

Use conventional commits:

```
<type>(<scope>): <short summary>

<body — what changed and why>
```

**Types**: feat, fix, refactor, docs, test, chore, perf, ci, build, style
**Scope**: The primary module, component, or area affected
**Summary**: Imperative mood, lowercase, no period, under 72 chars
**Body**: Explain the motivation and what changed. Focus on *why*, not *what* (the diff shows the what).

## Rules
- Read the full diff before writing — don't guess from filenames alone
- If changes span multiple concerns, suggest splitting into separate commits
- If the change is a single-line fix, a body is optional
- Never include file lists in the body — the diff is the source of truth

## Related Skills

- `code-review` — review code before committing
