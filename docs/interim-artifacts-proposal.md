# Proposal: Interim Artifacts and Brownfield Reconstruction

> Standardize the intermediate products between requirements, design, code, and operations without forcing every project to maintain the same document pack.

**Status**: Proposal only — no schema changes are made by this document yet.
**Intended follow-up**: Use this proposal to drive future updates to `.sdlc/` schema templates, work types, project-type guides, and runtime agent behavior.

---

## Why this proposal exists

The framework already standardizes the **phase backbone** and the **Artifact / ArtifactVersion** model, but it does not yet define a shared contract for the interim products that sit between SRS, design, implementation, verification, and release.

That gap becomes most visible in two cases:

1. **Greenfield delivery** — teams need enough architecture and design artifacts to release safely, but not so much documentation that the process becomes ceremonial.
2. **Brownfield maintenance** — teams often join a project mid-stream and discover that some or all architecture documentation is missing, stale, or split across code, tickets, and tribal knowledge.

The framework should therefore standardize:

- which interim artifacts exist,
- what question each artifact answers,
- which artifacts are required vs recommended vs optional,
- how artifacts map to project types,
- how missing artifacts are reconstructed incrementally,
- and how AI-generated or imported artifacts become trustworthy through provenance and approval.

This proposal keeps the framework **universal**. It does not introduce new phases. It defines an adaptive artifact contract that plugs into the existing SDLC backbone.

---

## Design principles

### 1. Standardize the contract, not the ceremony

The framework should standardize the **purpose** of interim artifacts, not force every team to produce the same set of diagrams.

For example, a project may need an interaction view, but that does not always mean a mandatory sequence diagram. The interaction view could be represented as:

- a sequence diagram,
- an activity diagram,
- a state machine,
- or a structured text artifact when the flow is simple.

### 2. Use one universal phase backbone

Interim artifacts are produced, verified, approved, and superseded through the existing phase flow:

`Intake → Define → Decide → Produce → Verify → Approve → Integrate`

Skills and work types may change **which** artifacts are expected, but they must not create separate pipelines.

### 3. Prefer adaptive completeness over exhaustive documentation

Not every team needs every view.

The framework should distinguish:

- **required** — needed for safe delivery or operation,
- **recommended** — high-value in common cases,
- **optional** — useful only when complexity or regulation justifies it.

### 4. Brownfield reconstruction is incremental

Missing architecture should be rebuilt **where change is happening**, not by attempting a full-system documentation sweep before work can begin.

The framework should support reconstructing:

- one system boundary,
- one service,
- one critical flow,
- one deployment slice,
- or one bounded context at a time.

### 5. Reconstructed artifacts are hypotheses until approved

Imported, AI-generated, or partially reconstructed artifacts must carry explicit provenance and approval state.

`.sdlc/` is an **audit trail, not a cache**. Reconstructed documents must be recorded as normal Artifact + ArtifactVersion entries and pass through the normal approval model before becoming authoritative.

---

## Proposed artifact model

The framework should define **interim artifacts** as a layer spanning requirements, architecture, design, implementation planning, verification, and release readiness.

Each interim artifact answers a specific question.

| Artifact family | Primary question answered | Typical ArtifactKind |
|---|---|---|
| Requirement artifact | What problem are we solving and what does done mean? | `requirement` |
| Scope / scenario artifact | Which actor or flow are we describing? | `design-artifact` or `requirement` |
| Architecture context artifact | What system boundary and external dependencies exist? | `design-artifact` |
| Architecture structure artifact | What deployable units, services, modules, or components exist? | `design-artifact` |
| Interaction artifact | How does behavior flow across components or services at runtime? | `design-artifact` |
| State artifact | How does an entity or process transition through states? | `design-artifact` |
| Deployment artifact | Where does the system run and what infrastructure boundaries matter? | `design-artifact` |
| Contract artifact | What API, schema, event, or interface is the source of truth? | `design-artifact` |
| Test design artifact | How will correctness be verified? | `test-case` |
| Review artifact | What findings, risks, or approvals were recorded? | `review-note` |
| Bug / incident artifact | What failed, why, and what evidence exists? | `bug-report` |
| Release / operations artifact | What must be true to release, roll back, or operate safely? | `release-note` or `design-artifact` |

This proposal does **not** require a new ArtifactKind for every diagram type. In most cases, diagram and structured design outputs should remain under `design-artifact`, with additional metadata describing subtype and scope.

---

## C4 + 4+1 synthesis

The framework should combine **C4** and **4+1** as follows:

- **C4** provides the most practical notation and zoom levels.
- **4+1** provides the most useful vocabulary for deciding which views are needed and which stakeholders they serve.

### Practical mapping

| Need | Preferred representation | C4 / 4+1 mapping |
|---|---|---|
| System boundary and external actors | System Context diagram | C4 Context / 4+1 Scenarios |
| Deployable applications, services, databases, queues | Container diagram | C4 Container / 4+1 Physical |
| Internal modules within a service or app | Component diagram | C4 Component / 4+1 Logical |
| End-to-end behavior for a critical flow | Sequence or activity diagram | C4 Dynamic / 4+1 Scenarios + Process |
| Async/concurrency/runtime boundaries | Sequence/activity/process view | 4+1 Process |
| Build/package/module boundaries | Development view | 4+1 Development |
| Infrastructure topology and runtime placement | Deployment diagram | C4 Deployment / 4+1 Physical |
| Entity or workflow lifecycle | State machine | 4+1 Logical / Process |
| Design rationale | ADR / decision artifact | outside C4, complements all views |

### Recommended stance

- Use **C4** for standard diagram structure and readability.
- Use **4+1** to decide **which views are worth producing**.
- Treat ADRs and requirement artifacts as the rationale and intent layer that neither C4 nor 4+1 fully covers.

---

## Required vs recommended vs optional artifacts

The framework should classify interim artifacts by delivery risk, not by modeling ideology.

### Required for most release-ready systems

| Artifact | Why it is required |
|---|---|
| Requirement / acceptance criteria | Defines done and anchors traceability |
| System context view | Clarifies external dependencies and system boundary |
| Container view | Clarifies deployable/runtime units |
| At least one critical interaction view | Validates the architecture against a real scenario |
| Source-of-truth contract artifacts | Prevents interface drift |
| ADRs for consequential decisions | Preserves rationale across phases and releases |

### Recommended in common cases

| Artifact | When it is valuable |
|---|---|
| Component view | Service internals, onboarding, large modules, refactors |
| Deployment view | Cloud systems, infra-heavy projects, incident readiness |
| Test design artifact | Complex acceptance criteria, regulated systems, tricky verification |
| Release / rollback artifact | Multi-service or high-risk deployments |
| Review-note artifacts | High-risk change review, auditability, governance |

### Optional / selective

| Artifact | When to use it |
|---|---|
| Code-level diagram | Only when auto-generated or needed for deep analysis |
| Full logical class model | Regulated, high-assurance, or heavily model-driven domains |
| State machine | When entity/process lifecycle complexity justifies it |
| Development view | Monorepos, plugin systems, complex build boundaries |

---

## Project-type applicability matrix

The same artifact contract should apply across all project types, but the required minimum differs.

| Project type | Minimum views beyond requirements |
|---|---|
| web-frontend | context, container, component, critical interaction, UX state if flow-heavy |
| backend-api | context, container, contract, critical interaction, deployment |
| full-stack-web | context, container, contract, critical interaction |
| mobile | context, container, interaction, release / distribution notes |
| microservices | context, container, deployment, critical interaction, process view, contracts |
| data-ml | context, container, data contract, interaction, deployment, metric thresholds |
| cli-devtool | context, component, contract / CLI interface, release notes |
| embedded-firmware | context, deployment / hardware view, state model, interaction |
| infrastructure-iac | context, deployment / physical view, change blast radius, rollback artifacts |

Project types should refine this through `project.yaml`, component profiles, and future artifact-specific overrides.

---

## Brownfield reconstruction workflow

Brownfield reconstruction should be a first-class operating mode of the framework.

### Goal

When architecture or design artifacts are missing, stale, or fragmented, the framework should help the team reconstruct the **minimum viable, currently useful** documentation before or during change work.

### Reconstruction stages

#### Stage 1 — Inventory

Identify what already exists:

- source code,
- API specs,
- infrastructure definitions,
- diagrams,
- README / wiki / PRD / SRS,
- test flows,
- incident reports,
- dashboards / APM traces,
- human knowledge holders.

Output:

- artifact inventory,
- source-of-truth candidates,
- missing-view list,
- confidence level per source.

#### Stage 2 — Minimum viable reconstruction

Rebuild only the views needed for the immediate task or release.

Typical targets:

- one context view,
- one container view,
- one critical flow sequence/activity diagram,
- one contract map,
- one deployment slice.

Output:

- draft design artifacts marked as reconstructed,
- open questions list,
- risk flags for unverified assumptions.

#### Stage 3 — Validation

Validate reconstructed artifacts using multiple signals:

- code structure,
- runtime traces,
- test flows,
- recent incidents,
- reviewer confirmation.

Output:

- updated confidence,
- approved or rejected artifacts,
- ADRs for clarified architecture decisions.

#### Stage 4 — Incremental deepening

Only extend documentation where justified by change frequency, operational risk, onboarding pain, or architectural ambiguity.

The framework should explicitly avoid “document the whole system first” as the default strategy.

---

## Reconstruction scope model

Reconstruction should support **partial scope**, not only whole-system scope.

Allowed scopes should include:

- `system`
- `subsystem`
- `service`
- `bounded-context`
- `component`
- `flow`
- `release-slice`

Examples:

- “Reconstruct the checkout payment flow.”
- “Reconstruct the container and deployment view for the auth service.”
- “Reconstruct the state model for order lifecycle.”

This makes the approach practical for maintenance work and ongoing releases.

---

## Provenance, authority, and confidence for reconstructed artifacts

Reconstruction must use the existing `ArtifactVersion` model.

### Required ArtifactVersion semantics

Every reconstructed artifact should record:

- `provenance_mode`
- `provider`
- `created_by_actor`
- `created_in_execution`
- `created_at`
- `checksum`
- `approval_state`
- `authority_state`
- `derives_from`
- `supersedes` when applicable

### Detailed `artifact_subtype` model

The framework should treat `artifact_subtype` as the primary classifier for `design-artifact` records and, when useful, for other artifact kinds such as `release-note` and `test-case`.

#### Naming rules

Subtype values should:

- use **kebab-case**,
- describe the artifact's architectural or delivery purpose,
- avoid tool-specific names (`mermaid-diagram`, `plantuml-diagram`),
- avoid role-specific names (`ops-doc`, `developer-doc`),
- and remain stable across runtimes.

Good examples:

- `context-view`
- `container-view`
- `interaction-view`
- `deployment-view`
- `release-checklist`

Bad examples:

- `drawio-file`
- `diagram-v2`
- `backend-architecture-doc`

#### Proposed subtype taxonomy

##### Architecture boundary and structure

| Subtype | Purpose | Typical scope |
|---|---|---|
| `context-view` | System boundary, external actors, upstream/downstream systems | system, subsystem |
| `system-landscape-view` | Relationship among multiple systems in the organization or platform | system, portfolio |
| `container-view` | Deployable/runtime units such as apps, services, DBs, queues | system, subsystem |
| `component-view` | Internal modules/components within one container or service | service, component |
| `development-view` | Build-time/package/module structure and ownership boundaries | repo, subsystem, service |

##### Runtime behavior

| Subtype | Purpose | Typical scope |
|---|---|---|
| `interaction-view` | End-to-end flow across components/services; usually sequence or activity | flow, service, system |
| `process-view` | Runtime concurrency, async boundaries, queues, failure isolation | service, subsystem, system |
| `state-view` | Entity or workflow lifecycle and legal transitions | entity, workflow, service |
| `failure-mode-view` | Retry, timeout, degradation, circuit breaker, recovery behavior | flow, service, subsystem |

##### Delivery and operations

| Subtype | Purpose | Typical scope |
|---|---|---|
| `deployment-view` | Nodes, infrastructure topology, runtime placement, trust boundaries | service, subsystem, system |
| `environment-view` | Differences across local, staging, production, or tenant environments | environment, system |
| `release-checklist` | Release-readiness, rollback, migration, operational preconditions | release-slice, system |
| `runbook-view` | Human/operator recovery or operational procedure | service, workflow |

##### Contracts and planning

| Subtype | Purpose | Typical scope |
|---|---|---|
| `contract-view` | API/event/schema/interface source-of-truth map | service, system, flow |
| `scenario-view` | Use-case or validation scenario used to test architecture against real behavior | flow, user-journey |
| `test-design-view` | Verification strategy for a critical flow or system slice | flow, service, release-slice |
| `migration-view` | Data, interface, or rollout transition plan between old and new states | release-slice, subsystem |

#### Normalization rule

The framework should prefer **semantic subtypes** over diagram notation. For example:

- Mermaid sequence diagram → `interaction-view`
- Excalidraw infrastructure diagram → `deployment-view`
- Markdown rollout checklist → `release-checklist`
- PlantUML state machine → `state-view`

This keeps artifact identity stable even if the rendering tool changes.

#### Scope compatibility rule

Each subtype should declare the scopes it supports. For example:

- `context-view` → `system`, `subsystem`
- `component-view` → `service`, `component`
- `interaction-view` → `flow`, `service`, `system`
- `release-checklist` → `release-slice`

If a subtype/scope combination is invalid, the framework should flag it during Define or Verify.

### Proposed additional metadata

The framework should allow interim and reconstructed artifacts to carry structured metadata such as:

- `artifact_subtype`
- `scope_type`: `system`, `subsystem`, `service`, `bounded-context`, `component`, `flow`, `entity`, `workflow`, `environment`, `release-slice`
- `scope_ref`: stable identifier for the target scope (`auth-service`, `checkout-payment-flow`, `order-lifecycle`)
- `confidence_level`: `low`, `medium`, `high`
- `validation_status`: `unvalidated`, `partially-validated`, `validated`
- `reconstructed_from`: list of source categories (`code`, `api-spec`, `infra`, `incident`, `human-interview`, `trace`, `ticket`, `legacy-doc`)
- `source_artifact_version_ids`: upstream artifact versions used during reconstruction or derivation
- `view_purpose`: concise sentence explaining what architectural question this artifact answers
- `audience`: list such as `developer`, `reviewer`, `operator`, `architect`, `product`
- `freshness_expectation`: `per-release`, `on-change`, `continuous`, `incident-driven`
- `waiver_state`: `none`, `waived`, `deferred`
- `waiver_rationale`: required when `waiver_state` is not `none`

These fields should initially live in artifact content frontmatter or artifact-specific metadata blocks, then move into formal schema only after the model stabilizes.

### Recommended metadata placement

To avoid a breaking change to the core `ArtifactVersion` schema in M1, the framework should use a two-layer approach:

1. **Core `ArtifactVersion` fields remain unchanged** for provenance, approval, authority, and traceability.
2. **Artifact-specific metadata** is stored either:
   - in frontmatter at the top of `content.md`, or
   - in a sibling `attributes.yaml` file under the artifact directory.

Recommended M1 structure:

```text
.sdlc/artifacts/design-artifact/{id}/
├── meta.json
├── content.md
└── attributes.yaml
```

Where `meta.json` keeps the canonical cross-artifact fields, and `attributes.yaml` stores subtype-specific metadata.

### Example `attributes.yaml`

```yaml
artifact_subtype: interaction-view
scope_type: flow
scope_ref: checkout-payment-flow
view_purpose: "Show the end-to-end interaction between checkout, payment, fraud, and notification services."
audience:
  - developer
  - reviewer
  - operator
confidence_level: medium
validation_status: partially-validated
reconstructed_from:
  - code
  - trace
  - incident
source_artifact_version_ids:
  - av-codefile-checkout-handler-v3
  - av-contract-payment-api-v2
freshness_expectation: on-change
waiver_state: none
```

### Trust rules

- Imported legacy documents default to `approval_state: draft` unless approved in the framework.
- AI-generated reconstruction defaults to `authority_state: derived`.
- No reconstructed artifact should be treated as source-of-truth until it passes Approve.
- Any artifact with unresolved assumptions must carry explicit open questions in the PhasePacket.

---

## Proposed artifact production rules

### For greenfield work

Before implementation begins, the framework should ensure the minimum required artifacts for the project type exist or are intentionally waived.

### For brownfield work

Before significant change work proceeds, the framework should:

1. detect missing required views for the target scope,
2. reconstruct the minimum viable subset,
3. route them through Define / Decide / Approve as needed,
4. then continue feature or maintenance execution.

### For release readiness

A release candidate should not rely entirely on implicit architecture.

At minimum, release readiness should include:

- traceable requirements,
- current boundary/structure views,
- at least one critical runtime flow view,
- source-of-truth contracts,
- operationally relevant release notes or rollback guidance,
- approved decisions for material tradeoffs.

---

## Proposed framework behavior

### 1. Adaptive artifact expectations

The framework should define a matrix of artifact expectations by:

- project type,
- work type,
- scope,
- release risk.

Projects should also be able to refine those expectations explicitly in `project.yaml`, rather than only inheriting guide defaults.

### 2. Artifact-gap detection

Intake and Define should be able to identify missing required artifacts for the current task.

Those checks should respect project-level artifact policy, especially when a team wants to elevate a view from “recommended” to “required” for its environment or workflows.

Example:

- work type: `requirement-analysis`
- project type: `microservices`
- scope: `service + flow`

If no current interaction view or contract artifact exists, the framework should raise an artifact gap before continuing.

### 3. Reconstruction as a skill / work type

The framework should eventually support a dedicated capability such as:

- skill: `reconstruct-architecture`
- or work type: `architecture-reconstruction`

This should orchestrate inventory → reconstruction → validation → approval.

### 4. Partial approval

Approval should apply to the reconstructed slice, not require whole-system sign-off.

For example:

- approve one sequence diagram for checkout,
- approve one container diagram for auth service,
- approve one deployment slice for notification pipeline.

---

## Suggested first implementation milestone

The first implementation should stay small and pragmatic.

### M1

1. Define a standard set of `design-artifact` subtypes:
   - context-view
   - container-view
   - component-view
   - interaction-view
   - state-view
   - deployment-view
   - contract-view

2. Add a document template for reconstructed artifacts with:
   - scope
   - confidence
   - reconstructed_from
   - open_questions
   - validation status

3. Define a release-readiness minimum matrix by project type.

4. Add a documented brownfield workflow for reconstructing missing artifacts incrementally.

5. Later, add a dedicated skill / work type for architecture reconstruction.

---

## Open design questions

These questions should be resolved before schema changes are finalized:

1. When should `artifact_subtype` move from `attributes.yaml` into the formal core schema?
2. Should confidence and validation be global ArtifactVersion fields or only design-artifact metadata?
3. Should interaction/state/deployment diagrams remain generic `design-artifact` or gain dedicated ArtifactKinds?
4. How should project types declare minimum required views — `project.yaml`, guide docs, or a dedicated artifact policy file?
5. How should human waiver of a “recommended but missing” artifact be recorded?

---

## Recommendation

Adopt an **adaptive interim artifact contract** for the framework.

Use:

- **C4** as the primary structure/notation model,
- **4+1** as the view-selection vocabulary,
- **Artifact + ArtifactVersion** as the persistence model,
- and **incremental brownfield reconstruction** as the default recovery strategy when documentation is missing.

This gives the framework a strong design/documentation layer without forcing every project into heavyweight architecture ceremony.
