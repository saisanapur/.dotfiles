# Obsidian Dotfiles (VSCode + AI Agents)

Personal dotfiles tailored for the Obsidian monorepo workflow.

## Structure

- `shell/obsidian-aliases.sh`: Handy shell aliases/functions
- `vscode/settings.json`: Workspace-safe VSCode defaults
- `vscode/extensions.txt`: Recommended extensions
- `agents/codex.md`: Codex working notes
- `agents/claude.md`: Claude working notes
- `install.sh`: Optional symlink installer

## Quick Start

```bash
cd /workspaces/obsidian/.dotfiles
./install.sh
```

Then reload your shell:

```bash
source ~/.bashrc
```

## Notes

- This repo avoids global destructive aliases.
- Commands are aligned with Obsidian AI rules (`just`, `turbo`, scoped tasks, `--output-logs=errors-only`).
