# Sai's Operating Doc

Auto-loaded into every Claude Code session. Personal layer above team rules; team rules win on conflict.

## North Star

**Optimize for: speed × productivity × business impact.**

Bloat test for any meta work I add to this harness: *Does it reduce a named business continuity risk (BCR)?* If a component cannot name a concrete BCR it mitigates — loss of velocity, loss of context across sessions / OOO, loss of quality, loss of customer trust, loss of team coordination — it is bloat. Cut it.

## Principles

1. **Minimalist with outsized impact** — fewest moving parts that deliver the goal.
2. **Customer-first, ruthless prioritization** — every artifact names *who benefits, by how much*, and *the cost of not doing it*.
3. **Rising tide** — patterns that prove out get promoted to AM KB or monorepo so the team benefits.

## Decision lenses

Apply during the clarify step of any non-trivial skill (`sai-product-opportunities`, `sai-solution-options`, `sai-jira-draft`, `sai-pr-creation`, `sai-senior-review`, `sai-launch-observability`):

- **Business case.** What's the cost of doing this vs. cost of not doing it? Time to value? Reversibility?
- **Customer-first.** Who benefits, by how much, in what user-visible way? Is the impact on Access Management customers (auditors, admins, end users)?
- **Rising tide.** Does this lift the AM team or the broader Vanta engineering org? If yes, what's the promotion path — AM KB? monorepo skill? `.ai-rules/`?

If a proposal scores low on all three, push back before implementing.

## Personal anti-patterns

Bitten by these; don't repeat:

- **No `as` casts** (except `as const`), no `any`, no `!`. Fix at the root, not at the call site.
- **Spec must precede code.** Phase 1 of `sai-pr-creation` is non-negotiable for non-trivial work.
- **Never reply to PR comments without explicit human approval.** Phase 7 of `sai-pr-creation` applies to every reply, including "thanks" and "done".
- **Never use `git add -A` in business PRs.** Stage by name; no hitchhiking dotfiles or editor metadata.
- **Slow, low-leverage, or business-disconnected output is a failure mode** regardless of technical quality.

(This list is curated from weekly synthesis of `sai-weakness-register.md`. Edit in place when patterns emerge.)

## Definition of Done — checklist (not a gate)

| Phase | "Done" means… |
|---|---|
| Analysis | Problem in customer terms; top friction points named with file:line; cost-of-not-doing articulated. |
| Design | 2-4 options with effort/impact bands; recommendation justified against constraints; open questions listed. |
| Spec | BDD/TDD-shaped; rollout + error handling + observability decided; AC verifiable independently. |
| Implementation | Tests-first; strict TS; Phase 5 verification gates green; staged by name. |
| Review | Verdict + risk summary; questions for author resolved or promoted. |
| Launch | Rollout dashboard live; guardrails firing; adoption baseline measured; rollback rehearsed. |

This is a reference checklist. The dispatching skill or I read it; no separate agent gates against it.

## Current focus

Edit in place at quarter starts (or ad-hoc when priorities shift).

**Quarter goals (Q-TBD 2026):**
- TBD — fill in at next planning cycle

**Top customer pains being tracked:**
- TBD — populate from `sai-weakness-register.md` `#product` synthesis

**Active focuses:**
- TBD

## References

- **Weakness register:** `~/dotfiles/claude/sai-weakness-register.md`
- **Auto-memory:** `~/.claude/projects/-workspaces-obsidian/memory/`
- **AM KB:** `git@github.com:VantaInc/access-mgmt-knowledge-base.git`
- **gsync workflow:** `npx gsync` from the obsidian repo (auth, upload, view, comments)
- **Personal marketplace (sai-wip):** `~/dotfiles/claude-plugins/`
- **Friday synthesis schedule:** `~/dotfiles/claude/sai-schedules.md`
- **Cheat sheets:** `~/dotfiles/claude/cheat-sheets/` (sdlc, team-process, meta-ops)
