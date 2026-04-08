---
name: fix-bug
description: Investigate and fix a bug through an evidence-first coworker workflow. The AI gathers evidence, analyzes root cause, suggests next actions, applies the smallest safe fix when justified, and creates a PR. Use when a developer says "fix X", "bug in Y", "error when Z".
argument-hint: "[bug description, error message, or ticket ID]"
user-invocable: true
work-type: debugging
---

# Skill: fix-bug

Orchestrates a focused, coworker-style bug-fix pipeline:
`Intake → Define → Decide → Produce → Verify → Approve → Integrate`

Define = symptom confirmation + evidence plan. Decide = ranked hypotheses + chosen action. No heavyweight design unless contracts change.

## How to invoke

`/fix-bug <description>` or paste an error message/stack trace directly into chat.

Reference a ticket: `/fix-bug BUG-456` or `/fix-bug https://jira.company.com/...`

## What happens

| Phase | What the AI does | Human does |
|-------|-----------------|-----------|
| **Intake** | Creates bug WorkItem, searches `.sdlc/` for similar prior bugs, identifies likely evidence sources | Provide ticket, incident link, trace ID, or error details if available |
| **Define** | Confirms symptom, defines reproduction or evidence plan, separates obvious local bugs from investigation-heavy incidents | Confirm symptom, scope, and any missing runtime access |
| **Decide** | Ranks hypotheses, proves root cause when possible, suggests next actions and minimal fix or mitigation options | Choose risky runtime actions, provide access, or approve the suggested action path when needed |
| **Produce** | Writes regression test or durable failing check, applies the chosen minimal change, updates bug artifacts | Execute privileged runtime actions if the plan requires a human operator |
| **Verify** | Re-checks tests plus the same evidence surface that exposed the bug, records remaining unknowns | Confirm live-system improvement when the fix depends on operational behavior |
| **Approve** | Gate only if risk flags raised in Decide | Review if triggered |
| **Integrate** | Creates PR with full context | Merge PR |

## Key constraints for fix-bug

- **Minimal fix only** — never refactor while fixing a bug
- **Evidence before guesses** — do not propose fixes before confirming the symptom and checking the strongest available evidence
- **Regression test first when code is the chosen action** — write the test that reproduces the bug before writing the fix
- **Coworker mode by default** — AI investigates and suggests; humans coordinate risky runtime actions, access, and final operational confirmation
- **Three-attempt circuit breaker** — after three materially different failed action attempts, stop patching and hand the case back with a structured closeout
- Decide uses `claude-sonnet-4` (not Opus) — root cause analysis is scope-limited

## Work type

Default work type is `debugging`. Agents should load `.sdlc/work-types/debugging.md` plus any `project.yaml -> work_type_overrides.debugging` content before Define, Decide, and Verify.

Project-specific investigation details belong in `project.yaml`, especially:

- `observability.platform`
- `observability.log_sources`
- `observability.trace_sources`
- `observability.incident_channel`
- `work_type_overrides.debugging.required_tools`

## Approve gate for fix-bug

Auto-passes unless Decide raises:
- `architecture_change`
- `api_contract_change`
- `security_sensitive`
- `runtime_action_requires_human`
- `artifact_gap_required`

Simple locally proven bug fixes usually never require human approval — they go straight from Verify → Integrate.
Complex investigations may still pause for coworker checkpoints inside Define, Decide, and Verify without forcing the full Approve phase.

## Output artifacts in `.sdlc/`

- `.sdlc/artifacts/bug-report/{id}/` — structured bug report with root cause
- `.sdlc/artifacts/test-case/{id}/` — regression test case (linked to bug report)
- `.sdlc/phases/{id}/*.json` — full phase trail

Each closeout should clearly state:

- symptom confirmed
- strongest hypothesis or proven cause
- evidence checked
- chosen action
- remaining unknowns
