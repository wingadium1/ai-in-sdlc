---
name: "SDLC [Type] Rules"
description: "Coding rules and conventions for [type] projects using the ai-in-sdlc framework"
applyTo: "**"
---

# ai-in-sdlc — [Type] Project Rules

## Phase contract

Always read `.sdlc/profiles/project.yaml` before generating code.
Always read the prior phase's PhasePacket from `.sdlc/phases/{work-item-id}/{phase}.json` before acting.
Write your output PhasePacket before offering the handoff button.

## Code generation rules

[FILL IN: type-specific rules]

## What to never do

[FILL IN: type-specific anti-patterns]

## Artifact traceability

Every file you create or modify must be registered in `.sdlc/artifacts/{kind}/{id}/meta.json`.
Every artifact must have `derives_from` pointing to at least one upstream requirement or decision.
Never produce code that cannot be traced to a requirement or approved decision.
