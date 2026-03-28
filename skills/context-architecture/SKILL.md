---
name: context-architecture
description: >
  Design context management for coding agents: sub-agent decomposition, context
  resets, progressive disclosure hierarchies, and artifact handoffs. Use when
  agents lose coherence on long tasks, when context windows fill up, when you
  need to decompose complex workflows into isolated subtasks, or when setting up
  sub-agent patterns. Use this skill whenever the user mentions context windows,
  sub-agents, context management, agent memory, or long-running agent tasks.
---

# Context Architecture

Design how a coding agent manages its context window across tasks of varying complexity.

## Overview

1. Assess the task complexity and context demands
2. Identify where context isolation, resets, or progressive disclosure would help
3. Design the context management strategy
4. Define handoff protocols between contexts

## Core Principle

Context is finite and degrades with noise. Every token in the context window competes for attention. The goal is to keep the agent's working context focused on the current subtask while preserving access to broader knowledge on demand.

## When Context Management Matters

Not every task needs context architecture. Match the strategy to the task:

| Task Type | Strategy |
|---|---|
| Single file edit, quick question | No special management needed |
| Multi-file feature, moderate complexity | Progressive disclosure + sub-agents for research |
| Large refactor, cross-cutting changes | Sub-agent decomposition with clear boundaries |
| Long-running development (hours/days) | Context resets with structured handoffs |
| Multi-step pipeline (plan → build → review) | Multi-agent with isolated contexts (see `multi-agent-design`) |

## Progressive Disclosure

Structure information so agents load it when needed, not upfront.

### Three Levels

1. **Always in context** (~100 words): Root instruction file. What the agent needs for every task.
2. **On-demand reference** (unlimited): Docs the agent reads when working in a specific area. Triggered by file paths, task descriptions, or explicit pointers.
3. **Executable knowledge** (unlimited): Scripts the agent runs without loading into context. The output enters context, not the source code.

### Designing the Hierarchy

Map each piece of information to a level:

```
Always in context:
  - Build/test commands
  - Hard rules (3-5 lines)
  - Architecture overview pointing to docs

On-demand reference:
  - docs/api-design.md → read when modifying API endpoints
  - docs/data-model.md → read when changing schemas
  - docs/testing.md → read when writing tests

Executable knowledge:
  - scripts/check-deps.sh → run to verify dependency graph
  - scripts/db-status.sh → run to check migration state
```

Reference docs from the root instruction file with clear triggers: "Read `docs/api-design.md` before modifying any endpoint."

## Sub-Agent Decomposition

Use sub-agents (forked contexts) to isolate discrete subtasks. The parent agent dispatches work and receives compacted results, keeping its own context clean.

### When to Use Sub-Agents

- **Research tasks.** "Find all usages of this API and summarize the patterns." The sub-agent reads dozens of files; the parent receives a summary.
- **Independent implementations.** Parallel changes to unrelated modules.
- **Codebase analysis.** Understanding a large module before making changes.
- **Exploratory work.** Trying multiple approaches where only the result matters.

### Sub-Agent Design

Each sub-agent gets:
- A **clear task description** with expected output format
- **Relevant context** (file paths, constraints, background)
- A **scope boundary** — what it should and shouldn't touch

The parent agent receives:
- A **compacted result** — the answer, not the journey
- **Citations** — file paths and line numbers for claims about the codebase
- **Decision points** — anything requiring human input, surfaced up

### Context Firewall Pattern

Sub-agents act as context firewalls. Intermediate noise (file contents, search results, false starts) stays inside the sub-agent. Only the distilled result crosses back to the parent.

```
Parent context:
  "Implement the payment refund feature"
  → spawns research sub-agent
  ← receives: "Payments are in src/payments/, use PaymentService.refund().
     The refund flow requires: 1) validate order status, 2) call Stripe API,
     3) update order record. See src/payments/service.py:142."
  → spawns implementation sub-agent with the research summary
  ← receives: "Implemented refund endpoint. Files changed: [list].
     Needs review: error handling for partial refunds."
```

The parent never loaded the dozens of files the research agent read.

## Context Resets

For long-running tasks (multi-hour sessions, multi-day projects), context degrades even with sub-agents. The working context accumulates stale state, abandoned approaches, and resolved discussions.

### When to Reset

- The agent starts repeating mistakes it was corrected on earlier
- Output quality noticeably drops compared to session start
- The agent "forgets" instructions from the root file
- You're switching to a substantially different phase of work

### Structured Handoff

A context reset is only useful if the new context starts with the right information. Write a handoff artifact before resetting:

```markdown
## Handoff: [Task Name]

### Completed
- [What was done, with file paths]

### Current State
- [What's working, what's broken, what's partially implemented]

### Next Steps
- [What remains, in priority order]

### Decisions Made
- [Key decisions and why, so the new context doesn't relitigate them]

### Known Issues
- [Bugs, edge cases, or concerns discovered but not yet addressed]
```

The new context starts with: root instructions + handoff artifact + relevant file contents.

### Reset vs. Compaction

Some agent systems offer context compaction (summarizing the conversation). This preserves continuity but doesn't give a clean slate. Use compaction for minor cleanups; use full resets when the context is significantly polluted.

| Approach | When to Use |
|---|---|
| Compaction | Moderate noise, still on the same subtask |
| Full reset + handoff | Switching phases, severe quality degradation, accumulated stale context |

## Agent System Specifics

### Claude Code
- Sub-agents via the Agent tool or `context: fork` in skills
- Nested CLAUDE.md files provide per-directory progressive disclosure
- Skills with `context: fork` run in isolated context automatically

### Codex
- Tasks run in isolated sandboxes by default
- AGENTS.md supports per-directory nesting
- Long tasks benefit from explicit task decomposition in the prompt

### Cursor / Windsurf
- Limited native sub-agent support
- Progressive disclosure via rule directories (`.cursor/rules/`)
- For complex tasks, manually decompose into sequential prompts

## Anti-Patterns

- Dumping all documentation into the root instruction file instead of using progressive disclosure
- Using sub-agents for trivial tasks that don't benefit from context isolation
- Resetting context without writing a handoff artifact
- Assuming bigger context windows eliminate the need for context management — attention degradation occurs regardless of window size
- Nesting sub-agents more than two levels deep — returns diminish and coordination overhead increases
