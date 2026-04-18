---
name: sai-jira-draft
description: Use when the user wants to draft JIRA ticket *content* — "draft a jira ticket for X", "write up a ticket for Y", "I need ticket content for Z". Produces a structured markdown draft with Title, Background, Requirements (testable), Out of Scope, and Acceptance Criteria (verifiable). Content-only — does NOT file the ticket. For actually creating the ticket in Jira with ACLI + ADF formatting, hand off to the `jira-operations:jira` skill.
---

# sai-jira-draft

Quick, structured drafting of JIRA ticket content. The deliverable is a markdown block the user can paste into Jira (or hand to `jira-operations:jira` to file automatically).

## When to trigger

- "Draft a jira ticket for X"
- "Write up a ticket for Y"
- "I need ticket content for Z"
- "Give me a jira for [feature / bug / task]"

## Do not trigger for

- "Create the ticket" / "file the ticket" / "open a jira" → hand off to `jira-operations:jira` (which has ACLI integration, ADF formatting, custom fields, and attachments).
- Long-form spec / design docs → this skill is for one ticket's worth of content, not a multi-page document.
- Updates to an existing ticket → `jira-operations:jira` has the update flow.

## Step 1: Fast clarification (one question, with timeout)

Drafting is a lightweight task — don't interrogate. Ask **at most one** clarifying question, and only if critical info is missing. The typical missing pieces:

- **Type** — is this a story, bug, task, or spike? Shapes tone of Title and what "AC" means.
- **User / system behavior expected** — if the ask is vague ("improve X"), confirm the specific change.

If the user's request already contains enough to draft reasonably, **skip the question** and go straight to drafting.

**Timeout:** if the user doesn't answer within ~1 minute / their next turn, pick the most likely type (usually "task") and draft. List the inferred type at the top of the draft so the user can redirect.

## Step 2: Draft

### Required sections

Each gets a **bold section title**, in this order:

1. **Title** — concrete, specific, under ~80 chars. Prefer verb-first ("Add X to Y" / "Fix Z in W"). Avoid vague words like "improve", "handle", "address" unless the ticket genuinely is open-ended.
2. **Background / Context** — 2-4 sentences. What's the current state? Why does this exist? Link to the precipitating conversation, bug report, or design doc if named. No marketing language.
3. **Requirements** — bulleted list. Each bullet is **testable** — i.e. a reader can verify it's done by observation. Good: "`AccessReviewList` page shows a column `Assignee` with the reviewer's display name." Bad: "Make it clear who's reviewing."
4. **Out of Scope** — bulleted. What this ticket does **not** solve. Include things that might otherwise be assumed in scope.
5. **Acceptance Criteria** — bulleted. Each criterion is **verifiable** — typically a Given/When/Then, a concrete UI-state check, or an observable system output. AC differs from Requirements: requirements describe what the system should do; AC describes how we'll know it's done.

### Style

- **Concise** — no filler. Every sentence earns its place.
- **Specific** — file paths, page names, GraphQL fields, user roles should be named when relevant.
- **Actionable** — the engineer reading this should know what to do. If the answer is "figure it out", the ticket is probably still a discovery, not a story.
- **Avoid vague language** — drop words like "improve", "handle better", "make it nicer", "properly", "as needed" unless the ticket is explicitly a discovery / spike.
- **Bold formatting only on section titles** — not scattered through bullets.

### When the request is too vague for a draft

If the user's request genuinely doesn't support a structured ticket ("jira for access reviews" with no more context), don't guess. Ask for the minimum clarifier (one question) and stop. A weak draft is worse than asking.

## Step 3: Suggest next step

End the output with a single-line pointer:

> **Next:** paste into Jira, or run `jira-operations:jira` to file it (handles ADF formatting, attachments, custom fields).

Don't automate the file step from this skill — that's explicitly the other skill's job.

## Anti-patterns for this skill

- **Running the full investigation playbook.** This is drafting, not investigation. No worktree, no parallelization, no top-5 options. If the user wants investigation output to become a ticket, do the investigation with the right skill first, then hand the findings here.
- **Interrogating with many questions.** One question max. The input is usually enough.
- **Duplicating `jira-operations:jira`.** If the user says "file it", stop and hand off.
- **Vague bullets.** "Ensure good UX" is not a requirement. Either it's specific enough to test or it doesn't belong.
- **AC = Requirements restated.** Requirements describe behavior; AC describes verification. If they're identical, the AC is weak.
- **Padding.** Don't pad a 2-bullet requirement list to 5. Tickets that are genuinely small should look small.

## Output format

```
**Title**
<concrete verb-first title>

**Background / Context**
<2-4 sentences>

**Requirements**
- <testable bullet>
- <testable bullet>
- ...

**Out of Scope**
- <thing not being solved here>
- ...

**Acceptance Criteria**
- <verifiable criterion>
- <verifiable criterion>
- ...

**Next:** paste into Jira, or run `jira-operations:jira` to file it.
```

If the user said "just draft it, I'll file myself", drop the Next line.
