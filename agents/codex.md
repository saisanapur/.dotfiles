# Codex Notes for Obsidian

## Fast Command Set

- Sync deps: `just post-pull`
- Generate types: `turbo generate-types --output-logs=errors-only`
- Scoped typecheck: `turbo typecheck -F <workspace> --output-logs=errors-only`
- Scoped lint: `turbo lint -F <workspace> --output-logs=errors-only`
- Scoped tests: `turbo unit-test -F <workspace> --output-logs=errors-only`
- Changed-file format: `npx prettier --write <files>`
- Changed-file lint fix: `npx eslint --fix <files>`

## Guardrails

- Never run `tsc` directly.
- Keep turbo commands scoped (`-F`).
- Workspace-level typecheck/lint only on explicit request.
- Escalate immediately on missing tooling or blocked commands.
