---
name: sai-solution-options
description: Use when the user wants a feasibility study or technical options analysis before implementation — "how should we approach X", "explore options for Y", "investigate feasibility of Z", "what are the trade-offs between A and B", "technical solutions for…". Produces 2-4 ranked approaches with pros/cons/when-appropriate plus an explicit recommendation grounded in stated constraints. Does NOT implement — produces decisions and trade-offs. Complements `superpowers:brainstorming` (which is more exploratory/creative); this skill is structured options analysis.
---

# sai-solution-options

Structured feasibility analysis. The user has a goal and wants to understand the option space before committing to an implementation — simplest/quickest path, more robust/scalable path, and (sometimes) a creative alternative.

## When to trigger

- "How should we approach X?"
- "What's the simplest way to Y?"
- "Explore options for Z" / "feasibility of Z"
- "What are the trade-offs between A and B?"
- "I want to add/change X — what are my options?"
- User explicitly wants decision support before implementation.

## Do not trigger for

- "Build X" / "implement X" → go straight to implementation (or invoke `superpowers:writing-plans` if the task is large).
- Creative ideation with no clear goal → `superpowers:brainstorming` is better; it's designed for open-ended exploration.
- Single-obvious-path tasks where there's no meaningful trade-off.

## Step 1: Clarify scope — with a timeout

**Ask clarifying questions first** to establish common understanding. Batch them as one short numbered list — not an interrogation. Ask only for what's missing:

- **Goal** — the specific user-visible outcome, not a technical description
- **Value / priority** — is this high-value work that justifies a robust solution, or a signal-level feature where cheapest-viable wins?
- **Constraints** — deadlines, areas the user *doesn't* want touched, rollout sensitivity, performance budget
- **Out of scope** — things explicitly decided-against
- **Branch context** — should this investigate the current working branch, or latest main? (defaults handled in Step 2)

Give the user an explicit bail-out: *"If you'd rather I proceed with reasonable assumptions, reply 'go ahead' and I'll list them before starting."*

**Timeout behavior.** If the user doesn't answer the clarifying questions within ~1 minute / their next turn — whether by silence, "go ahead", or replying about something else — assume they're focused on another task. Do **not** re-ask. Proceed with reasonable assumptions, and:

- List every assumption **explicitly at the top of the investigation** under an **"Assumptions (no clarification received)"** header
- Mark the recommendation as **provisional** on those assumptions
- Note which assumption would change the answer most if wrong

Default assumption stance (use unless evidence suggests otherwise):

- Goal: take the stated goal literally, no embellishment
- Value / priority: medium — neither drop-everything nor throwaway
- Constraints: prefer lowest-complexity option; assume flag-gating is required for any new user-visible behavior
- Out of scope: nothing assumed out of scope
- Branch: latest `origin/main` in a worktree (see Step 2)

## Step 2: Where to run the investigation — default to a worktree off main

**Default:** run the investigation in a separate git worktree off latest `origin/main`. Two reasons:
- Grounds analysis in the real shipped code, not the user's in-progress branch
- Doesn't leave exploratory reads / test files / notes littered across the user's working tree

Use the workspace's [`superpowers:using-git-worktrees`](~/.claude/plugins/cache) skill (or the `.claude/worktrees/` convention) to set one up.

**Run in the current branch instead when:**
- The user explicitly says "investigate here" / "use my current branch" / "use the code I've changed"
- The goal is specifically about finishing in-flight work ("how should we complete this PR?")
- The investigation needs files the branch just created that don't exist on main

If uncertain which applies, ask in Step 1 and include it in the clarifying batch.

## Step 3: Ground in the current code

Greenfield proposals are almost always less useful than options that fit the code as it exists.

1. **Read the current implementation.** Start from the file / module the user named. Trace its callers, callees, data model, and GraphQL surface. Note existing patterns used for similar problems — new options should prefer these patterns unless there's a concrete reason not to.
2. **Check for near-neighbors.** The cheapest option is frequently "extend what's already there." Search the monorepo for the shape of the problem before inventing a new abstraction.

## Step 4: If the investigation is complex, parallelize

If the goal decomposes into **independent** sub-investigations, split and delegate rather than serializing everything.

**Good signals to parallelize:**
- The goal has 3+ orthogonal sub-questions ("how do we add A, B, and C?" where each touches a different system)
- Each sub-question lives in a different package / domain
- Answers don't constrain each other — any combination of sub-answers is internally consistent

**How:** invoke the workspace's [`superpowers:dispatching-parallel-agents`](~/.claude/plugins/cache) skill, or send one message with multiple `Agent` calls — typically `Explore` subagents for "what exists" and `Plan` for "how would this work." They run concurrently.

**Reconcile after all sub-agents return:**
- Merge findings into a single option map (each sub-question gets 1-2 options)
- Surface cross-sub-question dependencies explicitly (e.g. "option A1 is only viable if option B2 is chosen")
- Produce one unified recommendation — not N parallel mini-recommendations

**Do NOT parallelize when:**
- The goal is a single cohesive question (parallel agents would duplicate context-loading and fight over the same files)
- Sub-questions are sequentially dependent (B's answer requires A's finding)
- Total scope is small enough a single investigator holds it all in context

## Option generation

Always produce at least **2 options**; ideally **3**; no more than **4**. Too few means shallow; too many means the user can't decide.

Required categories (produce at least the first two):

- **Simplest / quickest** — minimum viable change. Typically extends an existing pattern; may not solve the general case. For low-value work, this is usually the right answer.
- **More robust / scalable** — the version you'd build if this mattered long-term. Usually involves new abstractions, schema changes, or broader integration. Cost is higher.
- **Creative / less obvious alternative** *(optional)* — a different angle: reuse of something elsewhere in the code, a pattern from an adjacent domain, a question of whether the goal itself should be reframed. Include only if it's genuinely plausible.
- **Greenfield / clean-slate** *(optional but surface it when warranted)* — include as a first-class option when the existing code has structural issues that make every incremental path expensive, when the incremental sum-of-costs clearly exceeds a fresh build, or when the user has asked to see it. Don't default to it, but don't suppress it either — if it's the right answer, the explicit cost comparison needs to be visible.

For each option, include:

### Option N: `<concise name>`

- **What it is** — one-paragraph explanation of the approach
- **Key implementation steps** — 3-6 bullets. Concrete files/modules/functions that change. Not full code unless essential.
- **Pros** — 2-4 bullets
- **Cons / risks** — 2-4 bullets. Include operational risks (rollout, observability, reversibility) not just coding cost.
- **Effort & resourcing** — use the scale below with a one-sentence reason and the key drivers (packages touched, schema changes, migrations, other-team dependencies)
- **When this approach is appropriate** — constraint conditions under which this is the right call

### Effort scale (assumes heavy AI use)

Baseline: one engineer paired with AI for coding, review, and testing — not unassisted eng time. Adjust **upward** when other-team coordination, blocking external dependencies, or cross-repo work are required. Adjust **downward** when the change is almost entirely AI-generatable with the user spot-checking.

| Label | Duration | What it looks like |
|---|---|---|
| **XS** | < 0.5 day | Config change, 1-file edit, trivial wiring |
| **S** | 0.5–1 day | Contained to 1-2 files / one package; no schema or API change |
| **M** | 1–3 days | Cross-cutting within a single domain; new abstraction or minor schema/API change |
| **L** | 3–7 days (~1 week) | Spans multiple packages; migration or new service; multi-step rollout |
| **XL** | > 1 week | Greenfield, major refactor, cross-team coordination, or phased multi-sprint delivery |

Call out explicitly if the estimate would shift a band without AI assistance (e.g. "without AI pairing: M → L") — this is the delta that makes AI-heavy workflows worth choosing over traditional estimates.

## Compare & recommend

- **Trade-off table** — a compact comparison across the options on the dimensions that matter (effort, scope, rollout risk, long-term flexibility, user-visible impact).
- **Recommendation** — state one option as the recommended choice. Justify it **specifically against the stated constraints**, not in the abstract. If the stated constraint is "low value, prioritize low effort", the recommendation must honor that even when a more robust option is technically prettier.
- **When the recommendation would change** — one line: "if the priority shifts to X, switch to option N."

## Anti-patterns for this skill

- **Skipping clarification.** Even if the user's prompt looks complete, at least confirm the value/priority signal — the recommendation is useless without it.
- **Re-asking after timeout.** If Step 1 didn't get answered, don't keep asking. Proceed with listed assumptions and move.
- **Running in the user's working tree by default.** Unless explicitly asked, don't spelunk in an in-progress branch. Use a worktree off main.
- **Parallelizing a single cohesive question.** Multiple agents exploring the same files burns context and produces duplicate findings. Reserve for independent sub-questions.
- **Jumping to implementation.** The deliverable is a decision, not code. Minimal pseudo-code for the recommended option is fine; full scaffolding is not.
- **Greenfield as the default.** Greenfield is a legitimate option and should be surfaced when warranted (see "Required categories") — but never let it be option 1 by reflex. If your first instinct is "rewrite from scratch", re-run Step 3 before locking it in.
- **Hand-wavy effort estimates.** "This is pretty big" isn't a cost. Every option gets a band from the effort scale, plus the key drivers. If genuinely uncertain, give a range (S–M) and name the uncertainty.
- **False parity.** Don't present options as equally-weighted when one is clearly better under the constraints. State a strong recommendation.
- **Padded option count.** Two good options > three where the third is obvious fluff.
- **Ignoring the value/priority signal.** If the user said "this is a signal-level thing, not high value", an option that costs a quarter of eng time is not viable regardless of technical elegance.
- **Unreconciled parallel output.** If sub-agents ran, the user wants one unified recommendation, not N mini-recommendations stitched together.

## Output format

```
## Investigation context
- Source: <worktree path off main at SHA, OR "current branch <name>">
- Ran in parallel: <yes — N agents / no>
- Clarification status: <"user confirmed scope" OR "no response, proceeding on assumptions below">

## Assumptions (no clarification received)   ← include ONLY if Step 1 timed out
- <explicit assumption 1> — changes recommendation if wrong? <y/n>
- <explicit assumption 2> ...

## Problem restatement
<1-2 sentences confirming understanding>

## Constraints & priority
<bulleted; include explicit "out of scope" if stated>

## Current state
<1-2 paragraphs: the relevant code, existing patterns, near-neighbors worth noting>

## Options

### Option 1: <name>
[as described above]

### Option 2: <name>
...

## Trade-off comparison
<compact table. Required columns: Option | Effort (band, heavy-AI) | Rollout risk | Long-term fit | Key trade-off. Optional columns: user impact, observability cost, reversibility.>

## Recommendation
<one option, justified against constraints. Flag as "provisional" if assumptions were made above.>

## Open questions
<anything not resolved — esp. any assumption where being wrong changes the recommendation>
```

Keep explanations concise but meaningful. If the user asks a follow-up ("now do option 2"), hand off to implementation — this skill's job is done once the decision is made.
