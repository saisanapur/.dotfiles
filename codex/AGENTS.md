# Personal Codex instructions

## GitHub authentication in dev environments

- Use the existing environment authentication for `gh`; do not request an interactive `gh auth login`.
- Check `gh auth status` in the target environment before GitHub work. A failure in a noninteractive shell alone does not establish that credentials are missing.
- If the first check fails, retry `bash -ic 'gh auth status'`. Interactive Bash startup can load `GH_TOKEN` even when the agent's default shell does not inherit it.
- When that succeeds, run authorized GitHub CLI commands in the same workspace through `bash -ic '<command>'`. For example: `bash -ic 'gh pr view 211965 --repo VantaInc/obsidian'`.
- If both checks fail, report the errors from both shell contexts and ask for the existing environment authentication to be restored. Do not ask for a token in chat, print its value, or copy it into configuration files.
- Treat command approval-policy rejections separately from authentication failures. Do not wrap a rejected command or switch APIs to evade an approval requirement.

## User preference: code and PR quality

Across all PRs, apply Robert C. Martin’s Clean Code and Clean Architecture principles pragmatically: intention-revealing names, small cohesive functions, straightforward control flow and guard clauses, clear responsibilities and package boundaries, and behavior-focused tests. Prefer simple existing abstractions; do not create layers or helpers merely to satisfy a pattern. Review readability before publication, including confusing ternaries, repeated null checks, and mixed levels of abstraction. Preserve repository conventions and explicit user-approved contracts.
