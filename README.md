# skillz

A Claude Code plugin with skills for **harness engineering** — configuring, optimizing, and verifying coding agent workflows — plus general dev workflow skills.

Works with Claude Code, Codex, Cursor, Windsurf, Copilot, and custom agent systems.

## Install

```
/plugin marketplace add zander/skillz
/plugin install skillz@zander-skillz
```

## Harness Engineering Skills

Start with `harness-audit` to assess your current setup, then use the targeted skills it recommends.

| Skill | What it does |
|---|---|
| `harness-audit` | Audit an agent harness and surface problems with prioritized fixes |
| `write-agent-instructions` | Write or improve CLAUDE.md, AGENTS.md, .cursorrules, etc. |
| `context-architecture` | Design context management: sub-agents, resets, progressive disclosure |
| `agent-legibility` | Optimize a codebase for agent readability and navigation |
| `verification-harness` | Set up back-pressure: hooks, linters, tests, CI checks |
| `multi-agent-design` | Design multi-agent workflows (planner/generator/evaluator patterns) |

## General Dev Skills

| Skill | What it does |
|---|---|
| `code-review` | Structured code review (security, performance, correctness, readability) |
| `commit-message` | Generate conventional-commit messages from staged diffs |
| `python-uv` | Python project conventions (uv, click, pytest, type hints) |
| `openrouter-api` | LLM integration patterns via OpenRouter |

## Usage

Invoke skills as `/skillz:<skill-name>`:

```
/skillz:harness-audit
/skillz:write-agent-instructions
/skillz:code-review
```

Most skills also auto-trigger when Claude detects a relevant task.

## Adding a Skill

Create `skills/<name>/SKILL.md` with YAML frontmatter:

```yaml
---
name: my-skill
description: What it does and when to use it
---

Instructions for Claude when this skill is active.
```

See [meta-skill.md](meta-skill.md) for writing guidelines.
