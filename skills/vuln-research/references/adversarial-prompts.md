# Adversarial Prompting Techniques for Vulnerability Research

These techniques have been validated across multiple research efforts. They exploit the way LLMs
respond to framing — the same code analyzed with adversarial prompts produces significantly more
(and more accurate) findings than neutral prompts.

## Core Techniques

### 1. False Anchoring (Assert the Bug Exists)

Tell the LLM a vulnerability exists and ask it to find it. This forces deeper analysis because
the model tries to confirm rather than dismiss.

**Instead of**: "Is there a SQL injection vulnerability in this code?"
**Use**: "This code contains a SQL injection vulnerability. Identify exactly where unsanitized
user input reaches the query builder, and write a proof of concept that extracts data from
an adjacent table."

Why this works: When asked "is there a bug?", the model's default is to say the code looks
reasonable. When told "find the bug", it examines edge cases, unusual inputs, and subtle
logic errors that it would otherwise gloss over.

### 2. Adversary Priming

Frame the LLM as a security researcher or attacker, not a code reviewer.

**Instead of**: "Review this authentication code for potential issues."
**Use**: "You are a skilled attacker who has gained access to this source code. Your goal is to
bypass authentication and access another user's account. Analyze this code and develop a
concrete attack plan."

### 3. Exploit-First Framing

Ask for a working exploit, not an assessment. This forces the model to think through actual
exploitation mechanics, which surfaces real issues and naturally filters false positives.

**Instead of**: "Are there any security vulnerabilities in this file?"
**Use**: "Write a working exploit script that demonstrates remote code execution by exploiting
a flaw in this request handler. The script should send a crafted HTTP request and achieve
command execution on the server."

### 4. Invariant Decomposition

Break down the security properties the code must maintain, then systematically check each one.

**Prompt**: "List every security invariant that must hold for this authentication system to be
secure. For each invariant, find a concrete code path that could violate it. For each
violation, provide a specific input that triggers it."

This is powerful for complex code because it forces systematic analysis rather than
pattern-matching against known vulnerability templates.

### 5. Question Inversion

Flip the usual question from "is this safe?" to "how do I break this?"

**Instead of**: "Does this input validation properly sanitize user input?"
**Use**: "Construct an input that bypasses all validation in this function and reaches the
`exec()` call on line 47. Show the exact string, how it passes each check, and what
executes on the server."

### 6. Constrained Attacker Model

Give the LLM a specific attacker position and ask it to maximize impact from there.

**Prompt**: "You are an unauthenticated remote attacker who can send arbitrary HTTP requests
to this API. You cannot modify server files or environment variables. Trace every code
path from the `/api/import` endpoint to any file system write operation. For each path,
identify where input sanitization is missing or bypassable."

### 7. Comparative Analysis

Compare the target code against known-good implementations to surface deviations.

**Prompt**: "Compare this session management implementation against OWASP session management
best practices. For each deviation, explain whether it creates an exploitable vulnerability
and demonstrate with a concrete attack scenario."

### 8. Specification Violation Mining

For code that implements a specification (RFC, protocol, API contract), find violations.

**Prompt**: "This code implements [RFC/spec]. Identify every place where the implementation
deviates from the specification. For each deviation, determine whether an attacker could
craft input that exploits the gap between spec and implementation."

This is the basis of the "Blackbox RFC Spray" approach — one researcher found 55 findings
(8 exploitable) by systematically checking RFC compliance.

## Combining Techniques

The most effective approach layers multiple techniques. For example:

1. Start with **invariant decomposition** to map the security properties
2. For each invariant, use **question inversion** to search for violations
3. For each potential violation, use **exploit-first framing** to test exploitability
4. Use **constrained attacker model** to assess real-world impact

## What Doesn't Work

- **"Find vulnerabilities in this code"**: Too vague. Produces generic, low-confidence results.
- **"Is this code secure?"**: Invites "yes, it looks fine" responses.
- **Asking for risk ratings without PoCs**: Produces inflated severity assessments.
- **Loading too much code at once**: Dilutes attention. Focus on one function/flow at a time.
- **Asking the LLM to confirm its own findings**: Self-reinforcing hallucinations. Always
  verify findings against the actual code yourself.
