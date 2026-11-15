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

### Function readability and decomposition

Keep functions readable as a clear sequence of intent at one level of abstraction. When a function mixes distinct responsibilities—such as validation, data loading, business decisions, and response mapping—decompose cohesive steps into well-named private methods or pure functions as appropriate. Keep orchestration concise and implementation details in the owning helper. Review the entire function for clarity; simplifying one conditional does not address an otherwise overloaded method. Preserve behavior and verify through public-contract tests rather than helper structure or call order. Avoid arbitrary line limits, trivial wrappers, and excessive fragmentation; extract only when it makes the code easier to understand.

### Human-review readability

Keep anything presented for human review concise and quick to scan. Focus on scope, important interfaces, responsibilities, decisions, and essential behavioral tests. Show public and private method signature stubs with short high-level pseudocode when they clarify the design; avoid full implementation listings. For pending decisions, present the options, their trade-offs, and a recommendation. Avoid redundant agent instructions and repeated constraints; link shared guidance and keep execution mechanics in the worker handoff. For ticket dispatch, settle interfaces and the high-level breakdown in the review packet before launching the worker.

### Comments and interface intent

Do not put caller-specific product flows, eligibility rules, or usage instructions on lower-layer APIs. Describe only the contract and non-obvious mechanics owned by that layer. Do not repeat permission decorators or self-evident signatures in prose unless repository tooling requires it. Prefer no comment over a redundant one.

Name filters explicitly and keep related selection criteria in a small typed `filters` object when appropriate; add only supported fields, not speculative operators or a generic framework. Make filtering and result construction clear at the call site. Give a cohesive result-building helper ownership of the complete collection when that keeps orchestration readable. Name tests in plain English for observable behavior; avoid phrases such as “contracted identity” or “adapts provenance.”
