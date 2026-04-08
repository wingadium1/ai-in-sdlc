# Deliverables / Artifact Expectation Matrix

> Define which artifacts are expected across the SDLC backbone, how those expectations change by work type, and how project types raise or lower the minimum viable documentation set.

**Status**: Framework design reference.
**Purpose**: Connect phase behavior, work types, project types, and interim artifacts into one adaptive expectation model.

---

## Why this document exists

AI-in-SDLC already defines:

- a universal phase backbone,
- a knowledge model centered on `Artifact` and `ArtifactVersion`,
- project types,
- work types,
- and a proposal for interim artifacts.

What the framework still needs is a practical matrix answering:

1. **Which artifacts should exist at each phase?**
2. **Which artifacts become required for a given work type?**
3. **Which project types raise or lower the minimum expected views?**
4. **When is a missing artifact a blocker versus only a recommendation?**

This document provides that expectation model.

---

## Design principles

### 1. One phase backbone, adaptive artifact expectations

The framework must not create different pipelines for different project types or tasks.
Instead, the same phases apply everywhere, while the expected artifacts change according to:

- work type,
- project type,
- change scope,
- and delivery risk.

### 2. Required vs recommended vs optional

Artifact expectations use three levels:

- **Required** — missing this artifact should block or gate progress.
- **Recommended** — should exist in common or risky cases; missing it raises a warning or follow-up.
- **Optional** — valuable only in specific contexts.

### 3. Artifact expectations are scope-aware

A flow-level change does not require whole-system architecture recovery.
The matrix assumes artifact expectations are applied to the **active scope**:

- system,
- subsystem,
- service,
- bounded context,
- component,
- flow,
- entity/workflow,
- release slice.

### 4. Brownfield gaps are recoverable

If a required artifact is missing, the default behavior is not “stop forever.”
The default behavior is:

1. detect the gap,
2. reconstruct the minimum viable artifact,
3. validate it,
4. then continue.

---

## Artifact families used in this matrix

This matrix uses the framework’s current artifact families and artifact kinds.

| Artifact family | Typical persistence form | Typical examples |
|---|---|---|
| Requirement | `requirement` artifact | requirement set, acceptance criteria, change request |
| Design / architecture | `design-artifact` artifact | context view, container view, component view, interaction view, deployment view, contract view |
| Decision | `decision` record and sometimes linked `design-artifact` | ADR, design rationale, tradeoff note |
| Review | `review-note` artifact | review findings, approval package, audit note |
| Bug / incident | `bug-report` artifact | failure evidence, root-cause summary |
| Test design / verification | `test-case` / `test-run-report` artifacts | regression case, scenario validation, evidence summary |
| Release / operations | `release-note` or `design-artifact` artifact | release checklist, rollback note, runbook |

For design artifacts, subtype guidance comes from `artifact_subtype` in `docs/interim-artifacts-proposal.md`.

---

## Phase-level baseline matrix

This is the baseline expectation independent of project type.

| Phase | Required artifacts | Recommended artifacts | Optional artifacts |
|---|---|---|---|
| **Intake** | WorkItem, linked source requirement/bug/ticket if it exists | prior decision links, prior related review notes, prior bug reports | brownfield inventory note |
| **Define** | requirement or scope statement for the active slice | scenario-view, open-question list, source-of-truth map | stakeholder map |
| **Decide** | impact map, decision record when tradeoffs are material | design-artifact for affected architecture slice, contract-view, risk note | component-view, migration-view |
| **Produce** | primary output artifact(s) for the work type | implementation-supporting design artifacts, test design, release/runbook draft | additional diagrams for onboarding |
| **Verify** | verification evidence linked to produced artifacts | updated interaction/state/deployment view if verification changed understanding | extended benchmark/profiling artifacts |
| **Approve** | approval package for any gated artifact | review-note summary, waiver note, release checklist | broader architecture pack |
| **Integrate** | final approved artifact versions and phase trail | invalidation list, supersession links, release-note | follow-up backlog notes |

### Interpretation

- Intake and Define should ensure the task is anchored in a source of truth.
- Decide should ensure the architecture and change impact are explicit enough to proceed safely.
- Produce should create the actual artifacts the work type is responsible for.
- Verify should prove those artifacts are grounded and usable.
- Approve should convert gated artifacts from draft/proposed to approved/rejected.
- Integrate should propagate supersession and invalidation cleanly.

---

## Work-type expectation matrix

These are the main artifact expectations by work type.

## 1. Requirement Analysis

| Phase | Required | Recommended | Optional |
|---|---|---|---|
| Intake | requirement source, linked prior decisions | stakeholder map | prior review-note |
| Define | requirement artifact, acceptance criteria, scope boundary | scenario-view, source-of-truth map | context-view update |
| Decide | impact map, invalidation list | contract-view, component-view, migration-view | deployment-view |
| Produce | updated requirement artifact, design-artifact if contracts/views changed | scenario-view, test-design-view | state-view |
| Verify | traceability to affected downstream artifacts | criteria review note | deeper design review |
| Approve | approved requirement version | approval summary note | waiver note |
| Integrate | invalidation propagation, linked downstream updates | release-note if change is externally visible | broader architecture refresh |

### Core rule

If acceptance criteria materially change and no current requirement artifact exists for the active scope, the framework should reconstruct or create one before implementation continues.

---

## 2. Debugging

| Phase | Required | Recommended | Optional |
|---|---|---|---|
| Intake | bug-report or failure evidence | prior similar bug reports | incident timeline |
| Define | reproduction note, expected vs actual behavior | active flow interaction-view if missing | state-view for lifecycle bugs |
| Decide | root-cause statement, blast-radius note | contract-view or deployment-view if the bug crosses boundaries | component-view |
| Produce | bug-report update, regression test-case | patched interaction-view or state-view if behavior understanding changed | runbook note |
| Verify | regression evidence, test-run-report or equivalent proof | update to design-artifact if the fix clarified hidden architecture | benchmark/profiling report |
| Approve | only when risk flags demand it | review-note for high-risk fixes | waiver note |
| Integrate | final bug-report, linked regression evidence | release-note for operationally meaningful fixes | incident postmortem |

### Core rule

If the bug affects a critical flow and there is no current interaction-view or equivalent flow description, the framework should strongly recommend reconstructing that view before or during the fix.

---

## 3. Code Review

| Phase | Required | Recommended | Optional |
|---|---|---|---|
| Intake | review scope, linked requirement/bug/decision context | prior review-note history | release-slice note |
| Define | review standard, affected surface summary | contract-view or scenario-view for critical flow | component-view |
| Decide | findings list, recommendation, risk note | architecture/design diff note | deployment-view |
| Produce | review-note artifact | updated checklists, follow-up task list | broader audit pack |
| Verify | evidence that findings are grounded in real code/tests/artifacts | traceability summary | performance/security deep dive |
| Approve | approved review-note when blocking or gated | waiver note | secondary reviewer note |
| Integrate | linked required revisions or approval result | superseded prior review-note if scope changed | release-note summary |

### Core rule

For high-risk or cross-boundary changes, review work should not rely on code diff alone. At least one supporting architecture or contract artifact should be available or reconstructed.

---

## Project-type matrix: minimum views beyond requirements

This section refines the baseline minimum design-artifact expectations for release-ready work.

| Project type | Required minimum views | Recommended additions |
|---|---|---|
| web-frontend | `context-view`, `container-view`, `interaction-view` for critical UX flow | `component-view`, `state-view`, UX-specific scenario artifacts |
| backend-api | `context-view`, `container-view`, `contract-view`, `interaction-view` | `deployment-view`, `component-view`, `migration-view` |
| full-stack-web | `context-view`, `container-view`, `contract-view`, `interaction-view` | `component-view`, `deployment-view`, `state-view` |
| mobile | `context-view`, `container-view`, `interaction-view` | `state-view`, release/distribution checklist, offline/sync scenario-view |
| microservices | `context-view`, `container-view`, `contract-view`, `interaction-view`, `deployment-view` | `process-view`, `failure-mode-view`, release-checklist |
| data-ml | `context-view`, `container-view`, `contract-view`, `interaction-view`, `deployment-view` | metric-threshold design note, `state-view`, `migration-view`, runbook-view |
| cli-devtool | `context-view`, `component-view`, `contract-view` | release-checklist, scenario-view, development-view |
| embedded-firmware | `context-view`, `deployment-view`, `state-view`, `interaction-view` | component-view, failure-mode-view, runbook-view |
| infrastructure-iac | `context-view`, `deployment-view`, `migration-view` or change-plan artifact | release-checklist, runbook-view, failure-mode-view |

### Interpretation

- These are **minimum viable views**, not a demand for exhaustive documentation.
- The active scope still matters. A change to one service in a microservices system does not require whole-platform reconstruction.
- Project-type guides and future `project.yaml` policies should refine these defaults.

---

## Combined decision rules

The matrix is meant to drive practical decisions. These rules summarize how to use it.

### Rule 1 — Missing required artifact for active work type

If a required artifact for the active work type is missing at the current scope:

- raise an artifact gap in Intake or Define,
- reconstruct or create the minimum viable artifact,
- then continue.

### Rule 2 — Project type can elevate recommendations to requirements

Example:

- `deployment-view` is generally recommended,
- but for `microservices`, `data-ml`, and `infrastructure-iac`, it is often effectively required for release-ready changes.

### Rule 3 — Review and debugging can depend on existing design artifacts

`debugging` and `code-review` are not only consumers of code. They often require supporting design artifacts such as:

- `interaction-view`
- `contract-view`
- `deployment-view`
- `state-view`

If those artifacts do not exist, brownfield reconstruction should create the minimum viable slice.

### Rule 4 — Requirement changes propagate invalidation

When `requirement-analysis` changes a requirement materially, downstream artifacts become suspect until reviewed or updated:

- design artifacts,
- test cases,
- review notes,
- release notes,
- maybe deployment/runbook artifacts.

### Rule 5 — Approval is artifact-specific, not system-wide

The framework should approve the **active slice**:

- one requirement set,
- one interaction-view,
- one review-note,
- one deployment slice,

not require whole-system re-approval.

### Rule 6 — Project artifact policy can refine the matrix

Projects may refine the framework defaults via `project.yaml -> artifact_policy`.

Recommended policy semantics:

- `required` — missing artifact should block or gate progress for the active scope
- `warn` — raise an artifact gap and recommend reconstruction/template routing
- `optional` — no automatic warning unless the workflow explicitly asks for it

Precedence should be:

1. active scope reality
2. `project.yaml -> artifact_policy.by_work_type`
3. `project.yaml -> artifact_policy.baseline`
4. project-type guide defaults
5. framework deliverables matrix

---

## Brownfield usage model

For existing systems with incomplete documentation, use this matrix as a gap detector.

### Example: microservice bug in checkout flow

- Work type: `debugging`
- Project type: `microservices`
- Scope: `flow`

Minimum expectation:

- bug-report
- reproduction note
- interaction-view for checkout flow
- contract-view if service interaction is part of the failure
- deployment or process context if infra/runtime boundaries matter

If interaction or contract views are missing, reconstruct them before closing the fix as fully understood.

### Example: data-ml requirement change

- Work type: `requirement-analysis`
- Project type: `data-ml`
- Scope: `pipeline` or `model flow`

Minimum expectation:

- updated requirement artifact
- schema/contract artifact
- metric threshold definition
- interaction-view or flow description
- downstream invalidation map

---

## Suggested next implementation targets

This matrix should drive future framework changes in this order:

1. Add artifact expectation policy hooks to work types.
2. Add project-type minimum-view policy to guides or config.
3. Add brownfield artifact-gap detection to `/sdlc-init` or future reconstruction workflows.
4. Add templates for the most common required design-artifact subtypes:
   - `context-view`
   - `container-view`
   - `interaction-view`
   - `contract-view`
   - `deployment-view`

---

## Final recommendation

AI-in-SDLC should treat deliverables as an **adaptive expectation matrix**, not a fixed document checklist.

The right question is not:

> “Did we produce every possible document?”

The right question is:

> “Do we have the minimum artifacts required to understand, verify, approve, and safely integrate this change at the current scope?”

That framing keeps the framework universal, practical, and compatible with both greenfield delivery and brownfield reconstruction.
