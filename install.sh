#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="/workspaces/obsidian/.dotfiles"
BASHRC="$HOME/.bashrc"
ALIASES_LINE='[ -f /workspaces/obsidian/.dotfiles/shell/obsidian-aliases.sh ] && source /workspaces/obsidian/.dotfiles/shell/obsidian-aliases.sh'

if ! grep -Fq "$ALIASES_LINE" "$BASHRC"; then
  echo "$ALIASES_LINE" >> "$BASHRC"
  echo "Added Obsidian aliases to $BASHRC"
else
  echo "Aliases line already present in $BASHRC"
fi

mkdir -p "$HOME/.config/Code/User"
ln -sf "$DOTFILES_DIR/vscode/settings.json" "$HOME/.config/Code/User/settings.json"

echo "Linked VSCode settings and shell aliases."
echo "Run: source ~/.bashrc"
