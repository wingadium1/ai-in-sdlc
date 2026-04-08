# ai-in-sdlc — Project Overview

> Universal AI-assisted Software Development Lifecycle framework.  
> Delivered as agent skill toolsets, starting with GitHub Copilot.

---

## Vision

A framework where AI agents assist developers across the **full SDLC** — from requirements analysis through coding, testing, and release — while maintaining human control at critical decision points.

The framework is:
- **Universal**: works for any project type (web, mobile, backend, data pipeline)
- **Project-aware**: adapts to the specific stack, conventions, and team workflow via configuration
- **Open/extensible**: external artifacts (Figma mockups, Jira tickets, OpenAPI specs) are first-class inputs, not afterthoughts
- **Runtime-portable**: core design maps to GitHub Copilot, Claude Code, and OpenCode

---

## Core Problem

Developers spend significant time on repetitive but context-heavy SDLC tasks:
- Translating requirements into design decisions
- Bootstrapping new features with correct patterns
- Writing unit and automation tests after implementation
- Maintaining traceability between requirements, code, and tests

Current AI tools (Copilot, Claude Code) assist at the **file/function level** but lack awareness of the broader SDLC context — what requirement drives this code, what design decisions were made, what tests are missing.

---

## Solution

A layered system of **agent skills** that each target a specific developer intent and drive a **phase pipeline** through the SDLC, backed by a **persistent knowledge base** that maintains project context across sessions.

> **Related note**: The idea of a Karpathy-style layered LLM wiki is captured separately in [`docs/llm-wiki-knowledge-layer-note.md`](docs/llm-wiki-knowledge-layer-note.md). It is intentionally positioned as an external knowledge-system direction, not part of the core `ai-in-sdlc` architecture in this repository.

### Developer Entry Points (Skills)

| Skill | Developer Intent | Phases Triggered |
|-------|-----------------|-----------------|
| `start-feature` | Begin implementing a new feature | Intake → Define → Decide → Produce → Verify → Approve → Integrate |
| `fix-bug` | Investigate and patch a defect | Intake → Define → Decide → Produce → Verify → Approve → Integrate |
| `write-unit-tests` | Generate or improve unit test coverage | Intake → Define → Decide → Produce → Verify → Integrate |
| `write-auto-tests` | Create automation/E2E test scripts | Intake → Define → Decide → Produce → Verify → Approve → Integrate |
| `update-requirements` | Capture and propagate requirement changes | Intake → Define → Decide → Produce → Approve → Integrate |

---

## Delivery Targets

### MVP — GitHub Copilot Toolset
- Platform: VS Code with GitHub Copilot (Agent Mode)
- Mechanism: `.agent.md` + `SKILL.md` + `.prompt.md` + `.instructions.md`
- State: workspace files under `.sdlc/`
- Human gates: Copilot handoff buttons (`send: false`)

### Phase 2 — Claude Code
- Platform: Claude Code CLI
- Mechanism: `SKILL.md` + `AGENTS.md` + slash commands
- State: `.sdlc/` (same schema, same files)
- Human gates: interactive prompts + checkpoint system

### Phase 3 — OpenCode (OMO)
- Platform: OpenCode CLI
- Mechanism: skills in `~/.config/opencode/skills/`
- State: `.sdlc/` (same schema)
- Human gates: `question` tool + todo continuation

> **Portability principle**: The `.sdlc/` artifact schema and knowledge base format are identical across all runtimes. Only the skill injection mechanism changes.

---

## Key Design Principles

1. **Universal phase backbone, not per-project pipelines** — the same 8-phase DAG applies to all project types; project specifics are a configuration layer
2. **Knowledge base as adapter** — local files first, swappable to vector DB or graph DB
3. **External artifacts are first-class** — Figma, Jira, OpenAPI specs enter the system as normalized `ArtifactVersion` objects, not raw text
4. **Shortest valid path** — skills skip non-applicable phases; no ceremony for trivial tasks
5. **Human gates only at irreversible/ambiguous points** — not every phase requires human approval
6. **Provenance ≠ Approval** — who created an artifact (AI/human/external) is tracked separately from whether it's been approved

---

## Project Structure

```
ai-in-sdlc/
├── PROJECT.md              # This file
├── ARCHITECTURE.md         # System design, phase model, schemas
├── DECISIONS.md            # Architecture Decision Records (ADRs)
├── ROADMAP.md              # Phased delivery plan
│
├── .planning/              # Framework design artifacts (meta)
│
└── runtime/
    ├── copilot/            # GitHub Copilot implementation
    │   ├── .github/
    │   │   ├── agents/     # .agent.md files (phase agents)
    │   │   ├── skills/     # SKILL.md files
    │   │   ├── prompts/    # .prompt.md files (slash commands)
    │   │   └── instructions/ # .instructions.md files
    │   └── .sdlc/          # Runtime state schema
    │
    ├── claude-code/        # Claude Code implementation (Phase 2)
    └── opencode/           # OpenCode implementation (Phase 3)
```

---

## Status

- [x] Concept validated
- [x] Architecture designed
- [x] GitHub Copilot capability research complete
- [x] Decision log initialized
- [ ] MVP implementation: GitHub Copilot toolset
- [ ] Pilot on real project
