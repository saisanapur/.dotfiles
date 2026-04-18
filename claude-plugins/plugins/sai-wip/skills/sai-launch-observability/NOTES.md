# sai-launch-observability — iteration notes

## Prompts that triggered the skill correctly

## Prompts that should have triggered but didn't

_Watch for: "instrument this", "how do we know if X is working", "monitoring plan" — may not hit the obvious trigger words._

## Prompts that wrongly triggered

_Watch for: triggers on pup/datadog query requests where the user wants to read existing data, not plan new instrumentation. If so, tighten the "Do not trigger for" section._

## Behavioral failures (skill triggered, but output was wrong)

### Skipped the signal inventory
_If Step 3 gets glossed and the plan jumps to "here are new metrics to add", the cheapest wins are missed. Reinforce — or require the output to contain an existing-signals section before metric proposals are accepted._

### Vanity metrics snuck in
_"Total feature invocations" with no decision attached. Watch and tune the anti-pattern language._

### Generic dashboards
_"Usage dashboard" / "errors dashboard" without audience + time window + specific widgets. Consider requiring audience + time window as fields, not prose._

### Alerted on everything
_Every metric labeled as "alert on this" — produces an alerting pager burden. Should trend toward most metrics being dashboard-only with a small alert set._

### Cardinality blindness
_Suggests metrics tagged by domainId / userId without flagging cost. Call these out as expensive explicitly._

### Dashboards disconnect from metrics
_Widgets reference metrics not in the proposed metric list, or metrics without widgets anywhere. They should cross-reference._

## Framework-specific gaps

- **GrowthBook / feature-flag cohort splitting** — if the rollout is flag-gated, the rollout dashboard NEEDS cohort-vs-control comparison on the guardrails. Watch for the skill getting this right without being told.
- **Heap events** — is the skill confident about the boundary between Datadog (backend / infra) and Heap (product analytics)? If client-side events are landing in Datadog proposals, something's wrong.
- **Mongo specifics** — COLLSCAN alerts, aggregation latency, lock percentage. If these are missing from System Health, the Vanta-specific lens isn't strong enough.

## Interactions with pup / datadog skills

_Should this skill automatically invoke pup's "search logs" / "get monitors" when checking existing signals? That'd tighten Step 3 significantly. Currently the skill describes it in prose — test whether Claude actually reaches for those tools._

## Open questions / edge cases to cover before promoting

- Is the "three dashboards, no more, no fewer" rule right? Or should complex rollouts get a 4th (cost / business-metrics dashboard)?
- The per-metric spec is a lot of fields — does the output consistently produce all of them, or does it collapse them into prose? If it collapses, consider a compact table format.
- How does this interact with the feature-flag rollout tooling the team uses? Should the skill auto-reference the flag's name + config if provided?
- Should this skill eventually graduate to `.claude/skills/`? Observability planning is team-relevant — probably yes, after a few real launches shake out the bugs.
