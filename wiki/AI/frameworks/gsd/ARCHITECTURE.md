# GSD Architecture

## System Overview
GSD is a meta-prompting framework that sits between the user and AI coding agents (Claude Code, Gemini CLI, OpenCode, Kilo, Codex, Copilot, etc.).

## Layer Stack
1. **Command Layer** — commands/gsd/*.md — Prompt-based command files
2. **Workflow Layer** — get-shit-done/workflows/*.md — Orchestration logic
3. **Agent Layer** — Specialized agents with fresh context windows
4. **CLI Tools Layer** — gsd-tools.cjs — Node.js utilities
5. **File System** — .planning/ — PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md

## Design Principles
1. Fresh Context Per Agent — eliminates context rot
2. Thin Orchestrators — never do heavy lifting
3. File-Based State — survives context resets
4. Absent = Enabled — feature flags default to true
5. Defense in Depth — plan-checker → executor → verifier → UAT

## Agent Model
- Orchestrator loads context via gsd-tools.cjs
- Resolves model via gsd-tools.cjs resolve-model
- Spawns agent with fresh context (up to 200K)
- Collects result, updates state

## Primary Agents (21)
- Researchers: gsd-project-researcher, gsd-phase-researcher, gsd-ui-researcher, gsd-advisor-researcher
- Synthesizers: gsd-research-synthesizer
- Planners: gsd-planner, gsd-roadmapper
- Checkers: gsd-plan-checker, gsd-integration-checker, gsd-ui-checker
- Executors: gsd-executor
- Verifiers: gsd-verifier
- Mappers: gsd-codebase-mapper (4 parallel)
- Debuggers: gsd-debugger
- Auditors: gsd-ui-auditor, gsd-security-auditor
- Doc Writers: gsd-doc-writer, gsd-doc-verifier
- Profilers: gsd-user-profiler

## Wave Execution
During execute-phase, plans are grouped into dependency waves:
- Plans with no deps → Wave 1 (parallel)
- Plans depending on Wave 1 → Wave 2
- Each executor gets fresh 200K context
- Parallel commit safety via --no-verify + STATE.md file locking

## Context Propagation
PROJECT.md → All agents
REQUIREMENTS.md → Planner, Verifier, Auditor
ROADMAP.md → Orchestrators
STATE.md → All agents (decisions, blockers)
CONTEXT.md → Researcher, Planner, Executor
RESEARCH.md → Planner, Plan Checker
PLAN.md → Executor, Plan Checker
SUMMARY.md → Verifier, State tracking
