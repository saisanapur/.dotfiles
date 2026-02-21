# Claude Notes for Obsidian

## Preferred Workflow

1. Read `.ai-rules/codebase-foundations.md` before coding changes.
2. Run `just post-pull` if environment looks stale.
3. Use scoped turbo tasks with `--output-logs=errors-only`.
4. Format/lint changed files before summarizing.
5. Run relevant unit tests.

## Useful Commands

- `just pp`
- `turbo unit-test -F <workspace> --output-logs=errors-only`
- `turbo build -F <workspace> --output-logs=errors-only`
- `just add-workspace-dependency <consumer> <dependency>`
