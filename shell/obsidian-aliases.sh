# Obsidian monorepo aliases

alias obsidian='cd /workspaces/obsidian'
alias dfd='cd /workspaces/obsidian/.dotfiles'
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

