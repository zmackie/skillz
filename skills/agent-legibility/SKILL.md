---
name: agent-legibility
description: >
  Optimize a codebase for agent readability: documentation structure, domain
  organization, discoverability, and knowledge capture. Use when agents struggle
  to find relevant code, when tribal knowledge lives outside the repo, when
  onboarding an agent to an existing codebase, or when restructuring docs for
  agent workflows. Use this skill whenever the user wants to make their codebase
  easier for agents to navigate or understand.
---

# Agent Legibility

Make a codebase navigable and understandable by coding agents.

## Overview

1. Assess current codebase legibility from the agent's perspective
2. Identify knowledge gaps — what does the agent need that isn't in the repo?
3. Restructure documentation and code organization for agent discovery
4. Capture tribal knowledge as repo-resident docs

## Core Principle

Anything not in the repo doesn't exist for the agent. Slack threads, wiki pages, onboarding docs, architecture diagrams in Figma — none of it is accessible. If it matters for making correct decisions, it must be in the repo in a format the agent can read.

## Assessment

Evaluate the codebase by answering these questions:

### Can the agent find what it needs?

1. Pick three recent tasks that were done in this codebase.
2. For each, trace the path an agent would take: what files would it read to understand the task? Can it find them from the root instruction file or directory structure alone?
3. If the path requires knowledge that lives outside the repo (Slack context, verbal conventions, wiki pages), that's a legibility gap.

### Is the structure self-documenting?

```
Good: src/payments/refund.py     → clear domain, clear purpose
Bad:  src/utils/helpers2.py      → what domain? what purpose?
Good: docs/api/authentication.md → findable by topic
Bad:  docs/notes.md              → findable by... luck
```

Check whether directory names map to domains and file names describe their contents.

### Are conventions discoverable?

An agent joining this codebase should be able to answer:
- What's the project structure? Where do new files go?
- What patterns does existing code follow?
- What's the test strategy? Where are fixtures?
- How are dependencies managed?
- What's the deploy process?

If the answers require reading dozens of files or asking a human, the conventions aren't discoverable.

## Making the Codebase Legible

### 1. Documentation Structure

Organize docs by domain, not by document type:

```
docs/
├── architecture.md       # Module boundaries, dependency graph, domain map
├── api/
│   ├── authentication.md # Auth patterns, token handling
│   ├── endpoints.md      # Endpoint conventions, request/response formats
│   └── errors.md         # Error handling, status codes
├── data/
│   ├── models.md         # Schema conventions, migration process
│   └── queries.md        # Query patterns, indexing strategy
└── ops/
    ├── deployment.md     # Deploy process, environment configs
    └── monitoring.md     # Alerts, dashboards, runbooks
```

Each doc should be self-contained for its domain. An agent reading `docs/api/authentication.md` should learn everything it needs to implement auth correctly without reading other files.

### 2. Architecture Map

Create a single `docs/architecture.md` that serves as the agent's map:

```markdown
## Module Map

| Directory | Domain | Owner | Key Files |
|---|---|---|---|
| src/api/ | HTTP layer | Platform team | routes.py, middleware.py |
| src/payments/ | Payment processing | Payments team | service.py, stripe.py |
| src/workers/ | Background jobs | Platform team | scheduler.py, tasks/ |
| src/models/ | Data layer | Shared | user.py, order.py |

## Dependency Direction
api → payments → models
api → workers → models
payments ✗→ api (never import api from payments)

## Key Decisions
- All external API calls go through src/clients/ (never call APIs directly)
- Database access only through SQLAlchemy models (no raw SQL)
- Background jobs must be idempotent
```

Reference this from the root instruction file.

### 3. Capture Tribal Knowledge

Common sources of tribal knowledge to bring into the repo:

| External Source | Capture As |
|---|---|
| "We always do X when..." | Directive in instruction file or per-directory doc |
| Architecture decisions | ADR (Architecture Decision Record) in `docs/decisions/` |
| Onboarding guide | `docs/architecture.md` + per-domain docs |
| Incident learnings | Constraints in relevant domain docs |
| Code review norms | Conventions in instruction file or linter rules |

Write each as a directive, not a story. "Use optimistic locking for concurrent order updates" not "After the incident in Q3 where two users modified the same order..."

### 4. Code Organization for Navigation

Agents navigate by reading directory listings and file names. Optimize for scanning:

- **One domain per directory.** Don't mix payments and notifications in `src/services/`.
- **Descriptive file names.** `payment_refund.py` over `refund.py` if it's in a generic directory.
- **Index files where helpful.** A `README.md` in complex directories explaining what's there and how files relate.
- **Consistent patterns.** If `src/api/users.py` defines user endpoints, `src/api/orders.py` should define order endpoints — not `src/api/order_management.py`.

### 5. Linter-Enforced Boundaries

Use linters to enforce architectural rules that agents (and humans) might violate:

- **Import restrictions.** Prevent cross-domain imports that break boundaries.
- **File size limits.** Flag files over 300-500 lines for splitting.
- **Naming conventions.** Enforce consistent patterns mechanically.
- **Dependency direction.** Ensure dependencies flow the right way.

See `verification-harness` for implementation details.

## Validating Legibility

After restructuring, test with a fresh agent session:

1. Give the agent a task that touches the restructured area
2. Watch what files it reads and in what order
3. Check: did it find what it needed without excessive searching?
4. Check: did it make correct decisions based on what it read?

If the agent still struggles, the documentation isn't providing what it needs — revise based on what it looked for but couldn't find.

## Anti-Patterns

- Writing documentation for humans and assuming agents will benefit equally — agents need directives, not narratives
- Documenting everything instead of what agents actually need for decision-making
- Organizing docs by creation date or document type instead of by domain
- Putting architectural knowledge only in diagrams or visual formats agents can't read
- Assuming the agent will "figure it out" from reading the code — conventions that aren't explicit aren't discoverable
