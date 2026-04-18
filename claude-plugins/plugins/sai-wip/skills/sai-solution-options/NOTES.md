# sai-solution-options — iteration notes

## Prompts that triggered the skill correctly

## Prompts that should have triggered but didn't

_Watch for: "what's the best way to…" phrasing without the word "options". Description may need more trigger variants._

## Prompts that wrongly triggered

_Watch for: loads on "build X" / "implement X" when the user actually wants code. If it does, tighten the "Do not trigger for" section._

## Behavioral failures (skill triggered, but output was wrong)

### Jumped to implementation
_If the output starts producing code instead of options, the "Anti-patterns" section needs to be more directive._

### Greenfield / ungrounded proposals
_If options 1-3 all rewrite the existing code rather than extending it, the "Before proposing options — ground in current code" step was skipped. Reinforce._

### Padded option count
_If the output consistently has 4 options where the 3rd and 4th are filler, consider tightening the count guidance._

### Weak recommendation / false parity
_If the recommendation reads as "it depends" without committing, the constraint-justification requirement isn't landing. Tighten._

## Output-format drift

_Does the skill keep the structured format? If the model collapses the sections into prose, the Output format template needs to be stricter._

## Open questions / edge cases to cover before promoting

- When the goal is fuzzy and the user hasn't stated constraints, is the skill probing the right clarifying questions? Or is it inventing constraints?
- How does this compose with `superpowers:brainstorming`? Clear handoff if the user wants more creative/open-ended exploration?
- For cross-package changes (monorepo), does the skill surface which packages each option touches?
