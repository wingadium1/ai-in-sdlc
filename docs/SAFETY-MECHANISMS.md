# ai-in-sdlc — Safety Mechanisms

This document defines the safety, control, and recovery systems that prevent the AI phase engine from running off-rails during autonomous execution. It complements the human-gate policy in [ADR-010](DECISIONS.md#adr-010) with *automated* guardrails that operate inside and between phases.

These mechanisms apply to all runtimes (GitHub Copilot, Claude Code, OpenCode) but vary in implementation detail based on each runtime's autonomy model.

---

## 1. Circuit Breakers

A **circuit breaker** is an automated stop condition that halts or pauses execution before damage occurs. Circuit breakers are *orthogonal* to human gates — they fire automatically without waiting for human review.

### 1.1 Max Autonomous Phases

**Rule**: No work item may execute more than **N consecutive fully-autonomous phases** without a human checkpoint.

| Runtime | N | Checkpoint Mechanism |
|---------|---|---------------------|
| GitHub Copilot | 1 | Handoff button (`send: false`) between every phase; autopilot mode is per-session opt-in |
| Claude Code | 3 | `--dangerously-skip-permissions` caps at 3 autonomous `Task` calls before interactive prompt |
| OpenCode | 3 | `task()` calls with `run_in_background=true` are limited to 3 per work item; `question` tool forces gate |

**Rationale**: Even in autonomous mode, humans must re-enter the loop periodically. Three phases (e.g., `Intake → Define → Decide`) is enough to complete analysis and planning, but `Produce` — the only phase that mutates the working tree — requires explicit human permission or a circuit-breaker pause.

**Override**: None. This is a hard safety limit. The only way to continue is for the human to click/confirm the next step.

### 1.2 Stop Conditions

The following conditions trigger an immediate **soft stop** (pause for human review) or **hard stop** (abort and preserve state):

| Condition | Severity | Trigger | Recovery |
|-----------|----------|---------|----------|
| **Test failure cascade** | Hard | >3 consecutive test failures in Produce with no passing state | Rollback to pre-Produce snapshot |
| **Unbounded loop** | Hard | >10 iterations of the same phase without producing a new artifact | Abort, mark execution as `failed`, preserve PhasePacket |
| **Token budget exhaustion** | Soft | Cumulative token spend exceeds per-work-item budget (see §1.3) | Pause; human may approve budget increase or switch to scaffold mode |
| **Time limit exceeded** | Soft | Wall-clock time since work-item start exceeds per-skill limit | Pause; human may extend or abort |
| **Divergence from plan** | Soft | Replanning detector flags a material deviation (see §2) | Pause; human reviews deviation and approves replan or rollback |
| **Security-sensitive path touched** | Hard | File matching `security_path_patterns` in `org.yaml` is modified without Approve gate | Revert the file change, force Approve gate |
| **External dependency added** | Soft | New entry in `package.json`, `requirements.txt`, `Cargo.toml`, etc. | Pause; human confirms dependency is approved |
| **Gate bypass detected** | Hard | PhasePacket shows `human-required` gate but no human Decision recorded | Halt immediately, flag audit log |

### 1.3 Token Budget Model

Each work item carries a **token budget** derived from the skill configuration and model tier:

```yaml
# .sdlc/profiles/org.yaml
safety:
  token_budgets:
    default: 500_000        # tokens per work item
    per_phase:
      intake: 10_000
      define: 30_000
      decide: 100_000
      produce: 300_000
      verify: 20_000
      integrate: 10_000
    per_skill:
      start-feature: 750_000
      fix-bug: 250_000
      write-unit-tests: 200_000
```

- **Soft cap**: At 80% of budget, the agent emits a budget-warning artifact and switches to lower-tier model for mechanical tasks.
- **Hard cap**: At 100% of budget, the agent stops and hands off to human with a summary of work completed and remaining.
- **Overflow**: Human may grant a one-time `budget_extension` (e.g., `+200_000` tokens) recorded in the PhasePacket.

### 1.4 Circuit Breaker State Machine

```
[Closed]  ──trigger──>  [Open]  ──human resume──>  [Half-Open]  ──success──>  [Closed]
   │                       │                              │
   │                       └──── rollback (§3) ──────────┘
   └─────────────────────────────────────────────────────┘
```

- **Closed**: Normal execution. Breakers monitor conditions.
- **Open**: Execution halted. No agent actions permitted until human resolves.
- **Half-Open**: One trial phase allowed (e.g., a single `Task` or `task()` call). If it succeeds, breaker closes. If it fails, breaker re-opens and rollback is offered.

---

## 2. Replanning Detection

**Replanning** occurs when the AI deviates from the approved plan produced in the `Decide` phase. This is normal for minor course corrections, but *material* replanning — changes to architecture, scope, or dependencies — requires human approval.

### 2.1 Plan as Contract

The `Decide` phase emits a `decision.json` containing:

```json
{
  "plan": {
    "scope_boundaries": ["src/auth/*", "tests/auth/*"],
    "new_dependencies": [],
    "api_changes": [],
    "data_model_changes": [],
    "expected_artifacts": ["src/auth/PasswordResetService.ts", "tests/auth/PasswordResetService.test.ts"],
    "risk_flags": ["none"]
  }
}
```

This plan is the **contract** against which `Produce` is evaluated.

### 2.2 Replanning Severity Matrix

During `Produce` and `Verify`, the agent continuously compares actual changes against the plan:

| Deviation | Severity | Action |
|-----------|----------|--------|
| File created outside `scope_boundaries` | **Material** | Soft stop + human review |
| New dependency added not in `new_dependencies` | **Material** | Soft stop + human review |
| API contract changed not in `api_changes` | **Material** | Hard stop + rollback offer |
| Data model changed not in `data_model_changes` | **Material** | Hard stop + rollback offer |
| Expected artifact missing | **Material** | Soft stop; human may waive or extend |
| Unexpected artifact created (e.g., refactor of unrelated module) | **Material** | Hard stop + rollback offer |
| Implementation detail changed (algorithm, naming) with no external impact | **Minor** | Log divergence, continue |
| Additional test case added beyond plan | **Minor** | Log divergence, continue |
| Minor dependency version bump (patch) | **Minor** | Log divergence, continue |

### 2.3 Detection Algorithm

The replanning detector runs as a lightweight sub-step inside `Produce` after every file write:

1. **Snapshot diff**: Compare `git diff --name-only` against `plan.scope_boundaries` and `plan.expected_artifacts`.
2. **Dependency scan**: Parse `package.json` / `requirements.txt` / `go.mod` and diff against `plan.new_dependencies`.
3. **API diff**: Run type checker / linter / OpenAPI diff and compare against `plan.api_changes`.
4. **Data model diff**: Compare ORM schemas / migration files against `plan.data_model_changes`.
5. **Score**: If any **Material** deviation found, trigger soft/hard stop per matrix.

### 2.4 Replanning Artifact

When a deviation is detected, the agent writes a `replan-report.json`:

```json
{
  "work_item_id": "wi-20260407-001",
  "detected_at": "2026-04-07T14:32:00Z",
  "severity": "material",
  "deviations": [
    {
      "type": "scope-creep",
      "planned": ["src/auth/*"],
      "actual": ["src/auth/*", "src/email/SmtpClient.ts"],
      "rationale": "Agent created email helper outside auth scope"
    }
  ],
  "recommended_action": "rollback_or_replan",
  "phase_packet_ref": ".sdlc/phases/wi-20260407-001/produce.json"
}
```

The human chooses:
- **Approve deviation**: Update the `Decide` plan in-place, mark as `replan-approved`, continue.
- **Request replan**: Loop back to `Decide` with deviation context.
- **Rollback**: Invoke §3 rollback protocol.

---

## 3. Rollback Protocol

### 3.1 Pre-Condition: Snapshot Before Autonomy

Before any autonomous `Produce` phase begins, the system creates a **snapshot** of the working tree:

```bash
# Git-based snapshot (all runtimes)
git stash push -m "sdlc-snapshot:wi-{id}-pre-produce"
# OR, if stash is insufficient:
git branch sdlc-snapshot/wi-{id}-pre-produce
```

- The snapshot branch is **not pushed** to origin; it is local-only.
- Snapshot is created automatically by the `Produce` agent before first file write.
- Snapshot ID is recorded in the `Produce` PhasePacket.

### 3.2 Rollback Triggers

| Trigger | Rollback Scope |
|---------|---------------|
| Hard circuit breaker fires | Full rollback to pre-Produce snapshot |
| Replanning detector flags material deviation + human chooses rollback | Full rollback to pre-Produce snapshot |
| Human rejects at Approve gate | Partial rollback: revert files changed in Produce, preserve decisions/artifacts from Define/Decide |
| Verify phase fails with unrecoverable errors | Partial rollback: revert to last passing test state, keep design artifacts |
| Emergency stop (`/sdlc-abort`) | Full rollback to pre-Produce snapshot |

### 3.3 Rollback Procedure

**Step 1 — Safety check**
```bash
git status --short
# If uncommitted changes exist outside .sdlc/, warn human before proceeding
```

**Step 2 — Restore working tree**
```bash
# Full rollback
git reset --hard sdlc-snapshot/wi-{id}-pre-produce
# OR for partial rollback (keep some files):
git checkout sdlc-snapshot/wi-{id}-pre-produce -- src/ tests/
```

**Step 3 — Update knowledge base**
- Write `rollback.json` to `.sdlc/phases/{work-item-id}/`:

```json
{
  "work_item_id": "wi-20260407-001",
  "rollback_type": "full",
  "trigger": "circuit-breaker:test-failure-cascade",
  "snapshot_ref": "sdlc-snapshot/wi-20260407-001-pre-produce",
  "timestamp": "2026-04-07T14:45:00Z",
  "files_reverted": ["src/auth/PasswordResetService.ts", "tests/auth/PasswordResetService.test.ts"],
  "files_preserved": [".sdlc/phases/wi-20260407-001/decide.json"],
  "human_confirmed": true
}
```

**Step 4 — Update PhasePacket**
- Set `produce.json` → `gate_status: "blocked"`
- Set `produce.json` → `recommended_next_phase: "decide"` (loop back)
- Append `rollback.json` to `produce.json` → `evidence_ids`

**Step 5 — Clean up snapshot**
```bash
git branch -D sdlc-snapshot/wi-{id}-pre-produce
# Keep for 7 days if rollback was partial (human may need to reference)
```

### 3.4 Rollback Without Git

If the project is not in a git repo (edge case), the `Produce` agent performs a **file-level backup**:

```
.sdlc/snapshots/
  └── wi-{id}-pre-produce/
      ├── src/auth/PasswordResetService.ts
      └── tests/auth/PasswordResetService.test.ts
```

Rollback copies files from snapshot back to working tree. This is slower and less reliable than git; the framework logs a warning recommending `git init`.

---

## 4. Ultrawork Bounds

**Ultrawork** (`/ulw-loop`) is an OpenCode execution mode in which the AI runs continuously, iterating on a task until completion without per-step human confirmation. It is the highest-autonomy mode available in the framework.

Because ultrawork removes the natural friction of handoff buttons and interactive prompts, it requires the strictest safety bounds.

### 4.1 What `/ulw-loop` CAN Do

| Capability | Condition |
|-----------|-----------|
| Iterate within a single phase | Must stay within the current phase's scope (e.g., `Produce` only) |
| Run background tasks | Parallel subagents for independent work (e.g., UI + API scaffold) |
| Execute mechanical operations | Lint, typecheck, test run, coverage report, PR creation |
| Self-correct on test failure | Up to 3 attempts per test failure before escalating to human |
| Generate documentation, comments, logs | No restrictions |
| Call MCP servers | Read-only by default; write requires explicit tool permission |
| Read from `.sdlc/` | Full read access to knowledge base |

### 4.2 What `/ulw-loop` CANNOT Do

| Prohibition | Enforcement |
|-------------|-------------|
| **Skip human gates** | Approve phase is always `human-required`; ultrawork pauses and emits `question` tool prompt |
| **Change architecture without approval** | Replanning detector (§2) runs continuously; material deviation triggers hard stop |
| **Modify security-sensitive paths** | `security_path_patterns` match triggers hard stop + rollback offer |
| **Add external dependencies** | Dependency changes trigger soft stop; ultrawork cannot auto-approve |
| **Exceed token budget** | Hard stop at 100% budget; no auto-extension |
| **Ignore Verify phase failures** | Verify must run after Produce; unrecoverable failures trigger rollback |
| **Cross work-item boundaries** | Ultrawork is scoped to one `WorkItem`; it cannot start a new work item |
| **Modify `.sdlc/` schema** | Schema files are read-only; only `Integrate` phase may write to `.sdlc/` |
| **Delete or overwrite human-authored decisions** | `Decision` records with `made_by: human` are immutable to AI |
| **Run indefinitely** | Max 2 hours wall-clock per ultrawork session; hard stop after timeout |

### 4.3 Ultrawork Checkpointing

Every 15 minutes or every 5 iterations (whichever comes first), ultrawork performs an automatic **checkpoint**:

1. Write current PhasePacket to `.sdlc/phases/{id}/produce-checkpoint-{N}.json`
2. `git commit -m "[sdlc-checkpoint] wi-{id} iteration {N}"` (amendable, not pushed)
3. Emit heartbeat to user: "Checkpoint N saved. Tokens used: X / Y. Files changed: Z."

If a hard stop fires, the human can resume from the latest checkpoint instead of starting over.

### 4.4 Runtime Mapping

| Runtime | Ultrawork Equivalent | Bound Enforcement |
|---------|---------------------|-------------------|
| GitHub Copilot | Autopilot mode + `send: true` on handoffs | Not available in MVP; handoff buttons (`send: false`) enforce per-phase gates |
| Claude Code | `--dangerously-skip-permissions` + autonomous `Task` loop | Claude's own permission system enforces tool boundaries; framework adds replanning + budget checks |
| OpenCode | `/ulw-loop` skill | Framework `task()` wrapper injects circuit breaker, replanning detector, and checkpoint logic before each iteration |

---

## 5. Safety Configuration

All safety parameters are centralized in `.sdlc/profiles/org.yaml`:

```yaml
safety:
  circuit_breakers:
    max_autonomous_phases: 3
    max_test_failure_iterations: 3
    max_unbounded_loop_iterations: 10
    time_limit_minutes: 120
    token_budgets:
      default: 500000
      per_phase:
        intake: 10000
        define: 30000
        decide: 100000
        produce: 300000
        verify: 20000
        integrate: 10000
      per_skill:
        start-feature: 750000
        fix-bug: 250000
        write-unit-tests: 200000
        write-auto-tests: 400000

  replanning:
    scope_boundary_strictness: strict  # strict | warn | off
    dependency_change_requires_approval: true
    api_change_requires_approval: true
    data_model_change_requires_approval: true

  rollback:
    auto_snapshot_before_produce: true
    snapshot_retention_days: 7
    allow_partial_rollback: true

  ultrawork:
    enabled: false  # default off; human must enable per session
    checkpoint_interval_minutes: 15
    checkpoint_interval_iterations: 5
    max_session_minutes: 120
    allow_background_tasks: true
    max_parallel_subagents: 3

  security_paths:
    patterns:
      - "**/auth/*"
      - "**/security/*"
      - "**/crypto/*"
      - "**/secrets/*"
      - "**/.env*"
      - "**/docker-compose*.yml"
      - "**/Dockerfile*"
    gate: human-required  # always human-required regardless of skill auto-pass rules
```

---

## 6. Audit & Observability

Every safety event is recorded in `.sdlc/executions/`:

```json
{
  "id": "exec-20260407-001",
  "work_item_id": "wi-20260407-001",
  "phase": "produce",
  "actor_id": "agent:sdlc-produce",
  "started_at": "2026-04-07T14:00:00Z",
  "ended_at": "2026-04-07T14:32:00Z",
  "status": "failed",
  "safety_events": [
    {
      "type": "circuit-breaker",
      "subtype": "test-failure-cascade",
      "timestamp": "2026-04-07T14:32:00Z",
      "severity": "hard",
      "action_taken": "rollback",
      "human_confirmed": true
    }
  ],
  "consumed_artifact_version_ids": [...],
  "produced_artifact_version_ids": [...]
}
```

This creates an immutable audit trail for post-mortem analysis and compliance.

---

## 7. Summary Table

| Mechanism | What It Prevents | Fires Automatically? | Human Can Override? |
|-----------|-----------------|---------------------|---------------------|
| Max autonomous phases | Runaway autonomy | Yes | No (hard limit) |
| Test failure cascade | Broken code accumulation | Yes | Yes (approve partial state) |
| Unbounded loop | Infinite iteration | Yes | No |
| Token budget | Runaway cost | Yes (soft), then hard | Yes (one-time extension) |
| Time limit | Runaway session | Yes (soft) | Yes (extend or abort) |
| Replanning detector | Scope creep, architecture drift | Yes | Yes (approve deviation) |
| Security path guard | Unauthorized security changes | Yes | No (always gates) |
| Dependency guard | Unapproved dependencies | Yes (soft) | Yes (approve) |
| Rollback protocol | Irreversible damage | On trigger | Yes (choose partial/full) |
| Ultrawork bounds | Over-autonomy in loop mode | Yes | No (bounds are invariant) |

---

## References

- [ADR-010](DECISIONS.md#adr-010) — Human gate policy
- [ADR-011](DECISIONS.md#adr-011) — Produce phase autonomy modes
- [ARCHITECTURE.md](ARCHITECTURE.md) §7 — Approve phase human-in-the-loop protocol
- [ARCHITECTURE.md](ARCHITECTURE.md) §8 — Runtime capability matrix
