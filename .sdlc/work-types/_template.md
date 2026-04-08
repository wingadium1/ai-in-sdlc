---
id: ""
name: ""
maps_to_skills: []
version: "1.0.0"
---

# Work Type: [NAME]

> One-line description of this class of work.

## When This Work Type Applies

Describe the situations where the agent should treat the work item as this work type.
Explain how this work differs from a generic feature or bug task.

## Thinking Steps

Agent must execute these steps in order. Project-specific overrides may replace or extend them from `project.yaml`.

### Step 1: [Step Name]

**Goal**: [What the agent is trying to learn or decide]

**How**:
- [Concrete action]
- [Concrete action]

**Output**: [Artifact, note, or decision produced by this step]

**Gate**: [always | if X | never]

### Step 2: [Step Name]

**Goal**: ...

**How**:
- ...

**Output**: ...

**Gate**: ...

## Required Tools / Skills

- `codebase`: Repository search for implementation patterns.
- `[tool-or-skill]`: Why it is required.

## Artifacts Produced

| Artifact | Location | Notes |
|---|---|---|
| [artifact-kind] | `.sdlc/artifacts/...` | [when it is created] |

## Verification Criteria

Before this work type is considered complete:

- [ ] [Criterion]
- [ ] [Criterion]

## Per-Phase Behavior

How this work type changes the default SDLC phase behavior:

| Phase | Behavior |
|---|---|
| Intake | ... |
| Define | ... |
| Decide | ... |
| Produce | ... |
| Verify | ... |
| Approve | ... |
| Integrate | ... |

## Known Variations by Project Type

These are defaults. Projects can extend or replace them via `project.yaml -> work_type_overrides`.

| Project Type | Key Difference |
|---|---|
| microservices | ... |
| data-ml | ... |
| web-frontend | ... |
