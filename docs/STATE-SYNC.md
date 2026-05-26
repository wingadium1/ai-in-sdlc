# State Synchronization Mechanism

> **Task 9** of AI-SDLC Integration Framework
>
> Defines how the 4 systems (GSD Redux, OMO/OpenCode, AI-in-sdlc, agent-for-ba)
> keep shared state consistent without a central orchestrator.

---

## 1. Design Principles

1. **File-based, not API-based** — All sync happens through lightweight file adapters reading/writing each system's canonical KB (per ADR-016: File-based Convention Layer Integration).
2. **Single-owner per state field** — Every piece of state has exactly one system that writes it; all others read it (per ADR-017: Distributed Knowledge Base Ownership).
3. **Eventual consistency with explicit gates** — Sync is asynchronous and polling-based. Human gates block propagation when conflicts are detected.
4. **Conflict = signal, not error** — A detected conflict means the systems disagree on reality; it triggers a human review rather than an automatic override.
5. **Write-once, read-many** — A state field is written by its owner and never mutated by another system. Cross-system updates are expressed as new events, not edits.

---

## 2. Canonical State Ownership Matrix

### 2.1 State Domains

| State Domain | Description | Canonical Owner | Storage Location |
|-------------|-------------|-----------------|------------------|
| **Work Item Lifecycle** | Phase transitions, status (open/in-progress/done), skill routing | AI-in-sdlc | `.sdlc/work-items/{id}.json` |
| **Phase Execution** | PhasePacket emission, gate status, artifact gaps, risk flags | AI-in-sdlc | `.sdlc/phases/{work-item-id}/{phase}.json` |
| **Execution Roadmap** | Milestones, phases, waves, task decomposition | GSD Redux | `.planning/PLAN.md` |
| **Execution Progress** | Which tasks are done, in-flight, blocked | GSD Redux | `.planning/STATE.md` / `.planning/boulder.json` |
| **Agent Runtime State** | Running tasks, background jobs, agent outputs | OMO/OpenCode | Implicit / `.sisyphus/` (runtime-specific) |
| **Domain Knowledge** | Requirements, UI specs, acceptance criteria | agent-for-ba | `wiki/projects/{name}/` |
| **Technical Artifacts** | Design artifacts, test cases, code index, decisions | AI-in-sdlc | `.sdlc/artifacts/` / `.sdlc/decisions/` |
| **Integration Mapping** | Cross-system handoff state, sync metadata, conflict log | Integration Layer | `.sdlc/integration/` |

### 2.2 Read/Write Permissions

| System | Can Write | Can Read (read-only) |
|--------|-----------|---------------------|
| **AI-in-sdlc** | `.sdlc/work-items/`, `.sdlc/phases/`, `.sdlc/artifacts/`, `.sdlc/decisions/`, `.sdlc/integration/` | `.planning/PLAN.md`, `.planning/STATE.md`, `wiki/projects/{name}/` |
| **GSD Redux** | `.planning/PLAN.md`, `.planning/STATE.md`, `.planning/tasks/`, `.planning/phases/` | `.sdlc/work-items/{id}.json`, `.sdlc/phases/{work-item-id}/`, `.sdlc/integration/` |
| **OMO/OpenCode** | Agent outputs (code, tests), implicit runtime state | `.sdlc/profiles/project.yaml`, `.sdlc/work-items/{id}.json`, `.planning/PLAN.md` |
| **agent-for-ba** | `wiki/projects/{name}/requirements/`, `wiki/projects/{name}/ui-spec/` | `.sdlc/artifacts/requirement/` (to check existing requirements) |
| **Integration Layer** | `.sdlc/integration/sync-state.json`, `.sdlc/integration/conflict-log.json` | All of the above (read-only adapter) |

---

## 3. Sync Rules

### 3.1 Sync Directions

```
+---------------+       +---------------+
|  GSD Redux    |       | agent-for-ba  |
| (.planning/)  |       |   (wiki/)     |
+-------+-------+       +-------+-------+
        |                       |
        | 1 PLAN -> WorkItem    | 3 Req -> Artifact
        | 2 Phase -> STATE      | 4 Invalidation
        |                       |
        v                       v
+---------------------------------------+
|         AI-in-sdlc (.sdlc/)          |
|  work-items/  phases/  artifacts/    |
+-------+-------+-----------+-----------+
        |                   |
        | 5 Dispatch task   | 6 Write outputs
        v                   v
+---------------+   +---------------+
|  OMO/OpenCode |   |   Codebase    |
| (task() calls)|   | (src/, tests/)|
+---------------+   +---------------+
```

### 3.2 Sync Triggers

| Sync Flow | Trigger | Source | Target | Action |
|-----------|---------|--------|--------|--------|
| **SF-1: Plan Ingestion** | `PLAN.md` created or updated | GSD Redux | AI-in-sdlc | Adapter parses PLAN.md and creates/updates `.sdlc/work-items/{id}.json` |
| **SF-2: Phase State Update** | PhasePacket written | AI-in-sdlc | GSD Redux | Adapter writes phase completion to `.planning/STATE.md` |
| **SF-3: Requirement Propagation** | `wiki/` requirement updated | agent-for-ba | AI-in-sdlc | Adapter converts markdown frontmatter to `.sdlc/artifacts/requirement/{id}/meta.json` |
| **SF-4: Invalidation Cascade** | Requirement version bumps | AI-in-sdlc | agent-for-ba | AI-in-sdlc marks linked artifacts `draft` in `.sdlc/artifacts/.../meta.json`; does NOT write to `wiki/` |
| **SF-5: Task Dispatch** | WorkItem enters Produce phase | AI-in-sdlc | OMO/OpenCode | Adapter extracts task from PhasePacket and emits `task()` call |
| **SF-6: Task Completion** | `task()` returns | OMO/OpenCode | AI-in-sdlc | Agent output (code, tests) written to codebase; Verify phase triggered |
| **SF-7: Decision Sync** | ADR accepted in Decide phase | AI-in-sdlc | GSD Redux | `.sdlc/decisions/{id}.json` mirrored to `.planning/decisions/` (read-only copy) |

### 3.3 Sync Timing

| Sync Type | Frequency | Mechanism |
|-----------|-----------|-----------|
| **Polling sync** | Every 30 seconds during active work | Adapter scans source KB for files with `mtime` newer than last sync checkpoint |
| **Event-driven sync** | Immediate on file write | Source system writes a `.sync` trigger file (e.g., `.sdlc/integration/triggers/gsd-{timestamp}.json`) |
| **Batch sync** | On commit / pre-push | CI adapter runs full consistency check and reconciles drift |
| **Manual sync** | On human command | `/sync-state` skill (future) forces a full reconciliation |

---

## 4. Conflict Detection

### 4.1 Conflict Definition

A **conflict** exists when two systems hold incompatible views of the same entity at the same logical time.

### 4.2 Conflict Types

| Type | ID | Description | Example |
|------|----|-------------|---------|
| **Phase Mismatch** | C-PHASE | GSD and AI-in-sdlc disagree on the current phase of a work item | GSD `STATE.md` says "Decide done"; AI-in-sdlc `PhasePacket` says "Decide blocked" |
| **Status Mismatch** | C-STATUS | A work item is marked done in one system but open in another | GSD checks off a task; AI-in-sdlc `work-item.json` still shows `status: in-progress` |
| **Artifact Version Fork** | C-ARTIFACT | Two systems independently modified the same artifact | BA updates requirement in `wiki/` while AI-in-sdlc updates `.sdlc/artifacts/requirement/` without ingesting the BA change |
| **Gate Override** | C-GATE | A human gate was bypassed or incorrectly auto-passed | AI-in-sdlc `gate_status: auto-pass` but GSD `STATE.md` shows `human-required` |
| **Circular Dependency** | C-CYCLE | Sync propagation creates a loop | GSD writes -> AI-in-sdlc reads -> AI-in-sdlc writes -> GSD reads -> GSD re-writes |
| **Orphaned Work Item** | C-ORPHAN | A work item exists in one KB but has no counterpart in another | `work-item.json` exists but no entry in `PLAN.md` |

### 4.3 Conflict Detection Algorithm

Each sync run performs the following checks:

```
FOR each work_item IN union(.sdlc/work-items/, .planning/tasks/):
  1. CROSS-REFERENCE: Does the work_item exist in ALL relevant KBs?
     IF missing in one KB -> flag C-ORPHAN

  2. PHASE ALIGNMENT: Compare phase field across systems
     IF .planning/STATE.md phase != .sdlc/phases/latest.phase -> flag C-PHASE

  3. STATUS ALIGNMENT: Compare completion state
     IF GSD task checked BUT AI-in-sdlc work-item.status != 'done' -> flag C-STATUS
     IF AI-in-sdlc work-item.status == 'done' BUT GSD task unchecked -> flag C-STATUS

  4. GATE CONSISTENCY: Compare gate_status
     IF .sdlc/phases/{phase}.gate_status != expected_from_STATE.md -> flag C-GATE

  5. ARTIFACT VERSION CHECK: Compare artifact version timestamps
     IF wiki/ requirement mtime > .sdlc/artifacts/requirement/ mtime -> flag C-ARTIFACT

  6. CYCLE DETECTION: Check sync propagation depth
     IF same work_item updated > 3 times in one sync window -> flag C-CYCLE
```

### 4.4 Conflict Log

All detected conflicts are written to `.sdlc/integration/conflict-log.json`:

```json
{
  "conflict_id": "C-20260526-001",
  "type": "C-PHASE",
  "severity": "blocking",
  "work_item_id": "wi-20260526-042",
  "systems_involved": ["gsd-redux", "ai-in-sdlc"],
  "canonical_value": "Decide",
  "divergent_value": "Produce",
  "detected_at": "2026-05-26T14:32:00Z",
  "resolution_status": "open",
  "assigned_to": "human"
}
```

---

## 5. Conflict Resolution Protocol

### 5.1 Resolution Principles

1. **Human authority wins** — When a conflict is detected, automatic resolution is forbidden. A human must decide which system's view is correct.
2. **Canonical owner wins by default** — If the human abstains, the canonical owner's value is adopted (see Section 2.1).
3. **No silent overwrite** — A sync adapter must never overwrite a conflicting value without logging it in the conflict log.
4. **Block forward progress** — A detected conflict blocks phase handoff until resolved.

### 5.2 Human Gate for Conflicts

When a conflict is detected, the following gate is triggered:

```
+--------------------------------------------------+
|  CONFLICT DETECTED: C-PHASE                      |
|  Work Item: wi-20260526-042                      |
|                                                  |
|  GSD Redux says:    Phase = "Decide" (done)      |
|  AI-in-sdlc says:   Phase = "Produce" (blocked)  |
|                                                  |
|  [Resolve as GSD]  [Resolve as AI-in-sdlc]      |
|  [View Details]    [Defer (blocks handoff)]     |
+--------------------------------------------------+
```

### 5.3 Resolution Actions

| Human Choice | Action | Side Effects |
|-------------|--------|--------------|
| **Accept GSD view** | Write GSD phase to AI-in-sdlc PhasePacket; mark conflict `resolved` | AI-in-sdlc may need to roll back or skip a phase |
| **Accept AI-in-sdlc view** | Update GSD `STATE.md` to match AI-in-sdlc phase; mark conflict `resolved` | GSD may need to create a new task or wave |
| **Defer** | Leave conflict open; block phase handoff | Work item cannot proceed until resolved |
| **Merge** | Human defines a merged state; write to both systems | Both KBs updated with the merged truth |

### 5.4 Auto-Resolution (Non-Blocking Conflicts Only)

The following conflicts MAY be auto-resolved without a human gate:

| Conflict Type | Auto-Resolution Rule | Rationale |
|--------------|---------------------|-----------|
| C-ORPHAN (work item in AI-in-sdlc only) | Create placeholder task in GSD `PLAN.md` | AI-in-sdlc is the canonical owner of work items |
| C-ORPHAN (work item in GSD only) | Create `work-item.json` with `status: draft` | GSD tasks should be tracked in the SDLC KB |
| C-GATE (minor drift) | Adopt AI-in-sdlc `gate_status` | AI-in-sdlc evaluates gate criteria; GSD records outcomes |
| C-ARTIFACT (BA ahead by <5 min) | Trigger immediate SF-3 sync | Timing jitter, not a real conflict |

**All other conflicts (C-PHASE, C-STATUS, C-ARTIFACT with significant divergence, C-CYCLE) MUST trigger a human gate.**

### 5.5 Post-Resolution Propagation

After a conflict is resolved:

1. The resolution is written to `.sdlc/integration/conflict-log.json` with `resolution_status: resolved`.
2. The winning state is propagated to all non-owning systems via the normal sync rules (Section 3).
3. A resolution event is emitted to prevent the same conflict from re-detecting on the next sync pass.

---

## 6. Sync State Checkpointing

### 6.1 Checkpoint File

`.sdlc/integration/sync-state.json` tracks the last successful sync per system pair:

```json
{
  "last_sync": "2026-05-26T14:30:00Z",
  "checkpoints": {
    "gsd-to-sdlc": {
      "last_file": ".planning/STATE.md",
      "last_mtime": "2026-05-26T14:28:00Z",
      "items_synced": 12
    },
    "sdlc-to-gsd": {
      "last_file": ".sdlc/phases/wi-20260526-042/Decide.json",
      "last_mtime": "2026-05-26T14:29:30Z",
      "items_synced": 8
    },
    "ba-to-sdlc": {
      "last_file": "wiki/projects/acme/requirements/login.md",
      "last_mtime": "2026-05-26T14:15:00Z",
      "items_synced": 3
    }
  },
  "open_conflicts": ["C-20260526-001"]
}
```

### 6.2 Recovery

If a sync run crashes or is interrupted:

1. The next sync run reads `sync-state.json` to resume from the last checkpoint.
2. Files with `mtime` newer than the checkpoint are re-evaluated.
3. If a conflict was being resolved when the crash occurred, it is re-detected and re-presented to the human.

---

## 7. Implementation Notes

### 7.1 Adapter Responsibilities

| Adapter | Source | Target | Key Logic |
|---------|--------|--------|-----------|
| `gsd-to-sdlc` | `.planning/` | `.sdlc/` | Parse markdown plans, map phases to 7-phase backbone |
| `sdlc-to-gsd` | `.sdlc/phases/` | `.planning/STATE.md` | Summarize PhasePacket state into markdown |
| `ba-to-sdlc` | `wiki/` | `.sdlc/artifacts/` | Extract frontmatter, serialize to ArtifactVersion |
| `sdlc-to-ba` | `.sdlc/artifacts/` | `wiki/` (read-only) | Generate invalidation warnings, NOT writes |
| `omo-dispatch` | `.sdlc/phases/Produce.json` | OMO `task()` | Extract task description, build prompt |
| `omo-callback` | OMO output | `.sdlc/phases/Verify.json` | Capture agent output, trigger Verify phase |

### 7.2 Future Enhancements

- **Vector-based sync**: When `VectorDBAdapter` or `GraphDBAdapter` is adopted, sync can use semantic similarity to detect conflicts in artifact content, not just metadata.
- **Real-time sync**: File watchers (e.g., `fswatch`, `inotify`) can replace polling for near-instant sync.
- **Conflict prediction**: Machine learning on conflict log patterns to predict and prevent conflicts before they occur.

---

## 8. Acceptance Criteria

| Criterion | Status |
|-----------|--------|
| Document at `docs/STATE-SYNC.md` | Done |
| State ownership matrix per system | Done (Section 2) |
| Sync rules (triggers, directions, timing) | Done (Section 3) |
| Conflict detection algorithm | Done (Section 4) |
| Conflict resolution protocol with human gate | Done (Section 5) |
| Sync state checkpointing | Done (Section 6) |
| Adapter responsibilities table | Done (Section 7.1) |

---

## Appendix A: Glossary

| Term | Definition |
|------|-----------|
| **KB** | Knowledge Base — a system's directory of persistent state |
| **PhasePacket** | The canonical handoff contract between SDLC phases (see ARCHITECTURE.md) |
| **Sync Adapter** | A lightweight script that reads one system's KB and writes to another's |
| **Human Gate** | A deliberate pause requiring human approval before a transition proceeds |
| **Canonical Owner** | The single system with write authority over a given state domain |
| **Conflict Log** | The audit trail of detected and resolved conflicts |
