---
name: sai-launch-observability
description: Use when the user is planning observability for a feature rollout — "what metrics do we need for launching X", "dashboards for this rollout", "how do we monitor feature Y in prod", "observability plan for launch", "what should we alert on for Z". Produces a structured plan: existing-signal inventory, decision-driving metrics grouped by health axis (rollout / system / product / adoption / edge cases), leading vs lagging indicators, dashboard sketches (command / product / debug), and tradeoff recommendations. Complements the workspace's `pup` / `datadog` skills — those are for querying existing data, this is for planning new instrumentation.
---

# sai-launch-observability

Structured observability-plan generation for a feature rollout. The question isn't "what can we measure?" — it's "what decisions do we need to make during and after launch, and what signals let us make them?"

## When to trigger

- "What metrics do we need for this launch?"
- "Build me a dashboard plan for feature X"
- "How do we monitor Y in prod?"
- "Alerting plan for Z rollout"
- User is shipping something and wants a launch observability plan, not just ad-hoc graphs

## Do not trigger for

- Querying existing metrics / debugging live issues → [`pup`](~/.claude/plugins/cache) / `datadog` skills (read-only query tools)
- Investigating *why* a known alert fired → `pr-diagnostics` or `pup` for log dives
- General "how do we improve X" product investigations → `sai-product-opportunities`

## Step 1: Clarify scope — with a timeout

Batch clarifying questions (one short numbered list). For observability planning, the critical inputs are:

- **Feature description** — what's shipping, in one sentence, plus the user-visible change
- **Target users / segments** — all users, specific roles, auditors, specific domains, beta cohort?
- **Rollout strategy** — feature flag (% rollout, cohort-based, domain-based)? Regions? Scheduled dates?
- **Known risks / failure modes** — what the team is worried about. Shapes the alert set.
- **Tool constraints** — Datadog (usual), Heap (if frontend/product), any others? Any constraints on cardinality budget, custom metric cost, or retention?
- **Relevant code / services** — files, services, or packages the change lives in. Needed to find existing signals.

Explicit bail-out: *"If you'd rather I proceed with reasonable assumptions, reply 'go ahead' and I'll list them before starting."*

**Timeout behavior.** If the user doesn't answer within ~1 minute / their next turn, don't re-ask. Proceed with assumptions:

- Feature description: take what's stated literally
- Users: assume all users on the affected flow
- Rollout: assume GrowthBook flag with staged % rollout (matches Vanta's default pattern)
- Known risks: infer from the code itself — what could fail in that code path is the starting risk list
- Tools: Datadog for backend/infra, Heap for product analytics
- Code: use the files the user named; if none, refuse to proceed — observability without code reference produces generic noise

List assumptions at the top under **"Assumptions (no clarification received)"**. Mark the plan **provisional**.

## Step 2: Where to run the investigation

**Default:** worktree off latest `origin/main` — this investigation reads existing instrumentation and service code widely; don't pollute the user's in-flight branch. Use [`superpowers:using-git-worktrees`](~/.claude/plugins/cache).

**Current branch instead** when the user says so, or when the change being monitored is not-yet-on-main (pre-launch planning on the branch that will ship it).

## Step 3: Inventory existing signals before proposing new ones

You cannot plan instrumentation without knowing what's already emitted. Skipping this step produces redundant metrics and misses the cheapest wins.

**Sources to check:**

1. **Code emission sites** — grep the affected packages for: `statsd`, `metrics`, `logger.info|warn|error`, `recordMetric`, `traceSpan`, `emit(`, Datadog client usage, StatsD / OTEL patterns. Note what's emitted, what tags, from which code path.
2. **Platform / infra signals** — the service already has baseline HTTP / BullMQ / Mongo metrics. Name them: request rate, error rate, latency p50/p95/p99, queue depth, DB query time, event-loop blocking.
3. **Client-side (if frontend)** — Heap events / page views / click tracking on the affected surface. Grep for `track(` / `heap.track` / analytics events.
4. **Existing dashboards** — mention if there's a nearby dashboard (same service / same domain) whose widgets could inform yours.
5. **Existing alerts / monitors** — use the `pup get-monitors` / Datadog MCP tools to find monitors adjacent to the code path.

**Call out gaps explicitly.** The most valuable findings are often "there's no metric for X on the hot path" — those become instrumentation recommendations in Step 4.

## Step 4: If the launch is broad, parallelize discovery

When the feature spans multiple services / surfaces, discovering existing signals serially is wasteful. Use [`superpowers:dispatching-parallel-agents`](~/.claude/plugins/cache) or parallel `Agent` calls (`Explore` subagents each with a different service/surface).

**Good signals to parallelize:**
- Feature touches 3+ services (e.g. web API, background worker, frontend)
- Server-side and client-side signal discovery are independent enough to split
- Rollout has multiple independent hazard surfaces (latency, error rate, data integrity)

**Do NOT parallelize** when the feature is contained to a single service.

**Reconcile after return** — merge into one signal inventory, one metric plan, one dashboard set. Not N parallel mini-plans.

## Step 5: Define metrics — opinionated, not exhaustive

Group by **what decision the metric supports**. Avoid vanity metrics — every metric must answer: *"if this changes, what do we do differently?"*

### Rollout Health (Guardrails)

Detect regressions during a staged rollout. **These fire alerts during launch windows.**

- Error rate delta (rollout cohort vs. control)
- Latency delta on the affected endpoints
- 5xx rate on services touched
- Anything the team called out as a known failure mode

### System Health (Reliability & Performance)

Steady-state reliability of the code path. Survives past the launch window.

- Request/job rate, error rate, latency (p50/p95/p99)
- Queue depth + stalled jobs (if BullMQ)
- DB query latency + COLLSCAN presence (if Mongo)
- Event-loop blocking (Vanta-specific concern for web containers)

### Product Success (User Value)

Does the feature do what it's supposed to do? Tied to the product hypothesis.

- Completion rate of the affected user flow
- Time-to-complete delta vs. baseline
- Adoption by the target segment
- AI-driven features: was the AI recommendation accepted / rejected / ignored?

### Adoption & Usage

Who is using this, and how often? Feeds rollout decisions.

- Users exposed (flag evaluations), users who actually hit the feature
- Split by role / domain / plan tier as relevant
- Funnel drop-off between "exposed" and "first success"

### Edge Cases / Failure Modes

The scary tail. Often catches problems guardrails miss.

- Retries per request
- Permission-denied rate (shifts suggest authz regression)
- Empty-state or null-response rate
- Timeout rate
- Anything the team explicitly called out in clarification

### Per-metric specification

For each metric proposed, give:

- **Name** — concrete, namespaced
- **Definition** — exactly what is measured, in words. One sentence.
- **Source** — where it comes from (existing log pattern, Mongo aggregation, new counter to add, OTEL trace, Heap event)
- **Why it matters** — tie to a concrete risk, rollout decision, or product question. No "good to have".
- **Expected baseline / what good looks like** — if inferable from current data, name it. Otherwise "unknown, establish during first % rollout step".
- **Alerting recommendation** — should this alert? Threshold? Severity? If not alertable, say why (e.g. "dashboard-only, too noisy for paging").
- **New vs. existing** — mark clearly so the "work required" list is obvious

## Step 6: Leading vs lagging indicators

Separate the metrics into two groups. Leading = early warning. Lagging = confirmation of success/failure.

- **Leading:** error rate, latency, failed-request rate, retry rate, permission-denied rate — these move within minutes of a bad deploy.
- **Lagging:** adoption, completion rate, time-to-complete, user satisfaction — these move over hours/days.

State which leading indicators trigger rollback decisions, and which lagging ones determine ship/iterate/revert once the launch window closes.

## Step 7: Dashboard sketches

Propose **three dashboards** — no more, no fewer. Each has a different audience and time window.

### 1. Rollout Command Dashboard

**For:** on-call / launch monitor / product lead during the launch window.
**Time window:** real-time (last 30 min / 1 hr).
**Widgets:** rollout-health guardrails (cohort vs. control), top 5 leading indicators, active alert status, exposure counts, single "rollback / hold / proceed" scorecard at the top.
**Grouping:** rollout cohort vs. control, explicitly.

### 2. Product Health Dashboard

**For:** product + eng to evaluate whether the feature is working post-launch.
**Time window:** trend (last 7-14 days), compared against the pre-launch baseline window.
**Widgets:** lagging indicators — adoption curve, completion rate, time-to-complete, user segmentation breakdowns.
**Grouping:** by target segment (role / domain / plan tier).

### 3. Debugging / Deep-Dive Dashboard

**For:** engineers diagnosing a known issue.
**Time window:** flexible (tied to an incident / investigation window).
**Widgets:** raw signals — request breakdown by endpoint + status, error-log samples, slow queries, retries, event-loop samples, relevant traces.
**Grouping:** by service, endpoint, error class.

For each dashboard list: required widgets, suggested breakdowns, and whether any widget requires new instrumentation (flag it).

## Step 8: Tradeoffs + minimal launch set

End the plan with an explicit prioritization:

- **Launch with** — the minimal subset of metrics and alerts that must exist *before* the rollout begins. Typically: rollout guardrails + the top 2-3 known-risk-mode signals.
- **Add post-launch** — nice-to-have metrics that don't block launch. Pushing these to later is a feature, not a concession.
- **High-value but expensive** — call out any metric that requires high-cardinality tags, custom metrics with cost implications, or new storage. Flag the cost and suggest whether it's worth it.
- **Potentially misleading** — metrics that look useful but are systematically wrong without context (e.g. "completion rate" when completion is optional).

## Anti-patterns for this skill

- **Skipping existing-signal inventory.** Producing new metric proposals without checking what's already instrumented means redundant work and missed free wins.
- **Vanity metrics.** Every metric must drive a decision. "Total feature invocations" is not a metric; "flag-exposed users who completed the affected flow" is.
- **Generic dashboards.** "Usage dashboard", "errors dashboard" — no. Each dashboard has a specific audience and time window. Name them.
- **Alerting on everything.** Noisy alert set kills the alerting muscle. Mark metrics explicitly as "dashboard-only" when alerting would be too noisy.
- **Ignoring cardinality cost.** High-cardinality tags (domain IDs, user IDs) are expensive in Datadog. Flag them, don't silently recommend them.
- **Recommending AI-driven signals without evidence.** Same rule as `sai-product-opportunities`: AI-driven metrics (model accuracy, recommendation acceptance) need a concrete decision they support.
- **Confidence without signal inventory.** If you don't know what's emitted today, you cannot confidently recommend a minimal launch set. Go back to Step 3.

## Output format

```
## Investigation context
- Source: <worktree off main at SHA, OR "current branch <name>">
- Ran in parallel: <yes — N agents / no>
- Clarification status: <"user confirmed scope" OR "no response, proceeding on assumptions below">

## Assumptions (no clarification received)   ← include ONLY if Step 1 timed out
- <explicit assumptions>

## Feature under observation
<1 sentence what's shipping + rollout strategy summary>

## Existing signals inventory
### Already emitted
<bulleted: signal → source → current use>
### Gaps
<bulleted: where there's no signal on the hot path>

## Proposed metrics

### Rollout Health (Guardrails)
<per-metric spec as described above>

### System Health
<per-metric spec>

### Product Success
<per-metric spec>

### Adoption & Usage
<per-metric spec>

### Edge Cases / Failure Modes
<per-metric spec>

## Leading vs lagging indicators
<two bulleted lists, plus the rollback-trigger / ship-decision callout>

## Dashboards

### 1. Rollout Command Dashboard
<widgets, breakdowns, time window, new instrumentation required>

### 2. Product Health Dashboard
<same structure>

### 3. Debugging / Deep-Dive Dashboard
<same structure>

## Launch set + tradeoffs
- **Must have before launch:** <bullets>
- **Add post-launch:** <bullets>
- **High-value but expensive (decide separately):** <bullets>
- **Potentially misleading:** <bullets>

## Open questions
<anything unresolved — missing baseline data, uncertain cardinality, unclear rollout mechanics>
```

The goal is a plan a product + engineering team can use to: quickly detect rollout issues, understand user impact, and make confident ship / rollback / iterate decisions.
