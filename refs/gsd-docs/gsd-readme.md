# GSD - Get Shit Done Redux

## Overview
GSD is a meta-prompting and context engineering system for AI code editors. It provides structured workflows for Claude Code, OpenCode, Gemini CLI, Kilo, Codex, Copilot, Cursor, Windsurf, and more.

**Key facts:**
- npm package: `@opengsd/get-shit-done-redux`
- 1.2K GitHub stars, 3,115 commits
- MIT License
- Works on Mac, Windows, Linux

## Core Loop (6 Commands)
1. `/gsd-new-project` — Questions → research → requirements → roadmap
2. `/gsd-discuss-phase N` — Capture implementation decisions before planning
3. `/gsd-plan-phase N` — Research + plan + verify (up to 3 iterations)
4. `/gsd-execute-phase N` — Execute plans in parallel waves
5. `/gsd-verify-work N` — Manual acceptance testing
6. `/gsd-ship N` — Create PR from verified phase work

## Solves 3 Problems
1. **Context bloat**: GSD keeps main context clean by doing heavy work in fresh subagent contexts
2. **No shared memory**: PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md, CONTEXT.md persist across sessions
3. **No verification**: Verify step walks through what was built, diagnoses failures

## State Files (.planning/)
- PROJECT.md — Vision
- REQUIREMENTS.md — Scope with REQ-IDs
- ROADMAP.md — Where you're going
- STATE.md — Current position and decisions
- CONTEXT.md — Per-phase implementation decisions
- config.json — Model profiles, workflow toggles

## Architecture
- **Fresh Context Per Agent**: Every spawned agent gets a clean 200K token window
- **Thin Orchestrators**: Workflow files load context, spawn agents, collect results, update state
- **File-Based State**: All state in .planning/ as Markdown and JSON
- **Wave Execution Model**: Plans grouped into dependency waves, executed in parallel
- **33 agents, 86 commands, 11 hooks**
