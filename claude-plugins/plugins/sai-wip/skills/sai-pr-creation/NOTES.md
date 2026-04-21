# sai-pr-creation — iteration notes

## Prompts that triggered the skill correctly

## Prompts that should have triggered but didn't

_E.g. "let's work on AMEPD-2309" — does the skill fire on ticket-only prompts, or do I need to say "implement" / "ship" explicitly? If the latter, broaden the description's trigger phrases._

## Prompts that wrongly triggered

_E.g. one-line config changes or exploratory questions where the skill should have stayed out of the way. If it keeps firing on tiny fixes, tighten "Do not trigger for" or lean harder on quick-mode._

## Behavioral failures (skill triggered, but output was wrong)

_Paste the transcript and note what went wrong. Candidates:_
- _Skipped Phase 1 spec confirmation and started coding_
- _Skipped Phase 3 consensus gates_
- _Wrote tests after implementation instead of before_
- _Leaked implementation details into the Changes section_
- _Forgot the "through human discussions" phrasing in AI Model line_
- _Silently widened a type instead of stopping and asking_
- _Expanded PR scope via "drive-by refactoring" without surfacing it_
- _Inlined a design doc into the PR description instead of linking it_
- _Didn't save spec/design to `./.ai-dev/`_
- _Skipped Phase 5 (pre-push verification) and pushed straight to CI_
- _Ran team-scoped checks before change-scoped — inverted the cost curve_
- _Retried lint OOM more than 5 times / didn't persist the elevated heap setting_
- _**Posted a reply to a PR comment without explicit human approval**_
- _Marked a review conversation as resolved / re-requested review / promoted to ready autonomously_
- _Treated a multi-file CI fix as trivial instead of routing through the full loop_
- _Staged `.gitignore` / `.claude/settings*.json` / `.vscode/` / `CLAUDE.md` / `.ai-dev/` alongside a business change_
- _Used `git add -A` / `git add .` instead of staging by name_
- _Let the PR grow past 300 non-test lines / 6 dense functions without proposing a stack_
- _Proposed a stack split for a PR that was mostly rename / codemod churn (should have stayed as one)_

## Output-format drift

_Does the model keep the phase structure? Does it actually produce two artifacts (spec + design) when appropriate, or does it skip one? Does it keep description concise or drift back to file/function lists?_

## Defer-to-workspace behavior

_Does the model actually invoke `commit-and-pr` for mechanics rather than re-implementing draft/label/rebase logic? Does it hand off to `sai-solution-options` / `sai-launch-observability` / `sai-jira-draft` when appropriate, or try to do everything itself?_

## Interaction with sibling skills

- **vs `commit-and-pr`** — this skill should *augment*, not *duplicate*. If the model starts restating branch / label / draft rules, pare them out of this skill.
- **vs `superpowers:finishing-a-development-branch`** — that skill presents 4 options (merge / push+PR / keep / discard). Does this skill hand off cleanly to it, or collide?
- **vs `sai-senior-review`** — this skill tries to pre-satisfy that review's bar. Does it actually help? Worth comparing a PR shipped with this skill vs. without against a senior review.
- **vs `sai-solution-options`** — Phase 2 hand-off. Does the model recognize ambiguity and hand off, or does it push through on a shaky plan?

## Quick-mode calibration

_Is the quick-mode threshold right? ~50 lines is a guess. If the model uses quick-mode on changes that really needed the full loop, tighten the criteria. If it uses the full loop on trivial one-liners and the user pushes back, loosen them._

## Spec-format preference

_Does the user actually write BDD-style, TDD-style, or something else in practice? Adjust the Phase 1 wording to match what they naturally produce._

## Open questions / edge cases to cover before promoting

- Should Phase 3's error-handling grill be its own skill (reusable during code review too)?
- Should the `.ai-dev/` convention be promoted to the repo / documented in `AGENTS.md`?
- For PRs that go through multiple review rounds, should this skill own the "update description after scope change" path, or hand that back to `commit-and-pr`?
- Should there be a lint/guard that fails PR creation if Changes section contains file paths or function names (implementation-detail leak detector)?
- Model name in the AI Model line — should it be fetched programmatically from the active session, or is hardcoding "Claude Opus 4.7" fine?
- Does the `through human discussions` phrasing feel right long-term, or does it read as awkward? Revisit after a few PRs.
- Phase 5c team list is hardcoded (access-management + integrations-platform workspaces). If the team scope shifts, update the list — or better, derive it from package ownership metadata if/when that's available.
- Lint OOM retry budget is 5 — is that right? Too low = premature CI delegation, too high = wasted time. Tune after observing real sessions.
- Phase 7 blocks all outgoing comments. Should there be a narrow exception (e.g. "acknowledging receipt" / "PTAL"-style pings) that doesn't need per-reply approval, or does the full gate stay?
- CI-fix escalation threshold — currently "non-trivial = new logic, schema / type shifts, multi-file refactor." Is that the right line? Watch for cases where a "simple" fix silently grew.
- Scope-watch thresholds (~300 non-test lines, >6 logically dense functions) — tune after observing real sessions. Too strict = constant noise; too loose = review-fatigue PRs slip through.
- "Logically dense function" is subjective. Should there be a more objective proxy (cyclomatic complexity, AST node count)? Probably overkill — judgment is fine — but note if the model keeps mis-classifying.
- Default-exclude list for staging — keep an eye on real sessions. If the model keeps trying to stage a path not on the list, add it.
- Staging rule interaction with the user's dotfiles repo — this skill assumes `~/dotfiles` exists. If a user lands on this skill without that setup, the "commit settings separately" advice needs a fallback.
- Is the stacking-mechanics advice too prescriptive (`-01-foundation` / `-02-impl` / `-03-wiring`)? Compare against whatever branch shapes the user naturally produces.
