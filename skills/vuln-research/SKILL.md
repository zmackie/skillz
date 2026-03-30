---
name: vuln-research
category: security
description: >
  LLM-assisted vulnerability research on open-source codebases. Use when the user wants to
  find security vulnerabilities, audit code for bugs, analyze patches for security implications,
  or perform security-focused code review. Also triggers for CVEs, exploit development, attack
  surface analysis, or threat modeling. For lighter-weight review, see `code-review` instead.
---

# LLM-Assisted Vulnerability Research

This skill guides you through a proven methodology for finding real vulnerabilities in open-source
codebases using LLMs. The methodology is synthesized from researchers who collectively found 50+ CVEs
using these techniques.

The single most important lesson from all the research: **keep your scaffolding minimal and your
focus narrow.** LLM performance degrades sharply as context grows — this is the "needle in a haystack"
problem. A lean threat model and focused audit slices dramatically outperform elaborate frameworks.

## Token Budget Rule

This ratio matters more than which model you use:

- **<10% scaffolding** — threat model, system prompt, skill instructions
- **60-80% slice audits** — actual code analysis, the core work
- **20-30% verification** — PoC construction, false positive filtering

If you notice scaffolding bloating past 10%, stop and trim. Every token spent on framework is a token
not spent finding bugs.

## Critical Warning: AI Inflates Findings

Every researcher who published results on this topic encountered the same problem: LLMs generate
false positives at high rates. Some approaches produced 50+ "findings" with 0 reportable bugs.
Treat every LLM finding as a hypothesis, not a conclusion. The human is the filter.

---

## Phase 1: Target Selection & Recon

Good target selection matters more than model sophistication. Fresh, under-audited targets yield
dramatically more results than hardened ones.

### Assess the Target

Before diving in, gather context:

1. **CVE history**: Search for prior CVEs against this project. This reveals which bug classes have
   appeared before — they often recur in nearby code or similar patterns.
   ```
   Search: site:cve.mitre.org OR site:nvd.nist.gov "[project name]"
   Check: GitHub Security Advisories for the repo
   ```

2. **Target freshness**: Has this codebase been professionally audited? Projects with recent
   Trail of Bits or similar audits are harder targets. New projects, fast-moving projects, and
   projects that recently added major features are better targets.

3. **Language and complexity**: Some patterns are more amenable to LLM analysis than others.
   Parsing code, auth logic, crypto usage, and memory management have well-known bug classes
   that LLMs can pattern-match against.

4. **Size assessment**: Can the relevant code fit in context? If the whole codebase is huge,
   you need to identify the critical subsystems. You cannot audit everything — pick the
   highest-risk surfaces.

### Choose Your Approach

Based on the target, select an approach. See `references/approaches.md` for detailed guidance on
each. Brief summary:

| Approach | Best When | Key Strength |
|----------|-----------|-------------|
| **Slice-based audit** | You have source access, clear attack surfaces | Methodical, high coverage of chosen surfaces |
| **Patch diffing** | Analyzing specific patches/commits for security impact | Fast, focused, good for n-day research |
| **SECRA pipeline** | Fresh target, want maximum impact | Domain research feeds frontier model analysis |
| **Hypothesis-driven** | You have specific bug classes in mind from CVE history | Targeted, efficient for known patterns |
| **Blackbox RFC spray** | Protocol implementations, parsers | Good for spec-compliance bugs |

You can combine approaches. SECRA's research phase feeds into any of the others.

---

## Phase 2: Threat Modeling

This is the only scaffolding you need. Build it before touching any code.

A threat model is not a formality — it is the lens that makes the audit productive. Without it,
you're asking the LLM to "find bugs" in a vacuum, which produces noise.

### Build the Threat Model

For the target codebase, identify:

1. **Entry points**: Where does untrusted input enter? (HTTP endpoints, file parsers, CLI args,
   IPC, deserialization, environment variables, database reads)

2. **Trust boundaries**: Where does privilege change? (auth checks, permission gates, sandbox
   boundaries, user/kernel transitions, client/server boundaries)

3. **High-risk operations**: What dangerous things does the code do? (memory allocation, SQL
   queries, command execution, file system access, crypto operations, pointer arithmetic)

4. **Attacker model**: Who is the attacker, what do they control, what's their goal?
   Be specific: "unauthenticated remote attacker who controls HTTP request bodies" is useful.
   "An attacker" is not.

5. **Bug classes to hunt**: Based on CVE history and code characteristics, which vulnerability
   types are most plausible? (injection, auth bypass, SSRF, path traversal, type confusion,
   use-after-free, race conditions, logic errors)

### Threat Model Format

Keep it brief. A good threat model fits in 20-40 lines:

```
## Target: [project name] v[version]
## Component: [specific subsystem]

### Attacker Model
[Who, what they control, what they want]

### Entry Points
- [entry point 1]: [what input, what validation]
- [entry point 2]: ...

### Trust Boundaries
- [boundary 1]: [what changes across it]

### High-Risk Operations
- [operation 1]: [why it's dangerous]

### Priority Bug Classes
1. [bug class]: [why plausible here]
2. [bug class]: [why plausible here]
```

---

## Phase 3: Slice-Based Execution

Split the audit into thin slices, each targeting one attack surface or bug class. Audit one
slice at a time. This is how you keep context focused and LLM performance high.

### Define Slices

Each slice should be:
- **Narrow**: One attack surface or bug class (e.g., "SQL injection in the query builder",
  not "all injection bugs")
- **Self-contained**: All relevant code fits in context together
- **Tied to the threat model**: Every slice maps to an entry point + bug class combination

Example slices for a web framework:
1. Path traversal in static file serving
2. SSRF in webhook/callback URL handling
3. Auth bypass in session management
4. Prototype pollution in request body parsing
5. ReDoS in route pattern matching

### Audit Each Slice

For each slice, use adversarial prompting techniques. See `references/adversarial-prompts.md`
for the full catalog. The key principles:

1. **Prime as adversary**: "You are a security researcher hunting for exploitable vulnerabilities."
   This framing produces better results than "review this code for issues."

2. **Assert the bug exists**: "This code contains a [bug class] vulnerability. Find it and write
   a proof of concept." False anchoring forces deeper analysis — the model tries harder to find
   something rather than dismissing code as safe.

3. **Ask for exploits, not assessments**: "Write a working exploit" produces more rigorous
   analysis than "is this vulnerable?" The model must think through actual exploitation,
   which surfaces real issues and exposes false positives.

4. **Decompose invariants**: "What security invariants must hold for this code to be safe?
   For each invariant, find a code path that violates it."

5. **Invert the question**: Instead of "is this input validated?", ask "construct an input
   that bypasses all validation and reaches [dangerous operation]."

6. **Constrain the attacker model**: "Assume the attacker controls [specific input]. Trace
   every code path from [entry point] to [dangerous operation] and identify where sanitization
   is missing or insufficient."

### Slice Execution Checklist

For each slice:
- [ ] Load only the relevant code files (keep context minimal)
- [ ] State the specific bug class and entry point from the threat model
- [ ] Use adversarial prompting (assert bug exists, ask for exploit)
- [ ] If a finding surfaces, immediately attempt to construct a PoC
- [ ] Record the finding with: location, bug class, trigger condition, impact
- [ ] Move to the next slice — don't keep expanding scope

---

## Phase 4: Validation & Triage

Every finding from Phase 3 is a hypothesis. Most will be false positives.

### Validate Each Finding

For each potential vulnerability:

1. **Trace the data flow manually**: Follow the untrusted input from entry point to dangerous
   operation. Check every sanitization step, type check, and validation along the way.
   The LLM often misses or hallucinates intermediate checks.

2. **Build a proof of concept**: A finding without a PoC is not a finding. Attempt to:
   - Construct a concrete malicious input
   - Trace it through the actual code (not the LLM's summary of the code)
   - Demonstrate the security impact

3. **Check for mitigations the LLM missed**: Common things LLMs overlook:
   - Framework-level middleware (CSRF tokens, rate limiting, WAF rules)
   - Type systems that prevent certain inputs
   - Database constraints that limit injection impact
   - OS-level protections (ASLR, DEP, sandboxing)

4. **Severity assessment**: If the bug is real, assess:
   - What's the actual impact? (RCE, data leak, DoS, privilege escalation)
   - What are the prerequisites? (auth required? specific config? race condition?)
   - How reliable is exploitation?

### Triage Categories

- **Confirmed exploitable**: PoC works, clear security impact → report it
- **Likely real, needs more work**: Bug pattern is sound but PoC incomplete → invest more time
- **Theoretical only**: Plausible bug class but no concrete path to exploitation → deprioritize
- **False positive**: LLM hallucinated a check being missing, or missed a mitigation → discard

---

## Phase 5: Reporting

Structure findings for maximum clarity and actionability.

### Finding Report Template

```markdown
## [Vulnerability Title]

**Severity**: [Critical/High/Medium/Low]
**Bug Class**: [CWE-XXX: Name]
**Component**: [file:function]
**Affected Versions**: [version range]

### Summary
[One paragraph: what the bug is, how to trigger it, what the impact is]

### Root Cause
[Technical explanation of why the vulnerability exists — the actual code defect]

### Proof of Concept
[Concrete steps or code to reproduce the issue]

### Impact
[What an attacker can achieve — be specific about the security boundary crossed]

### Suggested Fix
[How to remediate — patch suggestion if possible]

### Discovery Notes
[Which approach/slice found this, any context about the analysis process]
```

### Responsible Disclosure

If real vulnerabilities are found:
- Check the project's security policy (SECURITY.md, security@ email)
- Use coordinated disclosure — report privately before publishing
- Give maintainers reasonable time to patch (typically 90 days)
- Include all PoC details in the private report so they can reproduce and fix

---

## Anti-Patterns to Avoid

These patterns were identified across multiple research efforts as actively harmful:

1. **Over-scaffolding**: Bloated AGENT.md/SKILLS.md files that eat context. The threat model
   is the only scaffolding you need.

2. **"Find all vulnerabilities"**: Vague, broad prompts produce noise. Be specific about the
   bug class and entry point.

3. **Trusting LLM assessments**: The LLM saying "this is vulnerable" means nothing without
   a working PoC. The LLM saying "this is safe" also means nothing.

4. **Context overload**: Loading the entire codebase into context. Performance degrades sharply.
   Load only the files relevant to the current slice.

5. **Over-orchestration**: Complex multi-agent pipelines with elaborate handoffs. Simple
   focused prompts outperform complex frameworks in most cases.

6. **Skipping threat modeling**: Going straight to "audit this code" without understanding
   what you're looking for. This produces generic, low-value findings.

7. **Not verifying**: Accepting findings at face value without PoC construction.
   Researchers report 50-90% false positive rates in raw LLM output.

## Related Skills

- `code-review` — for lighter-weight review when full vulnerability research isn't needed
- `verification-harness` — automate the security checks your research identifies
