---
name: sai-senior-review
description: Use when the user asks for a senior- or staff-level PR review, a "deep review", says "review this like a senior engineer at Vanta", or wants holistic judgment (not just rule violations) on a PR or diff. Produces a structured verdict with Must Fix / Should Fix / Nits, severity per comment, and reinforcement of good patterns. Complements the workspace's rule-based `/review` command rather than replacing it.
---

# sai-senior-review

Opinionated senior/staff-level PR review. The workspace's built-in `/review` and `.ai-rules/code-review/reviewer.md` focus on **rule violations** (patterns explicitly codified in `CODE_REVIEW.*.md` files). This skill layers a **holistic judgment** review on top of that: architecture, design quality, long-term maintainability.

## When to trigger

- "Senior review", "staff review", "deep review", "thorough review"
- "Review this like a senior/staff engineer at Vanta"
- The user wants judgment calls, not just rule enforcement — trade-offs, design concerns, worry about future maintainers

Do **not** trigger for:
- "Fix CI" / "what's blocking this PR" → use `pr-diagnostics`
- Narrow rule-violation-only scans → use `/review` or `/ci-code-review`

This skill covers security and tenant safety as one of its lenses. `/security-review` remains available as a narrower dedicated scan and can be run alongside.

## Defer to these first

Before adding your own observations, incorporate these workspace sources of truth so the review inherits team conventions automatically:

1. **[`.ai-rules/code-review/reviewer.md`](.ai-rules/code-review/reviewer.md)** — the read-only reviewer workflow.
2. **All `CODE_REVIEW.*.md` files** — run `npx doc-tools ancestor-docs --doc-file-pattern 'CODE_REVIEW.*\.md$'` from the repo root, or find them manually if read-only.
3. **`AGENTS.md` / `CLAUDE.md`** — repo-wide hard rules (no `any`, no `as`, no `!`, lint/format before diff, never `tsc` directly, etc.).

Flag workspace-rule violations as **Must Fix** with a pointer to the rule.

## High bar — review for all of these

- **Correctness** — logic, edge cases, happy path **and** error paths.
- **Reliability & error handling** — what can fail, how we detect it, what we do about it. Retries, timeouts, fallbacks, partial-failure behavior, idempotency.
- **Security & tenant safety** — authz checks, cross-tenant data leaks, secret handling, input validation.
- **Performance & scale** — query/index use, N+1, unbounded loops, event-loop blocking, batch patterns.
- **Observability & logging** — are the right signals emitted to know this works in prod? Logs at the right levels (no secrets), metrics on the critical path, traces across service boundaries, alertable conditions, no silently-swallowed errors.
- **Rollout safety** — is there a safe way to ship this? Feature-flag gating, backward compatibility, migration reversibility, canary / staged rollout plan, rollback story.
- **Maintainability & design quality** — encapsulation, clear boundaries, naming, readability for a future maintainer.
- **Test quality** — meaningful assertions, failure-mode coverage, no over-mocking that drifts from prod.
- **Vanta conventions** — TypeScript / GraphQL / Mongo / monorepo package layout, Alpaca design system on frontend.

Focus especially on:

- **Clean layer separation** — API/GraphQL ↔ service/model ↔ data-access. Flag violations.
- **Unsafe TypeScript** — `any`, broad unions, `as` assertions, `!` non-null, enum misuse, missing runtime validation (Zod).
- **Auth/authz & cross-tenant risks** — every new resolver or data fetch needs explicit tenant scoping.
- **Query & scale hazards** — unindexed Mongo queries, missing aggregation stages, request fan-out.
- **Error-handling discipline** — every awaited call has a defined failure path. No silently-swallowed errors (`catch {}` / `catch (e) { /* empty */ }`). Logs include enough context to diagnose. Retries are idempotent. Partial failures don't corrupt state.
- **Observability gaps** — if this feature breaks in prod, would we notice before a user complains? Is there a metric, log, or alert that would fire? Are counters / timings / error rates emitted on the hot path?
- **Rollout safety** — is the change flag-gated or otherwise reversible? If it's a Mongo migration, is it backwards-compatible with the previous-deploy's code? Is there a rollback plan if a deploy goes bad? For irreversible changes, is staged / canary rollout planned?
- **Code that will be hard to evolve** — tight coupling, hidden I/O inside pure-looking functions, missing seams for testing.

## Product behavior & assumptions — grill the author

Surface expectations the author has baked in that aren't made explicit. Ask — don't assume — the author's intent on each of these whenever the PR / description doesn't make it obvious:

- **Corner cases** — empty input, null, concurrent writes, failed upstream calls, retries, an inactive user, deactivated domain, mid-tier permissions, role transitions, partial data.
- **Vague or unclear assumptions** — PR says "users can X" or "this works when Y" — under what *precise* conditions? Is that documented, tested, or just inferred? Restate the assumption and ask for confirmation.
- **Implicit product decisions** — defaults, ordering, tie-breakers, truncation limits, pagination size. Are they intentional or incidental?
- **Expected user-visible behavior** — error messages, loading states, empty states, permission-denied states. Are all the non-happy-path states designed, or just coded reactively?
- **Unspecified interactions** — what happens if the user navigates away mid-flow? what if two people edit the same record simultaneously? what does the UI show while a background job is still running?
- **Missing requirements signal** — if the PR description / linked ticket doesn't answer one of the questions above, that's a review finding in itself: the requirements weren't clear, and the author made a call that may diverge from product intent.

Phrase these as **questions for the author**, not recommendations. Hand-wave responses ("we'll handle that later", "edge case, not worth it", "probably fine") should be flagged as a risk — either promote to a ticket or demand the edge case be handled now.

## What to avoid

- Personal-style arguments that don't affect readability, consistency, correctness, or maintainability.
- Restating rule violations you already flagged as Must Fix.
- Vague hand-waving ("this feels off") — every comment needs a concrete recommendation.

## Output destination

Always **save the full review to a local file in addition to showing it in chat**, so the user can refer to it after the session ends. Reviews live in a gitignored directory at the repo root so they never get committed accidentally.

1. Resolve the target path: `<repo-root>/.ai-reviews/<branch-slug>-<YYYYMMDD-HHmm>.md` where `<branch-slug>` is the current branch with `/` replaced by `-`. If a PR number is known (from `gh pr view`), prefix with `pr<number>-` for easier lookup.
2. Ensure `.ai-reviews/` exists and is gitignored:
   - If `<repo-root>/.ai-reviews/` does not exist, create it.
   - If `.ai-reviews/` (or a pattern matching it) is not in `<repo-root>/.gitignore`, append it. Do this quietly — don't commit it unless the user asks; just leave the `.gitignore` change as a working-tree edit so the user can decide.
3. Write the full review (every section below, in the same structure) to that file. The chat response should summarize the verdict and risks, then link to the saved file path so the user knows where to find the full write-up.

Never write review output under `.git/`, `node_modules/`, or any path that is not gitignored. If for any reason the `.gitignore` cannot be updated (e.g. permissions, read-only env), warn the user in the chat response and fall back to `/tmp/claude-reviews/<branch-slug>/<timestamp>.md`.

## Output

### 1. Verdict

One of: **Approve** / **Approve with minor comments** / **Request changes**.
One sentence justification.

### 2. High-impact risk summary

A concentrated list of the top 2-5 risks **where a failed assumption or unhandled failure would be high-impact** — not every concern, only the ones that matter if they go wrong. Acceptable impact axes:

- **Tenant / security breach** — cross-tenant data leak, privilege escalation, secret exposure
- **Data loss or corruption** — irreversible migration, missing idempotency on a write path, schema change without backfill plan
- **Broad reliability hit** — event-loop blocker on a hot path, unbounded query, retry storm, missing timeouts
- **Non-reversible rollout** — change that can't be safely rolled back if it misbehaves in prod
- **Silent regression** — no observability to detect breakage; users notice before we do

Format each as:
- **[Risk]** — one sentence: what could go wrong
- **Blast radius** — who/what is affected if it fires (all tenants? a single role? a specific flow?)
- **Triggered by** — which assumption / unresolved question / unhandled failure mode. Link back to the relevant Must Fix / Should Fix / Question section below.
- **Mitigation** — the specific change or clarification that closes the risk

If nothing rises to "high impact", write: **No high-impact risks identified.** Do not pad this section.

### 3. Must fix

Blocks merge. Typically: correctness bugs, auth/tenant issues, rule violations from `CODE_REVIEW.*.md`, unsafe TS that will break at runtime.

Each item:
- **[Severity: high]** — file:line — the problem
- **Why it matters:** the concrete risk (production bug, security, unmaintainable)
- **Recommendation:** specific change

### 4. Should fix

Strongly recommended before merge but not blocking. Design concerns, missing tests for important paths, operability gaps.

Same format as Must fix, **[Severity: medium]**.

### 5. Nits / follow-ups

Small improvements or follow-up tickets. **[Severity: low]**. Mark as "follow-up" if out of scope for this PR.

### 6. Questions for the author

Clarifications needed before merge. These are **not** comments to action — they're places where intended behavior is unclear and the author's answer shapes whether something is a bug, a feature, or a ticket.

Each question:
- The specific uncertainty (file:line if relevant)
- **Why it matters:** what's the risk if it goes the wrong way? (wrong UX, data loss, silent regression, etc.)
- **What a good answer looks like:** a framework so the author knows what shape of response unblocks merge

Hand-waves get promoted to Must fix or Should fix depending on severity.

### 7. Good patterns worth reinforcing

Call out 1-3 things done well — specific enough that the author knows what to keep doing. This matters; reviews that only surface negatives distort the signal.

### For large PRs — review strategy

If the diff is > ~500 lines or touches > ~10 files, before diving in, propose a review order:
1. Contract / API surface first (GraphQL schema, public types, exported functions).
2. Then the core logic change.
3. Then tests.
4. Then call sites / migration patterns.

Explicitly name which files are low-risk skims vs. require line-by-line attention.
