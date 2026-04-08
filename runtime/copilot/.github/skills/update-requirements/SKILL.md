---
name: update-requirements
description: Capture new or changed requirements, structure them in the knowledge base, and propagate invalidations to linked design artifacts, code, and tests. Use when requirements change, new user stories are added, or acceptance criteria need updating.
argument-hint: "[new requirement text, changed story, or external ticket ID]"
user-invocable: true
work-type: requirement-analysis
---

# Skill: update-requirements

Requirements management pipeline:
`Intake → Define → Decide → Produce → Approve → Integrate`

No Produce-code phase — Integrate means propagating invalidations to linked artifacts, not writing code.

## How to invoke

`/update-requirements <input>` — input can be:
- Free text: `/update-requirements Users must be able to reset their password via SMS`
- A ticket: `/update-requirements PROJ-99` (normalizes Jira/Linear ticket into structured requirement)
- A change: `/update-requirements REQ-042 is changing — the timeout is now 30s not 60s`

## What happens

| Phase | What the AI does | Human does |
|-------|-----------------|-----------|
| **Intake** | Creates requirements-change WorkItem, loads existing related requirements | — |
| **Define** | Structures the requirement: user story, acceptance criteria, constraints, priority | — |
| **Decide** | Identifies which existing requirements are superseded; maps impact to design/code/test artifacts | — |
| **Produce** | Creates new `ArtifactVersion` in `.sdlc/artifacts/requirement/`; marks superseded versions | — |
| **Approve** | **PM/stakeholder review** — requirements always require human approval | Approve structured requirements |
| **Integrate** | Marks linked design, code, and test artifacts as `draft` (needs re-review); creates audit trail | — |

## Requirement structure (Produce phase output)

Every requirement is stored as:
```markdown
## REQ-{id}: {title}

**User Story**: As a {role}, I want to {action} so that {benefit}

**Acceptance Criteria**:
- AC-1: {criterion}
- AC-2: {criterion}

**Constraints**: {platform, performance, security constraints}
**Priority**: P1 | P2 | P3
**Status**: proposed | approved | superseded
**Supersedes**: {prior REQ id if applicable}
```

## Invalidation propagation (Integrate phase)

When a requirement changes, Integrate marks as `approval_state: "draft"` any artifact that `derives_from` the changed requirement:
- Design documents
- Code files (if indexed)
- Test cases
- Mockups

This surfaces a review queue: "these artifacts may be out of date with the new requirements."

## Approve gate

Requirements **always** require human approval — they are the source of truth for all downstream work. The Approve agent presents the structured requirement and waits for explicit PM/stakeholder sign-off.

## Work type

Default work type is `requirement-analysis`. Agents should load `.sdlc/work-types/requirement-analysis.md` plus any `project.yaml -> work_type_overrides.requirement-analysis` content before Define and Decide.

## Output artifacts in `.sdlc/`

- `.sdlc/artifacts/requirement/{id}/` — new structured requirement version
- Updated `approval_state` on all downstream artifacts (draft = needs review)
- `.sdlc/phases/{id}/*.json` — full phase trail
