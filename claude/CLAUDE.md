**CRITICAL**: When developing plans, designs, or research artifacts always store them in `.ai-dev` directories. Place the artifact in the closest subdirectory to the subject of the change. If not applicable, put in `.ai-dev` in the root of the repository.

Example directory: `packages/my-package/src/my-dir/.ai-dev/plans/2025-12-01-support-new-feature.md`.

## gsync — sync .ai-dev artifacts to Google Docs

`gsync` is a CLI in the obsidian repo (`npx gsync ...`, workspace `@vanta/gsync`) for syncing local markdown to Google Docs. Use it to share `.ai-dev` plans/designs with teammates as Google Docs while keeping the markdown as source of truth.

- One-time auth: `npx gsync auth login` (browser OAuth)
- Upload: `npx gsync upload path/to/.ai-dev/plans/foo.md [--folder <drive-folder-id-or-url>]`
- Pull comments back: `npx gsync comments path/to/foo.md` (or `--json`)
- Pull remote edits back: `npx gsync view path/to/foo.md --format markdown`
- Re-upload finalizes via `--publish` (sets frontmatter to prevent overwriting orphaned comments)

The CLI writes `gdrive_file_id` into the markdown's frontmatter on first upload, so subsequent commands resolve the local `.md` to its remote doc automatically.

@sai-operating.md
