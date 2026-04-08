---
name: reconstruct-architecture
description: Reconstruct missing or stale architecture/design artifacts for an existing project or subsystem. Detects artifact gaps, rebuilds the minimum useful slice, validates it, and records the result in `.sdlc/`. Use when a developer says "map this system", "recover the architecture", "we're missing diagrams", or "understand how this flow works".
argument-hint: "[system, subsystem, service, flow, or brownfield scope to reconstruct]"
user-invocable: true
work-type: null
---

# Skill: reconstruct-architecture

Reconstructs missing architecture/design artifacts for brownfield or partially documented systems.

This skill is not a full implementation workflow. It is a recovery workflow that creates the minimum useful artifact slice needed for understanding, review, debugging, or release.

## When to use

Use this skill when the user is trying to:

- recover missing architecture or design documentation
- understand an unfamiliar system, service, or flow before making changes
- reconstruct the minimum required views for brownfield maintenance

Typical user phrases:

- "map this system"
- "reconstruct the checkout flow"
- "we're missing architecture docs for this service"

## When not to use

Do **not** use this skill when:

- the user already has the required architecture artifact and needs to implement a feature → use `/start-feature`
- the user only wants to update requirements → use `/update-requirements`
- the user is fixing a bug and already has sufficient architecture context → use `/fix-bug`

Anti-trigger examples:

- "implement password reset" → should use `/start-feature`
- "fix this null pointer in auth service" → should use `/fix-bug`
- "update AC-3 for timeout behavior" → should use `/update-requirements`

## How to invoke

Primary invocation:

`/reconstruct-architecture <scope>`

Alternative invocation patterns:

- `/reconstruct-architecture checkout-payment-flow`
- `/reconstruct-architecture auth-service`
- `/reconstruct-architecture payment-platform`

## What happens

| Phase | What the AI does | Human does |
|-------|------------------|-----------|
| **Intake** | Defines the reconstruction scope and loads any existing docs/artifacts/specs | Clarify the scope if ambiguous |
| **Define** | Inventories current sources, detects missing artifact gaps, and chooses the minimum useful templates | Confirm priorities if several gaps are equally urgent |
| **Decide** | Chooses the reconstruction order and records assumptions/risk | Review if the scope or authority of artifacts is unclear |
| **Produce** | Creates draft design artifacts using `docs/artifact-templates/` and records subtype metadata | Optionally refine human-known facts |
| **Verify** | Cross-checks reconstructed artifacts against code, tests, specs, infra, or runtime evidence | Validate or correct uncertain assumptions |
| **Approve** | Packages reconstructed artifacts for approval if they will become reference material | Approve the active slice if needed |
| **Integrate** | Stores the reconstructed slice in `.sdlc/` with provenance, confidence, and traceability | Use the recovered artifacts for downstream work |

## Work type

`work-type: null` for now because this skill spans multiple artifact questions rather than one existing reasoning pattern. It coordinates gap detection, subtype routing, and validation across several artifact templates.

## Key constraints

- reconstruct the smallest useful slice first
- do not attempt whole-system documentation by default
- keep confidence and assumptions explicit
- use the template set under `docs/artifact-templates/`
- treat reconstructed outputs as normal `.sdlc/` artifacts with provenance and approval state

## Gate behavior

This skill usually produces `draft` or `proposed` design artifacts.

Human approval is recommended when:

- reconstructed artifacts will become a source of truth for other work
- the scope crosses architecture or API boundaries
- key assumptions remain unresolved

## Project adaptation

Before reconstructing, the AI loads:

- `.sdlc/profiles/project.yaml`
- `.sdlc/decisions/*.json`
- existing `.sdlc/artifacts/`
- `docs/deliverables-matrix.md`
- `docs/interim-artifacts-proposal.md`
- `docs/artifact-templates/*.md`

## Output artifacts in `.sdlc/`

- `.sdlc/work-items/{id}.json` — reconstruction work item
- `.sdlc/artifacts/design-artifact/{id}/` — reconstructed views
- `.sdlc/phases/{id}/*.json` — full phase trail
- optional linked review or decision records when reconstruction clarifies architecture choices

## Trigger examples

These should trigger this skill:

1. "map this payment system before we change it"
2. "reconstruct the checkout payment flow"
3. "we're missing architecture docs for auth service"
4. "recover the deployment picture for this platform"
5. "understand the interfaces and runtime layout of this brownfield repo"

## Anti-trigger examples

These should **not** trigger this skill:

1. "implement password reset" → `/start-feature`
2. "fix flaky test in checkout" → `/fix-bug`
3. "review this PR" → `/code-review`
4. "update timeout requirement to 30s" → `/update-requirements`
5. "initialize .sdlc for this repo" → `/sdlc-init`
