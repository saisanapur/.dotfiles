# sai-jira-draft — iteration notes

## Prompts that triggered the skill correctly

## Prompts that should have triggered but didn't

_Watch for: "help me write a ticket", "turn this into a jira", "I need a story for…" — may not hit trigger keywords._

## Prompts that wrongly triggered

_Watch for: triggers on "file a ticket" / "create a jira in Jira" which should go to `jira-operations:jira`. If this happens, tighten the trigger description._

## Behavioral failures (skill triggered, but output was wrong)

### Over-asking clarification
_If the skill keeps asking 2-3 clarifying questions, the "one question max" guidance isn't landing. Tighten._

### Vague bullets
_"Ensure users can X" isn't testable. Watch for consistent drift back to vague language and reinforce if needed._

### AC = Requirements
_If Acceptance Criteria keeps mirroring Requirements verbatim, the distinction ("requirements = behavior; AC = how we verify") isn't landing. Consider adding an example pair in the skill body._

### Running the investigation machinery
_If the skill starts doing worktree setup / parallel agents for a drafting task, the "Anti-patterns" / "This is drafting, not investigation" language needs to be more directive._

### Padding
_5-bullet requirements for a 2-bullet ticket. Watch and reinforce._

### Hand-off drift
_Does the skill reliably stop at drafting and point to `jira-operations:jira` for filing? Or does it try to run ACLI commands itself?_

## Open questions / edge cases to cover before promoting

- **Should this skill graduate at all?** This is a personal shortcut more than a team convention. The team's canonical JIRA flow is already `jira-operations:jira`. Probably stays in sai-wip permanently.
- **Bug ticket shape** differs from story/task — does "AC" even make sense for a pure bug report, or should that be "Steps to reproduce + Expected vs Actual"? Might be worth branching the template by type.
- **Vanta-specific custom fields** (Investment, Story Points) — should the draft include TODO placeholders for these, or leave them entirely to `jira-operations:jira`?
