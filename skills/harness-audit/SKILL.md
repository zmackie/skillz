---
name: harness-audit
description: >
  Audit a coding agent's harness (instructions, context management, verification,
  codebase legibility) and surface problems with prioritized fixes. Use when
  setting up a new agent workflow, inheriting a project with agent configuration,
  when agent quality degrades, or as a starting point when no harness exists.
  Use this skill whenever the user mentions agent harness, agent configuration,
  CLAUDE.md review, AGENTS.md review, or wants to improve how agents work in
  their codebase — even if they don't use the word "harness."
---

# Harness Audit

Inspect a coding agent's harness and produce a prioritized list of problems with concrete next steps.

## Overview

1. Identify the agent system in use (Claude Code, Codex, Cursor, Windsurf, custom)
2. Gather harness artifacts: instruction files, tool configs, hooks, CI checks, sub-agent definitions
3. Run diagnostic checks across five areas
4. Produce a findings report ordered by impact, with each finding linking to a fix

## Identifying the Agent System

Check for these markers to determine which agent system is in use:

| File | Agent System |
|------|-------------|
| `CLAUDE.md`, `.claude/` | Claude Code |
| `AGENTS.md`, `.agents/` | Codex / OpenAI |
| `.cursorrules`, `.cursor/` | Cursor |
| `.windsurfrules` | Windsurf |
| `.github/copilot-instructions.md` | GitHub Copilot |

Multiple systems may coexist. Audit each one present.

## Diagnostic Checks

Work through each area. Inspect available artifacts, determine whether the problem exists, and record a finding if it does. Prioritize by impact on agent output quality.

### 1. Agent Instructions

**Check:** Do instruction files exist?

Look for the instruction file appropriate to the agent system. If none exist, that's the first finding — start with `write-agent-instructions`.

**Check:** How long are the instruction files?

Measure line count. Flag files over 60 lines at the root level.

**Finding if too long:** Long instruction files cause agents to lose focus on what matters. Root-level instructions should be under 60 lines, using progressive disclosure to point agents to detailed docs when needed. Use `write-agent-instructions` to restructure.

**Check:** Are instructions auto-generated?

Look for boilerplate patterns, tool-generated headers, or instructions that read like documentation rather than directives.

**Finding if auto-generated:** Auto-generated instructions tend to be verbose and generic. Hand-written instructions that encode domain-specific decisions outperform generated ones. Use `write-agent-instructions` to replace with targeted directives.

**Check:** Do instructions contain general knowledge?

Flag explanations of what tools are, how languages work, or definitions the agent already knows.

**Finding if present:** Instructions that explain general concepts waste context on things the agent already knows. Cut definitions, motivation, and framework lists. Keep only domain-specific procedures and decisions.

**Check:** Is there progressive disclosure?

Look for references to detailed docs, READMEs, or reference files that the agent can read on demand.

**Finding if flat:** A single monolithic instruction file forces everything into context upfront. Structure as a lean entry point that points to detailed docs organized by domain. Use `context-architecture` to design the disclosure hierarchy.

### 2. Context Management

**Check:** Are sub-agents or forked contexts used for complex tasks?

Look for sub-agent definitions, context fork configurations, or patterns where discrete tasks are isolated.

**Finding if absent:** Without context isolation, long tasks accumulate noise that degrades agent performance. Discrete subtasks (research, implementation, review) should run in isolated contexts that return compacted results. Use `context-architecture`.

**Check:** Is there evidence of context window exhaustion?

Look for conversation logs showing degraded output quality late in sessions, or user complaints about the agent "forgetting" earlier instructions.

**Finding if present:** Context exhaustion causes agents to drop instructions and repeat mistakes. Design context resets with structured handoffs for long-running tasks. Use `context-architecture`.

### 3. Verification & Back-Pressure

**Check:** Do hooks or CI checks run automatically after agent actions?

Look for hook configurations, pre-commit hooks, CI pipelines triggered by agent PRs, or automated test runs.

**Finding if absent:** Without automated verification, agents don't learn from their mistakes within a session. Hooks that surface typecheck errors, lint failures, or test results after each action create a feedback loop. Use `verification-harness`.

**Check:** Are verification outputs context-efficient?

Check whether test/lint output is silent on success and shows only errors on failure.

**Finding if verbose:** Verbose test output (printing all passing tests) wastes context. Configure verification to be silent on success, showing only failures with enough context to fix them. Use `verification-harness`.

**Check:** Are there custom linters or taste enforcement tools?

Look for project-specific lint rules, architecture checks, or style enforcement beyond standard formatters.

**Finding if absent:** Standard linters catch syntax issues but not domain-specific conventions. Custom linters encode human preferences (naming, file size limits, dependency direction) that apply to every change without micromanaging. Use `verification-harness`.

### 4. Codebase Legibility

**Check:** Is the codebase organized for agent navigation?

Look for clear directory structure, domain-based organization, and documentation that helps agents find relevant code.

**Finding if disorganized:** Agents navigate codebases by reading docs and following references. A codebase organized by domain with clear entry points outperforms a flat or deeply nested structure. Use `agent-legibility`.

**Check:** Is tribal knowledge captured in the repo?

Check whether important decisions, conventions, or context live only in Slack, wikis, or people's heads.

**Finding if external:** Anything not in the repo doesn't exist for the agent. Move architectural decisions, onboarding context, and domain conventions into the codebase as docs the agent can discover. Use `agent-legibility`.

### 5. Multi-Agent Architecture

**Check:** For complex tasks, is work decomposed across specialized agents?

Look for multi-agent configurations, pipeline definitions, or patterns where different agents handle planning, implementation, and review.

**Finding if monolithic:** A single agent handling planning, implementation, and review produces lower quality than specialized agents with clear roles. For complex workflows (app development, large refactors), consider a planner/generator/evaluator pattern. Use `multi-agent-design`.

**Check:** Do agents self-evaluate their own output?

Look for patterns where the same agent generates and judges its own work.

**Finding if self-evaluating:** Agents exhibit self-evaluation bias — they consistently rate their own output higher than independent judges. Separate generation from evaluation using distinct agents or contexts. Use `multi-agent-design`.

## No Harness Exists

If the project has no agent configuration at all:

1. Start with `write-agent-instructions` to create a lean instruction file
2. Add basic verification with `verification-harness` (typecheck + test hooks)
3. Assess codebase readability with `agent-legibility`
4. Design context management only after the basics are working — use `context-architecture`

Do not recommend multi-agent architecture until single-agent workflows are stable.

## Report Format

Present findings ordered by impact:

```
### [Problem Title]
**Status:** Problem exists / OK / Cannot determine
[1-2 sentence explanation of the specific problem found]
**Fix:** [Concrete action, referencing a skill]
```

Group under the five diagnostic areas. Omit areas where no problems were found.

## Anti-Patterns

- Running the audit as a checklist without inspecting actual artifacts
- Reporting generic advice disconnected from the user's specific setup
- Recommending multi-agent architecture before single-agent basics are solid
- Suggesting complex context management when the instruction file is the real problem
- Treating this as a one-time event — re-audit after major workflow changes
