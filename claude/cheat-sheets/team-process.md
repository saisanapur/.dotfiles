# Cheat Sheet — Team Process Skills

Skills for the operating cadence of the Access Management team and broader Vanta processes — standups, forums, sprints, KB hygiene, retros, planning. All from `am-kb` (Access Management knowledge base) unless noted.

**Important runtime norms:**
- Project-agnostic skills must use `{PROJECT_DIR}` / `{PROJECT_KEY}` placeholders, not hardcoded names. Enforced by `.husky/pre-commit` in the kb repo.
- Daily-write skills must branch on a `dz/*` branch in `.worktrees/<skill>-<date>/` before the first Write.
- Track project tasks in `p-<project>/tasks.md`, not Claude's TaskCreate.
- End every KB session with `/finish-kb-session` — runs retro + commit + draft PR.
- Draft PRs only — humans squash-merge.

## Daily

| Skill | Trigger phrases | Purpose |
|---|---|---|
| `/today` | "today", "what should I do", "what's overdue", "morning checklist" | Read operating cadence; show ranked punch list of overdue rituals + urgent project items. <30 sec, <15 lines. |
| `/standup` | "standup", "fill the standup", or when Slack reminder fires | Draft daily async standup entry from git + GitHub PRs + Jira. **Does NOT write to the sheet** — Sai pastes. |
| `/forum-prep` | "forum prep", "prep for forum", "daily prep" | Daily forum agenda — only items needing synchronous judgment today. Recommend cancellation if 0 items. |
| `/project-status` | "project status", "snapshot project state" | Daily project snapshot to `p-<project>/planning/daily-status/<date>.md`. Trajectory, top risks, sprint goal, milestone drift. |

## Weekly

| Skill | Trigger phrases | Purpose |
|---|---|---|
| `risk-audit` | "risk audit", "audit the risks", auto-flagged on Friday | Friday risk register sweep. Stale entries → archive; unresolved → roll forward. |
| `kb-drift` | "kb drift", "lint the kb" | Find contradictions, stale references, orphan files, duplicates. Fix what's safe; surface the rest. |
| `reorganize-kb` | "reorganize kb", "audit hot tier" | Compact hot-tier files; move content to right tier (hot/warm/cold per CONTEXT_ECONOMY.md). |

## Per Sprint

| Skill | Trigger phrases | Purpose |
|---|---|---|
| `sprint-prep` | "sprint prep", "plan next sprint" | Day-1 sprint planning artifact. Pulls Jira, milestones, risks; drafts sprint plan doc. |
| `sprint-execution-update` | "sprint update", "execution update", "fill out the update", end-of-sprint | Friday biweekly execution update for leadership: parallel data-gathering agents → KB sync → timeline calc → lean update draft. |

## Per Project

| Skill | Trigger phrases | Purpose |
|---|---|---|
| `/new-kb` | "/new-kb", "start a new project KB" | Scaffold a new `p-<project>/` directory. Asks for project name, description, raw inputs. Run from inside the kb repo. |
| `/sync` | "sync the kb", "ingest from raw/" | Multi-source ingest (granola, jira, risk-register) — turn raw inputs into structured kb pages. Branches before write. |
| `extract-meeting-insights` | "ingest these meeting notes", "extract from this transcript" | Decisions / action items / open questions from notes. Files to `p-<project>/log.md` or research/. |

## Session lifecycle (KB)

| Skill | Trigger phrases | Purpose |
|---|---|---|
| `/finish-kb-session` | "finish", "wrap up", "done for now", `/finish-kb-session` | Single exit point: runs `/session-retro` → updates resume.md → consistency check → commit → draft PR. **Always draft.** |
| `/session-retro` | "retro", "end of session" | Extract durable team-generic learnings; classify (KB vs personal memory); update `_index.md` AI Working Norms. |

## Cross-functional / leadership

| Skill | Trigger phrases | Purpose |
|---|---|---|
| `grill-me` | "grill me on this", "stress test my plan" | Adversarial questioning. Use before forums or design reviews. |
| `point-eng-spec` | "point this spec" | Sizing for engineering specs — feeds sprint planning. |
| `point-oncall-tickets` | "point the oncall queue" | Sizing for on-call ticket queue — feeds capacity planning. |
| `vanta-staging` | "test on staging", "log into staging", "switch domain on staging" | Staging environment ops: impersonation links, domain switching, auditor flows. |
| `add-aws-secret` | "add a secret to SSM", "rotate this secret" | Generate the put-config.sh command to add/rotate AWS SSM secrets. |

## Cross-cutting reference

- **Operating cadence definitions:** `team/operating-cadence.md` in the kb repo
- **Project registry:** `AGENTS.md` in the kb repo
- **Context economy rules:** `CONTEXT_ECONOMY.md` in the kb repo (file budgets enforced by `.husky/pre-commit`)
- **Skill-authoring conventions:** `team/tools-and-skills.md#skill-authoring-conventions` in the kb repo

## Quick triggers — typical week

```
Mon AM    → /today → /standup → /forum-prep → forum
Mon-Thu   → /standup daily; /project-status after forum or ad-hoc
Fri PM    → risk-audit; kb-drift; sprint-execution-update (biweekly)
Sprint D1 → sprint-prep
Sprint D10→ sprint-execution-update
End of session → /finish-kb-session  (always)

Weekly meta → /sai-weakness synthesize  [MVP — Friday cron]
```
