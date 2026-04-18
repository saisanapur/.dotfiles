---
name: sai-product-opportunities
description: Use when the user asks for a product/UX investigation — "what are the top opportunities to improve X", "how can we reduce time to complete Y", "UX opportunities in Z", "where are we losing users in this flow", "top product improvements for…". Produces a ranked top-5 list of opportunities grounded in the current codebase, each with problem/improvement/feasibility/effort/impact, plus near-term + long-term recommendations. Sibling to `sai-solution-options` — use that one for technical/implementation options; this one for product/UX opportunities.
---

# sai-product-opportunities

Product-minded investigation: where the product experience has friction, what we could do about it, ranked by value-to-effort ratio. Output is a **ranked top-5**, not an exhaustive list.

## When to trigger

- "Top opportunities to improve X"
- "How do we reduce time to complete Y?"
- "UX improvements for Z" / "product wins in Z"
- "Where are users getting stuck in this flow?"
- User is in product-planning mode: impact over implementation elegance

## Do not trigger for

- Pure engineering refactors / tech-debt lists → `sai-solution-options` or a general plan skill
- Implementation tasks ("build this improvement") → go implement or use `superpowers:writing-plans`
- Metrics/dashboard planning → `sai-launch-observability` (to be scaffolded)
- Market / strategy analysis without a codebase grounding — this skill requires the product to exist in code

## Step 1: Clarify scope — with a timeout

Ask clarifying questions first to establish common understanding. Batch them as one short numbered list. Ask only for what's missing:

- **Flow or surface** — which page / feature / end-to-end flow is in scope? One user-visible journey, not "the whole product".
- **Target users / segments** — auditors, customers, specific roles, all users? Different segments have different friction.
- **Metric the user cares about** — time to complete, completion rate, retention, decision speed, error rate, NPS? Anchors the ranking.
- **Constraints** — freeze zones (team won't touch area X), deadline pressure, tech debt the user wants to honor or ignore
- **AI-value skepticism mode** — is AI assumed to help here, or is that an open question? (Default: open; require evidence before recommending AI-driven improvements)

Give the user an explicit bail-out: *"If you'd rather I proceed with reasonable assumptions, reply 'go ahead' and I'll list them before starting."*

**Timeout behavior.** If the user doesn't answer within ~1 minute / their next turn — silence, "go ahead", or replying about something else — **don't re-ask**. Proceed with assumptions:

- Flow: take the user's stated flow; if ambiguous, assume the most-trafficked one
- Target users: assume all users on the flow unless the flow itself is segmented
- Metric: default to **time-to-complete** (your original prompt focused on time savings)
- Constraints: assume no freeze zones; assume team has latitude to change anything on the flow
- AI value: assume skeptical — AI-driven ideas must demonstrate concrete time/effort reduction, not just "we could use AI here"

List every assumption at the top of the report under **"Assumptions (no clarification received)"**, and mark the opportunity rankings **provisional** on those assumptions.

## Step 2: Where to run the investigation

**Default:** worktree off latest `origin/main` — this investigation reads widely across flows, and you don't want it tangled in the user's in-progress branch. Use [`superpowers:using-git-worktrees`](~/.claude/plugins/cache).

**Current branch instead** when the user says so, or when the investigation is about an in-flight change ("here's what I'm building — what product wins does it unlock?").

## Step 3: Understand the current state before proposing anything

Before any opportunity list, you must be able to describe the flow end-to-end. Skimping on this step produces generic "add AI here" suggestions that aren't grounded.

1. **Trace the user flow.** Start from the entry point (page, route, deep-link) and walk through every step a user takes to complete the metric-anchor task. Name files, components, queries, mutations, and state transitions.
2. **Find friction points.** Wherever there are:
   - Latency that blocks decisions (slow queries, blocking fetches, page re-renders)
   - Repeated user actions (same click 10 times, re-entering data, paging through lists)
   - Decision bottlenecks (user can't tell what to do next, ambiguous labels, missing context)
   - Error-recovery loops (forms that lose input on error, unclear error messages)
   - Context switches (user has to leave the page to find information)
   - Missing bulk / batch operations when the natural use is in volume
3. **Note technical and product constraints** that meaningfully shape the solution space — e.g. auth model, permissions, multi-tenant isolation, existing data model shape, whether AI inference is already on the critical path.

## Step 4: If the investigation is broad, parallelize

If the flow has multiple independent sub-stages or user segments that could be analyzed separately, split and delegate via [`superpowers:dispatching-parallel-agents`](~/.claude/plugins/cache) or parallel `Agent` calls.

**Good signals for parallelization:**
- The flow has 3+ distinct sub-stages with different code ownership (e.g. "request creation" vs. "reviewer approval" vs. "post-approval provisioning")
- Different user segments use the flow in meaningfully different ways — analyzing each is its own exercise
- Backend vs. frontend friction are separately scoped enough to explore in parallel

**Reconcile after return.** The final output is one unified top-5, not five per sub-stage. Cross-cutting opportunities (same fix helps 3 sub-stages) get highlighted as such.

## Step 5: Generate the top 5 opportunities

**Always exactly 5.** Fewer if the codebase genuinely doesn't support more (say so explicitly); more is noise.

**Ranking priority:**
1. Highest-value + simplest/fastest wins first (XS-S effort, High impact)
2. Medium-complexity opportunities with strong impact next (M effort, High impact)
3. Heavier-lift or riskier solutions last, unless upside is clearly exceptional (L-XL effort, High impact only)

### For each opportunity

- **Title** — concrete, action-oriented ("Pre-select high-confidence AI recommendations by default")
- **Problem today** — the specific user pain, inefficiency, or decision slowdown. Cite the flow step / file where the friction lives.
- **Proposed improvement** — what changes in the UX / product experience. One paragraph.
- **Why this reduces <metric>** — be explicit about the mechanism for time savings / completion-rate gain / whatever the user's anchor metric is. No hand-waves.
- **Feasibility in current architecture** — reference the relevant systems, flows, files, or patterns. Does this fit existing primitives, or does it require new ones?
- **Implementation sketch** — 3-5 bullets of system changes. Rough, not full code.
- **Pros** — 2-3 bullets
- **Cons / risks** — 2-3 bullets. Include product risks (could this confuse a user segment?) not just eng risks.
- **Best when** — conditions under which this is the right choice. ("Only worth doing if >30% of reviewers use the keyboard-first flow.")
- **Estimated effort** — use the scale below (assumes heavy AI use)
- **Estimated impact** — **Low / Medium / High** with a one-sentence justification tied to the metric anchor

### Effort scale (assumes heavy AI use)

Same scale as `sai-solution-options`. One engineer paired with AI for coding, review, testing; adjust upward for cross-team coordination or blocking external dependencies.

| Label | Duration | What it looks like |
|---|---|---|
| **XS** | < 0.5 day | Config / copy / 1-file change |
| **S** | 0.5–1 day | Contained to 1-2 files / one package |
| **M** | 1–3 days | Cross-cutting within a single domain |
| **L** | 3–7 days | Multiple packages, migration, new service |
| **XL** | > 1 week | Greenfield / major refactor / multi-team |

Call out AI-delta where material ("without AI pairing: M → L").

## Step 6: Dual recommendation

Give both:

- **Best near-term path** — the opportunity the team should ship in the next 1-2 sprints. Justify using the constraint set.
- **Best strategic long-term path** — the opportunity with the highest compounding payoff even if it's M-L effort. This is where "the right thing that we should build toward" lives.

If these are the same opportunity, say so — don't manufacture a second pick.

If the codebase does not support a strong recommendation — e.g. the flow is too incoherent to confidently name a top-5, or the user's metric isn't measurable from current signals — say so explicitly. A calibrated "I don't know yet, here's what we'd need to learn" is better than manufactured confidence.

## Anti-patterns for this skill

- **Skipping clarification.** At minimum confirm the metric-anchor — without it, ranking is arbitrary.
- **Re-asking after timeout.** Proceed with listed assumptions.
- **"Add AI here" without evidence.** Your original prompt said: *"Be skeptical: do not assume AI adds value unless it clearly reduces user effort or decision time."* Honor it — for any AI-driven suggestion, name the exact user action AI removes or the decision time AI shrinks. If you can't, drop the suggestion.
- **Greenfield as default.** Same rule as `sai-solution-options`: greenfield can appear as an opportunity, but not as *the* default recommendation when incremental wins exist.
- **Padded top-5.** Four strong + one filler is worse than four strong.
- **Generic opportunities.** "Improve the UI" is not an opportunity. Every opportunity names a specific flow step, a specific change, and a specific mechanism for gain.
- **Ignoring the near-term / long-term split.** If your near-term = long-term, that's a signal — either say so or look harder.
- **False confidence.** If the codebase doesn't support a recommendation, say so.

## Output format

```
## Investigation context
- Source: <worktree off main at SHA, OR "current branch <name>">
- Ran in parallel: <yes — N agents / no>
- Clarification status: <"user confirmed scope" OR "no response, proceeding on assumptions below">

## Assumptions (no clarification received)   ← include ONLY if Step 1 timed out
- <explicit assumption 1>
- <explicit assumption 2>
...

## Current state summary
<1-2 paragraphs: the flow end-to-end, files/components/queries involved, key patterns>

## Key friction points
<bulleted list: specific user pains mapped to specific flow steps / files>

## Top 5 opportunities (ranked)

### 1. <Title>
[all fields as described above]

### 2. <Title>
...

## Recommended near-term path
<one opportunity, justified against constraints>

## Recommended long-term path
<one opportunity — can be same as near-term if genuinely so, flagged>

## Open questions / assumptions
<anything unresolved, esp. assumptions whose failure shifts the ranking>
```

Keep sections tight — product stakeholders skim these. Every line earns its place.
