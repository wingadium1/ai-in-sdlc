---
name: write-auto-tests
description: Create automation or E2E tests for user flows. Extracts flows from requirements or design artifacts, designs test architecture, and generates scripts using the project's E2E framework. Use for end-to-end, integration, or automation test creation.
argument-hint: "[flow name, feature, or requirement to automate]"
user-invocable: true
---

# Skill: write-auto-tests

Automation test pipeline with heavier Decide phase:
`Intake → Define → Decide → Produce → Verify → Approve → Integrate`

Decide uses `claude-opus-4` — test strategy, environment design, and oracle selection require careful thinking.

## How to invoke

`/write-auto-tests <target>` — target can be:
- A user flow: `/write-auto-tests the checkout flow`
- A feature: `/write-auto-tests login and session management`
- A requirement: `/write-auto-tests REQ-015 through REQ-018`
- A design artifact: `/write-auto-tests based on the Figma screens in .sdlc/artifacts/design-artifact/`

## What happens

| Phase | What the AI does | Human does |
|-------|-----------------|-----------|
| **Intake** | Creates test-task WorkItem, loads flow specs from design artifacts or requirements | — |
| **Define** | Extracts user flows, defines test environment needs, identifies test data requirements | Clarify ambiguous flows |
| **Decide** | Test architecture: framework, page/screen object model, data strategy, environment config, oracle selection | **Approve gate** — test strategy is architectural |
| **Produce** | Implements automation scripts per the decided architecture | — |
| **Verify** | Runs scripts against test environment, confirms flows pass | — |
| **Approve** | Human QA sign-off | Review test coverage of flows |
| **Integrate** | Creates PR, links test cases to requirements | Merge PR |

## Test architecture decisions (Decide phase)

The Decide agent will propose:
1. **Framework selection** — use `project.yaml → e2e_framework` if set, else recommend
2. **Structure pattern** — page object model, screen object model, or action-based
3. **Test data strategy** — factory pattern, fixtures, or API seeding
4. **Environment strategy** — local, CI, or cloud device farm
5. **Oracle design** — how to assert correctness for each flow

These are recorded as Decisions in `.sdlc/decisions/` for future test maintenance.

## Output artifacts in `.sdlc/`

- `.sdlc/artifacts/test-case/{id}/` — each automated flow, linked to requirements
- `.sdlc/decisions/{id}.json` — test architecture decisions
- `.sdlc/phases/{id}/*.json` — full phase trail
