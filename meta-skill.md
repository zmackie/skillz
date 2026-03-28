# How to Write Good Skills

Guidelines for creating and maintaining skills in this directory.

## Who Reads Skills

Skills are instructions for a **coding agent**. The agent is smart, has broad general knowledge, and doesn't need motivation. It needs domain-specific directives it wouldn't otherwise know.

## Writing Principles

### Write directives, not wisdom

Bad: "It's worth noting that keeping instruction files short is important because agents lose focus with too much context..."

Good: "Keep root instruction files under 60 lines. Use progressive disclosure for details."

### Cut general knowledge

Only include information the agent wouldn't already know. Cut:
- Definitions ("A sub-agent is...")
- Motivation ("Context management matters because...")
- Framework lists ("You can use X, Y, or Z")

Keep:
- Domain-specific procedures
- Templates with concrete examples
- Thresholds and constraints
- Anti-patterns specific to the domain

### Scope to the task

Every sentence should help the agent do its job. Process advice ("schedule weekly reviews") and organizational guidance ("assemble a team") belong elsewhere.

### Start with good defaults

Present the simplest correct approach first. Gate advanced techniques behind prerequisites.

### Be concrete

Bad: "Write clear instructions."

Good:
```
## Build Commands
uv run pytest tests/ -x
uv run mypy src/
```

### Convert warnings into directives

Instead of explaining what not to do and why:
- "Use binary pass/fail, not Likert scales" (directive in main section)
- One-line anti-patterns at the end

## Skill Structure

```yaml
---
name: skill-name
description: >
  What this skill does. Use when [triggers]. Do NOT use when [exclusions].
---
```

```markdown
# Skill Title

One-line summary.

## Overview
[High-level procedure]

## Prerequisites
[Only if applicable]

## Core Instructions
[The actual directives]

## Anti-Patterns
[One line each]
```

### Keep files under 500 lines.
Split reference material into separate files if needed. Don't nest references more than one level.

## Naming

- Lowercase with hyphens: `write-agent-instructions`, `harness-audit`
- Action-oriented: describes what the agent will do
- Specific: `verification-harness` not `quality-helpers`
