# ai-in-sdlc — Architecture

---

## 1. Universal Phase Backbone

The core is a **DAG of 8 phases** that every SDLC work item traverses. This is stable across all project types — what changes per-project is which phases are active and what tools/agents run inside each phase.

```
Intake → Define → Decide → Produce → Verify → Approve → Integrate
                                          ↑         |
                                          └─────────┘ (rework loop)
                                               ↓
                                            Observe → (new Intake)
```

### Phase Definitions

| Phase | Purpose | Agent Role | Human Role |
|-------|---------|-----------|-----------|
| **Intake** | Normalize the intent, load relevant context from knowledge base | Parse work item, fetch linked artifacts and decisions | Confirm scope if ambiguous |
| **Define** | Establish target behavior, acceptance criteria, expected outcomes | Draft requirements / bug reproduction / expected behavior | Approve if acceptance criteria are incomplete |
| **Decide** | Impact analysis, design decisions, change plan, dependency mapping | Analyze blast radius, propose technical approach, identify risks | Gate if architecture/API contracts change |
| **Produce** | Create or update artifacts: code, docs, test cases, configs | Mode A: fully autonomous. Mode B: scaffold + human finalizes | Mode B: review and complete the scaffold |
| **Verify** | Gather evidence: tests pass, linting clean, traceability complete | Run tests, check coverage, validate requirement links | — (auto-pass if evidence thresholds met) |
| **Approve** | Human review gate — only triggers at high-stakes transitions | Package review artifacts (diagrams, diffs, summaries) | **Open artifact, review, report decision** |
| **Integrate** | Merge, release, sync downstream systems, update knowledge base | Create PR, update graph state, propagate invalidations | Merge PR |
| **Observe** | Runtime feedback, defects, telemetry → new work items | Monitor, parse alerts, create new WorkItems | Report issues |

### Phase Composition Rules

- Each **Skill** defines the shortest valid path through this DAG
- Optional phases are **OFF by default** — activated by skill configuration or explicit user request
- **Verify** can loop back to **Decide** if evidence thresholds fail
- **Approve** can loop back to **Decide** with human feedback attached
- **Observe** always creates a new **Intake** — it never extends the current work item

### Skill → Phase Mapping

```
start-feature:       Intake → Define → Decide → Produce → Verify → Approve → Integrate
fix-bug:             Intake → Define → Decide → Produce → Verify → Approve → Integrate
                              (Define = reproduce + root cause; Decide = minimal fix plan)
write-unit-tests:    Intake → Define → Decide → Produce → Verify → Integrate
                              (Approve auto-pass unless coverage threshold fails)
write-auto-tests:    Intake → Define → Decide → Produce → Verify → Approve → Integrate
                              (Decide heavier: test env, data strategy, oracle selection)
update-requirements: Intake → Define → Decide → Produce → Approve → Integrate
                              (Integrate = propagate invalidations to linked artifacts)
```

---

## 2. Phase Packet — The Handoff Contract

Every phase emits a **PhasePacket** to the next phase. This is the framework's internal contract — runtime-agnostic.

```typescript
interface PhasePacket {
  work_item_id: string
  skill_id: string
  work_type?: string | null
  phase: PhaseId
  timestamp: string

  // Artifact links
  input_artifact_version_ids: string[]
  output_artifact_version_ids: string[]
  decision_ids: string[]
  evidence_ids: string[]

  // Gate status
  gate_status: "auto-pass" | "human-required" | "blocked"
  artifact_gaps: ArtifactGap[]
  artifact_policy_applied: ArtifactPolicyApplied
  open_questions: string[]
  risk_flags: RiskFlag[]

  // Routing
  recommended_next_phase: PhaseId | null
  skip_phases: PhaseId[]
}

interface ArtifactGap {
  artifact_subtype: string
  severity: "required" | "warn" | "optional"
  scope: string | null
  status: "missing" | "planned" | "waived" | "resolved"
  suggested_action: string | null
}

interface ArtifactPolicyApplied {
  active_scope: string | null
  baseline_source: string | null
  work_type_source: string | null
  resolution_order: string[]
}
```

A phase **cannot hand off** unless its outputs are linked back to at least one upstream requirement, bug report, or decision.

### Work Type Overlay

`work_type` is an optional routing hint carried by the `WorkItem` and copied into each `PhasePacket`.
It does **not** create new phases or a second pipeline. Instead, it injects a reusable thinking guide into the existing universal phase backbone.

Work types may also define an internal coworker protocol inside a phase sequence without introducing new top-level phases. For example, `debugging` can require evidence collection before proposing fixes, human checkpoints for risky runtime actions, and a closeout note listing remaining unknowns, while still using the same universal backbone.

Examples:

- `fix-bug` usually maps to `work_type: debugging`
- `update-requirements` usually maps to `work_type: requirement-analysis`
- Review-oriented skills can map to `work_type: code-review`

When present, the active agent loads the base work type definition from `.sdlc/work-types/{work_type}.md` and then applies any project override from `project.yaml -> work_type_overrides.{work_type}`.

After work-type guidance is loaded, the active agent resolves `artifact_policy` for the current scope in this order:

1. active scope reality
2. `project.yaml -> artifact_policy.by_work_type`
3. `project.yaml -> artifact_policy.baseline`
4. project-type guide defaults
5. framework deliverables matrix

That resolution determines whether a missing artifact is:

- `required` — gate or reconstruct before proceeding safely
- `warn` — carry forward as an artifact gap with a recommendation
- `optional` — do not raise automatically

---

## 3. Knowledge Base — Adapter Pattern

### Interface

All agents interact with the knowledge base through a single interface. The backing storage is swappable.

```typescript
interface KnowledgeAdapter {
  // Artifact management
  resolve(id: string): Promise<ArtifactVersion>
  fetch(query: ArtifactQuery): Promise<ArtifactVersion[]>
  store(artifact: ArtifactVersion): Promise<ArtifactVersion>
  diff(v1: string, v2: string): Promise<Diff>

  // Search
  search(query: SemanticQuery): Promise<ArtifactVersion[]>   // vector search if supported
  traverse(from: string, relation: Relation): Promise<ArtifactVersion[]>  // graph traversal if supported

  // Work items
  createWorkItem(item: WorkItem): Promise<WorkItem>
  updateWorkItem(id: string, patch: Partial<WorkItem>): Promise<WorkItem>
  getWorkItem(id: string): Promise<WorkItem>
}
```

### Implementations

| Adapter | Backend | When to Use | Capabilities |
|---------|---------|-------------|-------------|
| `LocalFileAdapter` | `.sdlc/` directory | **Default — zero infra** | Full CRUD, no semantic search, no graph traversal |
| `VectorDBAdapter` | Qdrant / Pinecone | When semantic search needed | Full CRUD + semantic similarity search |
| `GraphDBAdapter` | Neo4j + Graphiti | When requirement traceability needed at scale | Full CRUD + semantic search + multi-hop traversal + temporal queries |

### LocalFile Layout (Default)

```
.sdlc/
├── config.json                    # KnowledgeAdapter type, active providers, profile paths
├── .env                           # (gitignored) local credential overrides
│
├── profiles/
│   ├── project.yaml               # Stack, frameworks, build commands, conventions
│   ├── org.yaml                   # Approval policies, security rules (optional, org-wide)
│   ├── models.yaml                # Model routing: tier defaults + per-phase/skill overrides
│   └── components/                # Per-module profiles (patterns, examples, boundaries)
│       ├── auth.yaml
│       └── payment.yaml
│
├── work-types/
│   ├── debugging.md               # Root-cause analysis and minimal-fix guidance
│   ├── code-review.md             # Review and audit guidance
│   └── requirement-analysis.md    # Scope-shaping and acceptance-criteria guidance
│
├── work-items/
│   └── {id}.json                  # WorkItem: kind, title, status, skill_id, optional work_type
│
├── artifacts/
│   ├── requirement/
│   │   └── {id}/
│   │       ├── meta.json          # ArtifactVersion: provenance, approval_state, authority_state
│   │       └── content.md
│   ├── design-artifact/           # ADRs, diagrams, Figma refs, API specs, mockups
│   │   └── {id}/
│   │       ├── meta.json
│   │       └── content.md
│   ├── code-file/                 # Code index (from ingestor — no full content copy)
│   │   └── {id}/
│   │       └── meta.json          # path, language, module, symbols list
│   ├── review-note/
│   │   └── {id}/
│   │       ├── meta.json
│   │       └── content.md
│   ├── test-case/
│   │   └── {id}/
│   │       ├── meta.json
│   │       └── content.md
│   └── bug-report/
│       └── {id}/
│           ├── meta.json
│           └── content.md
│
├── decisions/
│   └── {id}.json                  # title, context, chosen option, rationale, status
│
├── executions/
│   └── {id}.json                  # actor, phase, artifacts consumed/produced, timestamp
│
├── actors/
│   └── {id}.json                  # kind: human|ai-agent|system, name, role
│
└── phases/
    └── {work-item-id}/
        ├── intake.json            # PhasePacket: inputs, outputs, gate_status, decisions
        ├── define.json
        ├── decide.json
        ├── produce.json
        ├── verify.json
        ├── approve.json
        └── integrate.json
```

#### What is NOT stored in `.sdlc/`

| Item | Reason |
|------|--------|
| Full source code | Already in repo — `code-file/` only indexes metadata |
| Raw provider payloads | Jira JSON, Figma raw data — too noisy; only normalized `ArtifactVersion` kept |
| Intermediate LLM prompts | Transient, not durable — causes graph bloat |
| Full test execution logs | Summary stored in `test-run-report` artifact; full logs stay in CI |
| Git history | Already in git — never duplicated |
| Credentials / tokens | Loaded from env vars; `.env` is gitignored (see ADR-013) |

### Bulk Ingest Pipeline

Separate from the runtime adapter — ingests large datasets into the knowledge base on demand.

```
BulkIngestor
├── CodebaseIngestor      → scan repo, extract module/file/symbol structure
├── DocumentIngestor      → PRD, Confluence, Notion, Word/PDF files
├── IssueIngestor         → Jira/Linear tickets, bug history
└── ApiSpecIngestor       → OpenAPI specs, GraphQL schemas

Flow: Raw source → normalize → ArtifactVersion → KnowledgeAdapter.store()
```

---

## 4. Knowledge Graph — Core Schema

The schema is identical regardless of whether LocalFile, VectorDB, or GraphDB is used. The backing adapter handles the physical representation.

### Node Types

```typescript
// A unit of work driving the SDLC task
interface WorkItem {
  id: string
  kind: "feature" | "bug" | "review" | "test-task" | "requirements-change"
  title: string
  description: string
  status: "open" | "in-progress" | "done" | "cancelled"
  skill_id: string
  work_type?: string | null
  linked_artifact_ids: string[]
  created_by: string          // Actor id
  created_at: string
}

// A logical "thing" that exists across versions
interface Artifact {
  id: string
  kind: ArtifactKind
  name: string
  description: string
  owner_id: string            // WorkItem or parent Artifact
}

type ArtifactKind =
  | "requirement"
  | "design-artifact"         // ADR, diagram, Figma file, mockup, API spec
  | "code-file"
  | "code-symbol"
  | "test-case"
  | "test-run-report"
  | "review-note"
  | "bug-report"
  | "release-note"

// An immutable snapshot of an Artifact at a point in time
interface ArtifactVersion {
  id: string
  artifact_id: string
  version: string
  content_ref: string         // file path, URL, or inline content

  // Provenance — who/what created this
  provenance_mode: "external" | "human" | "ai" | "mixed"
  provider: string            // "figma" | "jira" | "github" | "agent:planner" | "manual"
  source_uri?: string
  source_version?: string
  created_by_actor: string
  created_in_execution: string
  created_at: string
  checksum: string

  // Status — independent of provenance
  approval_state: "draft" | "proposed" | "approved" | "rejected" | "superseded"
  authority_state: "source" | "imported-reference" | "derived"

  // Traceability
  supersedes?: string         // previous ArtifactVersion id
  derives_from?: string[]     // upstream ArtifactVersion ids
}

// A design or product decision with rationale
interface Decision {
  id: string
  title: string
  context: string
  options_considered: string[]
  chosen_option: string
  rationale: string
  consequences: string
  status: "proposed" | "accepted" | "deprecated" | "superseded"
  made_by: string             // Actor id
  made_at: string
}

// One execution of a phase by an agent, human, or tool
interface Execution {
  id: string
  work_item_id: string
  phase: PhaseId
  actor_id: string
  started_at: string
  ended_at?: string
  status: "running" | "completed" | "failed"
  consumed_artifact_version_ids: string[]
  produced_artifact_version_ids: string[]
  decision_ids: string[]
  phase_packet?: PhasePacket
}

// A participant in the system
interface Actor {
  id: string
  kind: "human" | "ai-agent" | "external-system"
  name: string
  role?: string
}
```

### Key Traceability Relationships

```
WorkItem     ADDRESSES      Artifact
ArtifactVersion  VERSION_OF     Artifact
ArtifactVersion  SUPERSEDES     ArtifactVersion
ArtifactVersion  DERIVES_FROM   ArtifactVersion[]
ArtifactVersion  IMPLEMENTS     Artifact (requirement/decision/design)
TestCase     VERIFIES       Artifact (requirement/bug-report/code)
Artifact     CONTAINS       Artifact  (repo→file→symbol, suite→test)
Execution    CONSUMED       ArtifactVersion[]
Execution    PRODUCED       ArtifactVersion[]
Execution    MADE           Decision
Decision     APPROVES|REJECTS|WAIVES  ArtifactVersion|WorkItem
Actor        PERFORMED      Execution
```

---

## 5. External Provider — Adapter Pattern

External tools (Figma, Jira, Confluence, GitHub, OpenAPI) plug in as **artifact providers**. The framework consumes normalized `ArtifactVersion` objects — never raw provider payloads.

```typescript
interface ProviderAdapter {
  resolve(uri: string): Promise<ExternalRef>
  fetch(ref: ExternalRef): Promise<RawArtifact>
  normalize(raw: RawArtifact): Promise<ArtifactVersion>  // ← critical step
  diff(ref_v1: ExternalRef, ref_v2: ExternalRef): Promise<Diff>
  watch?(ref: ExternalRef, callback: ChangeCallback): Unsubscribe  // optional
}
```

### Available Providers

| Provider | Artifact Kinds | Priority |
|----------|---------------|----------|
| Jira / Linear | `requirement`, `bug-report` | MVP |
| Figma | `design-artifact` | MVP |
| OpenAPI / GraphQL | `design-artifact` | MVP |
| Confluence / Notion | `requirement`, `design-artifact` | Phase 2 |
| GitHub Issues | `bug-report`, `requirement` | Phase 2 |
| Git history | potential data (complex chunking) | Deferred |

---

## 6. Adaptation Layer

Project-specific context is injected into agent prompts as **layered profiles**. Never as a monolithic "project context" blob.

```
Prompt assembly:
  = universal phase instructions
  + model config         (tier resolved from models.yaml for this phase+skill)
  + skill profile        (phase toggles, gate thresholds, evidence requirements)
  + project profile      (stack, frameworks, build/test commands, repo layout)
  + component profile    (module boundaries, patterns, canonical examples)
  + linked decisions     (approved ADRs, past design decisions relevant to this work)
  + current work item    (requirement text, bug description, linked artifacts)
```

Artifact expectations are resolved as part of this adaptation layer, not hardcoded per skill. The universal runtime reads `project.yaml`, overlays work-type-specific policy, then falls back to project-type defaults and the framework matrix.

### Profile Files

#### `project.yaml` — Stack & Conventions

```yaml
# .sdlc/profiles/project.yaml
stack:
  language: typescript
  runtime: node
  frameworks: [react, express]
  test_framework: jest
  e2e_framework: playwright

commands:
  build: npm run build
  unit_test: npm test
  e2e_test: npm run test:e2e
  lint: npm run lint

repo_layout:
  source: src/
  tests: src/__tests__/
  e2e: e2e/
  docs: docs/

conventions:
  - "Use functional components with hooks, not class components"
  - "All API responses follow { data, error, meta } envelope"
  - "Error handling: throw typed errors, catch at route handler"

canonical_examples:
  - path: src/features/auth/AuthService.ts
    description: "Reference implementation for a service class"
```

#### `models.yaml` — Model Routing (see ADR-014)

```yaml
# .sdlc/profiles/models.yaml
# Tier aliases — change here to update all phases/skills at once
defaults:
  high: "claude-opus-4"       # Architecture decisions, complex design
  mid:  "claude-sonnet-4"     # Code generation, requirement structuring
  low:  "claude-haiku-3"      # Mechanical: checks, PR creation, indexing

# Per-phase tier assignments
phases:
  intake:   {tier: low}
  define:   {tier: mid}
  decide:   {tier: high}
  produce:  {tier: mid}
  verify:   {tier: low}
  approve:  {tier: null}      # Human-only phase — no model
  integrate:{tier: low}

# Per-skill phase overrides (optional — takes precedence over phase default)
skills:
  start-feature:
    decide: {model: "claude-opus-4"}
  fix-bug:
    decide: {model: "claude-sonnet-4"}
  write-auto-tests:
    decide: {model: "claude-opus-4"}

# Fallback chain if primary model unavailable
fallback_chain:
  high: ["claude-opus-4", "gpt-5.4", "claude-sonnet-4"]
  mid:  ["claude-sonnet-4", "gpt-5.4", "claude-haiku-3"]
  low:  ["claude-haiku-3", "gpt-4o-mini", "claude-sonnet-4"]
```

#### Resolution Order (highest → lowest priority)

```
phase-level override (models.yaml → phases.{phase})
  ↓ falls back to
skill-level override (models.yaml → skills.{skill}.{phase})
  ↓ falls back to
project default     (models.yaml → defaults.{tier})
  ↓ falls back to
org default         (org.yaml → models.defaults.{tier})
  ↓ falls back to
hardcoded fallback  (claude-sonnet-4)
```

---

## 7. Approve Phase — Human-in-the-Loop Protocol

Gates trigger **only** for: architecture changes, API/contract changes, design artifacts, PR merge, security-sensitive paths.

### Gate Flow

```
1. Agent completes Produce + Verify phases
2. System packages a review artifact:
   - Link to output artifact (excalidraw, doc, diff, diagram)
   - Summary: what changed, why, evidence collected
   - Explicit question with options: approve / reject / request-changes + comment
3. Human opens artifact independently, reviews at their own pace
4. Human reports decision back in CLI / chat
5. System resumes from checkpoint, records Decision in knowledge base
6. If rejected → loop back to Decide with human feedback attached as context
```

### What Triggers a Gate (vs Auto-Pass)

| Condition | Gate |
|-----------|------|
| Architecture or API contract change | ✅ Human required |
| New external dependency | ✅ Human required |
| New design artifact created | ✅ Human required |
| Missing artifact required by `artifact_policy` | ✅ Human required or blocked until reconstructed/waived |
| PR ready to merge | ✅ Human required |
| Security-sensitive code path | ✅ Human required |
| Unit test additions (coverage threshold met) | Auto-pass |
| Documentation updates | Auto-pass |
| Refactor with no behavior change | Auto-pass (with evidence) |

---

## 8. Runtime Capability Matrix

The same conceptual framework maps to different mechanisms per runtime.

| Framework Component | GitHub Copilot (MVP) | Claude Code (Phase 2) | OpenCode (Phase 3) |
|---------------------|---------------------|----------------------|-------------------|
| **Phase agents** | `.github/agents/*.agent.md` | `AGENTS.md` + subagents | `task()` with skills |
| **Skill injection** | `.github/skills/*/SKILL.md` | `SKILL.md` (GSD standard) | `load_skills=[...]` |
| **Slash commands** | `.github/prompts/*.prompt.md` | Slash commands in `CLAUDE.md` | `/skill-name` commands |
| **Always-on instructions** | `.github/copilot-instructions.md` | `CLAUDE.md` / `AGENTS.md` | `AGENTS.md` |
| **Human gate mechanism** | Handoff buttons (`send: false`) | `--dangerously-skip-permissions` off + interactive | `question` tool + todo continuation |
| **Tool permissions** | `tools:` in `.agent.md` frontmatter | Tool allowlists in CLAUDE.md | Category-based delegation |
| **State persistence** | Workspace files (`.sdlc/`) | Workspace files (`.sdlc/`) | Workspace files (`.sdlc/`) |
| **External APIs** | MCP servers | MCP servers | MCP servers |
| **File read/write** | `edit` tool | Direct file tools | Direct file tools |
| **Terminal access** | `terminal` tool | Bash tool | Bash tool |
| **Subagent delegation** | `agent` tool + `handoffs:` | `task()` subagents | `task()` subagents |
| **Parallel execution** | ❌ Sequential only | ✅ Background tasks | ✅ Background tasks |
| **Cross-session memory** | ❌ Files only | ✅ `phloem_remember` + files | ✅ Memory tools + files |
| **Phase tracking** | `.sdlc/phases/` files (manual) | `.sdlc/phases/` files | `.sdlc/phases/` files |
| **Model routing** | `model:` in `.agent.md` | `--model` flag | Category-based model selection |

### Key Gaps: Copilot vs Claude Code/OpenCode

| Gap | Impact | Mitigation for Copilot MVP |
|-----|--------|---------------------------|
| No parallel subagents | Phases run sequentially | Design phases as sequential; parallelize within a phase using MCP calls |
| No cross-session memory | Context lost between sessions | Write all state to `.sdlc/` files; each phase reads its predecessor's PhasePacket |
| No native phase engine | No "run phases 3-7 automatically" | Handoff chain: each agent's last action is a handoff button to the next phase agent |
| Autopilot mode is per-session opt-in | User must enable autonomous mode each session | Document clearly; use `send: false` handoffs as default (safer) |
| MCP disabled by default on Enterprise | Jira/Figma integrations may be blocked | Provide fallback: manual paste of external artifacts into chat |
