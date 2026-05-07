---
name: sai-pr-creation
description: Use when the user is starting a non-trivial feature, bug fix, or refactor that will ship as a PR — "implement X", "build Y", "ship a feature for Z", "create a PR for this", "let's work on [ticket]", "full flow for [change]". Also use when a CI fix escalates into a non-trivial change (new logic, schema / type shifts, multi-file refactor) — not just a one-line tweak. Opinionated end-to-end loop that augments (does NOT replace) the workspace's `commit-and-pr` skill and the `superpowers:finishing-a-development-branch` / `superpowers:requesting-code-review` skills. Enforces spec-first (TDD/BDD), tests-before-implementation, consensus on error handling + rollout safety + observability *before* writing code, strict TS discipline, Clean Code / Clean Architecture, a scoped pre-push verification sequence (change → package → team), and a human-approved reply loop for PR feedback. Defers to `sai-solution-options` for ambiguous problems, `sai-senior-review` for architectural bar, `sai-launch-observability` for telemetry planning, `sai-jira-draft` for follow-ups.
---

# sai-pr-creation

Opinionated ship-a-feature loop. The workspace's [`commit-and-pr`](../../../../../workspaces/obsidian/.agents/skills/commit-and-pr/SKILL.md) covers *mechanics* (rebase, draft-only, template sections, security labels) and [`superpowers:finishing-a-development-branch`](~/.claude/plugins/cache/claude-plugins-official/superpowers) covers *what-next-options*. This skill layers **discipline gates** around them: spec before code, tests before implementation, consensus on error handling / rollout / observability before merge, and a description style that respects the reader.

Do **not** restate what `commit-and-pr` already covers. Invoke it — don't inline it.

## When to trigger

- "Implement X" / "build X" / "ship X" / "work on [ticket]"
- "Start a new feature" / "kick off [change]"
- "Create a PR for this" / "let's ship this" / "full flow for Y"
- Any time the user is about to start writing non-trivial code that will end in a PR

## Do not trigger for

- Reading / exploring / answering questions → stay out of the way
- Trivial one-line config or typo fixes → hand straight to `commit-and-pr`
- **Simple** CI fixes (format, lint, obvious test flake, one-line type tweak) → `pr-diagnostics` directly
- Reviewing someone else's PR → `sai-senior-review` / workspace `/review`

**But do trigger when a CI fix grows.** If `pr-diagnostics` surfaces a root cause that requires non-trivial change — new logic, schema / type shifts, multi-file refactor, test redesign, behavioral change — **stop and invoke this skill.** The same spec / consensus / verification gates apply: a "CI fix" that edits 20 files is a feature in disguise and should be treated as one.

## Defer to these first

Before the first keystroke of code, internalize these — this skill's rules sit *on top* of them and must not contradict them:

1. **[`commit-and-pr`](../../../../../workspaces/obsidian/.agents/skills/commit-and-pr/SKILL.md)** — branch workflow, draft-only, template sections, security labels.
2. **Repo rules** — `AGENTS.md` / `CLAUDE.md`: no `any`, no `as` (except `as const`), no `!`, never call `tsc` directly, lint + format before diff.
3. **[`sai-senior-review`](../sai-senior-review/SKILL.md)** — the architectural / reliability / observability bar the eventual review will hold this PR to. Build toward it from the start.
4. **`superpowers:finishing-a-development-branch`** and **`superpowers:requesting-code-review`** — end-of-branch structured options and pre-merge subagent review.

If any rule here conflicts with one of those, those win. Escalate the conflict to the user rather than silently overriding.

## The loop

Seven phases. **Do not skip phases.** If the user insists on skipping one (e.g. "just start coding"), note the assumption and proceed — don't argue, but make the skipped phase visible at PR time.

| # | Phase | Gate |
|---|---|---|
| 1 | Spec (TDD / BDD) | Human-confirmed spec |
| 2 | Solution options (if ambiguous) | Design doc in `.ai-dev/` |
| 3 | Pre-implementation consensus | Rollout + error handling + observability signed off |
| 4 | Implementation discipline | Tests-first, strict TS, Clean Code, scope watch |
| 5 | Pre-push verification | Change-scoped → workspace-scoped → impacted-dependents checks green |
| 6 | PR creation | Concise description, required AI Model phrasing, staging hygiene |
| 7 | Review-response loop | **Never** reply to PR comments without human approval |

### Phase 1: Spec first (TDD / BDD)

Before any implementation, **ask the human to write (or confirm) a concise spec**. One or two short paragraphs is enough. The spec must answer:

- **What's the business or engineering motivation?** One sentence. Not "JIRA-123" — the actual *why*.
- **Who's affected?** Which users, roles, domains, systems.
- **What does success look like?** In observable terms (a user can do X / a metric moves / an error disappears).
- **What's explicitly out of scope?**

Format, in the human's own words — pick whichever fits:

- **BDD style:** `Given <context>, when <action>, then <observable outcome>.`
- **TDD style:** A bulleted list of the test cases that must pass before this is done.

**If the user says "you write it":** draft one based on what you know, then explicitly ask: *"Does this match your intent? Reply with corrections or 'looks good' — I won't start coding until confirmed."* Do not proceed on silence.

Save the spec to `./.ai-dev/<short-slug>-spec.md` so it survives the session and is visible to future-you / reviewers.

### Phase 2: If ambiguous, step into solution analysis

If the spec reveals material ambiguity — multiple plausible approaches, non-trivial trade-offs, cross-package impact, schema / migration shape unclear — **do not start coding**. Hand off to [`sai-solution-options`](../sai-solution-options/SKILL.md) and save its output to `./.ai-dev/<short-slug>-design.md`.

Signals you need the design pass:
- More than one reasonable approach exists and they differ on rollout risk, performance, or reversibility
- Touches data model, auth, tenant boundaries, or background jobs
- Requires a migration, a new service, or cross-team coordination
- User said "how should we approach this?" rather than "implement this"

The design doc lives at `./.ai-dev/<short-slug>-design.md` and is referenced from the PR description's Motivation section (but **not copy-pasted** into it — link it instead so the PR stays concise).

### Phase 3: Pre-implementation consensus gates

Before writing code, reach explicit consensus with the human on three things. **Ask — don't assume.** Batch as one short numbered message; don't interrogate.

**3a. Rollout safety.** Ask which is appropriate:
- Feature flag (which one, new or existing)? Cohort / % / domain-scoped?
- Backwards-compatible schema change + backfill?
- Kill switch / fast-disable path?
- None needed — stated reason

Write the answer into the spec doc so it doesn't get lost.

**3b. Error handling & corner cases.** Enumerate explicitly, then grill:
- Empty input, null, concurrent writes, failed upstream calls, retries
- Inactive user, deactivated domain, mid-tier permissions, role transitions
- Partial data, truncation, ordering, tie-breakers, pagination boundaries
- Timeouts, rate limits, idempotency on writes

For each: **what's the intended behavior, and how will we know it's working?** Hand-wave answers ("edge case, probably fine") are not acceptable — promote to a ticket or handle now. Achieve explicit consensus before coding.

**3c. Observability & success metrics.** Suggest and discuss. Do not punt to "we'll add logging later." For the kind of change at hand, propose:
- **Success metrics** — which signal tells us this worked? (product analytics event, metric delta, error-rate floor)
- **Error discovery** — which log / alert / metric fires if this breaks silently?
- **System KPIs** — latency / throughput / queue depth / error rate on the hot path. What threshold would page?
- **Product analytics** — which events establish adoption / funnel / success?

For non-trivial rollouts, hand off to [`sai-launch-observability`](../sai-launch-observability/SKILL.md) and link its output. Otherwise inline a 3-5 line plan in the spec doc.

### Phase 4: Implementation discipline

Code phase. Non-negotiables:

**Tests first.**
- Write the failing test that expresses the spec. Red, then green, then refactor.
- Writing tests first forces clean interfaces: if the test is awkward, the API is wrong.
- Exceptions (rare): genuinely exploratory code where the shape is unknown. Mark clearly and circle back to tests before PR.

**Test quality.**
- Test **business logic and key edge cases**, not implementation details.
- A good test survives a refactor that preserves behavior. A test that breaks when internal wiring changes is leaking implementation.
- No over-mocking. Mocks drift from prod; prefer real collaborators + seams.
- One assertion focus per test. Readable names that describe behavior, not method calls.

**TypeScript discipline.**
- Never give up type safety. No `any`. No `as` except `as const`. No `!`. No silent `as unknown as Foo`.
- Use `satisfies`, discriminated unions, `never` for impossible states, Zod at untyped boundaries.
- Prefer inference — annotate only where it adds information (boundaries, complex expressions, narrower-than-inferred constraints).
- Treat optional properties as `exactOptionalPropertyTypes` — omit the key rather than assign `undefined`.
- If type safety genuinely can't be preserved, **stop and ask** — don't widen silently. The user must explicitly authorize the loosening, and it must be commented with *why*.

**Code hygiene — readability, modularity, Clean Code / SOLID.**

*Readability.*
- Name things so a reader can skim the file and follow the story. Prefer a named function over a commented block; prefer a named constant over a magic literal; prefer a small helper over a clever one-liner.
- Early returns for guard clauses. Happy path at the lowest indentation level.
- One level of abstraction per function. Don't mix "orchestrate the workflow" with "parse a specific byte" in the same body.
- Prefer clarity over cleverness. If the reviewer has to pause and reason, rewrite.

*Modularity.*
- Split by concern, not by file size. Each module has one clear reason to exist and a narrow public surface.
- If a file starts accruing unrelated exports, split it. If a function signature needs five parameters with booleans controlling branches, split it.
- Co-locate implementation, tests, and fixtures: `feature.ts`, `feature.test.ts`, `feature.testutil.ts`.
- Layer boundaries: API/GraphQL ↔ service/domain ↔ data access. Keep them clean.

*SOLID, applied pragmatically.*
- **SRP** — one reason to change per function / module. If you can describe it with "and," it's two responsibilities.
- **OCP** — extend via composition or discriminated-union cases, not by editing every caller of a central switch. New behavior shouldn't require reopening unrelated code.
- **LSP** — alternative implementations honor the same contract. Don't narrow inputs or broaden outputs silently; don't throw where the base returns.
- **ISP** — consumers depend on the narrowest interface they actually use. Don't force a caller to import a kitchen-sink type just to reach one field.
- **DIP** — depend on abstractions at layer boundaries; inject concrete collaborators. Domain code doesn't import transport. Pure logic doesn't reach into I/O.

*Other Clean Architecture idioms.*
- Separate pure logic from I/O. Injectable dependencies. No I/O at module init.
- Prefer deletion over abstraction. Three similar lines is fine; a premature abstraction is not.
- Modern TS idioms: discriminated unions over boolean flags, tagged results over throwing for expected failures, Remeda (not lodash) for utilities.

**Comments.**
- Default: write none. Readable code with good naming beats comments.
- Exception: one short line when the *why* is non-obvious — a hidden constraint, a subtle invariant, a workaround for a specific bug, behavior that would surprise a reader.
- Reserve paragraph-form comments for **public API docs** and even there, describe *contract*, not *implementation*. Never leak internal structure into a docstring.
- Never narrate the diff. Never reference the current task, ticket, or caller ("used by X", "added for Y flow") — that rots.

**Proactive refactoring within scope.**
- While implementing, notice problems in the code path you're touching: dead code, dangerous patterns, redundant logic, unsafe TS, missing tests.
- If the fix is small and keeps the PR focused: do it.
- If the fix would materially grow scope or blast radius: **stop, surface it, and offer to draft a follow-up ticket** via [`sai-jira-draft`](../sai-jira-draft/SKILL.md). Do not silently expand the PR.
- Explicitly list every in-scope refactor in the PR description's Changes section so the reviewer isn't surprised.

**Scope watch — prefer stacking over a sprawling PR.**

Reviewers trade attention for size. Past a certain threshold, a single PR gets a worse review than the same change split into a stack. While implementing, keep an eye on the diff size. Flag a stacking recommendation to the human when *either* signal fires:

- **~300+ lines of non-test code changed** (exclude test files, generated code, lockfiles, fixtures, snapshots).
- **More than 6 logically dense functions** — new or materially rewritten. "Logically dense" means non-trivial branching / orchestration / domain logic; boilerplate getters, thin delegations, and mechanical helpers don't count.

When either threshold is crossed, **pause and propose a stack**. Don't keep piling onto the same branch. Surface the proposed split:

1. Identify the natural seams: typically **foundation layer first** (types / schema / interface), **implementation layer second** (the core logic), **wiring / UI / rollout third** (callsites, GraphQL glue, frontend integration, feature-flag plumbing).
2. Propose 2-4 stacked PRs in order, each independently reviewable and shippable. Each should tell a coherent story on its own.
3. Ask the human to approve the split before proceeding. If they say "keep it one PR", note the assumption and continue — but call out the size risk in the PR description's Expectations for Reviews section so the reviewer knows what they're in for.

**Stacking mechanics.** Once the split is approved:
- Each child branch targets the previous one (not `main`). Use `$BRANCH_PREFIX/<slug>-01-foundation`, `-02-impl`, `-03-wiring` naming.
- Rebase the stack when the base changes. Keep per-branch diffs clean.
- In each PR's description, link forward and backward: "Stack: (1 of 3) · next: <link>" so reviewers know where they are.

**Don't stack when:**
- The change is genuinely atomic (e.g. a single refactor that's meaningless halfway).
- The diff is dominated by mechanical churn (renames, generated code, codemod output) — high line count but low review cost.
- The human explicitly asked for a single PR.

The thresholds are **soft signals, not hard rules** — use judgment. A 350-line PR of boilerplate rename is fine as one; a 200-line PR of dense orchestration logic may still be worth splitting. Lean on the "logically dense functions" heuristic when line count is misleading.

### Phase 5: Pre-push verification — scoped, ordered, bounded

Never rely on CI to catch format / lint / type / test failures that can be caught locally. Run checks in this exact order, smallest scope first, and **stop / fix at each failing gate before continuing** — don't fan out broadly while a narrow check is red.

**Gate 5a — Change-scoped (fastest, always run first).**

Over just the changed files:

1. `npx oxfmt --write <changed files>` — format
2. `npx eslint --fix <changed files>` — lint
3. `just unit-test <relative path>` for each changed test file — tests
4. `turbo typecheck -F <workspace of changed file> --output-logs=errors-only` — typecheck at the tightest workspace that contains the edit

This should be fast (seconds to a minute). Fix issues here before touching broader scope.

**Gate 5b — Package / workspace-scoped.**

Run per-workspace for every workspace the diff touches:

- `turbo unit-test -F <workspace> --output-logs=errors-only`
- `turbo typecheck -F <workspace> --output-logs=errors-only`
- `turbo lint -F <workspace> --output-logs=errors-only` (on-demand per `AGENTS.md`, but this skill opts in)

**Gate 5c — Impacted-dependents only.**

Pre-push, extend the scope beyond the workspaces the diff directly edits *only* to the ones that are genuinely impacted — the downstream workspaces that import the changed code or depend on its types / fixtures. **Do not sweep all team-owned packages.** A blanket team sweep belongs on CI, not in every local pre-push loop.

**How to compute "impacted":**

1. Start from the set of directly-edited workspaces from Gate 5b.
2. Walk outward along dependents — any workspace that imports from an edited workspace, depends on a type / schema / fixture that changed, or shares a migration path.
3. Prefer turbo's built-in filtering when practical:
   - `turbo typecheck --filter='...[origin/main]' --output-logs=errors-only` (typechecks everything affected by the diff)
   - `turbo unit-test --filter='...[origin/main]' --output-logs=errors-only` (runs tests for everything affected)
   - If the full `[origin/main]` scope is too broad for local, filter to `'...[origin/main]'` intersected with the team-owned priority list (below).
4. For each impacted workspace found, run:

   ```bash
   turbo typecheck -F <workspace> --output-logs=errors-only
   turbo unit-test -F <workspace> --output-logs=errors-only
   ```

**Team-ownership as a *priority filter*, not a default set.**

The user's team owns these workspaces; when they appear in the impacted set, treat them as high priority and do not skip them. But **listing them here is not an instruction to run them blindly** — only run if genuinely impacted:

- **Access management** (primary): `client-access`, `client-access-core`, `access-management`
- **Integrations platform** (frequently coupled): `integrations-platform`, `integrations-platform-core`, `integrations-platform-models`, `integrations-platform-sdk`, `integrations-platform-ui`, `client-integrations-platform-ui`, `integrations`, `client-integration`, `client-integration-core`

If a workspace in the priority list is in the impacted set, do not prune it — run the check even if you'd otherwise be on the fence. If a workspace in the priority list is *not* in the impacted set, **do not run it** just because the team owns it — that's CI's job.

**Scope discipline.**
- Direct edits → covered in Gate 5b.
- One hop away (direct importers of edited code) → include.
- Two+ hops away where the change is an internal refactor with stable public types → skip, note the skip.
- Generated types regenerated after an `.graphql` / schema change → include the workspaces consuming the regenerated types.
- Shared fixtures / test utils changed → include any workspace that consumes them.

If uncertain whether something is impacted, err toward including it — but always name *why* it's impacted (e.g. "imports `FooType` which changed"). "Might be affected, not sure" is a sign to spend 30 seconds checking the import graph, not to sweep blindly.

**Lint OOM handling.**

If `turbo lint` / `npx eslint` fails with an OOM (JavaScript heap out of memory), allow up to **5 retries total** across the session with an elevated heap:

```bash
NODE_OPTIONS="--max-old-space-size=8192" npx eslint --fix <files>
# or
NODE_OPTIONS="--max-old-space-size=8192" turbo lint -F <workspace> --output-logs=errors-only
```

**Persist the setting** for the rest of the session — don't retry from scratch each time. Export it once in the shell or set it via the `.claude/settings.local.json` env block if the user wants it permanent.

If lint OOMs **more than 5 times** despite the elevated heap, **stop retrying and delegate to CI.** Record in the PR description's Testing section: "Lint skipped locally due to repeated OOM; relying on CI." Do not loop.

This applies to lint specifically — type check / tests OOMing is a different signal (usually an actual bug or a too-broad scope) and deserves investigation, not a retry budget.

**Failure routing.**
- Format / lint / type failure at Gate 5a → fix, re-run 5a, then continue.
- Test failure at Gate 5a or 5b → either the test is wrong (fix it) or the code is wrong (back to Phase 4). Don't push red.
- Type / test failure at Gate 5c → treat as high signal: you've regressed the team's owned surface. Resolve or narrow scope before push.
- Persistent lint OOM (>5) after the retry budget → delegate to CI with a note in Testing.

**Only after all applicable gates pass, proceed to Phase 6.**

### Phase 6: PR creation — augmented description style

Let [`commit-and-pr`](../../../../../workspaces/obsidian/.agents/skills/commit-and-pr/SKILL.md) handle the mechanics (draft flag, template sections, security label, rebase). **Override only the writing style of two sections:**

**Changes section — stricter style.**
- One or two sentences. High-level only.
- **Do not leak implementation details.** No file lists, no function names, no class hierarchies, no code snippets. The diff has those.
- High-level design is OK **only when non-obvious**: a one-liner like "Uses a background job so the request path stays synchronous" earns its place. "Added a function that does X" does not.
- If a design doc exists at `./.ai-dev/<slug>-design.md`, reference it — don't inline it.

**AI Model Used — mandatory format.**
Always output exactly this shape (substitute the actual model):

```
Designed and implemented with [model name] through human discussions.
```

Then, on new lines, add any additional context the template asks for (key prompts, unusual usage). Keep it under four lines total. The "through human discussions" phrasing is **required** — it signals this wasn't a one-shot generation and that the human is accountable for the design.

**Everything else** (Motivation, Testing, Deployment, Expectations for Reviews) — follow `commit-and-pr` verbatim. Do not duplicate its guidance here.

**Pre-push description re-verification — every push, not just the first.**

`commit-and-pr` covers description-update triggers tied to specific events (reviewer feedback, scope change, conflicts). That misses a quieter failure mode: a small follow-up commit can stale a "Changes" or "Testing" section without anyone noticing. Override:

Before **every** `git push` that adds new commits to a remote PR — not just the initial creation — re-read the live description and confirm every claim still matches the diff. If anything is now wrong, missing, or padded (e.g. a Testing section that lists test counts that just changed, a Changes bullet that claimed "no new files" but you just added one), update via `gh pr edit --body-file` **before** the push completes. This is cheap to do and prevents reviewers from re-grounding on a stale description mid-review.

**Staging hygiene — keep local / editor metadata out of business PRs.**

Business and spec-driven PRs should contain **only the code changes the spec implies**. Local settings, editor metadata, agent configuration, and personal tooling state must not be checked in alongside business changes unless the spec's reason genuinely warrants it.

**Default-exclude list** (do not stage unless the PR's spec explicitly calls for touching them):

- `.gitignore` (unless the spec is about ignoring new generated artifacts the change introduces)
- `.claude/settings.json`, `.claude/settings.local.json`, `.claude/commands/`, `.claude/agents/`, `.claude/plugins/`
- `.cursor/`, `.cursor-settings.json`, `.vscode/settings.json`, `.idea/`
- `.env`, `.env.local`, `.env.*.local`, anything resembling secrets
- `CLAUDE.md` / `AGENTS.md` (repo-wide; personal notes belong in the user's dotfiles repo, not here)
- `.ai-dev/`, `.ai-reviews/`, and any other agent-workspace directories
- Lockfile changes the business change didn't cause (e.g. `yarn.lock` drift from unrelated local installs)
- Dependency additions that weren't required by the spec
- Formatter / linter config changes (`.eslintrc*`, `.prettierrc*`, `oxfmt` config) unless the spec is specifically about them

**Process.** Before `git add`:

1. Run `git status` and `git diff` over the full working tree.
2. For each modified / new file, ask: *"does the PR spec actually require this change?"* If the answer is "no" or "it's just my local tooling," **exclude it**.
3. Stage files by explicit name. **Never** use `git add -A` or `git add .` in this skill's flow — those are the default path to smuggling local state into business PRs.
4. For anything borderline, surface it to the human: *"The diff includes X which the spec didn't mention — stage or leave out?"*
5. If a legitimately needed change happens to touch one of the default-exclude paths (e.g. the spec is *about* `.gitignore`), stage it and **call it out explicitly in the Motivation section** so the reviewer isn't surprised.

**When these changes do need to ship.** Personal settings, agent configs, and dotfiles belong in the user's dotfiles repo (`~/dotfiles`), not in business PRs. If you notice something useful accumulated (e.g. new allowlist entries in `.claude/settings.local.json`, a new `.ai-rules/*` guidance file) during the session, offer to commit it to the dotfiles repo **separately** — don't attach it to the business PR as a hitchhiker.

### Phase 7: Review-response loop — human approval required

After PR creation, reviewers will leave comments. **Never post a reply to a PR comment without explicit human review and approval of the reply text.** This applies to:

- Inline code comments
- Top-level review comments
- "Changes requested" review bodies
- Automated review bodies (Codex, bots) when the user is considering how to respond
- Re-review pings ("PTAL", "bumping this")

**The flow, every time:**

1. Fetch the feedback (via `pr-diagnostics` or `gh api`).
2. **Draft a proposed response in chat**, grouped by comment, each clearly labeled with the comment author + file:line.
3. Classify each proposed response: `Agree + fix`, `Agree + follow-up`, `Disagree + reasoning`, `Need clarification`, or `Ack only`.
4. For any `Disagree` or `Need clarification`: check with the human *first* whether the reasoning holds up before drafting public-facing text. The human may have context you don't.
5. For `Agree + fix`: make the code change, but **don't post "done" comments** until the fix is pushed and the human has approved the reply text.
6. **Wait for the human's explicit go-ahead** (`"post it"`, `"send"`, `"approved"`, or similar) before any `gh pr comment` / `gh api ... /comments` / reply-in-thread invocation. Silence is not approval.
7. If the human edits the drafted text, post *their* version, not yours.

**Never do any of the following autonomously:**
- Mark a review conversation as resolved
- Re-request review
- Promote the PR from draft to ready
- Post a reply, even a one-line "done" or "thanks"
- Edit the PR description in response to feedback (stage the diff for human review instead)

**Why this matters:** reviewer threads are part of the permanent record. A misaligned or presumptuous reply damages trust and creates rework. The marginal cost of one human review pass before posting is small; the cost of a bad reply is not.

**Scope note.** This rule is *specifically* about replying to comments. *Making* the requested code change still follows the normal loop (back to Phase 4 / 5 as needed). Only the **outgoing communication** is gated on human approval.

## Output contract

When this skill runs end-to-end, the user ends up with:

1. `./.ai-dev/<slug>-spec.md` — spec, rollout plan, error-handling consensus, observability plan.
2. (Optional) `./.ai-dev/<slug>-design.md` — if Phase 2 was needed.
3. Code written tests-first, strict TS, Clean Code / Clean Architecture.
4. A recorded pass through the Phase 5 verification gates (and a note in Testing if any were delegated to CI, e.g. persistent lint OOM).
5. A draft PR created via `commit-and-pr` mechanics, with:
   - A **concise, design-forward Changes section** that doesn't leak implementation.
   - An **AI Model Used** section using the required phrasing.
   - A Testing section that factually states what was added / run.
   - A rollout plan honoring the flag / safety decision from Phase 3a.
   - **Only business-relevant files staged** — no hitchhiking dotfiles / editor metadata / agent config.
   - Split into a **stack of 2-4 PRs** if the diff crossed the scope thresholds (or an explicit note explaining why one PR is appropriate).
6. Drafted (but **not yet posted**) replies for any reviewer comments, awaiting human approval per Phase 7.
7. (Optional) A drafted JIRA follow-up via `sai-jira-draft` for any refactor deferred from Phase 4.
8. (Optional) A **separate commit to the user's dotfiles repo** for any settings / agent-config / skill iteration that accumulated during the session and belongs there rather than in the business PR.

## Anti-patterns for this skill

- **Starting to code before the spec is confirmed.** The whole point is to catch misalignment before implementation cost.
- **Silently generating a spec and pretending the human wrote it.** If you drafted it, say so and wait for confirmation.
- **Skipping Phase 3 because "it feels obvious".** Error handling, rollout, and observability always feel obvious until prod — force the conversation anyway.
- **Punting observability to "follow-up".** Success metrics and error-discovery signals ship *with* the feature or the feature isn't ready.
- **Tests after the fact.** Tests written after the implementation mostly validate that the code does what it does — not that it does what the spec requires. Order matters.
- **Widening types to make errors go away.** If the type system is complaining, it usually knows something. Ask before loosening.
- **Over-commenting.** Every redundant comment is a future lie. Default to none.
- **Ignoring code hygiene.** Dense unreadable blocks, grab-bag modules, functions with five responsibilities, domain code reaching into transport — all ship as tech debt the reviewer has to flag. Apply readability / modularity / SOLID as you write, not as a post-hoc cleanup pass.
- **Leaking implementation into the description.** Reviewers read diffs. Tell them what they can't see.
- **Silently expanding PR scope while "refactoring along the way".** Surface the refactor or defer it — don't smuggle.
- **Omitting "through human discussions" from the AI Model line.** It's the signal of human accountability; its absence reads as a raw AI dump.
- **Inlining the full design doc into the PR description.** Link it. Keep the PR readable.
- **Re-implementing `commit-and-pr` rules here.** This skill augments — duplication means drift.
- **Skipping Phase 5 and relying on CI.** CI is the last line of defense, not the first. Format / lint / type / test issues discoverable locally should be fixed locally.
- **Running broad scopes before narrow ones.** If Gate 5a is red, running impacted-dependents is wasted signal. Fix narrow, then widen.
- **Sweeping all team-owned workspaces pre-push.** Gate 5c covers *impacted* packages, not the whole team surface. A blanket team sweep burns time locally and is what CI is for.
- **Including a team-owned workspace "just in case" when it isn't impacted.** Team ownership is a priority filter for workspaces already in the impacted set, not an instruction to run them unconditionally.
- **Retrying lint OOM indefinitely.** Five retries with elevated heap, then CI. No loops.
- **Responding to review comments without explicit approval.** The marginal cost of a human-review pass is small; a presumptuous reply damages trust.
- **Treating a "CI fix" as trivial when it isn't.** A 20-file change in response to a failing check is a feature, not a fix — route it back through the full loop.
- **Using `git add -A` / `git add .`.** Smuggles local settings, editor metadata, and agent config into business PRs. Always stage by name in this skill's flow.
- **Checking in `.gitignore` / `.claude/settings*.json` / `.vscode/` / `CLAUDE.md` / `.ai-dev/` / `.ai-reviews/` alongside a business change** unless the spec genuinely demands it. Those belong in the user's dotfiles repo and should be committed there separately.
- **Piling past 300 non-test lines or 6 dense functions without proposing a stack.** Reviewer attention is finite; a sprawling single PR gets a worse review than a coherent stack.
- **Stacking boilerplate.** If the diff is mostly rename / codemod / generated churn, don't split for splitting's sake — surface the line count but explain why one PR is fine.

## Quick-mode (for small changes)

For changes genuinely small enough that phases 2 + 3c are overkill (one-package tweak, contained bug fix, < ~50 lines), collapse to:

1. Confirm spec in one sentence.
2. Tests first, strict TS.
3. Rollout + error-handling consensus in a single short paragraph.
4. **Still run Phase 5a + 5b** (change + workspace scoped). Gate 5c (impacted dependents) is optional in quick-mode unless a team-owned workspace is in the impacted set, in which case run it for those workspaces.
5. Hand to `commit-and-pr` with the overridden Changes + AI Model style.
6. **Staging hygiene still applies** — stage by name, no local settings / editor metadata / agent config smuggled in.
7. **Phase 7 is never skipped.** Even in quick-mode, no reply is posted without human approval.

Use quick-mode only when the user explicitly signals small scope or when the diff demonstrably is. The default is the full loop.
