# ADR 018: Asynchronous Handoff Protocol

## Status
Accepted

## Context
When a BA completes a requirement, how does the developer agent know it's ready? When GSD plans tasks, how do OMO agents get triggered?

## Decision
We will use an **Asynchronous Handoff Protocol**. Hand-offs are triggered by specific state changes in files (e.g., adding a specific tag to a wiki page, or finalizing a `PLAN.md`). Adapters will be invoked either via git hooks, manual slash commands, or scheduled sweeps to process these state changes.

## Consequences
- **Pros**: Resilient to system failures. Hand-offs can be reviewed by humans before downstream execution starts.
- **Cons**: Introduces latency between a phase completing and the next phase starting.
