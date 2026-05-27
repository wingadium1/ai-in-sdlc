# OMO (OhMyOpenAgent) Overview

## What Is Oh My OpenAgent?
Oh My OpenAgent is a **multi-model agent orchestration harness** for OpenCode. It transforms a single AI agent into a coordinated development team.

- 59K+ GitHub stars
- Previously named "oh-my-opencode" (rename transition in progress)
- TypeScript project
- Dual-published as `oh-my-openagent` and `oh-my-opencode`

## Key Agents
| Agent | Role |
|-------|------|
| Sisyphus | Main orchestrator - delegates to subagents |
| Prometheus | Planner - creates structured work plans |
| Atlas | Executor - implements planned work |
| Oracle | High-IQ consultant for architecture/debugging |
| Librarian | Codebase research, documentation lookup |
| Explore | Codebase search and pattern discovery |

## Category-Based Model Routing
When Sisyphus delegates to a subagent, it picks a **category** — not a model name. The category automatically maps to the right model.

| Category | Purpose | Typical Model |
|----------|---------|---------------|
| visual-engineering | Frontend, UI/UX, styling | Gemini 3.1 Pro |
| ultrabrain | Hard logic, architecture | GPT-5.5 |
| deep | Autonomous research + execution | GPT-5.5 |
| artistry | Creative problem-solving | Gemini 3.1 Pro |
| quick | Trivial tasks, simple edits | GPT-5.4 Mini |
| unspecified-low | Low-effort fallback | GPT-5.4 Mini |
| unspecified-high | High-effort fallback | Claude Opus 4-7 |
| writing | Documentation, prose | Claude Opus 4-7 |

## Agents (11 Specialized)
Customize agent models, prompts, and permissions in `oh-my-openagent.jsonc`.

## Key Tools
- **call_omo_agent**: Spawn explore/librarian agents. Supports `run_in_background`.
- **task()**: Category-based delegation. Supports categories + skills.
