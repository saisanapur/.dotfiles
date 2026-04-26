# Cheat Sheet — Meta / Ops Skills

Skills for harness operations, dev environment, Claude Code itself, debugging, and external assist (Codex, etc.). Things that aren't directly producing customer value but reduce business continuity risk in how you work.

## Personal harness (sai-wip + dotfiles)

| Skill / Artifact | Source | Trigger | Purpose |
|---|---|---|---|
| **`sai-weakness log "<obs>"`** *(MVP)* | sai-wip | "log a weakness", "register: <text>", `/sai-weakness log <text>` | Append a dated, inline-tagged entry to `~/dotfiles/claude/sai-weakness-register.md`. ~30 sec capture. |
| **`sai-weakness synthesize`** *(MVP)* | sai-wip | Friday cron, `/sai-weakness synthesize`, "synthesize the register" | Roll up entries into themes; route follow-ups (harness edits / prompting best-practices / product opportunities / team-process suggestions). |
| **`sai-operating.md`** *(MVP)* | dotfiles | auto-loaded every session | Personal North Star, principles, lenses, anti-patterns, DoD checklist, current focus. |
| **`sai-schedules.md`** *(MVP)* | dotfiles | manual reference | Source of truth for personal cron entries; includes re-arm commands if `/schedule` doesn't survive Ona restarts. |

## Claude Code configuration

| Skill | Trigger phrases | Purpose |
|---|---|---|
| `update-config` | "allow X command", "add permission", "set DEBUG=true", "when claude stops show X" | Modify `settings.json` / `settings.local.json` — permissions, env vars, hooks. **Use this for "from now on…" automations** (memory cannot fulfill those). |
| `keybindings-help` | "rebind ctrl+s", "add a chord shortcut", "customize keybindings" | Edit `~/.claude/keybindings.json`. |
| `less-permission-prompts` | "reduce permission prompts" | Scan transcripts for common safe Bash/MCP calls; add prioritized allowlist to project `.claude/settings.json`. |
| `marketplace-vanta` | "what Vanta plugins exist", "enable plugin X", "find a plugin-gated skill" | Browse, enable, disable Vanta's local Claude plugins. |

## Schedules / loops / triggers

| Skill | Trigger phrases | Purpose |
|---|---|---|
| `loop` | `/loop 5m /foo`, `/loop /bar` (no interval = self-paced) | Run a prompt or slash command on a recurring interval. |
| `schedule` | "schedule X every Y", `/schedule list`, `/schedule add ...` | Cron-style scheduled remote agents. **Used by sai-weakness-friday MVP.** |

## Debugging / production ops

| Skill | Trigger phrases | Purpose |
|---|---|---|
| `pr-diagnostics` | "what's blocking this PR", "fix CI", "address reviewer feedback" | Structured CI-failure + comment analysis; sub-agents pinpoint to file:line. |
| `pup` / `datadog` | "query Datadog", "search logs", "check this monitor", "trace this request" | Unified Datadog CLI: logs, traces, metrics, monitors, events. Includes colon escaping for task ARNs, jq extraction, @ prefix on custom fields. |
| `web-container-debug` | "investigate this web container failure", "why was the container killed" | ECS web/web-admin container failures: OOM, health-check timeouts, event-loop blocking. Two modes: specific task ARN or batch over time range. |
| `debug-bullmq-worker` | "investigate worker OOM", "why did this job stall" | BullMQ worker container failures. Matches "Starting job" / "Completed job" / "Failed job" pairs. |
| `find-playwright-flake` | "this Playwright test is flaky", "find timing issues" | Static + execution analysis of Playwright tests. |
| `superpowers:systematic-debugging` | "systematically debug this", "what's the root cause" | Reproduce, isolate, fix — never guess. |

## Vanta dev environment

| Skill | Trigger phrases | Purpose |
|---|---|---|
| `vanta-dev-server` | "start the dev server", "tail logs for service X", "check what's running" | Local dev services management: detect running, start groups, tail, debug. **Local only — see vanta-staging for staging.** |
| `vanta-staging` | "test on staging", "log in as user X on staging", "switch domain" | Staging ops: impersonation links, magic-link login, domain switching, cross-domain access. |

## Codemods / migrations / refactors

| Skill | Trigger phrases | Purpose |
|---|---|---|
| `vanta-codemod` | "rename X everywhere", "codemod this transform" | Sequential workflow: check existing, dry-run, validate, execute. |
| `extract-package` | "extract this directory into its own package", "split this package" | Dependency analysis → strategy → edge severing → migration. |
| `infer-lean-doc` | "fix typecheck errors after swap-lean-doc-types script" | Type-only fixups after the Mongoose facade migration. **Temporary skill** (firebreak migration). |
| `brand-user-types` | "narrow this string ID to AuthUserId" | Refactor raw string IDs to branded types. |
| `zod-isolated-declarations` | "fix TS9010 on this Zod schema" | Type annotations for exported Zod variables. |

## External assist

| Skill | Trigger phrases | Purpose |
|---|---|---|
| `codex:rescue` | "stuck — get Codex's opinion", "second pass via Codex", "rescue this" | Delegate to Codex CLI for second-opinion implementation, deeper diagnosis, or substantial coding handoff. **Use when stuck or want a second implementation.** |
| `codex:setup` | "is Codex set up", "configure Codex CLI" | Check Codex CLI readiness; toggle stop-time review gate. |

## Plan / spec / brainstorm orchestration

| Skill | Trigger phrases | Purpose |
|---|---|---|
| `superpowers:brainstorming` | "brainstorm X", "let's design Y" | Idea → design doc with visual companion option. **HARD GATE: no implementation until design is approved.** |
| `superpowers:writing-plans` | "write the implementation plan", "plan this out from spec" | Spec → bite-sized TDD plan saved to plans dir. |
| `superpowers:executing-plans` | "execute the plan inline", "batch this with checkpoints" | Run a plan in-session with checkpoints. |
| `superpowers:subagent-driven-development` | "execute via subagents", "fresh subagent per task" | One subagent per plan task; review between tasks. **Recommended for parallelizable plans.** |
| `superpowers:dispatching-parallel-agents` | (auto-invoked from sai-* skills when work parallelizes) | Multi-agent dispatch when 2+ tasks are truly independent. |
| `superpowers:using-git-worktrees` | "use a worktree", "isolate this work" | Worktree creation with safety checks. |
| `superpowers:test-driven-development` | "TDD this" | Red-green-refactor discipline. |
| `superpowers:verification-before-completion` | "verify before declaring done" | Evidence before assertions; runs commands and checks output. |
| `superpowers:finishing-a-development-branch` | "wrap up this branch" | Structured options for merge / PR / cleanup. |
| `superpowers:requesting-code-review` | "review my work" | Pre-merge subagent review. |
| `superpowers:receiving-code-review` | "address these review comments" | Apply technical rigor to review feedback. |
| `superpowers:using-superpowers` | (auto-invoked at session start) | Establishes how to find and use superpowers skills. |
| `superpowers:writing-skills` | "create a new skill", "edit this skill" | Skill authoring + verification. |

## Memory / auto-memory

| Mechanism | Path | Purpose |
|---|---|---|
| User memory | `/home/vscode/.claude/projects/-workspaces-obsidian/memory/` | Persistent file-based memory across conversations. Index in `MEMORY.md` (loaded into every session, capped at 200 lines). Types: user / feedback / project / reference. |
| Operating doc | `~/dotfiles/claude/sai-operating.md` *(MVP)* | Static principles + lenses + DoD checklist + current focus. |
| Weakness register | `~/dotfiles/claude/sai-weakness-register.md` *(MVP)* | Personal log; weekly synthesis routes follow-ups. |

## gsync (markdown ↔ Google Docs)

```bash
npx gsync auth login                              # one-time OAuth
npx gsync upload path/to/.ai-dev/foo.md           # first upload (writes gdrive_file_id frontmatter)
npx gsync upload path/to/foo.md --publish         # finalize (prevents orphaned-comment overwrite)
npx gsync view path/to/foo.md --format markdown   # pull remote edits
npx gsync comments path/to/foo.md                 # list comments
```

Use for sharing `.ai-dev/` plans/designs as gdocs while keeping markdown as source of truth.

## When stuck

1. **Try a different skill.** `/sai-weakness log` the friction and try a fresh approach.
2. **Codex rescue.** `codex:rescue` for a second-opinion / deeper diagnosis pass.
3. **Brainstorm.** Drop back to `superpowers:brainstorming` if the problem is unclear.
4. **Systematic debugging.** `superpowers:systematic-debugging` if you're guessing.
5. **Ask a human.** When all else fails — Slack or pair.

## Quick triggers — meta hygiene

```
Daily   → /today (delegates to other skills)
Friday  → /sai-weakness synthesize  [MVP — automated cron]
Stuck   → codex:rescue OR superpowers:systematic-debugging
Setup   → /update-config OR /less-permission-prompts
```
