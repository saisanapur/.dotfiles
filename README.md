# Obsidian Dotfiles (VSCode + AI Agents)

Personal dotfiles tailored for the Obsidian monorepo workflow.

## Structure

- `shell/obsidian-aliases.sh` — shell aliases/functions (turbo shortcuts, skill helpers)
- `vscode/settings.json` — workspace-safe VSCode defaults
- `vscode/extensions.txt` — recommended extensions
- `agents/claude.md` — Claude working notes
- `agents/codex.md` — Codex working notes
- `claude/user-settings.json` — Claude Code **user-scope** settings (→ `~/.claude/settings.json`)
- `claude/obsidian-settings.local.json` — Claude Code **project-scope** local settings for the Obsidian repo (→ `/workspaces/obsidian/.claude/settings.local.json`)
- `claude-plugins/` — personal Claude marketplace (`sai-personal`) hosting the `sai-wip` plugin; see [`claude-plugins/README.md`](claude-plugins/README.md)
- `install.sh` — idempotent symlink installer with automatic backups

## Quick Start

```bash
cd ~/dotfiles
./install.sh
source ~/.bashrc
```

`install.sh` is safe to re-run: each symlink either already points at the right target (no-op), or the existing file is renamed to `<path>.pre-dotfiles-<timestamp>` before linking.

## Claude Code setup

`claude/user-settings.json` declares the `sai-personal` marketplace and auto-enables the `sai-wip` plugin, so every Claude Code session in any workspace has access to your WIP skills with no manual `/plugin install` step.

See [`claude-plugins/README.md`](claude-plugins/README.md) for the skill iteration workflow: scaffold a new skill with `wip-skill-new <name>`, iterate, then promote with `promote-skill <name>` once it's proven.

## Notes

- No destructive aliases.
- Commands align with Obsidian AI rules (`just`, `turbo`, scoped tasks, `--output-logs=errors-only`).
- `install.sh` never force-overwrites: previous files become `*.pre-dotfiles-<timestamp>` backups.
