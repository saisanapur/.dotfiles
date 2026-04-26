# Cheat Sheet — SDLC Skills

Skills organized by software development lifecycle phase. For full details, see each skill's `SKILL.md`. Sources: `sai-wip` (personal marketplace), `am-kb` (Access Management knowledge base), `obsidian` (Vanta monorepo `.claude/skills/`), `superpowers` (plugin), `built-in` (Claude Code default).

## 1. Analysis (left half — historically underserved)

| Skill | Source | Trigger phrases | Purpose |
|---|---|---|---|
| `sai-product-opportunities` | sai-wip | "top opportunities to improve X", "UX wins in Y", "where are users getting stuck" | Ranked top-5 product/UX opportunities grounded in code, with effort/impact/feasibility per opportunity. |
| `point-eng-spec` | am-kb | "point this eng spec", "estimate eng spec X" | Read engineering spec; produce points/effort estimate with rationale. |
| `point-oncall-tickets` | am-kb | "point oncall tickets", "estimate oncall queue" | Estimate effort for on-call ticket queue. |
| `extract-meeting-insights` | am-kb | "extract from meeting notes", "ingest these notes" | Pull decisions, action items, open questions from meeting transcripts/notes. |
| `grill-me` | am-kb | "grill me on this", "stress-test my plan" | Adversarial questioning to expose weak assumptions in a plan or design. |

## 2. Design

| Skill | Source | Trigger phrases | Purpose |
|---|---|---|---|
| `sai-solution-options` | sai-wip | "how should we approach X", "what are the trade-offs between A and B", "feasibility of Z" | Structured 2-4 option analysis with effort bands + recommendation against constraints. |
| `superpowers:brainstorming` | superpowers | "brainstorm X", "let's explore options" | Open-ended exploration → design doc; auto-checked for visual companion + spec gate. |
| `superpowers:writing-plans` | superpowers | "write the implementation plan", "plan this out" | Bite-sized task plan from a spec; TDD-shaped, fully detailed steps. |
| `walk-cuj` | built-in | "walk through CUJ", "test critical user journey" | Multi-agent automated walk through a Critical User Journey with screenshots + evaluator. |

## 3. Spec / Plan

| Skill | Source | Trigger phrases | Purpose |
|---|---|---|---|
| `sai-jira-draft` | sai-wip | "draft a jira for X", "ticket content for Y" | Markdown ticket draft (Title, Background, Requirements, Out of Scope, AC). Does NOT file. |
| `superpowers:test-driven-development` | superpowers | "TDD this", "write tests first" | Test-first discipline for the implementation phase. |

## 4. Implementation

| Skill | Source | Trigger phrases | Purpose |
|---|---|---|---|
| `sai-pr-creation` | sai-wip | "implement X", "build Y", "ship feature Z", "create a PR for this", "let's work on [ticket]" | Opinionated 7-phase loop: spec → design (if needed) → consensus → tests-first impl → verification gates → PR → review-response. |
| `frontend-dev` | obsidian | "build a React component", "add a page", "fix this UI bug" | Frontend conventions: useEffect, useSuspenseQuery, Apollo cache, Alpaca design system. Invoke alongside graphql-dev if change is full-stack. |
| `graphql-dev` | obsidian | "add a resolver", "schema change", "new mutation" | GraphQL schema/resolver work: `#graphql` imports, cache key fields, fragment colocation. |
| `backend-testing` | obsidian | "add backend tests", "test this resolver" | Backend test conventions: `mockGraphQLResolveInfo`, `mockExpressRequest`, `useSandbox`, type-safe Chai. |
| `frontend-testing` | obsidian | "add component test", "test this UI" | Frontend testing: Vitest, mock providers, GraphQL-backed UI. |
| `commit-and-pr` | obsidian | "commit these changes", "create the PR", "ship it" | Mechanics: rebase, draft-only, template sections, security label. Invoked from `sai-pr-creation` Phase 6. |
| `superpowers:using-git-worktrees` | superpowers | "use a worktree", "isolate this work" | Worktree creation with safety verification. |
| `vanta-codemod` | obsidian | "codemod this across the repo", "rename X everywhere" | Automate repetitive transformations with dry-run validation. |
| `add-tests` | am-kb | "add tests for this" | Generic test addition (cross-stack). |

## 5. Review

| Skill | Source | Trigger phrases | Purpose |
|---|---|---|---|
| `sai-senior-review` | sai-wip | "senior review", "staff review", "deep review", "review this like a Vanta senior" | Holistic judgment review: architecture, reliability, observability, security, rollout safety. Saves to `.ai-reviews/`. |
| `pr-diagnostics` | obsidian | "what's blocking this PR", "fix CI", "why is this failing", "address review feedback" | Structured CI-failure + reviewer-comment analysis with file:line attribution. |
| `superpowers:requesting-code-review` | superpowers | "review my work before merge", "verify this meets requirements" | Pre-merge subagent review against spec. |
| `superpowers:receiving-code-review` | superpowers | "received review feedback", "address these review comments" | Apply technical rigor to review feedback rather than performative agreement. |
| `superpowers:verification-before-completion` | superpowers | "verify before declaring done" | Run verification commands; evidence before assertions. |
| `code-simplifier` | obsidian (agent) | invoked by Sai or via `sai-pr-creation` Phase 4 | Simplify and refine code while preserving functionality. |
| `alpaca-audit` | obsidian | "audit Alpaca compliance", "check design system usage" | AST-based 5-gate audit of Alpaca design system non-negotiables. |
| `/review` | built-in | `/review` | Workspace-built rule-based review (CODE_REVIEW.*.md). |
| `/security-review` | built-in | `/security-review` | Security review of pending branch changes. |

## 6. Testing & Integration

| Skill | Source | Trigger phrases | Purpose |
|---|---|---|---|
| `test-plan` | am-kb | "draft a test plan" | Plan test coverage for a feature. |
| `run-test-plan` | am-kb | "run the test plan" | Multi-agent execution of a written test plan with executor/inferrer/verifier agents. |
| `find-playwright-flake` | obsidian | "this Playwright test is flaky", "find timing issues" | Static + execution analysis of Playwright test flakiness. |

## 7. Launch / Maintenance

| Skill | Source | Trigger phrases | Purpose |
|---|---|---|---|
| `sai-launch-observability` | sai-wip | "metrics for launching X", "observability plan for Y", "alerting for Z rollout" | Structured observability plan: existing-signal inventory, decision-driving metrics, leading vs lagging indicators, 3 dashboard sketches. |
| `alerting` | obsidian | "create a monitor", "review this alert", "what should we alert on" | Symptom-based alerting: golden signals, CASE framework. |
| `pup` / `datadog` | obsidian | "query Datadog", "search logs for X", "check this monitor" | Unified Datadog CLI for logs/traces/metrics/monitors. |
| `web-container-debug` | obsidian | "why was this web container killed", "investigate health-check timeout" | ECS web/web-admin container failure investigation. |
| `debug-bullmq-worker` | obsidian | "investigate worker OOM", "why did this job stall" | BullMQ worker container failures. |

## 8. Cross-cutting / discipline

| Skill | Source | Trigger phrases | Purpose |
|---|---|---|---|
| `superpowers:systematic-debugging` | superpowers | "systematically debug this" | Reproduce, isolate, fix sequence — never guess. |
| `superpowers:finishing-a-development-branch` | superpowers | "wrap up this branch", "what's next" | Structured options for merge / PR / cleanup. |
| `superpowers:dispatching-parallel-agents` | superpowers | (auto-invoked from sai-* skills when work parallelizes) | Parallel agent dispatch for independent sub-work. |
| `simplify` | built-in | `/simplify` | Review changed code for reuse, quality, efficiency; fix issues. |

---

## Quick triggers — daily reach

Most-used in a typical Sai SDLC pass:

```
1. Analysis     → sai-product-opportunities (or grill-me)
2. Design       → sai-solution-options (gsync upload to gdocs for alignment)
3. Spec         → sai-jira-draft → jira-operations:jira to file
4. Implement    → sai-pr-creation (orchestrates the rest)
5. Review       → sai-senior-review (saves to .ai-reviews/)
6. Launch       → sai-launch-observability (plan) → alerting / pup (deploy)
7. Reflect      → /sai-weakness log "<observation>"  [MVP — coming]
```
