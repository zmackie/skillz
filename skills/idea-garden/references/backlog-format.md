# Backlog Format

Each idea in `garden/BACKLOG.md` is a level-2 heading with a metadata block and sections.

## Template

```markdown
## Idea Title

<!-- metadata -->
slug: idea-title
status: vapor
priority: 3
attempts: 0
fitness: 0.0
last_tried: never
tags: [tag1, tag2]
<!-- /metadata -->

Short description of the idea — what it does and why it's interesting.

### Prototype Spec

What a working prototype looks like:
- Input: what it takes
- Output: what it produces
- Core mechanic: the key thing to build

### Attempt Log

(Entries added automatically by the garden loop)
```

## Field Reference

| Field | Type | Description |
|-------|------|-------------|
| `slug` | string | Kebab-case identifier, matches artifact directory name |
| `status` | enum | `vapor`, `fermenting`, `liquid`, `frozen`, `evaporated`, `shelved` |
| `priority` | int 1-5 | Higher = more likely to be picked (5 = urgent, 1 = someday) |
| `attempts` | int | Number of prototype attempts so far |
| `fitness` | float 0-1 | Best fitness score across attempts |
| `last_tried` | date/string | ISO date of last attempt, or `never` |
| `tags` | list | Freeform tags for categorization |

## Status Transitions

```
vapor → fermenting (after first attempt)
fermenting → liquid (fitness >= 0.6)
fermenting → evaporated (fitness < 0.3 AND attempts >= 3)
liquid → frozen (user ships/completes it)
any → shelved (user deprioritizes)
shelved → vapor (user re-invests)
```
