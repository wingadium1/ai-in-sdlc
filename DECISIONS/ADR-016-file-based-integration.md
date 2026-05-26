# ADR 016: File-based Convention Layer Integration

## Status
Accepted

## Context
We need to connect 4 disparate systems (GSD Redux, OMO, AI-in-sdlc, agent-for-ba) into a cohesive AI-augmented SDLC workflow. We could build a custom central orchestration engine (API/DB driven) or use a lightweight file-based approach.

## Decision
We will use a **Convention Layer (Model B)** integration approach. Systems will communicate via file-based adapters that read/write to agreed-upon directory structures and file formats.

## Consequences
- **Pros**: Easy to debug, git-friendly, requires zero modifications to the internal code of the 4 systems.
- **Cons**: Slower than direct API calls, relies on rigid file format contracts.
