# sai-personal Claude marketplace

Personal Claude Code marketplace hosted inside my dotfiles repo. Used as a staging area for work-in-progress skills before they graduate to the Obsidian monorepo at `.claude/skills/`.

## Structure

```
claude-plugins/
  .claude-plugin/
    marketplace.json        # declares the marketplace + plugin list
  plugins/
    sai-wip/                # the only plugin, hosts all WIP skills
      .claude-plugin/
        plugin.json
      skills/
        <skill-name>/
          SKILL.md          # the skill itself
          NOTES.md          # iteration notes (not read by Claude)
```

## One-time setup

In Claude Code, from any session:

```
/plugin marketplace add ~/dotfiles/claude-plugins
/plugin install sai-wip@sai-personal
```

Verify it worked with `ls ~/dotfiles/claude-plugins/plugins/sai-wip/skills/` — the skills listed there should be loadable in a new Claude Code session (check the Manage Plugins UI in the VSCode extension, or use `/plugin list` in the CLI).

## Iteration loop

1. Add or edit a skill under `plugins/sai-wip/skills/<name>/SKILL.md`.
2. Use it in a real Claude Code task.
3. Capture prompts-that-worked and failure transcripts in the adjacent `NOTES.md`.
4. Repeat until stable — at least a week of real use before promoting.
5. Copy the `SKILL.md` (and any supporting files) into `/workspaces/obsidian/.claude/skills/<name>/` in the monorepo, open a PR.
6. Delete the version under `plugins/sai-wip/skills/` once the monorepo version is merged.

## Why this layout

- **Dotfiles repo**: private, already pulled into every Ona environment.
- **Marketplace, not symlinks**: Claude Code's plugin system expects marketplaces; symlinks into `~/.claude/plugins/` would bypass its cache/registration machinery.
- **Separate from `~/dotfiles/claude/`**: that folder hosts `obsidian-settings.local.json` (linked into the Obsidian repo). Keeping plugins separate avoids accidental cross-linking.
