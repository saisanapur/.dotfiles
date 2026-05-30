**CRITICAL**: When developing plans, designs, or research artifacts always store them in `.ai-dev` directory in the root of the repository. Create directory when not present. When multiple related files are created put them under a newly created directory under `.ai-dev`. New folder can have a meaningful name based on conversation context.

After creating docs check if they need to go to Access Management Knowledge Base or Google Drive via gsync (see below).

## Access Management Knowledge Base (AM KB)

The **Access Management Knowledge Base** is the team’s shared docs and Claude skills repo: [VantaInc/access-mgmt-knowledge-base](https://github.com/VantaInc/access-mgmt-knowledge-base). It is cloned on most dev nodes and on the laptop.

**Where to find it on disk:**

- **Dev nodes (Codespaces / remote):** `/workspaces/access-mgmt-knowledge-base` (sibling to `/workspaces/obsidian` and other workspace repos). `install.sh` clones it there when missing; `amkb` and `am-kb-pull` assume this path.
- **Laptop and local checkouts:** usually cloned as a **sibling of the repo you are in** — the parent directory of most GitHub repos (e.g. if the project is `~/Documents/GitHub/obsidian`, AM KB is `~/Documents/GitHub/access-mgmt-knowledge-base`). Resolve with `../access-mgmt-knowledge-base` from the project root when present.

Prefer AM KB for durable team process, runbooks, and skills that should be shared across Access Management repos. Use `.ai-dev` in the current repo for work-in-progress plans tied to that codebase; promote to AM KB or Google Drive when the artifact is ready to share (see gsync below).

## gsync — sync .ai-dev artifacts to Google Docs

`gsync` is a CLI in the obsidian repo (`npx gsync ...`, workspace `@vanta/gsync`) for syncing local markdown to Google Docs. Use it to share `.ai-dev` plans/designs with teammates as Google Docs while keeping the markdown as source of truth.

- One-time auth: `npx gsync auth login` (browser OAuth)
- Upload: `npx gsync upload path/to/.ai-dev/plans/foo.md [--folder <drive-folder-id-or-url>]`
- Pull comments back: `npx gsync comments path/to/foo.md` (or `--json`)
- Pull remote edits back: `npx gsync view path/to/foo.md --format markdown`
- Re-upload finalizes via `--publish` (sets frontmatter to prevent overwriting orphaned comments)

The CLI writes `gdrive_file_id` into the markdown's frontmatter on first upload, so subsequent commands resolve the local `.md` to its remote doc automatically.



@sai-operating.md
