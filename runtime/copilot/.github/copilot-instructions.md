# AI in SDLC — Universal SDLC Co-pilot

You are an AI agent operating within the **AI in SDLC framework** — a universal system for AI-assisted software development across the full lifecycle.

## Framework Overview

Every SDLC task follows a universal phase backbone:
`Intake → Define → Decide → Produce → Verify → Approve → Integrate`

State is persisted in `.sdlc/` at the project root. Read phase packets from `.sdlc/phases/{work-item-id}/{phase}.json` before acting. Write your output back when the phase completes.

## Knowledge Base

All project knowledge lives in `.sdlc/`:
- **Work items**: `.sdlc/work-items/{id}.json`
- **Artifacts**: `.sdlc/artifacts/{kind}/{id}/` (requirements, design docs, test cases, bug reports)
- **Decisions**: `.sdlc/decisions/{id}.json`
- **Phase state**: `.sdlc/phases/{work-item-id}/{phase}.json`
- **Profiles**: `.sdlc/profiles/` (project stack, models, org policies)

Always load the project profile from `.sdlc/profiles/project.yaml` before generating code. Match the stack, conventions, and canonical examples defined there.

## Phase Packet Contract

Every phase must read the prior phase's packet and write its own before handing off:

```json
{
  "work_item_id": "wi-YYYYMMDD-NNN",
  "skill_id": "start-feature",
  "phase": "decide",
  "timestamp": "<ISO8601>",
  "input_artifact_version_ids": [],
  "output_artifact_version_ids": [],
  "decision_ids": [],
  "evidence_ids": [],
  "gate_status": "auto-pass | human-required | blocked",
  "artifact_gaps": [],
  "artifact_policy_applied": {
    "active_scope": null,
    "baseline_source": null,
    "work_type_source": null,
    "resolution_order": []
  },
  "open_questions": [],
  "risk_flags": [],
  "recommended_next_phase": "produce",
  "skip_phases": []
}
```

A phase cannot hand off unless outputs are linked to at least one upstream requirement, bug report, or decision.

## Artifact Policy Resolution

When a phase needs to decide whether a missing artifact is a blocker, a warning, or ignorable, resolve `project.yaml -> artifact_policy` in this order:

1. active scope reality
2. `project.yaml -> artifact_policy.by_work_type`
3. `project.yaml -> artifact_policy.baseline`
4. project-type guide defaults
5. framework deliverables matrix

Severity meanings:
- `required` — missing artifact must trigger a gate or an explicit reconstruction / waiver path
- `warn` — record an `artifact_gap` and recommend reconstruction or template routing
- `optional` — no automatic warning unless the workflow explicitly asks for it

Every phase that evaluates artifacts should persist:
- `artifact_gaps`: unresolved or noteworthy missing artifacts for the active scope
- `artifact_policy_applied`: which sources were used to resolve the policy

## Artifact Provenance

Every artifact version must record:
- `provenance_mode`: `external | human | ai | mixed`
- `approval_state`: `draft | proposed | approved | rejected | superseded`
- `authority_state`: `source | imported-reference | derived`

Never treat an artifact as approved unless `approval_state` is `approved`.

## Human Gate Policy

Gates trigger **only** for:
- Architecture or API contract changes
- New design artifacts
- PR merge readiness
- Security-sensitive code paths
- Missing `artifact_policy` artifacts marked `required` for the active scope

Everything else auto-passes when evidence thresholds are met (tests pass, lint clean, traceability link exists).

## Model Routing

Resolve model from `.sdlc/profiles/models.yaml`. Never hardcode a model name in prompts. Use tier references: `high` / `mid` / `low`.

## Code Generation Rules

1. Load `project.yaml` — match the exact stack, frameworks, and conventions
2. Load component profile if exists under `.sdlc/profiles/components/`
3. Follow `canonical_examples` — new code should match the reference implementations
4. Run the build and test commands defined in `project.yaml` to verify output
5. Link every produced artifact back to its upstream requirement or decision
