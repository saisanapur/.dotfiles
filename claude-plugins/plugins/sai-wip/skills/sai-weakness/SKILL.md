---
name: sai-weakness
description: Use when the user wants to log a personal observation about something that could be better — "log a weakness", "register: <text>", "/sai-weakness log <text>", "save this for the Friday synthesis" — or when invoked for weekly synthesis ("/sai-weakness synthesize", "synthesize the weakness register"). Two modes — `log` for ~30-second capture into a flat dated register at `~/dotfiles/claude/sai-weakness-register.md` with inline tags, and `synthesize` to roll up entries into themes with routed follow-ups (harness edits, prompting best-practices, product opportunities, team-process suggestions). Personal — does NOT touch team KBs or shared docs.
---

# sai-weakness

Capture and synthesize personal observations about gaps in (a) Sai's harness, (b) prompting patterns, (c) the Access Management product, and (d) team processes. The register is the input feed; weekly synthesis turns observations into routed action.

**Storage:** `~/dotfiles/claude/sai-weakness-register.md` — flat, dated, inline-tagged.

## Modes

### Mode 1 — `log`

**Trigger:**
- "log a weakness <text>" / "register: <text>"
- "/sai-weakness log <text>"
- A user observation during another skill's session that's worth keeping ("save this for Friday")

**Process:**

1. Take the observation as written. Do not interrogate.
2. Infer 1-3 inline tags. Default candidates: `#harness`, `#prompting`, `#product`, `#team-process`. Free-form tags allowed when none of the defaults fit (e.g., `#tooling`, `#docs`).
3. Append a dated entry to `~/dotfiles/claude/sai-weakness-register.md` under the `## Entries` section. Use today's date in `YYYY-MM-DD` format (read from `date +%Y-%m-%d` or `mcp__datetime__get-current-time`):
   ```
   - 2026-04-26 #prompting #harness — sai-pr-creation Phase 5 sweep was too broad on a small change; need a "minimal scope" signal.
   ```
4. Confirm in chat with one line: `Logged: <tags> — <first 60 chars of observation>...`

Total time: ~30 seconds. Do not produce summaries, follow-ups, or recommendations in this mode — that's `synthesize`'s job.

#### Tag inference rules

- Mention of a sai-wip skill name, harness mechanics, hooks, settings.json → `#harness`
- Mention of how a prompt was phrased, what context was loaded, agent confusion → `#prompting`
- Mention of the AM product, customer pain, UX, feature gap → `#product`
- Mention of standup, forum, sprint, planning, code review process, team norms → `#team-process`

If two tags apply, use both. If none apply, ask the user once for a tag — if they don't answer in their next turn, use `#unsorted` and move on.

#### Anti-patterns for log mode

- Asking clarifying questions. The whole point is fast capture.
- Editing the user's observation. Append it as written; tag-only is your contribution.
- Producing a summary. That's `synthesize`.
- Routing follow-ups. That's `synthesize`.

---

### Mode 2 — `synthesize`

**Trigger:**
- "/sai-weakness synthesize" / "synthesize the register"
- "Friday synthesis"
- The Friday `/schedule` cron entry (see `~/dotfiles/claude/sai-schedules.md`)

**Inputs:**
- `--days N` (default 7): synthesize entries from the last N days
- `--dry-run` (optional): produce the digest but don't mark entries as synthesized

**Process:**

1. **Read the register.** Open `~/dotfiles/claude/sai-weakness-register.md` and pull all entries from the last `--days` whose lines do *not* end with `(synthesized YYYY-MM-DD)`.

2. **Group by tag.** For each tag in the entry set, count occurrences. Identify themes where 3+ entries share a tag *or* share a clear semantic theme even across tags (e.g., 5 entries all complaining about clarifying-question fatigue across `#prompting` and `#harness`).

3. **Produce the digest.** For each theme:
   - 1-2 sentence summary of what the entries collectively say
   - The supporting entries listed (date + first 80 chars + tags)
   - **One routed follow-up**, picked by dominant tag:

     | Dominant tag | Follow-up form |
     |---|---|
     | `#harness` | Propose a specific edit to a sai-wip skill (name the skill + the section + the change) or a new skill stub if the pattern is clear. Do *not* edit the skill — propose only. |
     | `#prompting` | Append (or create) `~/dotfiles/claude/sai-prompting-best-practices.md` with the lesson, an example, and an anti-example. |
     | `#product` | Propose a `sai-product-opportunities` run on a specific surface (name the flow + metric anchor) **or** a one-line draft for AM roadmap input. |
     | `#team-process` | Suggest one item for the next forum agenda or sprint retro (with the framing of the suggestion). |
     | mixed / `#unsorted` | Surface the theme to Sai for manual routing — do not auto-route. |

4. **Mark entries as synthesized.** For each entry counted in a theme, append ` (synthesized YYYY-MM-DD)` (today's date) to the entry's line, in place. Entries not counted in any theme stay un-marked and roll over to next week.

5. **Write the digest.** Save to `~/dotfiles/claude/retros/<YYYY-MM-DD>-synthesis.md` with structure:
   ```markdown
   # Synthesis — 2026-04-26

   **Window:** last 7 days (2026-04-19 through 2026-04-26)
   **Entries reviewed:** N total, M synthesized into themes, K rolled over

   ## Themes

   ### Theme 1: <one-line title>
   <1-2 sentence summary>

   **Supporting entries:**
   - 2026-04-22 #harness — <first 80 chars>...
   - 2026-04-23 #prompting — <first 80 chars>...
   - 2026-04-25 #harness — <first 80 chars>...

   **Routed follow-up:** <as per the table above, concrete>

   ### Theme 2: ...

   ## Rolled over (no theme yet)
   - 2026-04-21 #product — <first 80 chars>... (1 entry — watch for related signals)
   - 2026-04-24 #team-process — <first 80 chars>... (1 entry — watch)
   ```

   If `~/dotfiles/claude/retros/` doesn't exist, create it.

6. **Echo the digest in chat.** Surface the file path + a 5-line summary.

#### When the register has nothing to synthesize

If no entries exist in the window (or fewer than 3 across all tags), output:

```
Nothing to synthesize this week. Register has N entries from <date> to <date> across tags <list>; minimum theme threshold is 3.
```

…and skip steps 4-6. This is a healthy state — don't manufacture themes from sparse data.

#### Anti-patterns for synthesize mode

- **Manufacturing themes.** If 3+ entries don't actually share a theme, the right answer is "rolled over" — not a forced theme.
- **Auto-editing skills or KBs.** This skill *proposes* follow-ups; it never edits sai-wip skill files or AM KB content. Sai approves and executes.
- **Re-synthesizing already-marked entries.** The trailing `(synthesized YYYY-MM-DD)` is the marker. If it's there, skip the entry.
- **Posting to PRs / Jira / Slack autonomously.** All routed follow-ups are *proposals* surfaced to Sai. Phase 7 of `sai-pr-creation` ("never post without approval") applies.
- **Padding short digests.** A digest with one theme + four rollovers is fine. Do not invent themes to make the digest look productive.

---

## Output format — log mode

```
Logged: <inline tags> — <first 60 chars of observation>...
```

Single line. Nothing else.

## Output format — synthesize mode

```
Synthesized N entries into M themes; K rolled over.
Digest saved to ~/dotfiles/claude/retros/<YYYY-MM-DD>-synthesis.md.

## Themes (top 3 by entry count)
1. <title> — <follow-up summary>
2. <title> — <follow-up summary>
3. <title> — <follow-up summary>

Open ~/dotfiles/claude/retros/<YYYY-MM-DD>-synthesis.md for full digest including routed follow-ups and rollovers.
```

## Anti-patterns (general)

- **Skill talks more than it logs.** This is a capture tool first. Verbosity in either mode is a failure.
- **Synthesize without log.** If `~/dotfiles/claude/sai-weakness-register.md` doesn't exist, create it (with the standard header) and exit cleanly with a "nothing to synthesize" message. Do not error.
- **Treating the register as team-shared.** Personal-only. Do not propose moving it into AM KB. Synthesized themes can route into team artifacts; raw entries stay private.
