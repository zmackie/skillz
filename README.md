# skillz

A Claude Code plugin with skills for **harness engineering** — configuring, optimizing, and verifying coding agent workflows — plus creativity, security, and general dev workflow skills.

Works with Claude Code, Codex, Cursor, Windsurf, Copilot, and custom agent systems.

## Install

```
/plugin marketplace add zmackie/skillz
/plugin install skillz@zmackie-skillz
```

## Which skill should I use?

| I want to... | Start with | Then consider |
|---|---|---|
| Set up or improve my agent workflow | `harness-audit` | The skills it recommends based on findings |
| Write CLAUDE.md / AGENTS.md / .cursorrules | `write-agent-instructions` | `verification-harness` to enforce them |
| Fix an agent losing context on long tasks | `context-architecture` | `multi-agent-design` if decomposition helps |
| Make my codebase easier for agents to navigate | `agent-legibility` | `write-agent-instructions` for the instruction side |
| Add hooks, linters, or CI checks for agent quality | `verification-harness` | `harness-audit` to identify what's missing |
| Design multi-agent pipelines | `multi-agent-design` | `context-architecture` for isolation patterns |
| Brainstorm creative or novel ideas | `cross-domain-ideation` | `idea-garden` to prototype the best ones |
| Prototype ideas autonomously in the background | `idea-garden` | `vibe-research` to write up results |
| Write a design doc, RFC, or research report | `vibe-research` | -- |
| Find security vulnerabilities in code | `vuln-research` | `code-review` for lighter review |
| Review code for quality | `code-review` | `vuln-research` for deeper security focus |
| Generate a commit message | `commit-message` | -- |
| Set up or work on a Python project | `python-uv` | `verification-harness` for pytest/mypy hooks |
| Integrate LLM APIs | `openrouter-api` | `python-uv` for Python project setup |

## Skill Map

### Harness Engineering

Start with `harness-audit` to assess your current setup — it diagnoses issues across five areas and points you to the right specialized skill.

```
harness-audit (start here)
  |
  |-- write-agent-instructions    Write/improve CLAUDE.md, AGENTS.md, etc.
  |-- verification-harness        Set up hooks, linters, test runners, CI checks
  |-- agent-legibility            Optimize codebase for agent navigation
  |-- context-architecture        Design sub-agents, resets, progressive disclosure
  |-- multi-agent-design          Planner/generator/evaluator patterns
```

### Creativity & Research

Three skills that form a generate -> prototype -> write-up pipeline:

| Skill | What it does |
|---|---|
| `cross-domain-ideation` | Generate novel ideas using analogical mapping from distant domains |
| `idea-garden` | Autonomously prototype ideas from a backlog (vapor -> fermenting -> liquid -> frozen) |
| `vibe-research` | Produce polished written artifacts through multi-agent review loops |

### Security

| Skill | What it does |
|---|---|
| `vuln-research` | LLM-assisted vulnerability research: threat modeling, slice-based auditing, adversarial prompting, PoC validation |

### General Dev

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
category: harness-engineering  # or: creativity, security, general-dev
description: What it does and when to use it
---

Instructions for Claude when this skill is active.
```

See [meta-skill.md](meta-skill.md) for writing guidelines and [AGENTS.md](AGENTS.md) for plugin structure.
