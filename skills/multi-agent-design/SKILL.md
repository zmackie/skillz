---
name: multi-agent-design
description: >
  Design multi-agent workflows for complex tasks: planner/generator/evaluator
  patterns, agent role definitions, sprint contracts, and handoff protocols.
  Use when a single agent struggles with complex tasks, when you need separated
  planning and implementation, when agent self-evaluation is unreliable, or when
  designing automated development pipelines. Use this skill whenever the user
  mentions multi-agent, agent pipelines, planner/builder/reviewer patterns,
  or wants to decompose work across multiple agents.
---

# Multi-Agent Design

Design workflows where multiple specialized agents collaborate on complex tasks.

## Overview

1. Assess whether multi-agent architecture is warranted
2. Define agent roles with clear responsibilities and boundaries
3. Design handoff protocols and communication contracts
4. Set up evaluation separation to avoid self-assessment bias

## When Multi-Agent Helps

Multi-agent architecture adds coordination overhead. Use it only when the overhead pays for itself:

| Situation | Single Agent | Multi-Agent |
|---|---|---|
| Single file edit | Yes | No |
| Feature in one module | Yes | Rarely |
| Cross-module feature | Yes, with sub-agents | Sometimes |
| Full application build | Possible but fragile | Yes |
| Long-running development | Degrades over time | Yes, with context resets |
| Tasks requiring independent evaluation | Biased | Yes |

**Rule of thumb:** Start with a single agent. Move to multi-agent when you observe specific failure modes that isolation would fix — not preemptively.

## The Generator/Evaluator Pattern

The foundational multi-agent pattern, inspired by GANs. One agent generates, another evaluates. Neither sees the other's internal reasoning.

### Why Separate Evaluation

Agents exhibit self-evaluation bias: they consistently rate their own output higher than an independent judge would. This isn't a flaw to fix — it's structural. The generator has full context on its reasoning and intent, making it sympathetic to its own choices.

Separation creates honest feedback. The evaluator sees only the output, judges it against criteria, and reports what it finds.

### Roles

**Generator:**
- Receives a task specification
- Implements the solution
- Self-checks before submitting (catch obvious issues)
- Does NOT assess overall quality — that's the evaluator's job

**Evaluator:**
- Receives the output and evaluation criteria
- Tests and inspects the output independently
- Grades against specific, pre-defined criteria
- Reports findings with evidence

The evaluator should interact with the actual output (run the code, test the UI, read the files) rather than just reading the source.

## The Planner/Generator/Evaluator Pattern

For complex tasks, add a planning phase before generation:

```
User prompt (1-4 sentences)
    ↓
[Planner] → Full specification + technical design
    ↓
[Generator] → Implementation (one sprint at a time)
    ↓
[Evaluator] → Test, grade, report findings
    ↓
[Generator] → Fix issues based on evaluation
    ↓
[Evaluator] → Re-evaluate
    ↓
(repeat until criteria met)
```

### Planner

Converts a brief user prompt into a detailed specification:

- Feature list with acceptance criteria
- Technical architecture decisions
- Scope boundaries — what's included and what's explicitly not
- Sprint breakdown for incremental delivery

The planner should be ambitious but specific. Vague specs produce vague implementations.

### Sprint Contracts

Break implementation into sprints. Before each sprint:

1. The generator proposes what it will build (scope, files, approach)
2. The evaluator reviews the proposal against the spec
3. Both agree before implementation starts

This prevents drift between what was specified and what gets built. The contract is a file both agents can reference.

```markdown
## Sprint 2 Contract

### Scope
- Payment refund endpoint
- Stripe API integration
- Refund status tracking

### Acceptance Criteria
- POST /refunds creates a refund via Stripe API
- Refund status is tracked in the orders table
- Partial refunds are supported
- Error handling for failed Stripe calls

### Out of Scope
- Refund notification emails (Sprint 3)
- Admin dashboard for refund management (Sprint 4)
```

## Communication Between Agents

Agents communicate through files, not conversation. This keeps handoffs clean and auditable.

### File-Based Handoffs

| Artifact | Written By | Read By | Purpose |
|---|---|---|---|
| `spec.md` | Planner | Generator, Evaluator | What to build |
| `sprint-N-contract.md` | Generator | Evaluator | What this sprint delivers |
| `evaluation-N.md` | Evaluator | Generator | What passed, what failed |
| `handoff.md` | Any agent | Next agent | State transfer on context reset |

### Evaluation Reports

The evaluator writes structured reports:

```markdown
## Evaluation: Sprint 2

### Criteria Results
| Criterion | Score | Evidence |
|---|---|---|
| Refund endpoint works | Pass | POST /refunds returned 200, Stripe mock called |
| Partial refunds | Fail | Endpoint rejects amount < total, should allow partial |
| Error handling | Pass | Stripe failure returns 502 with error message |

### Issues
1. Partial refund validation rejects valid amounts (src/api/refunds.py:47)
2. Missing database index on refund_status column

### Summary
3/4 criteria pass. Fix partial refund validation and re-submit.
```

## Designing Evaluation Criteria

Good criteria determine whether multi-agent architecture actually improves output. Poorly designed criteria waste the evaluator's effort.

### Principles

- **Specific and observable.** "The signup flow works" not "the UI is good."
- **Weighted by importance.** Subjective criteria (design quality, user experience) often matter more than technical ones (code style, test coverage) — weight accordingly.
- **Calibrated with examples.** Show the evaluator what different scores look like. A score of 8/10 on "design quality" means nothing without a reference point.
- **Focused on what agents get wrong.** Don't evaluate things the model does well by default. Focus criteria on areas where agents need external pressure.

### Calibrating the Evaluator

The evaluator prompt needs iteration. It won't get grading right on the first try.

1. Run the full pipeline on a test task
2. Read the evaluator's grades and reasoning
3. Compare against your own assessment
4. Where they diverge, update the evaluator's criteria, examples, or grading rubric
5. Repeat for 2-3 tasks

Common calibration issues:
- Evaluator is too lenient → add more explicit fail conditions with examples
- Evaluator misses visual/UX issues → add testing steps (screenshots, user flows)
- Evaluator flags non-issues → narrow the criteria scope

## Verification Methods for Evaluators

The evaluator should verify work through interaction, not just code reading:

| Output Type | Verification Method |
|---|---|
| Web application | Playwright: navigate pages, take screenshots, test interactions |
| API | HTTP requests: test endpoints, check responses, verify error handling |
| CLI tool | Run commands: test flags, check output format, verify error messages |
| Data pipeline | Run pipeline: check output format, validate sample records |
| Library | Import and call: test public API, verify type signatures |

For web applications, Playwright screenshots are especially valuable — they catch visual regressions and layout issues that code review misses.

## Cost and Complexity Trade-offs

Multi-agent pipelines are significantly more expensive than single-agent (roughly 10-20x for a full planner/generator/evaluator loop). They're worth it when:

- The task is at the edge of what a single agent can handle reliably
- Independent evaluation catches errors that self-review misses
- The cost of a bad output exceeds the cost of the pipeline

As models improve, reassess. Remove agents whose contribution no longer justifies their cost. What needed a planner + generator + evaluator with one model generation may only need a generator + evaluator with the next.

## Implementation by Agent System

### Claude Code
- Use Agent tool or `context: fork` skills for sub-agents
- File-based communication via the workspace
- Evaluator can use Bash tool for Playwright, API testing

### Codex
- Each agent is a separate Codex task
- Tasks run in isolated sandboxes with full tool access
- Orchestrate via a script that dispatches tasks and collects results

### Custom Pipelines
- Use the LLM API directly with separate system prompts per role
- Manage context explicitly — each agent gets only what it needs
- Store handoff artifacts in a shared workspace directory

## Anti-Patterns

- Using multi-agent for simple tasks where a single agent suffices
- Having the generator evaluate its own work without an independent evaluator
- Evaluating only at the end instead of per-sprint — errors compound
- Skipping evaluator calibration and trusting grades at face value
- Designing evaluation criteria that test what models already do well instead of where they struggle
- Adding more agents instead of improving instructions for existing ones
