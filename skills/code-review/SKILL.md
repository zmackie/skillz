---
name: code-review
category: general-dev
description: >
  Perform a structured code review covering security, performance, correctness, and
  readability. Use when asked to review code, check a PR, or audit a file. For deeper
  security-focused analysis, see `vuln-research` instead.
---

# Code Review

Perform a thorough code review of the specified code. Structure your review as follows:

## 1. Security
- Check for injection vulnerabilities (SQL, command, XSS)
- Look for hardcoded secrets, credentials, or API keys
- Verify input validation and sanitization at system boundaries
- Check authentication and authorization logic

## 2. Correctness
- Identify logic errors, off-by-one bugs, race conditions
- Check error handling — are failures caught and handled appropriately?
- Verify edge cases (empty inputs, nulls, boundary values)
- Check that the code does what it claims to do

## 3. Performance
- Flag unnecessary allocations, N+1 queries, or O(n²) where O(n) is possible
- Look for missing indexes, unbounded fetches, or missing pagination
- Check for resource leaks (unclosed connections, file handles)

## 4. Readability & Maintainability
- Are names clear and consistent?
- Is the abstraction level appropriate — not too clever, not too verbose?
- Are there any dead code paths or unused variables?

## Output Format
For each issue found, report:
- **File and line**: `path/to/file.py:42`
- **Severity**: Critical / Warning / Suggestion
- **Issue**: One-line description
- **Fix**: Concrete recommendation

End with a summary: total issues by severity, and an overall assessment (approve, approve with suggestions, or request changes).

## Related Skills

- `vuln-research` — for deeper security-focused analysis beyond standard code review
- `commit-message` — after review, generate conventional-commit messages for fixes
