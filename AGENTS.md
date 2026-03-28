## skillz — Claude Code Plugin

Skills for coding agent harness engineering and common dev workflows.

### Structure
- `skills/<name>/SKILL.md` — each skill is a directory with a SKILL.md file
- `.claude-plugin/plugin.json` — plugin manifest
- `.claude-plugin/marketplace.json` — marketplace catalog for installation
- `meta-skill.md` — writing guidelines for new skills
- `docs/harness-engingeering/` — source articles for harness engineering skills

### Adding a New Skill
1. Read `meta-skill.md` for writing guidelines
2. Create `skills/<skill-name>/SKILL.md`
3. Include YAML frontmatter with `name` and `description`
4. Add supporting files alongside SKILL.md if needed (reference docs, scripts)
5. Keep skill names lowercase with hyphens (e.g., `code-review`)

### Skill Frontmatter
```yaml
---
name: skill-name
description: What it does and when to use it (under 250 chars)
---
```

Optional fields: `disable-model-invocation`, `user-invocable`, `allowed-tools`, `argument-hint`

### Versioning
Version lives in `.claude-plugin/plugin.json`. To release:

1. Update `version` in `plugin.json`
2. Commit: `git commit -am "v0.X.Y"`
3. Tag: `git tag v0.X.Y`
4. Push: `git push origin main --tags`
