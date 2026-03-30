---
name: write-agent-instructions
category: harness-engineering
description: >
  Write or improve instruction files for coding agents (CLAUDE.md, AGENTS.md,
  .cursorrules, etc.). Use when creating a new agent instruction file, when
  agent output quality is inconsistent, when instructions are too long or
  too generic, or when onboarding a project to a new agent system. Use this
  skill whenever the user mentions CLAUDE.md, AGENTS.md, agent instructions,
  agent rules, or system prompts for coding agents. Part of the harness
  engineering workflow; start with `harness-audit` for overall assessment.
---

# Write Agent Instructions

Write or restructure an instruction file that tells a coding agent how to work in this codebase.

## Overview

1. Identify the target agent system and its instruction file format
2. Gather the domain-specific decisions and conventions the agent needs
3. Write a lean root instruction file with progressive disclosure to detailed docs
4. Validate by checking that every line passes the "does this help the agent do its job?" test

## Instruction File Formats

| Agent System | File | Notes |
|---|---|---|
| Claude Code | `CLAUDE.md` (root) + `.claude/skills/` | Supports nested CLAUDE.md per directory |
| Codex | `AGENTS.md` (root) + per-directory AGENTS.md | Same nesting pattern |
| Cursor | `.cursorrules` or `.cursor/rules/` | Single file or rule directory |
| Windsurf | `.windsurfrules` | Single file |
| Copilot | `.github/copilot-instructions.md` | Single file |

If the user's system isn't listed, ask which format they need. The principles apply to any agent instruction system.

## Gathering Context

Before writing, collect:

1. **What does this codebase do?** One sentence.
2. **What are the hard rules?** Things that must always or never happen (e.g., "always use uv, never pip", "all API endpoints require auth middleware").
3. **What decisions would a new engineer get wrong?** These are the highest-value instructions. Examples: which test framework to use, how to handle database migrations, which directories map to which domains.
4. **What conventions exist but aren't enforced by tooling?** Naming patterns, file organization, import ordering, error handling patterns.
5. **Where is detailed documentation?** READMEs, architecture docs, ADRs, runbooks — anything the agent should read on demand.

Ask the user these questions. Don't infer conventions from code alone — the codebase may not follow its own conventions consistently.

## Writing the Root File

**Target: under 60 lines.** This is the always-in-context entry point. Every line competes for attention.

### Structure

```markdown
## [Project Name] — one-line description

### Build & Test
[Exact commands for build, test, lint, deploy — not explanations of what they do]

### Hard Rules
[Non-negotiable constraints, one per line]

### Conventions
[Project-specific decisions the agent wouldn't know]

### Architecture
[Brief domain map pointing to detailed docs]
Read [path/to/architecture.md] for detailed module documentation.
```

### What to Include

- **Exact commands.** `uv run pytest tests/ -x` not "run the test suite."
- **Domain-specific decisions.** "Use SQLAlchemy 2.0 style (not legacy)" not "use an ORM."
- **Pointers to detailed docs.** "Read `docs/api-design.md` before modifying endpoints" not a summary of the API design.
- **Constraints that prevent common mistakes.** "Never import from `internal/` outside its parent module."

### What to Cut

- **General knowledge.** The agent knows what Python is, how git works, and what REST means.
- **Motivation.** Why you chose a framework doesn't help the agent use it. State the decision.
- **Tool descriptions.** Don't explain what pytest does. Say `uv run pytest tests/ -x`.
- **Encouragement or personality directives.** "Be helpful" and "think step by step" waste context.
- **Long examples.** Put examples in reference docs, not the root file.

### Writing Style

Use imperative directives. State what to do, not what to avoid when possible.

| Instead of | Write |
|---|---|
| "It's important to note that we use uv for package management because pip has dependency resolution issues" | "Use `uv` for all package management" |
| "Please make sure to run the type checker before committing" | "Run `mypy src/` before committing" |
| "We've found that keeping files under 300 lines improves readability" | "Keep files under 300 lines. Split when approaching the limit." |

## Progressive Disclosure

The root file is layer 1. Organize deeper knowledge in files the agent reads on demand.

### Layer 2: Per-directory instructions

For systems that support nested instruction files (Claude Code, Codex), add domain-specific instructions in subdirectories:

```
src/
├── CLAUDE.md          # "Read ../CLAUDE.md first. This module handles payments..."
├── api/
│   └── CLAUDE.md      # API-specific conventions
├── workers/
│   └── CLAUDE.md      # Background job patterns
└── models/
    └── CLAUDE.md      # Data model conventions
```

Each nested file should be self-contained for its domain. Don't repeat root-level instructions.

### Layer 3: Reference docs

Detailed documentation the agent reads when working in a specific area:

```
docs/
├── architecture.md     # Module boundaries, dependency directions
├── api-design.md       # Endpoint conventions, auth patterns
├── testing.md          # Test patterns, fixtures, factories
└── deployment.md       # Deploy process, environment configs
```

Reference from the root file: "Read `docs/testing.md` before writing tests."

Keep reference files under 500 lines. If longer, split by subdomain.

## Validating Instructions

After writing, check each line:

1. **Does this help the agent do its job?** If not, cut it.
2. **Would the agent already know this?** If yes, cut it.
3. **Is this a directive or wisdom?** If wisdom, convert to a directive or cut it.
4. **Is this specific enough to act on?** "Write good tests" is useless. "Use pytest fixtures from `tests/conftest.py` for database setup" is actionable.
5. **Is this still true?** Stale instructions are worse than no instructions.

Read the complete file as if you were the agent seeing it for the first time. Is it clear what to do? Is anything confusing or contradictory?

## Migrating Between Systems

When moving from one agent system to another (e.g., Cursor to Claude Code):

1. Read the existing instruction file
2. Identify which instructions are system-specific (tool configs, file format quirks) vs. universal (project conventions)
3. Port universal instructions to the new format
4. Add system-specific instructions for the new agent
5. Don't delete the old file unless the team has fully migrated

## Anti-Patterns

- Auto-generating instructions from codebase analysis without human input on what actually matters
- Copying another project's instructions without adapting to this codebase's specific decisions
- Including instructions that duplicate what linters or CI already enforce
- Writing instructions for the human reader instead of the agent
- Letting instruction files grow without periodic pruning — review quarterly

## Related Skills

- `harness-audit` — run an audit first to identify what your instructions are missing
- `verification-harness` — enforce what your instructions specify with automated hooks
- `agent-legibility` — make the codebase match what your instructions describe
