## skillz — Claude Code Plugin

Skills for coding agent harness engineering and common dev workflows.

### Structure
- `skills/<name>/SKILL.md` — each skill is a directory with a SKILL.md file
- `.claude-plugin/plugin.json` — plugin manifest
- `.claude-plugin/marketplace.json` — marketplace catalog for installation
- `meta-skill.md` — writing guidelines for new skills
- `docs/harness-engineering/` — source articles for harness engineering skills

### Skill Categories

Skills belong to one of four categories, indicated by the `category` field in their frontmatter:

- **harness-engineering** — Configuring and optimizing coding agent workflows. `harness-audit` is the entry point; it diagnoses issues and recommends specific skills.
- **creativity** — Idea generation, prototyping, and research writing workflows.
- **security** — Vulnerability research and security-focused code analysis.
- **general-dev** — Common development workflow automation.

### Adding a New Skill
1. Read `meta-skill.md` for writing guidelines
2. Create `skills/<skill-name>/SKILL.md`
3. Include YAML frontmatter with `name`, `category`, and `description`
4. Add supporting files in `references/` subdirectory if needed (not alongside SKILL.md)
5. Add a `## Related Skills` section at the bottom pointing to 2-4 sibling skills
6. Keep skill names lowercase with hyphens (e.g., `code-review`)

### Skill Frontmatter
```yaml
---
name: skill-name
category: harness-engineering  # or: creativity, security, general-dev
description: What it does and when to use it (under 250 chars)
---
```

Optional fields: `disable-model-invocation`, `user-invocable`, `allowed-tools`, `argument-hint`

### Cross-References

Each SKILL.md has a `## Related Skills` section listing sibling skills with directional guidance (e.g., "after using this skill, consider X for..."). When writing new skills, add cross-references to existing skills in the same category.

### Reference Files

Supporting material goes in `references/` subdirectories within the skill directory. Example: `skills/openrouter-api/references/models.md`. Don't place reference files alongside SKILL.md at the top level.

### Versioning
Version lives in `.claude-plugin/plugin.json`. To release:

1. Update `version` in `plugin.json`
2. Commit: `git commit -am "v0.X.Y"`
3. Tag: `git tag v0.X.Y`
4. Push: `git push origin main --tags`
