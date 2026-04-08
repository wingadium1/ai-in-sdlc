---
name: code-review
description: Review an existing implementation, diff, or pull request and produce structured findings, risks, and recommended next actions. Use when a developer says "review this", "check my changes", "audit this PR", or "look over this diff".
argument-hint: "[PR URL, branch name, file path, or diff summary]"
user-invocable: true
work-type: code-review
---

# Skill: code-review

Orchestrates a review-focused SDLC pipeline:
`Intake → Define → Decide → Produce → Verify → Approve → Integrate`

## How to invoke

`/code-review <input>` — input can be:
- A PR URL: `/code-review https://github.com/org/repo/pull/123`
- A branch or diff summary: `/code-review branch: feature/session-timeout`
- A file or module path: `/code-review src/services/AuthService.ts`
- A natural request: `/code-review review the new checkout flow changes`

## What happens

| Phase | What the AI does | Human does |
|-------|------------------|-----------|
| **Intake** | Creates review WorkItem, loads linked requirements, decisions, and changed-code context | Clarify intent if the review scope is ambiguous |
| **Define** | States review scope, review standard, and affected modules/contracts | Confirm review focus if needed |
| **Decide** | Performs risk analysis: correctness, blast radius, security, performance, and maintainability | **Review gate** if blocking issues or high-risk changes are found |
| **Produce** | Writes structured review findings, recommended fixes, and follow-up tasks | Apply changes or request revisions |
| **Verify** | Confirms findings are grounded in actual code, tests, or artifacts | — |
| **Approve** | Packages the review summary for maintainer sign-off when required | **Review and decide** |
| **Integrate** | Stores findings in `.sdlc/` and can draft review-ready summary text for the PR | Merge, revise, or close |

## Approve gate for code-review

Approve is triggered when Decide raises any blocking condition such as:
- `architecture_change`
- `api_contract_change`
- `security_sensitive`
- `new_external_dependency`
- `blocking_review_findings`

Non-blocking reviews can auto-pass after findings are recorded.

## Work type

Default work type is `code-review`. Agents should load `.sdlc/work-types/code-review.md` plus any `project.yaml -> work_type_overrides.code-review` content before Decide and Verify.

## Output artifacts in `.sdlc/`

- `.sdlc/artifacts/review-note/{id}/` — structured findings, severity, and recommendation
- `.sdlc/decisions/{id}.json` — risk or design decisions captured during review
- `.sdlc/phases/{id}/*.json` — full phase trail
