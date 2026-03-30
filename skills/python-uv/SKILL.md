---
name: python-uv
category: general-dev
description: >
  Python project conventions — uv package manager, click CLIs, pytest, type hints. Use when
  creating or modifying Python projects. See `verification-harness` for setting up pytest/mypy
  hooks, and `openrouter-api` for LLM integration patterns.
---

# Python Project Conventions

When working on Python projects, follow these conventions:

## Package Management
- Always use `uv` — never pip, poetry, or pipenv
- Initialize with `uv init` for new projects
- Add dependencies with `uv add <package>`
- Use `uv sync` to install from lockfile
- Run scripts with `uv run <script>`

## Project Structure
```
project-name/
├── pyproject.toml
├── src/
│   └── project_name/
│       ├── __init__.py
│       └── ...
├── tests/
│   └── ...
└── README.md
```

## CLIs
- Use `click` for all command-line interfaces
- Add a `--debug` flag with extra logging on every CLI
- Use `rich` for visual feedback (spinners, tables, progress bars) when operations take time
- Define entry points in `pyproject.toml` under `[project.scripts]`

## Testing
- Use `pytest` for all tests
- Run with `uv run pytest`
- Place tests in `tests/` mirroring `src/` structure

## Code Style
- Use type hints on all function signatures
- Use `pathlib.Path` over `os.path`
- Prefer f-strings over `.format()` or `%`
- Use `logging` module, not print statements (except in CLIs where `rich` console output is appropriate)

## LLM Integration
- Use OpenRouter (`openai` SDK pointed at `https://openrouter.ai/api/v1`) for LLM calls
- Store API keys in environment variables, never hardcode

## Related Skills

- `verification-harness` — set up pytest/mypy hooks for Python projects
- `openrouter-api` — LLM integration patterns when building AI-powered Python apps
