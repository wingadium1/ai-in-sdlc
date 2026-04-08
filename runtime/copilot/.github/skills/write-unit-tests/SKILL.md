---
name: write-unit-tests
description: Generate or improve unit tests for existing code. Analyzes coverage gaps, designs test cases linked to requirements, and writes tests following project conventions. Use when coverage is missing or requirements are untested.
argument-hint: "[file/module/feature to test, or coverage target]"
user-invocable: true
---

# Skill: write-unit-tests

Focused test-generation pipeline:
`Intake → Define → Decide → Produce → Verify → Integrate`

Approve phase is skipped by default (auto-pass if coverage threshold met).

## How to invoke

`/write-unit-tests <target>` — target can be:
- A file: `/write-unit-tests src/services/AuthService.ts`
- A feature: `/write-unit-tests the login flow`
- A requirement: `/write-unit-tests REQ-042`
- A gap: `/write-unit-tests — we're below 80% coverage`

## What happens

| Phase | What the AI does |
|-------|-----------------|
| **Intake** | Creates test-task WorkItem, loads related code and requirements |
| **Define** | Identifies coverage gaps, lists untested requirements, defines coverage target |
| **Decide** | Test seam identification, mock strategy, fixture approach |
| **Produce** | Writes test cases — one assertion per test, Arrange/Act/Assert |
| **Verify** | Runs test suite, confirms coverage threshold met |
| **Integrate** | Creates PR with tests linked to requirements |

## Test quality rules (enforced by Produce agent)

- One assertion per test (no multi-assert tests)
- Test names describe behavior: `should return 401 when token is expired`
- Tests are isolated — no shared mutable state between tests
- All mocks/stubs declared in test setup, never in production code
- Each test case linked to a requirement or code unit in `.sdlc/`

## Coverage gate

If coverage is below the threshold defined in `org.yaml`:
- Approve gate triggers with a coverage gap report
- QA must sign off before integration

Default threshold: 80% (configurable in `.sdlc/profiles/org.yaml`)

## Output artifacts in `.sdlc/`

- `.sdlc/artifacts/test-case/{id}/` — each test case, linked to requirement
- `.sdlc/phases/{id}/*.json` — full phase trail with coverage evidence
