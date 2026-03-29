# Vulnerability Research Approaches

Each approach is suited to different targets and goals. Choose based on your situation, or
combine them — SECRA's research phase feeds well into any of the others.

---

## Slice-Based Audit

**Source**: "Needle in the Haystack" (devansh) — 30+ vulns across Parse Server, HonoJS, ElysiaJS, etc.

**Best for**: Source code access, clear attack surfaces, methodical coverage.

**How it works**:
1. Build a threat model (entry points, trust boundaries, bug classes)
2. Split the audit into thin slices — one attack surface per slice
3. For each slice, load only the relevant code and audit with adversarial prompts
4. Validate findings with PoCs

**Key insight**: Keep each slice narrow enough that all relevant code fits in context without
crowding. A slice like "path traversal in static file serving" is good. "All input validation"
is too broad.

**Typical yield**: High volume of findings, ~20-40% validation rate after triage. Best at
finding logic bugs and missing validation in application code.

---

## Patch Diffing

**Source**: Akamai's PatchDiff-AI, Elastic Security Labs — 88.6% correct function identification

**Best for**: Analyzing security patches, n-day research, understanding specific fixes.

**How it works**:
1. Obtain the patch/diff (git diff, binary diff via BinDiff/BSim)
2. Feed the diff to the LLM with context about the surrounding code
3. Ask: what vulnerability does this patch fix? What was the root cause?
4. For n-day research: can the pre-patch version be exploited?

**Key insight**: Patches are naturally focused — they show exactly what changed. This avoids the
context overload problem. The LLM excels at reasoning about "what was wrong before this fix."

**Akamai's multi-agent approach**: Split analysis across specialized agents:
- Reverse engineering agent: analyzes the binary/code changes
- Domain expert agent: provides context about the subsystem (e.g., Windows internals)
- Vulnerability research agent: synthesizes into root cause analysis

Cost: ~$0.14 per report with GPT-4. Very efficient.

**Typical yield**: High accuracy for root cause analysis. The Elastic team found a DWM
use-after-free and built a full exploit chain starting from a BSim patch diff.

---

## SECRA Pipeline

**Source**: xclow3n — 14+ vulns, 9 CVE-worthy, across multiple targets

**Best for**: Fresh targets, maximizing impact, combining domain knowledge with code analysis.

**How it works**:
1. **Domain research phase**: Before touching code, gather:
   - All prior CVEs for the target and similar projects
   - Known vulnerability patterns for the tech stack
   - Relevant RFCs/specs the code should implement
   - Security advisories from dependencies
   - Novel attack techniques from recent research
2. **Feed research to frontier model**: Give the LLM the research context alongside the code
3. **Focused analysis**: Use the research to guide which code paths to examine

**Key insight**: The research phase is what makes this approach powerful. Instead of asking the
LLM to find bugs from scratch, you're giving it a knowledge base of "here's what has gone
wrong before in similar code." This dramatically improves signal-to-noise ratio.

**Typical yield**: Fewer total findings but much higher quality. xclow3n's SECRA approach had
the best reportable-to-total ratio of any approach tested.

---

## Hypothesis-Driven

**Source**: xclow3n (Approach 3) — 38 hypotheses, 12 confirmed

**Best for**: When you have specific bug classes in mind from CVE history or domain knowledge.

**How it works**:
1. From CVE history and code review, form specific hypotheses:
   "This project uses X library for parsing, which had CVE-YYYY-NNNN for buffer overflow
   in malformed input. The project's wrapper doesn't add bounds checking."
2. Test each hypothesis with targeted code analysis
3. For confirmed hypotheses, build PoCs

**Key insight**: This is the most efficient approach per-token because you're only analyzing
code you have reason to suspect is vulnerable. The tradeoff is you miss bug classes you
didn't hypothesize about.

**Typical yield**: Good confirmation rate (~30%) but findings tend to be lower impact because
the obvious hypotheses tend to target known patterns that may already be mitigated.

---

## Blackbox RFC Spray

**Source**: xclow3n (Approach 1) — 55 findings, 8 exploitable

**Best for**: Protocol implementations, parsers, anything with a formal specification.

**How it works**:
1. Identify which spec/RFC the code implements
2. Systematically generate test cases for spec edge cases:
   - Boundary values, malformed input, unusual but valid combinations
   - Areas where the spec is ambiguous
   - Optional features that are often implemented incorrectly
3. Fuzz the implementation with these targeted inputs
4. Analyze crashes/unexpected behavior for exploitability

**Key insight**: Specs define what code SHOULD do. The gap between spec and implementation is
where bugs live. LLMs are good at reading specs and generating adversarial test cases that
target ambiguous areas.

**Typical yield**: High volume of findings, but many are spec-compliance issues without security
impact. The exploitable subset (~15%) tends to be in parsing edge cases.

---

## RAG-Augmented Analysis

**Source**: Nikhil's Cybersec Blog — local LLM + vector database approach

**Best for**: Repeated analysis across similar targets, building up a knowledge base over time.

**How it works**:
1. Build a vector database of:
   - Prior CVE descriptions and patches
   - Vulnerability patterns for relevant languages/frameworks
   - Security advisories and write-ups
2. For each code section under review, query the RAG pipeline for relevant context
3. Feed the code + retrieved context to the LLM for analysis

**Key insight**: This scales well for teams doing repeated security reviews. The knowledge base
grows over time and improves analysis quality. Works well with local/smaller models because
the RAG context compensates for the model's smaller training set.

**Practical note**: Can be set up with Ollama + Qdrant + n8n for a fully local pipeline.
Good for organizations that can't send code to external APIs.

---

## Choosing an Approach

Quick decision tree:

1. **Analyzing a specific patch?** → Patch Diffing
2. **Fresh target, want maximum impact?** → SECRA Pipeline
3. **Have source code, want thorough coverage?** → Slice-Based Audit
4. **Code implements a spec/RFC?** → Blackbox RFC Spray (can combine with Slice-Based)
5. **Know specific bug classes to look for?** → Hypothesis-Driven
6. **Doing this repeatedly across many similar targets?** → RAG-Augmented Analysis

Most real engagements combine 2-3 approaches. A common effective pattern:
1. SECRA research phase (gather domain knowledge)
2. Hypothesis-driven for known bug classes
3. Slice-based audit for systematic coverage of remaining surfaces
