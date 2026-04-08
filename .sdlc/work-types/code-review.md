---
id: code-review
name: Code Review
maps_to_skills: []
version: "1.0.0"
---

# Work Type: Code Review

> Evaluate a change for correctness, risk, maintainability, and project-fit before it is merged or approved.

## When This Work Type Applies

Use this work type when the primary task is reviewing an existing implementation, validating a proposed change, or auditing a pull request or diff for risk and quality.
The output is not new feature code by default. The output is review evidence, findings, and recommended actions.

## Thinking Steps

Agent must execute these steps in order. Project-specific overrides may replace or extend them from `project.yaml`.

### Step 1: Understand Intent

**Goal**: Identify what the change is trying to accomplish.

**How**:
- Read the work item, linked requirement, or PR summary.
- Determine the claimed scope and expected behavior.
- Identify whether the review is functional, architectural, security-focused, or release-focused.

**Output**: Review scope statement.

**Gate**: if the intended behavior is unclear.

### Step 2: Inspect Change Surface

**Goal**: Understand exactly what changed and where risk may exist.

**How**:
- Review touched files, affected modules, and interfaces.
- Check dependency boundaries, public contracts, and callers.
- Compare the implementation against project conventions and canonical examples.

**Output**: Change surface summary and potential hotspots.

**Gate**: never.

### Step 3: Evaluate Quality and Risk

**Goal**: Determine whether the change is safe, correct, and maintainable.

**How**:
- Check correctness, edge cases, and failure handling.
- Check tests, evidence, and traceability back to requirements or bug reports.
- Flag architecture, security, performance, or operability risks.

**Output**: Findings list with severity and rationale.

**Gate**: if high-severity findings block approval.

### Step 4: Recommend Action

**Goal**: Produce a clear disposition.

**How**:
- Classify findings as must-fix, should-fix, or informational.
- State whether the change should proceed, be revised, or be rejected.
- Make the next action obvious to the human reviewer or author.

**Output**: Review recommendation and next-step summary.

**Gate**: always if the review feeds a human approval decision.

## Required Tools / Skills

- `codebase`: Understand the touched files against existing patterns.
- `usages`: Trace public interfaces and blast radius.
- `findTestFiles`: Verify test coverage and affected checks.
- Project-specific audit tools may be appended in `project.yaml`.

## Artifacts Produced

| Artifact | Location | Notes |
|---|---|---|
| Review note | `.sdlc/artifacts/review-note/{id}/` | Summary of findings and recommendation |
| Phase packets | `.sdlc/phases/{work-item-id}/` | Preserve evidence and review decision flow |

## Recommended Artifact Templates

When review work needs stronger architecture grounding, prefer these templates:

- `docs/artifact-templates/context-view.md` — for system boundary clarity
- `docs/artifact-templates/container-view.md` — for static runtime unit boundaries
- `docs/artifact-templates/interaction-view.md` — for critical flow review
- `docs/artifact-templates/contract-view.md` — for interface ownership and compatibility
- `docs/artifact-templates/deployment-view.md` — for rollout, infra, and blast-radius review

## Verification Criteria

Before this work type is considered complete:

- [ ] Review scope is explicit.
- [ ] The affected change surface is summarized.
- [ ] Findings include rationale and severity.
- [ ] A clear recommendation is given.
- [ ] Blocking issues are tied to requirements, decisions, or project rules where possible.

## Per-Phase Behavior

| Phase | Behavior |
|---|---|
| Intake | Treat the incoming request as an audit or review, not fresh implementation by default. |
| Define | Clarify review scope, expected standards, and approval threshold. |
| Decide | Focus on risk analysis, standards compliance, and missing evidence. |
| Produce | Generate review findings, requested changes, or approval notes. |
| Verify | Confirm that cited issues are real and linked to actual code or artifacts. |
| Approve | Human reviewer uses the packaged findings to accept or reject the change. |
| Integrate | Store review results and propagate required revisions if the change is blocked. |

## Known Variations by Project Type

These are defaults. Projects can extend or replace them via `project.yaml -> work_type_overrides`.

| Project Type | Key Difference |
|---|---|
| microservices | Review emphasizes contract compatibility, consumer impact, rollout order, and observability. |
| data-ml | Review emphasizes schema stability, reproducibility, metrics thresholds, and lineage. |
| infrastructure-iac | Review emphasizes blast radius, environment promotion, policy compliance, and rollback safety. |
