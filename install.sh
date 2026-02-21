#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="~/dotfiles"
ALIASES_FILE="$DOTFILES_DIR/shell/obsidian-aliases.sh"
ALIASES_LINE="[ -f $ALIASES_FILE ] && source $ALIASES_FILE"

# Detect shell rc file
if [[ "$SHELL" == *"zsh"* ]]; then
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

mkdir -p "$HOME/.config/Code/User"
ln -sf "$DOTFILES_DIR/vscode/settings.json" "$HOME/.config/Code/User/settings.json"

echo "Done. Restart your shell or run: source $RC_FILE"
