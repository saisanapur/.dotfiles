---
name: sai-hello
description: Use when the user types "sai hello", "sai bootstrap", or asks whether their personal WIP skills plugin (sai-wip) is loaded and working. Confirms the plugin is installed and lists the other skills currently living in it.
---

# sai-hello

A no-op skill that exists only to verify the `sai-wip` plugin is loaded into the current Claude Code session.

## When to trigger

- User says "sai hello"
- User says "sai bootstrap"
- User asks "is my WIP plugin loaded?" / "is sai-wip working?"

## What to do

1. Respond with: `sai-wip plugin is loaded. Source: ~/dotfiles/claude-plugins/plugins/sai-wip/`
2. List the other skills currently available in the plugin by running `ls ~/dotfiles/claude-plugins/plugins/sai-wip/skills/` and reporting the directory names (excluding `sai-hello` itself).
3. Remind the user of the promotion path: when a skill is ready, copy the `SKILL.md` (and any supporting files) into the Obsidian monorepo at `.claude/skills/<name>/`, then open a PR.
