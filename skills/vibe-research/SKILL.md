---
name: vibe-research
category: creativity
description: >
  AI-accelerated research workflow for producing polished written artifacts (design docs,
  RFCs, investigation reports, analysis papers) through multi-agent review loops. Use when
  the user wants to write a design doc, RFC, investigation report, or any substantial written
  artifact. Also triggers for "write a doc about", "research X and write it up", "draft an
  RFC", "vibe research", or "help me think through X as a document". Part of the creativity
  workflow — use to write up results from `idea-garden` or `cross-domain-ideation`.
---

# Vibe Research

Produce polished written artifacts by orchestrating multiple AI review passes in a structured loop. Inspired by [Vincent Grégoire's "Vibe Research" methodology](https://vincent.codes.finance/posts/vibe-research-paper/) — the human provides direction, taste, and verification while AI provides velocity.

The core insight: rapid iteration through **review → consolidate → fix → review** cycles, using multiple AI perspectives, produces documents that are dramatically better than a single-pass draft.

## When to Use This

This workflow shines for artifacts that are:
- Longer than a page (substantial enough to benefit from iteration)
- Intended for an audience (needs polish and clarity)
- Research-backed (benefits from exploring prior art or evidence)

Examples: design docs, RFCs, investigation reports, security analysis, competitive evaluations, incident postmortems, knowledge-sharing posts.

For quick one-pagers or informal notes, this is overkill — just write directly.

## Output Structure

Documents and workspaces are created relative to your working directory:

```
research/
  <slug>.md              # The document
  <slug>-workspace/      # Review artifacts
    reviews/
    plan.md
    verification.md
```

## The Workflow

There are 5 phases. The human is consulted at the end of phases 0, 1, and 3. Phases 2 and 4 can run with minimal supervision.

### Phase 0: Seed the Idea

**Goal**: Turn a vague idea into a concrete plan.

1. **Clarify the topic** with the user:
   - What's the question or problem?
   - Who's the audience? (team, org, external?)
   - What format? (design doc, RFC, investigation, analysis, blog post)
   - What's the scope? (What's in, what's explicitly out?)

2. **Explore prior art** — search for existing work:
   - Check the working directory for related notes or prior research
   - Use web search for public prior art, related docs, existing solutions
   - If Codex MCP is available, use it to sanity-check the framing

3. **Produce a plan** — write an outline with:
   - Document title and one-line thesis
   - Section outline (headings + 1-2 sentence description of each)
   - Key questions the document should answer
   - Sources to investigate
   - Target length (rough page count)

4. **STOP and get user approval** before proceeding. Show the plan and ask:
   > "Here's the outline. Does this cover what you need? Anything to add/remove/reframe?"

### Phase 1: Generate First Draft

**Goal**: A complete (rough) document with all sections filled in.

1. **Create the output file**: `research/<slug>.md` where `<slug>` is a kebab-case version of the title.

2. **Write the full draft** following the approved outline. Every section should have real content, not placeholders. It's fine to be rough — the review loop will polish it.

3. **Use this frontmatter**:
   ```yaml
   ---
   title: "Document Title"
   date: YYYY-MM-DD
   type: research  # or: design-doc, rfc, investigation, analysis
   status: draft
   audience: [team name or "org-wide" or "external"]
   iteration: 1
   ---
   ```

4. **Commit the draft** to a branch:
   ```bash
   git checkout -b research/<slug>
   git add research/<slug>.md
   git commit -m "research(<slug>): initial draft"
   ```

5. **STOP and notify the user**:
   > "First draft is at `research/<slug>.md`. I recommend skimming it before I start the review loop — any major directional issues are cheapest to fix now."

### Phase 2: Multi-Agent Review Loop

**Goal**: Rapidly improve the document through diverse AI feedback. This is the core engine.

Run **3 review rounds** (can do more if the user wants). Each round:

#### Step 1: Collect Reviews

Launch **two review perspectives in parallel** using subagents:

**Review A — "Full Context Review"** (subagent):
```
Read this document thoroughly: <path to doc>
Write a structured review covering:
1. **Thesis clarity**: Is the main argument/recommendation clear?
2. **Evidence quality**: Are claims supported? Any gaps?
3. **Structure**: Does the flow make sense? Any sections that should be reordered/split/merged?
4. **Audience fit**: Is the tone and detail level right for the intended audience?
5. **Blind spots**: What's missing that a reader would ask about?
6. **Specific fixes**: List concrete improvements with line references.
Save your review to: <workspace>/reviews/round-N-full-context.md
```

**Review B — "Fresh Eyes Review"** (subagent, or Codex MCP if available):
```
You are reviewing a document cold, with no prior context. Read it as the intended audience would.
<paste full document content>
Write a review focusing on:
1. **First impression**: What's confusing or unclear on first read?
2. **Strongest/weakest sections**: What works, what doesn't?
3. **Missing context**: Where do you need more background to follow the argument?
4. **Actionability**: If this is a proposal, could you act on it? If analysis, do you trust the conclusions?
5. **Nitpicks**: Awkward phrasing, repetition, formatting issues.
Save your review to: <workspace>/reviews/round-N-fresh-eyes.md
```

#### Step 2: Consolidate and Implement

1. Read both reviews
2. Write a consolidated list of changes, prioritized:
   - **Must fix**: Logical errors, missing evidence, structural problems
   - **Should fix**: Clarity improvements, better examples, flow issues
   - **Nice to have**: Style tweaks, formatting, minor wording
3. Implement all "must fix" and "should fix" items
4. Commit: `git commit -am "research(<slug>): review round N"`
5. Bump the `iteration` count in frontmatter

#### Step 3: Repeat

After 3 rounds (or when reviews stop surfacing substantive issues), move to Phase 3.

### Phase 3: Targeted Deep Dives

**Goal**: Strengthen the weakest parts identified during reviews.

1. **Identify recurring flags** — look across all review rounds for issues that kept coming up or weren't fully resolved.

2. **Research each flag**:
   - Use web search for evidence, data, examples
   - Search internal docs for supporting material
   - If technical claims need verification, write and run code to check them

3. **Incorporate findings** into the document.

4. **STOP and get user input**:
   > "I've done 3 review rounds and targeted research on [flagged areas]. The document is at iteration N. Key improvements since the first draft: [summary]. Want to review it now, or should I proceed to verification and polish?"

### Phase 4: Verification & Polish

**Goal**: Ensure accuracy and readability.

#### Verification Checklist

Go through every factual claim in the document:

- [ ] **Links**: Do all URLs resolve? Are they pointing to the right thing?
- [ ] **Data/numbers**: Are statistics, metrics, or measurements sourced and current?
- [ ] **Technical claims**: Can code examples run? Are API references correct?
- [ ] **Attributions**: Are ideas properly attributed to their sources?
- [ ] **Internal references**: Do internal links point to existing documents?

Log any issues found and fix them. If something can't be verified, flag it with a `<!-- TODO: verify -->` comment.

#### Polish Pass

- **Simplify**: Cut any section that doesn't earn its space. Shorter is almost always better.
- **Tighten the intro**: The first 3 sentences should tell a busy reader whether to keep reading.
- **Format for scanning**: Use headers, bullets, bold key terms. A reader should get 80% of the value from headers + bold text alone.
- **Add a TL;DR** at the top if the document is longer than 2 pages.

#### Finalize

1. Update frontmatter: `status: review` (or `final` if user says it's done)
2. Commit: `git commit -am "research(<slug>): verification and polish"`
3. Tell the user it's ready for their read-through.

## Output Location

All documents go to `research/<slug>.md` relative to your working directory.

After finalizing, log completion to the console:
```
Completed: research/<slug>.md — [one-line description]
```

## Key Principles

These aren't rules for the sake of rules — they come from hard-won experience in the original methodology:

1. **Human steers, AI rows.** The human picks the destination and course-corrects. AI covers the distance. Never skip the user checkpoints — a wrong-direction draft that's been polished 5 times is still wrong.

2. **Multiple perspectives > one deep pass.** Two reviewers with different instructions catch more than one reviewer with twice the time. That's why we use parallel review agents with different framings.

3. **Trust but verify.** AI will confidently cite things that don't exist, state "facts" that are wrong, and present plausible-sounding nonsense. The verification phase isn't optional — it's what separates a polished artifact from an impressive-looking hallucination.

4. **Git is your safety net.** Every iteration gets committed. Bad experiments go in branches. You can always revert. This removes the fear of bold changes.

5. **Iterate > deliberate.** Three fast review rounds beat one slow perfect draft. The review loop is the engine — feed it cycles, not perfection.

## Workspace

Create a workspace for review artifacts at `research/<slug>-workspace/` containing:
- `reviews/` — all review reports by round
- `plan.md` — the approved outline from Phase 0
- `verification.md` — the verification checklist results

## Related Skills

- `cross-domain-ideation` — generate novel angles for research topics before writing
- `idea-garden` — research workflow for garden artifacts that graduate to "frozen"
