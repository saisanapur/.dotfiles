# sai-product-opportunities — iteration notes

## Prompts that triggered the skill correctly

## Prompts that should have triggered but didn't

_Watch for: "how can we make X faster", "where can we save time", "what should we work on next" — may not hit the trigger keywords. Tune description if so._

## Prompts that wrongly triggered

_Watch for: triggers on engineering-improvement requests that should go to `sai-solution-options` instead. If this happens, tighten "Do not trigger for"._

## Behavioral failures (skill triggered, but output was wrong)

### Generic opportunities
_"Improve the UI" / "add AI" with no specific flow step. If this keeps happening, the "no hand-waves" language in the anti-patterns needs to be more directive or more prominent._

### AI-optimism
_If every opportunity is "apply AI to X" without evidence, the skeptical-AI instruction isn't landing. Consider requiring a "user action removed" field on any AI-driven suggestion to force the evidence._

### Ungrounded in flow
_If opportunities don't cite specific files / components / queries, Step 3 (understand current state) was shallow. Reinforce._

### Near-term = long-term collapse
_If the skill keeps picking the same opportunity for both recommendations, is it genuinely right or is it lazy? Watch and tune._

### Padded top-5
_Is the 5th opportunity consistently filler? Consider making 3-5 configurable by the user's instruction, or tightening "padded top-5" in the anti-patterns._

### Confidence without evidence
_Look for "this will save 30% of review time" with no source. Either the opportunity has measurable evidence or it doesn't — no made-up numbers._

## Metric-anchor behavior

_Does the skill reliably surface the metric and use it to rank? If opportunities don't tie back to the metric, the ranking isn't calibrated — reinforce Step 1._

## Open questions / edge cases to cover before promoting

- How does this interact with `sai-solution-options`? Clean split between "product/UX opportunities" vs "technical options"?
- For flows that span multiple surfaces (e.g. web + email notifications), does the skill handle cross-surface opportunities well?
- If the user says "no AI — just UX", does the skill cleanly drop AI-driven opportunities and produce a pure-UX top-5?
- Should this skill surface instrumentation gaps ("we can't rank confidently because we don't measure X") and cross-reference `sai-launch-observability`?
