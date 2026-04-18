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

# ---- VSCode user settings ----
link_with_backup "$DOTFILES_DIR/vscode/settings.json" "$HOME/.config/Code/User/settings.json"

# ---- Claude: user-scope settings (global across all workspaces) ----
link_with_backup "$DOTFILES_DIR/claude/user-settings.json" "$HOME/.claude/settings.json"

# ---- Claude: project-scope local settings for the Obsidian workspace ----
if [ -d "/workspaces/obsidian" ]; then
  link_with_backup "$DOTFILES_DIR/claude/obsidian-settings.local.json" "/workspaces/obsidian/.claude/settings.local.json"
fi

echo
echo "Done. Restart your shell or run: source $RC_FILE"
