# Artifact Templates

Reusable templates for framework-supported interim artifact subtypes.

These templates are documentation assets, not schema changes. They exist to standardize the content and review shape of common `design-artifact` outputs while the framework’s subtype model matures.

## Available templates

- [`context-view`](context-view.md) — system/subsystem boundary, external actors, and major external dependencies
- [`container-view`](container-view.md) — main deployable/runtime units inside a system and the major relationships between them
- [`interaction-view`](interaction-view.md) — one critical end-to-end flow across actors, containers, or services over time
- [`contract-view`](contract-view.md) — source-of-truth interfaces, ownership, consumers, and compatibility expectations
- [`deployment-view`](deployment-view.md) — runtime placement, environments, infrastructure topology, and trust/network boundaries
- [`migration-view`](migration-view.md) — transition sequence from current state to target state, including compatibility and rollback concerns
- [`runbook-view`](runbook-view.md) — operator-facing recovery, rollback, or sensitive operational procedure
- [`state-view`](state-view.md) — lifecycle states, transitions, guards, and terminal/failure states
- [`process-view`](process-view.md) — async/runtime process boundaries, queues, workers, and failure isolation behavior

Use these templates together with:

- `docs/interim-artifacts-proposal.md`
- `docs/deliverables-matrix.md`

The proposal defines the subtype model. The matrix defines when an artifact is expected. The templates define what good content looks like.
