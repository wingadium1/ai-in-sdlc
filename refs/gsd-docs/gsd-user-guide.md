# GSD User Guide

## End-to-End Walkthrough

### 1. Create Project
`/gsd-new-project` — Questions about your idea → parallel research agents → requirements → roadmap

### 2. Discuss Phase
`/gsd-discuss-phase 1` — Capture implementation preferences before planning

### 3. Plan Phase
`/gsd-plan-phase 1` — Research agent → Planner → Plan Checker (up to 3 iterations)
- Produces: RESEARCH.md, PLAN.md files, VALIDATION.md

### 4. Execute Phase
`/gsd-execute-phase 1` — Wave analysis → Executor per plan → atomic commits → Verifier
- Each executor gets fresh 200K context window
- Parallel waves where dependencies allow
- Produces: SUMMARY.md per plan, VERIFICATION.md

### 5. Verify Work
`/gsd-verify-work 1` — Extract deliverables, walk through them, diagnose failures

### 6. Ship
`/gsd-ship 1` — Push branch, create PR with auto-generated body

## Workflow Diagrams
- Full Project Lifecycle: init → (discuss → ui? → plan → execute → verify) → ship → audit → complete → next
- Planning Agent Coordination: 4 parallel researchers → Planner → Plan Checker (loop up to 3x)
- Validation (Nyquist Layer): Map automated test coverage per requirement before code is written

## Multi-Runtime Support
GSD supports 15 runtimes: Claude Code, OpenCode, Kilo, Gemini CLI, Codex, Copilot, Antigravity, Trae, Cline, Augment Code, Cursor, Windsurf, Qwen Code, Hermes Agent, CodeBuddy

## Namespace Routing (v1.40)
6 namespace meta-skills: gsd-workflow, gsd-project, gsd-quality, gsd-context, gsd-manage, gsd-ideate
Each routes to concrete sub-skills. Keeps eager skill-listing cost low (~120 tokens vs ~2,150).
