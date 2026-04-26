# Obsidian monorepo aliases

# Ona injects user secrets (JIRA_API_TOKEN, AWS creds, API keys, etc.) into
# /etc/profile.d/ona-secrets.sh at environment start. Login shells source it
# automatically; non-login shells (e.g. Claude Code's Bash tool) do not.
# Sourcing here makes the secrets available in every shell that sources this
# aliases file (i.e. every shell once install.sh has linked it into .bashrc).
[ -f /etc/profile.d/ona-secrets.sh ] && source /etc/profile.d/ona-secrets.sh

# Auto-pull dotfiles + re-run install.sh on shell startup, rate-limited to once
# per 24h so opening many terminals isn't slow. Runs in background, silent on
# failure, only on the main branch with a clean tree (so in-progress edits are
# never disturbed). Skip with DOTFILES_NO_AUTOSYNC=1.
_dotfiles_autosync() {
  local dir="$HOME/dotfiles"
  local stamp="$dir/.last-autosync"
  [ -d "$dir/.git" ] || return 0
  [ "${DOTFILES_NO_AUTOSYNC:-}" = "1" ] && return 0
  # Once per 24h.
  if [ -f "$stamp" ] && [ "$(find "$stamp" -mtime -1 2>/dev/null)" ]; then
    return 0
  fi
  (
    cd "$dir" || exit 0
    # Only auto-pull on main with a clean tree — never disturb WIP edits.
    [ "$(git symbolic-ref --short HEAD 2>/dev/null)" = "main" ] || exit 0
    [ -z "$(git status --porcelain 2>/dev/null)" ] || exit 0
    if git pull --ff-only --quiet 2>/dev/null; then
      bash "$dir/install.sh" >/dev/null 2>&1 || true
      touch "$stamp"
    fi
  ) &
  disown 2>/dev/null || true
}
_dotfiles_autosync

alias obsidian='cd /workspaces/obsidian'
alias dfd='cd $HOME/dotfiles'
alias gs='git status -sb'
alias gl='git log --oneline --decorate --graph -20'
alias gd='git diff'
alias gdc='git diff --cached'
alias justpp='just post-pull'

# Turbo shortcuts (always scoped)
tt() {
  turbo typecheck -F "$1" --output-logs=errors-only
}

tl() {
  turbo lint -F "$1" --output-logs=errors-only
}

tu() {
  turbo unit-test -F "$1" --output-logs=errors-only
}

tb() {
  turbo build -F "$1" --output-logs=errors-only
}

# Common repo tasks
alias tg='turbo generate-types --output-logs=errors-only'
alias fmt='npx prettier --write'
alias lintf='npx eslint --fix'
alias jt='just unit-test'
alias jadd='just add-workspace-dependency'

# Guardrail helper: remind scoped turbo usage
thelp() {
  echo 'Usage: tt|tl|tu|tb <workspace>, e.g. tu @vanta/api-external'
}

# Start ngrok (pass service name)
ngs() {
  ngrok start "$1"
}

# Start integration with local impersonation disabled
stweb() {
  NO_LOCAL_IMPERSONATION_ENABLED=true just dev-start-web
}

stint() {
  local service="${1:?service required (e.g. zoom, slack, teams)}"
  shift
  NO_LOCAL_IMPERSONATION_ENABLED=true NGROK_URL="https://${service}.tunnel.vantaroo.com" just dev-start-integration "$@"
}

# -----------------------------------------------------------------------------
# Claude skill iteration helpers
#
# Skills live in two places:
#   WIP:       ~/dotfiles/claude-plugins/plugins/sai-wip/skills/<name>/
#   Monorepo:  /workspaces/obsidian/.claude/skills/<name>/
#
# Workflow: wip-skill-new <name>  →  iterate  →  promote-skill <name>
# -----------------------------------------------------------------------------

# Scaffold a new WIP skill in the sai-wip plugin.
wip-skill-new() {
  local name="${1:?skill name required, e.g. wip-skill-new my-idea}"
  local dir="$HOME/dotfiles/claude-plugins/plugins/sai-wip/skills/$name"

  if [ -e "$dir" ]; then
    echo "Already exists: $dir" >&2
    return 1
  fi

  mkdir -p "$dir"
  cat > "$dir/SKILL.md" <<EOF
---
name: $name
description: TODO one sentence — when to trigger and what this skill does. Be specific; this is what Claude matches against user requests.
---

# $name

## When to trigger
- TODO list the phrases or situations that should load this skill

## What to do
1. TODO
EOF

  cat > "$dir/NOTES.md" <<EOF
# $name — iteration notes

## Prompts that triggered the skill correctly

## Prompts that should have triggered but didn't

## Prompts that wrongly triggered

## Behavioral failures (skill triggered, but output was wrong)

## Open questions / edge cases to cover before promoting
EOF

  echo "Scaffolded $dir"
  echo "Edit $dir/SKILL.md to define the skill."
}

# Promote a proven WIP skill into the Obsidian monorepo's .claude/skills/.
# Copies everything except NOTES.md (notes stay in dotfiles for history).
# Leaves committing + PR to you.
promote-skill() {
  local name="${1:?skill name required, e.g. promote-skill my-idea}"
  local src="$HOME/dotfiles/claude-plugins/plugins/sai-wip/skills/$name"
  local dest="/workspaces/obsidian/.claude/skills/$name"

  if [ ! -d "$src" ]; then
    echo "Source skill not found: $src" >&2
    return 1
  fi
  if [ -e "$dest" ]; then
    echo "Destination already exists: $dest — delete it or pick a new name" >&2
    return 1
  fi

  mkdir -p "$dest"
  ( cd "$src" && tar -cf - --exclude='NOTES.md' . ) | ( cd "$dest" && tar -xf - )

  echo "Copied: $src -> $dest"
  echo
  echo "Next steps:"
  echo "  cd /workspaces/obsidian"
  echo "  git checkout -b \"\${BRANCH_PREFIX:-\$(gh api user --jq .login)}/skill-$name\""
  echo "  git add .claude/skills/$name"
  echo "  git commit -m 'Add $name skill'"
}

