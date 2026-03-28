## skillz — Claude Code Plugin

A collection of Claude Code skills packaged as a plugin.

### Structure
- `skills/<name>/SKILL.md` — each skill is a directory with a SKILL.md file
- `.claude-plugin/plugin.json` — plugin manifest
- `.claude-plugin/marketplace.json` — marketplace catalog for installation

### Adding a New Skill
1. Create `skills/<skill-name>/SKILL.md`
2. Include YAML frontmatter with `name` and `description`
3. Add supporting files alongside SKILL.md if needed (reference docs, scripts)
4. Keep skill names lowercase with hyphens (e.g., `code-review`)

### Skill Frontmatter
```yaml
---
name: skill-name
description: What it does and when to use it (under 250 chars)
---
```

Optional fields: `disable-model-invocation`, `user-invocable`, `allowed-tools`, `argument-hint`
