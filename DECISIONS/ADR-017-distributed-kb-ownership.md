# ADR 017: Distributed Knowledge Base Ownership

## Status
Accepted

## Context
With multiple AI agents operating in the same repository, there is a risk of them overwriting each other's state or causing git conflicts.

## Decision
We will maintain **Distributed Knowledge Base Ownership**.
- GSD Redux strictly owns `.planning/`
- AI-in-sdlc strictly owns `.sdlc/`
- agent-for-ba strictly owns `wiki/`

## Consequences
- **Pros**: No naming collisions, clean separation of concerns, systems can run independently.
- **Cons**: Data duplication (e.g., a requirement might exist as markdown in `wiki/` and JSON in `.sdlc/`), requiring synchronization adapters.
