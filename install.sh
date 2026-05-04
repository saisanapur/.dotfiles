#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
ALIASES_FILE="$DOTFILES_DIR/shell/obsidian-aliases.sh"
ALIASES_LINE="[ -f $ALIASES_FILE ] && source $ALIASES_FILE"

# ---- Shell rc: source the obsidian-aliases file ----
if [[ "${SHELL:-}" == *"zsh"* ]]; then
  RC_FILE="$HOME/.zshrc"
else
  RC_FILE="$HOME/.bashrc"
fi

touch "$RC_FILE"

if ! grep -Fq "$ALIASES_LINE" "$RC_FILE"; then
  echo "$ALIASES_LINE" >> "$RC_FILE"
  echo "Added Obsidian aliases to $RC_FILE"
else
  echo "Aliases line already present in $RC_FILE"
fi

# ---- Helper: back up a file before replacing it with a symlink ----
link_with_backup() {
  local target="$1"
  local link_path="$2"

  # If the link already points at the right target, nothing to do.
  if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$target" ]; then
    echo "Already linked: $link_path -> $target"
    return
  fi

  # Preserve anything that was there before (regular file or differently-pointing symlink).
  if [ -e "$link_path" ] || [ -L "$link_path" ]; then
    local backup="${link_path}.pre-dotfiles-$(date +%Y%m%d-%H%M%S)"
    mv "$link_path" "$backup"
    echo "Backed up existing $link_path -> $backup"
  fi

  mkdir -p "$(dirname "$link_path")"
  ln -s "$target" "$link_path"
  echo "Linked $link_path -> $target"
}

# ---- Global gitignore (applies to every repo, including obsidian) ----
link_with_backup "$DOTFILES_DIR/git/gitignore_global" "$HOME/.gitignore_global"
git config --global core.excludesfile "$HOME/.gitignore_global"
echo "Set git config --global core.excludesfile -> $HOME/.gitignore_global"

# ---- VSCode user settings ----
link_with_backup "$DOTFILES_DIR/vscode/settings.json" "$HOME/.config/Code/User/settings.json"

# ---- Claude: user-scope settings (global across all workspaces) ----
link_with_backup "$DOTFILES_DIR/claude/user-settings.json" "$HOME/.claude/settings.json"

# ---- Claude: user-scope CLAUDE.md (global instructions across all workspaces) ----
link_with_backup "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

# ---- Claude: project-scope local settings for the Obsidian workspace ----
if [ -d "/workspaces/obsidian" ]; then
  link_with_backup "$DOTFILES_DIR/claude/obsidian-settings.local.json" "/workspaces/obsidian/.claude/settings.local.json"
fi

# ---- Codex CLI: user-scope config (approval_policy, sandbox_mode, hooks toggle) ----
link_with_backup "$DOTFILES_DIR/codex/config.toml" "$HOME/.codex/config.toml"

# ---- Access Management KB: clone + per-skill symlinks ----
# AM KB hosts shared team skills (run-test-plan, new-kb, sprint-prep, etc.) at
# .claude/skills/. The run-test-plan skill in particular hardcodes the
# sibling-of-obsidian path for its scripts/agents, so cloning at this exact
# location is required.
#
# Skill *discovery* is separate from cloning: Claude Code only auto-discovers
# skills under installed plugins, <project>/.claude/skills/, or
# ~/.claude/skills/. Symlinking each AM KB skill into ~/.claude/skills/ surfaces
# them in every session (including outside obsidian) without forking the AM KB
# upstream. The skill SKILL.md files re-resolve to their AM KB sibling for
# scripts/agents, so the symlinks stay thin pointers.
AM_KB_DIR="/workspaces/access-mgmt-knowledge-base"
if [ -d /workspaces ] && [ ! -d "$AM_KB_DIR" ]; then
  if gh repo clone VantaInc/access-mgmt-knowledge-base "$AM_KB_DIR" >/dev/null 2>&1; then
    echo "Cloned access-mgmt-knowledge-base -> $AM_KB_DIR"
  else
    echo "Skipped AM KB clone (gh auth may be missing or no /workspaces dir)"
  fi
fi

if [ -d "$AM_KB_DIR/.claude/skills" ]; then
  mkdir -p "$HOME/.claude/skills"
  for skill_path in "$AM_KB_DIR"/.claude/skills/*/; do
    [ -d "$skill_path" ] || continue
    skill_name="$(basename "$skill_path")"
    link_path="$HOME/.claude/skills/$skill_name"
    if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "${skill_path%/}" ]; then
      continue
    fi
    if [ -e "$link_path" ] || [ -L "$link_path" ]; then
      mv "$link_path" "${link_path}.pre-am-kb-$(date +%Y%m%d-%H%M%S)"
    fi
    ln -s "${skill_path%/}" "$link_path"
    echo "Linked AM KB skill: $link_path -> ${skill_path%/}"
  done
fi

echo
echo "Done. Restart your shell or run: source $RC_FILE"
