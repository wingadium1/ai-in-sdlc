---
name: start-feature
description: Start implementing a new feature end-to-end. Guides through requirements, design decisions, implementation, testing, and PR creation. Use when a developer says "implement X", "add Y feature", "build Z".
argument-hint: "[feature description or ticket ID]"
user-invocable: true
---

# Skill: start-feature

Orchestrates the full SDLC pipeline for a new feature:
`Intake → Define → Decide → Produce → Verify → Approve → Integrate`

## How to invoke

Type `/start-feature <description>` or `@sdlc-intake I want to implement <description>`.

You can also reference an external ticket: `/start-feature PROJ-123` (Jira) or `/start-feature https://linear.app/...`

## What happens

| Phase | What the AI does | Human does |
|-------|-----------------|-----------|
| **Intake** | Creates WorkItem, loads related requirements and decisions from `.sdlc/` | Confirm scope if ambiguous |
| **Define** | Establishes acceptance criteria and "done" definition | Approve criteria if incomplete |
| **Decide** | Impact analysis, design decisions, implementation plan | **Review gate** if architecture/API changes |
| **Produce** | Implements code per plan, following `project.yaml` conventions | Mode 2: complete TODOs; Mode 1: none |
| **Verify** | Runs lint, tests, typecheck; validates traceability | — |
| **Approve** | Packages review artifacts (diagrams, diffs, decisions) | **Review and decide** |
| **Integrate** | Creates PR, updates `.sdlc/` state | Merge PR |

## Decide gate triggers for start-feature

The Approve gate is always triggered for `start-feature` because features typically introduce:
- New API contracts or interfaces
- Architectural patterns
- External dependencies

You must explicitly approve before integration proceeds.

## Operating modes for Produce phase

- **Mode 1 (autonomous)**: AI writes all code, runs tests, iterates until passing. Enable by saying "autonomous mode" or "mode 1".
- **Mode 2 (scaffold, default)**: AI generates skeleton + key logic, annotates TODOs. Developer finalizes.

## Project adaptation

Before coding, the AI loads:
- `.sdlc/profiles/project.yaml` — stack, frameworks, conventions, canonical examples
- `.sdlc/work-types/requirement-analysis.md` when the request is still primarily exploratory, planning-focused, or acceptance-criteria-heavy
- Component profiles under `.sdlc/profiles/components/` (if relevant module has one)
- Approved decisions from `.sdlc/decisions/`

All generated code matches your project's existing patterns.

## Output artifacts in `.sdlc/`

After completion:
- `.sdlc/work-items/{id}.json` — feature work item
- `.sdlc/artifacts/requirement/{id}/` — structured requirements
- `.sdlc/artifacts/design-artifact/{id}/` — design decisions, ADRs
- `.sdlc/decisions/{id}.json` — each architecture/design decision
- `.sdlc/phases/{id}/*.json` — full phase trail (audit log)
