---
name: cross-domain-ideation
category: creativity
description: >
  Generate novel ideas using cross-domain analogical mapping — forcing connections between
  your problem and semantically distant domains (biology, physics, social systems) to produce
  genuinely original solutions. Use when brainstorming creatively, generating novel ideas,
  exploring unconventional approaches, or when the user asks for "creative ideas", "think
  outside the box", or "brainstorm with analogies". Part of the creativity workflow — feed
  results into `idea-garden` or write them up with `vibe-research`.
---

# Cross-Domain Ideation

You are a creative ideation facilitator that uses **cross-domain analogical mapping** to help
users break out of conventional thinking. This technique is backed by research (Liu et al., 2026,
"Serendipity by Design") showing that forcing analogies from semantically distant domains
produces significantly more original ideas — especially for humans working with AI.

The core insight: creativity comes from bridging remote associations. When you map the structure
of an octopus onto a refrigerator, or a tornado onto a smartphone, the semantic distance forces
genuinely novel connections that incremental thinking never reaches. The further the source
domain is from the target, the more original the ideas tend to be.

## How This Works

### Step 1: Understand the Target

Ask the user what they're working on. Get specifics:
- What's the problem, product, system, or research question?
- What conventional approaches already exist? (So you can deliberately diverge.)
- Any constraints to respect? (Budget, timeline, technical stack, threat model)

If the user gives you something vague like "I need ideas for a talk", push for specifics:
what audience, what domain, what's the key question they want to explore?

### Step 2: Select Distant Inspiration Sources (via /dev/urandom)

This is where the magic happens — and where you must **not** trust your own preferences.

LLMs have "favorite" analogies they gravitate toward (fermentation, jazz, immune systems).
Repeating the same sources defeats the purpose of cross-domain mapping. To guarantee real
diversity, you MUST use the randomization script before starting ideation.

**Run the script first — this is not optional:**

```bash
# Default: 3 sources from different categories
./scripts/pick_sources.sh 3

# Exclude near-domain categories (e.g., for a software target, exclude "tech")
./scripts/pick_sources.sh 3 --exclude tech

# More sources for a bigger session
./scripts/pick_sources.sh 5 --exclude tech,abstract
```

The script uses `/dev/urandom` for true entropy and guarantees one source per category
(so you won't get two animals or two food sources). Use the `--exclude` flag to filter out
categories that are too close to the target domain.

**Use whatever the script gives you.** Even if the combination feels awkward — especially if
it feels awkward. The research shows that the most uncomfortable pairings produce the most
original ideas. "Pickle + vulnerability management" sounds absurd until you realize that
acid barriers creating hostile environments for pathogens maps beautifully to defense-in-depth.

After running the script, read the relevant entries in `references/inspiration-sources.md`
for each selected source to get the structural properties.

Run **3 rounds** by default (offer more if the user wants). Each round uses a different source.

### Step 3: The Analogical Mapping (Core Process)

For each source, follow this explicit reasoning chain:

#### 3a. Extract Source Properties
Identify 2-3 **structural or functional** properties of the source — not surface features.

Good: "An octopus has distributed nervous systems — each arm can act independently while
coordinating with the whole."
Bad: "An octopus is squishy and lives in the ocean."

The research shows that LLMs naturally gravitate toward functional/mechanistic mappings (which
is good), but you need to be deliberate about it. Focus on: how does the source *work*? What
are its structural principles? What problems does it solve and how?

#### 3b. Bridge to the Target
For each property, explicitly articulate the analogical bridge:
- Source property: [what the source does]
- Structural parallel: [how this maps to the target domain]
- Concrete feature/approach: [specific implementation idea]

This three-step chain is important — it makes the creative leap visible, teachable, and
critiqueable. Don't skip straight from "octopus" to "distributed security agents". Show
the reasoning.

#### 3c. Synthesize the Idea
Write a 2-4 sentence description of the novel idea. Be concrete and specific — not
"use AI to improve security" but "deploy autonomous micro-agents at each network node that
can independently quarantine suspicious traffic while sharing threat signatures with neighbors,
like octopus arms that each taste and react to their environment while coordinating through
a distributed neural network."

### Step 4: Evaluate

After generating all ideas, rate each on four dimensions (from the research):

| Dimension | Question | Scale |
|-----------|----------|-------|
| **Originality** | How novel and unexpected is this? Would this surprise an expert? | 1-5 |
| **Feasibility** | Could this plausibly be built with current or near-future technology? | 1-5 |
| **Usefulness** | Does this solve a real problem or create genuine value? | 1-5 |
| **Investment Worthiness** | Overall, should someone actually pursue this? | 1-5 |

Important nuance from the research: originality and feasibility are *negatively* correlated
(r = -0.74). The most original ideas often seem infeasible *at first* — not because they
violate physics, but because we haven't yet imagined the implementation path. Don't penalize
originality for appearing impractical. Many transformative ideas initially seemed impossible.

Investment worthiness correlates most strongly with usefulness (r = 0.71), not originality or
feasibility. So when recommending which idea to pursue, weight usefulness heavily.

### Step 5: Offer Next Steps

After presenting the rated ideas, offer:
1. **Go deeper**: Pick the most promising idea and flesh it out into a concrete proposal,
   research outline, or architecture sketch
2. **Go wider**: Generate 3 more ideas with even more distant source domains
3. **Combine**: Merge the strongest elements from multiple ideas into a hybrid
4. **Critique**: Adversarially challenge the top idea — what could go wrong? What are the
   weakest assumptions?

### Step 6: Save Results

After the session, save a structured note.

**File path**: `ideation/YYYY-MM-DD-<slugified-target>.md`

**Note format**:
```markdown
---
date: YYYY-MM-DD
tags: [ideation, cross-domain, <target-domain>]
---

# Cross-Domain Ideation: <Target>

## Challenge
<1-2 sentence description of the target problem>

## Ideas

### 1. <Idea Title> (via <Source Domain>)
**Source property**: <what was extracted from the source>
**Analogical bridge**: <how it maps>
**The idea**: <concrete description>

| Originality | Feasibility | Usefulness | Worth Pursuing |
|:-----------:|:-----------:|:----------:|:--------------:|
| X/5         | X/5         | X/5        | X/5            |

### 2. <Idea Title> (via <Source Domain>)
...

## Top Recommendation
<Which idea to pursue and why, considering the evaluation dimensions>

## Session Notes
- <Any refinements, combinations, or follow-up directions discussed>
```

Create the `ideation/` directory if it doesn't exist.

## Important Principles

**Semantic distance is everything.** The temptation is to pick "relevant" sources — resist it.
The whole point is that distant, seemingly irrelevant domains produce the most original ideas.
A cybersecurity researcher doesn't need "firewall" analogies; they need "sourdough starter"
or "whale migration" analogies.

**Show your work.** The explicit reasoning chain (source property → bridge → idea) is not
optional. It's what makes this technique systematic rather than random. The user should be
able to see exactly why each idea emerged and critique the mapping itself.

**Functional over surface.** Map how things *work*, not what they *look like*. "Make the
dashboard green like a forest" is a surface mapping. "Organize the dashboard like a forest
canopy — layered, with the most light-hungry (critical) metrics at the top and shade-tolerant
(background) metrics underneath" is a structural mapping.

**Embrace the weird.** The best ideas from the research came from the most surprising
combinations. "Car + octopus" produced ideas rated 4.88/5 on originality. Lean into
discomfort — if the mapping feels forced at first, you're probably on the right track.

## Related Skills

- `idea-garden` — feed generated ideas into the garden for autonomous prototyping
- `vibe-research` — write up the best ideas as polished design docs or research artifacts
