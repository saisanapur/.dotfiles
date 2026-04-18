# sai-senior-review — iteration notes

## Prompts that triggered the skill correctly

## Prompts that should have triggered but didn't

_If "review this PR" alone doesn't load the skill, the description may need to be more explicit. Consider adding exact trigger phrases you use day-to-day._

## Prompts that wrongly triggered

_e.g. loaded on CI-failure questions where `pr-diagnostics` should have run instead._

## Behavioral failures (skill triggered, but output was wrong)

_Paste the transcript and note what went wrong — wrong section structure, missed workspace rules, too many nits, too few good-patterns callouts, hallucinated line numbers, etc._

## Output-format drift

_Does the model keep the Must Fix / Should Fix / Nits structure reliably? If it collapses sections or skips "good patterns", tighten the output section._

## Defer-to-workspace behavior

_Does the model actually read `.ai-rules/code-review/reviewer.md` + `CODE_REVIEW.*.md` before generating its review? If not, the "Defer to these first" section needs to be more directive._

## Open questions / edge cases to cover before promoting

- How does this interact with the existing `/review` command? Do they collide or compose?
- Should I add a "quick mode" for small PRs vs. the full treatment for large ones?
- Is there value in generating review output as GitHub-comment-ready markdown (with file links) vs. plain structured text?
