# Document Format Reference

Templates for common document types. Pick the one that matches the `type` in frontmatter.

## Design Doc / RFC

```markdown
---
title: "Title"
date: YYYY-MM-DD
type: design-doc
status: draft
audience: engineering-team
iteration: 1
---

## TL;DR

[2-3 sentences: what you're proposing and why]

## Context & Problem

[What's the current state? Why is it a problem? What triggered this?]

## Goals & Non-Goals

**Goals:**
- ...

**Non-Goals:**
- ...

## Proposed Solution

### Overview
[High-level description]

### Design Details
[Technical details, architecture, data flow]

### Alternatives Considered
[What else was considered and why it was rejected]

## Migration / Rollout Plan

[How do we get from here to there?]

## Risks & Open Questions

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| ... | ... | ... | ... |

## References

- [link](url) — description
```

## Investigation Report

```markdown
---
title: "Title"
date: YYYY-MM-DD
type: investigation
status: draft
audience: security-team
iteration: 1
---

## TL;DR

[What was found, what's the impact, what's the recommendation]

## Background

[What prompted this investigation?]

## Methodology

[How was the investigation conducted? What tools/data sources?]

## Findings

### Finding 1: [Title]
**Severity**: High/Medium/Low
**Evidence**: [What was observed]
**Impact**: [What could happen]
**Recommendation**: [What to do about it]

### Finding 2: [Title]
...

## Timeline

| Date | Event |
|------|-------|
| ... | ... |

## Recommendations

[Prioritized list of actions]

## Appendix

[Raw data, detailed logs, supporting evidence]
```

## Analysis / Evaluation

```markdown
---
title: "Title"
date: YYYY-MM-DD
type: analysis
status: draft
audience: team-or-org
iteration: 1
---

## TL;DR

[Key conclusion in 2-3 sentences]

## Question

[What question is this analysis answering?]

## Approach

[How was the analysis conducted?]

## Findings

### [Theme 1]
...

### [Theme 2]
...

## Comparison Matrix

| Criterion | Option A | Option B | Option C |
|-----------|----------|----------|----------|
| ... | ... | ... | ... |

## Recommendation

[Clear recommendation with reasoning]

## Limitations

[What this analysis doesn't cover, caveats]

## References

- [link](url) — description
```

## Knowledge-Sharing Post

```markdown
---
title: "Title"
date: YYYY-MM-DD
type: knowledge-share
status: draft
audience: org-wide
iteration: 1
---

## TL;DR

[One paragraph summary]

## The Problem / Question

[What you'll learn from reading this]

## [Main Content Sections]

[Organized by concept, not chronology. Use concrete examples.]

## Key Takeaways

- ...
- ...

## Further Reading

- [link](url) — description
```
