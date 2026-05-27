# GSD — Get Shit Done Redux

> Meta-prompting and context engineering system for AI code editors.

- [Overview](README.md)
- [[ARCHITECTURE]]
- [[USER-GUIDE]]

## Quick Facts
- npm: `@opengsd/get-shit-done-redux`
- 1.2K GitHub stars, 3,115 commits
- Supports 15 runtimes: Claude Code, OpenCode, Gemini CLI, Copilot, Cursor, etc.
- 33 agents, 86 commands, 11 hooks

## Core Loop
1. `/gsd-new-project` — Initialize project
2. `/gsd-discuss-phase N` — Capture decisions
3. `/gsd-plan-phase N` — Research + plan + verify
4. `/gsd-execute-phase N` — Execute in parallel waves
5. `/gsd-verify-work N` — User acceptance testing
6. `/gsd-ship N` — Create PR
