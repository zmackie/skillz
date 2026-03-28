# skillz

A Claude Code plugin containing reusable skills for common dev workflows.

## Install

```
/plugin marketplace add zander/skillz
/plugin install skillz@zander-skillz
```

## Skills

| Skill | Description |
|---|---|
| `code-review` | Structured code review (security, performance, correctness, readability) |
| `commit-message` | Generate conventional-commit messages from staged diffs |
| `python-uv` | Python project conventions (uv, click, pytest, type hints) |
| `openrouter-api` | LLM integration patterns via OpenRouter |

## Usage

Skills are invoked as `/skillz:<skill-name>`:

```
/skillz:code-review
/skillz:commit-message
/skillz:python-uv
```

Some skills (like `python-uv` and `openrouter-api`) are also auto-invoked by Claude when relevant to your task.

## Adding a Skill

Create `skills/<name>/SKILL.md` with YAML frontmatter:

```yaml
---
name: my-skill
description: What it does and when to use it
---

Instructions for Claude when this skill is active.
```
