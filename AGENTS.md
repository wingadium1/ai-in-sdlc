# ai-in-sdlc — Agent Instructions

This repository contains the **ai-in-sdlc framework**: a universal AI-assisted SDLC toolset delivered as agent skills for GitHub Copilot (MVP), Claude Code (M2), and OpenCode (M3).

## Repository Layout

```
runtime/copilot/.github/    ← GitHub Copilot runtime (agents, skills, prompts)
.sdlc/                      ← Knowledge base schema and templates
ARCHITECTURE.md             ← Phase model, schemas, adapter design
DECISIONS.md                ← Architecture Decision Records (ADRs)
ROADMAP.md                  ← Milestone plan
```

## What You Are Working On

When contributing to this repo, you are working on the **framework itself** — not running it. You are editing agent instruction files (`.agent.md`), skill descriptions (`SKILL.md`), knowledge base schemas (`.sdlc/`), and runtime wiring.

## Key Conventions

- `.sdlc/` schema is runtime-agnostic — the same JSON/YAML structures work across Copilot, Claude Code, and OpenCode
- Every phase agent reads the prior phase's `PhasePacket` from `.sdlc/phases/{work-item-id}/{phase}.json` before acting
- `project.yaml` in `.sdlc/profiles/` is the primary project adaptation surface — agents must load it before generating code
- Human gates trigger **only** for: architecture change, API contract change, design artifact, PR merge, security-sensitive code
- Credentials never go in `.sdlc/` — load from env var → `.sdlc/.env` → global credential store

## Schema Files

All templates are in `.sdlc/` with a `_template` prefix. When referencing the schema:
- WorkItem: `.sdlc/work-items/_template.json`
- ArtifactVersion: `.sdlc/artifacts/_template-meta.json`
- PhasePacket: `.sdlc/phases/_template.json`
- Decision: `.sdlc/decisions/_template.json`
