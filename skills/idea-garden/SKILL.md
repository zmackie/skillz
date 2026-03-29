---
name: idea-garden
description: >
  Genetic-algorithm-inspired workflow for autonomously prototyping ideas from a backlog.
  Maintains a garden of ideas that transition through states (vapor → fermenting → liquid → frozen).
  Runs hourly via cron to pick and prototype ideas, or can be triggered manually. Use when the
  user says "idea garden", "start the garden", "stop the garden", "add to the garden", "try an
  idea", "try the top idea", "garden status", "prototype something", "what's in the garden",
  "garden report", "shelve idea", "invest in idea", or wants autonomous background prototyping.
  Also use when the user adds a new research idea or project concept they want to eventually
  try out. Even casual mentions like "I should try building X" or "here's an idea" can trigger
  adding to the garden.
---

# Idea Garden

A genetic algorithm for ideas. You feed in raw concepts, the system autonomously prototypes
them as runnable code, evaluates fitness, and the best ideas survive for further investment.

The backlog lives at `garden/BACKLOG.md`. Artifacts go to `garden/artifacts/<slug>/`.
All paths are relative to your working directory.

## Setup

Create the garden directory in your project root:

```
garden/
  BACKLOG.md     # Your idea backlog (see references/backlog-format.md)
  artifacts/     # Auto-created per idea
```

To use a different location, set environment variables `IDEA_GARDEN_BACKLOG` and `IDEA_GARDEN_ARTIFACTS`.

## Commands

Determine what the user wants and jump to the relevant section:

| User says | Action |
|-----------|--------|
| "start the garden" | → **Start Cron** |
| "stop the garden" | → **Stop Cron** |
| "try an idea" / "try the top idea" | → **The Loop** (single run) |
| "add X to the garden" / "here's an idea" | → **Add Idea** |
| "garden status" / "what's in the garden" | → **Show Status** |
| "shelve X" | → **Update Status** (set to shelved) |
| "invest in X" | → **Update Status** (bump priority or reset to vapor) |
| "garden report" | → **Generate Report** |

## The Loop: Pick → Execute → Evaluate → Report

This is the core workflow. Run it once manually or repeatedly via cron.

### Step 1: Pick an Idea

Run the picker script to get a random, weighted selection:

```bash
bash scripts/pick_idea.sh
```

The script uses `/dev/urandom` for true entropy, weighted by priority and freshness.
If all ideas are shelved/frozen/locked, it will error — tell the user to add more ideas.

Parse the output (tab-separated): `slug, status, priority, attempts, fitness, last_tried, title`

### Step 2: Read the Idea

Find the idea's section in `garden/BACKLOG.md` by searching for its `## Title` heading.
Read the description and **Prototype spec** section carefully — this is what you're building.

### Step 3: Create Artifact Directory

```
garden/artifacts/<slug>/attempt-<N>/
```

Where N = attempts + 1. Also create a lockfile at `garden/artifacts/<slug>/.lock`.

### Step 4: Write the Prototype

Build a **single runnable artifact** based on the prototype spec. Choose the right format:

- **uv script** (preferred for data analysis, API calls, computation):
  ```python
  # /// script
  # requires-python = ">=3.11"
  # dependencies = ["whatever-you-need"]
  # ///
  ```
  Must be runnable with `uv run script.py`.

- **HTML demo** (preferred for interactive visualizations, simulations):
  Single `.html` file with embedded CSS/JS. Must work when opened in a browser.

- **bash script** (preferred for CLI tools, pipeline demos):
  Must be runnable with `bash tool.sh`.

**Hard rules**:
- Must be runnable with a single command
- Must produce visible output (stdout, a file, or a rendered page)
- Spend at most ~15 minutes writing code. Bias toward getting something working fast.
- If the full computation would take >30 seconds, scale it down to a toy example that
  proves the concept. The point is to test whether the idea has legs, not to build the
  full thing.
- Prefer `uv` scripts — they're self-contained with inline deps and easy to run.

### Step 5: Run It

Execute the prototype and capture stdout/stderr. Use `scripts/evaluate_prototype.sh`
for the mechanical checks:

```bash
bash scripts/evaluate_prototype.sh <artifact-dir> "<run-command>"
```

This checks: code exists (+0.1), runs clean (+0.2), produces output (+0.1).

### Step 6: Evaluate (Subjective)

On top of the mechanical score (0-0.4), add subjective judgment (0-0.6):

| Signal | Points |
|--------|--------|
| Output is meaningful (not just errors/debug) | +0.1 |
| Demonstrates the core concept of the idea | +0.2 |
| Could be extended into a real tool/analysis | +0.2 |
| User would find this interesting to play with | +0.1 |

Be honest. A script that runs but prints garbage is not a 0.6. A script that crashes
but the approach was clearly right might deserve a 0.3 with a note about what to fix.

### Step 7: Update Backlog

Edit `garden/BACKLOG.md` to update the idea's metadata block:
- Increment `attempts`
- Update `fitness` with the new score
- Update `last_tried` to today's date (YYYY-MM-DD)
- Update `status` based on the transition rules:

| Condition | New Status |
|-----------|-----------|
| fitness ≥ 0.6 | `liquid` |
| fitness < 0.3 AND attempts ≥ 3 | `evaporated` |
| fitness 0.3–0.6 | `fermenting` |
| fitness < 0.3 AND attempts < 3 | `fermenting` |

Append to the idea's **Attempt Log** section:

```markdown
#### Attempt N (YYYY-MM-DD)
- **Approach**: <what you tried>
- **Result**: <what happened — ran/crashed/partial>
- **Fitness**: X.X
- **Artifact**: `garden/artifacts/<slug>/attempt-N/<filename>`
- **Run**: `<command to execute it>`
- **Insight**: <what was learned, especially if evaporating>
```

### Step 8: Remove Lock

Delete `garden/artifacts/<slug>/.lock`.

### Step 9: Report (Optional)

If fitness ≥ 0.4, write a report to `garden/YYYY-MM-DD-<slug>.md`:

```markdown
---
date: YYYY-MM-DD
tags: [garden, prototype, <idea-tags>]
status: <new-status>
fitness: <score>
---

# Garden: <Idea Title>

## Attempt N
**Approach**: <description>
**Artifact**: `garden/artifacts/<slug>/attempt-N/<file>`
**Run**: `<command>`

### Output
<paste or summarize key output>

### Fitness: X.X
<scoring breakdown>

### Next Steps
<what to try next, or why this is done>
```

If fitness ≥ 0.6 (reached liquid): log the result to the console and note it in the report.

## Add Idea

When the user wants to add an idea to the garden:

1. Ask for: title, brief description, and what a prototype would look like
2. Assign default priority 3 (or ask if they have a preference)
3. Append a new `## Title` section to `garden/BACKLOG.md` following the format
   in `references/backlog-format.md`
4. Confirm: "Added '<title>' to the garden as vapor (priority N). It'll be eligible
   for the next garden run."

## Show Status

Read and parse `garden/BACKLOG.md` using `scripts/parse_backlog.sh`. Present a summary:

```
Garden Status:
  vapor:      3 ideas (ready to try)
  fermenting: 2 ideas (resting after attempt)
  liquid:     1 idea (working prototype!)
  frozen:     0 ideas (shipped)
  evaporated: 0 ideas (failed, insight captured)
  shelved:    0 ideas (deprioritized)

Top priority vapor: "Exploitation Agent Toy Demo" (priority 5)
Most recent attempt: "K8s Topology" (2026-03-20, fitness 0.3)
```

## Update Status

For "shelve X": find the idea, set status to `shelved`.
For "invest in X": bump priority by 1, or if it's fermenting/evaporated, reset to `vapor`.

## Start Cron

Create an hourly cron job:

```
CronCreate: cron "7 * * * *", recurring true
prompt: "Run the idea garden: read the skill at .claude/skills/idea-garden/SKILL.md, then execute The Loop (pick an idea from garden/BACKLOG.md, prototype it, evaluate, update backlog)."
```

Tell the user: "Garden is running. It'll pick and prototype an idea every hour at :07.
Note: the cron job lives only in this session — it stops when you close Claude.
Say 'stop the garden' or 'garden status' anytime."

## Stop Cron

List cron jobs with CronList, find the garden job, delete it with CronDelete.
Tell the user: "Garden stopped. Your backlog and all artifacts are preserved."

## Generate Report

Summarize all garden activity: parse the backlog, list recent attempts with fitness scores,
highlight ideas that reached liquid, and suggest which fermenting ideas are ready to retry.

## Important Principles

**Bias toward completion.** A working toy that demonstrates 20% of the idea is worth more
than a beautiful plan for 100%. Get code running. Make it print something. Ship the smallest
possible thing that proves the concept.

**Gravity-driven flow.** If a prototype is working and you can see a clear path to making
it genuinely useful, follow that momentum. Don't stop at "good enough for a 0.6" if you
can push to 0.8 in a few more minutes. Good ideas flow downhill.

**Evaporation captures insight.** When an idea fails after 3 attempts, the `evaporated`
status requires recording what was learned. Maybe the data doesn't exist, or the approach
is wrong, or a different framing would work. This insight feeds future ideas.

**Song propagation.** When you discover a reusable pattern (a useful API, a visualization
technique, a data source), note it. Future prototypes benefit from past discoveries.
