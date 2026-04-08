---
id: requirement-analysis
name: Requirement Analysis
maps_to_skills: [update-requirements, start-feature]
version: "1.0.0"
---

# Work Type: Requirement Analysis

> Turn a request, ticket, or change idea into clear, testable, implementation-ready requirements with explicit impact and acceptance criteria.

## When This Work Type Applies

Use this work type when the main task is clarifying scope, decomposing a feature request, refining acceptance criteria, or analyzing the impact of a requirement change.
The primary output is a well-structured requirement set, not immediate code.

## Thinking Steps

Agent must execute these steps in order. Project-specific overrides may replace or extend them from `project.yaml`.

### Step 1: Identify Stakeholders and Source of Truth

**Goal**: Know who owns the request and which artifacts are authoritative.

**How**:
- Determine whether the input comes from a ticket, design artifact, bug report, or direct user request.
- Identify stakeholders, approvers, and linked systems.
- Locate prior decisions and existing requirements that constrain the change.

**Output**: Requirement source map and ownership context.

**Gate**: if the source of truth is unclear.

### Step 2: Clarify Scope and Outcomes

**Goal**: Separate must-have behavior from implied or unrelated work.

**How**:
- Rewrite the request as observable outcomes.
- Identify in-scope and out-of-scope behaviors.
- Surface assumptions, dependencies, and open questions.

**Output**: Clear scope statement and open-question list.

**Gate**: if unresolved ambiguity blocks implementation.

### Step 3: Define Acceptance Criteria

**Goal**: Make the work testable.

**How**:
- Convert outcomes into explicit acceptance criteria.
- Include edge cases, permissions, failure modes, and non-functional constraints.
- Reference contracts, schemas, or UX expectations where relevant.

**Output**: Requirement artifact or updated requirement criteria.

**Gate**: always before implementation when criteria are materially changed.

### Step 4: Assess Impact

**Goal**: Understand what downstream artifacts become stale or blocked.

**How**:
- Map affected code, APIs, test cases, docs, and decisions.
- Identify whether this is a net-new requirement or a change to existing behavior.
- Mark invalidations and follow-up work.

**Output**: Impact map and invalidation list.

**Gate**: if the change affects architecture, API contracts, or regulated flows.

## Required Tools / Skills

- `codebase`: Find current behavior and linked code paths.
- `openSimpleBrowser`: Inspect linked tickets or external references when available.
- Project-specific provider tools may be appended in `project.yaml`.

## Artifacts Produced

| Artifact | Location | Notes |
|---|---|---|
| Requirement artifact | `.sdlc/artifacts/requirement/{id}/` | Structured requirement or updated requirement set |
| Design artifact | `.sdlc/artifacts/design-artifact/{id}/` | Optional if contracts, diagrams, or UX specs are updated |
| Phase packets | `.sdlc/phases/{work-item-id}/` | Preserve assumptions, criteria, and invalidation map |

## Recommended Artifact Templates

When requirement work changes architecture, scope, or interfaces, prefer these templates:

- `docs/artifact-templates/context-view.md` — for boundary clarification
- `docs/artifact-templates/container-view.md` — for runtime-unit structure
- `docs/artifact-templates/interaction-view.md` — for critical scenario/flow definition
- `docs/artifact-templates/contract-view.md` — for APIs, schemas, and event contracts
- `docs/artifact-templates/deployment-view.md` — when runtime placement or environment behavior is part of the requirement

## Verification Criteria

Before this work type is considered complete:

- [ ] Scope is explicit and testable.
- [ ] Acceptance criteria cover expected behavior and failure modes.
- [ ] Downstream impact is identified.
- [ ] The source of truth and approver path are clear.
- [ ] Open questions are either resolved or explicitly carried as gates.

## Per-Phase Behavior

| Phase | Behavior |
|---|---|
| Intake | Normalize the request into a requirement-oriented work item with linked sources. |
| Define | Focus on acceptance criteria, business intent, and boundaries. |
| Decide | Produce an impact and invalidation map rather than implementation-first details. |
| Produce | Write or update requirement/design artifacts and supporting notes. |
| Verify | Confirm the criteria are testable and linked to affected artifacts. |
| Approve | Human gate is common because requirements become the source of truth. |
| Integrate | Propagate invalidations so implementation and tests can be updated downstream. |

## Known Variations by Project Type

These are defaults. Projects can extend or replace them via `project.yaml -> work_type_overrides`.

| Project Type | Key Difference |
|---|---|
| microservices | Requirements must name affected services, cross-service contracts, and owners. |
| data-ml | Requirements must include data schema, metric thresholds, freshness, and backfill rules. |
| web-frontend | Requirements must include UX states, accessibility, responsive behavior, and visual sign-off. |
