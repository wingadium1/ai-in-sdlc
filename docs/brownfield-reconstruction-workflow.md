# Brownfield Reconstruction Workflow

> Workflow for recovering missing or stale architecture/design artifacts in an existing project without forcing a full-system documentation rewrite.

**Status**: Framework workflow reference.
**Purpose**: Turn artifact-gap detection into a practical, repeatable workflow for reconstructing the minimum viable architectural slice needed for change, review, debugging, or release.

---

## Why this workflow exists

Most real projects do not begin with a clean, current architecture corpus.
Teams often enter a codebase mid-stream and find:

- missing diagrams,
- stale README or wiki pages,
- incomplete API ownership,
- undocumented deployment boundaries,
- or tribal-knowledge-only flows.

The framework should not force a team to “document everything first.”
Instead, it should reconstruct the **smallest useful artifact slice** needed for the active scope.

This workflow operationalizes that principle.

---

## Workflow summary

`Inventory → Gap Detection → Minimum Viable Reconstruction → Validation → Approval / Integration`

This workflow is intentionally scope-first and incremental.

---

## Stage 1 — Inventory

Goal: identify what already exists and how trustworthy it is.

### Search sources

- source code and repository structure
- OpenAPI / AsyncAPI / protobuf / JSON Schema files
- IaC and deployment config
- existing `.sdlc/artifacts/`
- README / docs / wiki pages
- Mermaid / Excalidraw / PlantUML diagrams
- tests and test flows
- incidents / bug reports / review notes
- dashboards, traces, or logs when available

### Output

- artifact inventory
- source-of-truth candidates
- stale artifact candidates
- confidence notes per source

---

## Stage 2 — Gap detection

Goal: identify the minimum required artifacts that are missing for the current task.

Use these inputs together:

- project type
- work type
- active scope
- deliverables matrix
- current risk / release context

### Typical gaps

- missing `context-view` for an unfamiliar subsystem
- missing `interaction-view` for a critical flow under debug
- missing `contract-view` for an API/event change
- missing `deployment-view` for runtime or infra-sensitive work
- stale `container-view` when service/runtime boundaries changed

### Output

- missing-view list
- recommended template list
- reconstruction priority order

---

## Stage 3 — Minimum viable reconstruction

Goal: create only the artifacts needed to continue safely.

### Reconstruction rules

1. Start with the active scope, not the whole system.
2. Use the matching template from `docs/artifact-templates/`.
3. Record uncertainty explicitly.
4. Link reconstructed artifacts to their sources.
5. Stop once the change/review/debug question can be answered safely.

### Common reconstruction sequences

#### A. Unknown system boundary

1. `context-view`
2. `container-view`

#### B. Unknown critical flow

1. `interaction-view`
2. `contract-view` if interfaces shape the flow

#### C. Unknown runtime placement or infra behavior

1. `deployment-view`
2. `container-view` if logical/runtime mapping is unclear

#### D. Cross-service / cross-team review

1. `contract-view`
2. `interaction-view`
3. `deployment-view` if rollout or blast radius matters

### Output

- draft `design-artifact` records
- `attributes.yaml` with subtype metadata
- open questions / assumptions
- explicit confidence level

---

## Stage 4 — Validation

Goal: prove the reconstructed artifacts are grounded enough to use.

### Validation signals

- code structure and call paths
- tests or test flows
- runtime traces / logs / dashboards
- specs and schema files
- IaC or deployment config
- human reviewer confirmation

### Validation outcomes

- `validation_status: validated`
- `validation_status: partially-validated`
- keep `validation_status: unvalidated` and raise a gate

### Core rule

A reconstructed artifact can guide work while still being `partially-validated`, but it must not quietly pretend to be authoritative.

---

## Stage 5 — Approval and integration

Goal: turn reconstruction into a usable part of the framework knowledge base.

### Requirements

- store the artifact as a normal `design-artifact`
- include subtype metadata
- link `derives_from`
- mark `authority_state: derived` unless promoted by approval
- update `approval_state` normally through the framework gate path

### Approval model

Approve the active slice only, for example:

- one flow interaction-view
- one service contract-view
- one subsystem deployment-view

Do **not** require whole-system re-approval unless the scope truly changed system-wide.

---

## Scope-first execution model

Allowed scopes include:

- `system`
- `subsystem`
- `service`
- `bounded-context`
- `component`
- `flow`
- `release-slice`

Examples:

- reconstruct checkout payment flow
- reconstruct auth service deployment view
- reconstruct notification contract ownership
- reconstruct the release slice for a production migration

---

## Template routing guide

Use this quick mapping when a gap is detected:

| Question | Recommended template |
|---|---|
| What system boundary are we in? | `context-view` |
| What runtime units exist? | `container-view` |
| How does this flow actually work? | `interaction-view` |
| What interface is the source of truth? | `contract-view` |
| Where does this run, and what boundaries matter? | `deployment-view` |

---

## Recommended skill handoff

When artifact gaps are detected during `/sdlc-init`, debugging, code review, or requirement analysis, the framework should route to:

- `/reconstruct-architecture`

That skill should:

1. inventory existing sources,
2. detect the minimum missing views,
3. reconstruct the smallest useful slice,
4. validate it,
5. and leave a traceable artifact trail in `.sdlc/`.

---

## Common mistakes to avoid

### 1. Whole-system perfectionism

Trying to rebuild every architecture artifact before continuing any work.

Fix: reconstruct only the slice needed for the active task.

### 2. Tool-first reconstruction

Generating a diagram because a tool can, not because a question needs answering.

Fix: pick the template based on the missing architectural question.

### 3. Hidden uncertainty

Treating inferred ownership, flow ordering, or deployment topology as fact.

Fix: keep confidence and assumptions explicit.

### 4. Reconstruction without integration

Creating documents outside `.sdlc/` traceability and approval flow.

Fix: treat reconstructed artifacts as first-class framework artifacts.

---

## Final recommendation

Brownfield reconstruction should be a normal framework workflow, not an emergency exception.

The right objective is:

> reconstruct the minimum architecture/design slice required to safely continue the current work.

That keeps the framework practical for maintenance teams, reduces documentation theater, and makes architecture recovery part of normal SDLC execution.
