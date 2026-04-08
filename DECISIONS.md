# ai-in-sdlc — Architecture Decision Records

This document captures all significant design decisions with rationale, alternatives considered, and **runtime mapping notes** to guide future porting from GitHub Copilot to Claude Code and OpenCode.

---

## Decision Log

| ID | Title | Status | Date |
|----|-------|--------|------|
| [ADR-001](#adr-001) | Universal phase backbone (not per-project pipelines) | Accepted | 2026-04-07 |
| [ADR-002](#adr-002) | Knowledge base as adapter pattern | Accepted | 2026-04-07 |
| [ADR-003](#adr-003) | LocalFile as default knowledge storage | Accepted | 2026-04-07 |
| [ADR-004](#adr-004) | External artifacts as normalized ArtifactVersions | Accepted | 2026-04-07 |
| [ADR-005](#adr-005) | Provenance, authority, and approval as separate fields | Accepted | 2026-04-07 |
| [ADR-006](#adr-006) | GitHub Copilot as MVP delivery target | Accepted | 2026-04-07 |
| [ADR-007](#adr-007) | Handoff chain as phase engine on Copilot | Accepted | 2026-04-07 |
| [ADR-008](#adr-008) | `.sdlc/` as runtime-portable state directory | Accepted | 2026-04-07 |
| [ADR-009](#adr-009) | SKILL.md as the portable skill unit | Accepted | 2026-04-07 |
| [ADR-010](#adr-010) | Human gate only at irreversible/ambiguous transitions | Accepted | 2026-04-07 |
| [ADR-011](#adr-011) | Produce phase supports two modes (autonomous + scaffold) | Accepted | 2026-04-07 |
| [ADR-012](#adr-012) | Bulk ingest as a separate concern from runtime adapter | Accepted | 2026-04-07 |
| [ADR-013](#adr-013) | `.sdlc/` committed to git; credentials loaded from environment | Accepted | 2026-04-07 |
| [ADR-014](#adr-014) | Model routing config: hierarchy override + centralized definition | Accepted | 2026-04-07 |
| [ADR-015](#adr-015) | Work type as an orthogonal thinking layer | Accepted | 2026-04-07 |

---

## ADR-001

### Universal phase backbone, not per-project pipelines

**Status**: Accepted  
**Date**: 2026-04-07

#### Context
Initial thinking was to design separate pipelines per project type (mobile, web, backend). This creates N pipeline implementations for N project types.

#### Decision
Use a single **8-phase DAG** as the universal backbone: `Intake → Define → Decide → Produce → Verify → Approve → Integrate → Observe`. All project types traverse the same phases. Project-specific behavior is injected via adaptation profiles, not separate pipelines.

#### Rationale
- Every SDLC task — regardless of tech stack — goes through the same state transitions
- Skills are **projections** over this DAG (they skip irrelevant phases, they don't define new ones)
- One engine to maintain, infinite project adaptations via configuration

#### Alternatives Rejected
- **Per-project pipelines**: N pipelines to maintain, diverge over time, cannot share improvements
- **Domain-specific phases**: e.g., "Mobile: TestFlight phase" — these become optional overlays, not core phases

#### Runtime Mapping
| Runtime | Impact |
|---------|--------|
| GitHub Copilot | Each phase = one `.agent.md` file; phases chain via handoffs |
| Claude Code | Each phase = one subagent invocation or slash command step |
| OpenCode | Each phase = one `task()` call with relevant skill |

---

## ADR-002

### Knowledge base as adapter pattern

**Status**: Accepted  
**Date**: 2026-04-07

#### Context
Agents need persistent project context across sessions. Different teams have different infra constraints — some can run Neo4j, others need zero-infra local files.

#### Decision
Define a single `KnowledgeAdapter` interface. All agents interact with this interface only. The backing implementation is swappable: `LocalFileAdapter`, `VectorDBAdapter`, `GraphDBAdapter`.

#### Rationale
- Agent logic doesn't change when storage backend changes
- Teams can start with LocalFile (zero infra) and migrate to GraphDB when scale demands it
- Enables gradual capability upgrade: semantic search added without rewriting agents

#### Alternatives Rejected
- **Hardcode Neo4j**: locks all users to Neo4j infra; kills adoption for small teams
- **Hardcode files**: no path to semantic search or multi-hop traceability queries
- **Let each agent pick its storage**: inconsistent state, no single source of truth

#### Runtime Mapping
| Runtime | Impact |
|---------|--------|
| GitHub Copilot | Agents read/write via `edit` tool + `search/codebase`; MCP server wraps KnowledgeAdapter for richer queries |
| Claude Code | Direct file tools + optional MCP server for VectorDB/GraphDB |
| OpenCode | Same as Claude Code |

---

## ADR-003

### LocalFile as default knowledge storage

**Status**: Accepted  
**Date**: 2026-04-07

#### Context
Need a zero-infra default that works immediately without setup — analogous to GSD's `.planning/` directory.

#### Decision
Default `KnowledgeAdapter` implementation is `LocalFileAdapter`, storing all artifacts, decisions, executions, and work items as JSON/Markdown files under `.sdlc/` in the project root.

#### Rationale
- Zero setup — works on first `git clone`
- Human-readable — developers can inspect and edit state directly
- Git-trackable — full history of project knowledge
- Follows GSD's proven `.planning/` pattern

#### Constraints / When to Upgrade
- No semantic similarity search → upgrade to `VectorDBAdapter` when semantic requirement search is needed
- No multi-hop graph traversal → upgrade to `GraphDBAdapter` when requirement traceability at scale is needed
- No temporal queries → `GraphDBAdapter` with Graphiti supports "state at point T"

#### Runtime Mapping
| Runtime | Physical Location | Notes |
|---------|-----------------|-------|
| GitHub Copilot | `.sdlc/` in workspace root | Agents access via `edit` tool; checked into git |
| Claude Code | `.sdlc/` in workspace root | Direct Read/Write tools |
| OpenCode | `.sdlc/` in workspace root | Direct Read/Write tools |

---

## ADR-004

### External artifacts as normalized ArtifactVersions

**Status**: Accepted  
**Date**: 2026-04-07

#### Context
External tools (Figma mockups, Jira tickets, OpenAPI specs) will be inputs to SDLC phases. Some projects will have designers providing mockups; others will have PMs managing requirements in Jira. The framework must be open to these without hard-coupling.

#### Decision
All external inputs pass through a `ProviderAdapter` that normalizes them into `ArtifactVersion` objects before any agent sees them. Raw provider payloads never enter agent prompts directly.

#### Rationale
- Agent prompts are stable regardless of which external tool provides the artifact
- New providers can be added without changing agent logic
- Provenance, version, and authority are always captured at import time

#### Provider Priority (MVP)
1. Figma (design artifacts)
2. Jira / Linear (requirements, bug reports)
3. OpenAPI / GraphQL specs (design artifacts)
4. Confluence / Notion — Phase 2
5. GitHub Issues — Phase 2
6. Git history — Deferred (complex chunking required)

#### Runtime Mapping
| Runtime | Integration Mechanism |
|---------|---------------------|
| GitHub Copilot | MCP server per provider (Figma MCP, Jira MCP); fallback: manual paste if MCP disabled |
| Claude Code | MCP servers (same servers, same interface) |
| OpenCode | MCP servers (same) |

> **Note**: If MCP is disabled at the Enterprise org level in Copilot, the fallback is the user pasting artifact content into the chat as context. The normalization step still runs — just with user-provided content instead of API-fetched content.

---

## ADR-005

### Provenance, authority, and approval as separate fields

**Status**: Accepted  
**Date**: 2026-04-07

#### Context
An AI-generated design document could be approved by a human. An externally-provided Figma mockup might not yet be approved. These are orthogonal concerns that must not be conflated.

#### Decision
Every `ArtifactVersion` carries three independent status fields:

- `provenance_mode`: `external | human | ai | mixed` — **who/what created it**
- `authority_state`: `source | imported-reference | derived` — **is this the source of truth?**
- `approval_state`: `draft | proposed | approved | rejected | superseded` — **has it been reviewed?**

#### Rationale
- Prevents AI-generated content from being silently treated as authoritative
- Allows external artifacts to be imported in `draft` state and approved via the standard Approve phase
- Enables audit queries: "show me all AI-generated artifacts that haven't been human-approved"

#### Rules
- Newly created artifacts default to `approval_state: "draft"`
- Only the Approve phase transitions `approval_state` to `approved` or `rejected`
- External imports default to `provenance_mode: "external"`, `authority_state: "source"`, `approval_state: "draft"`

---

## ADR-006

### GitHub Copilot as MVP delivery target

**Status**: Accepted  
**Date**: 2026-04-07

#### Context
Multiple AI runtime environments exist (GitHub Copilot, Claude Code, OpenCode, Cursor, etc.). We need to pick one for MVP to avoid over-engineering for multiple runtimes simultaneously.

#### Decision
GitHub Copilot (VS Code Agent Mode) is the MVP delivery target.

#### Rationale
- Highest adoption among enterprise developers
- Native VS Code integration — lowest friction for developers already using Copilot
- `.agent.md` + `SKILL.md` + handoffs provide sufficient capability for a v1 phase engine
- MCP support enables Jira/Figma integrations without custom server infra
- `SKILL.md` is now an open standard (agentskills.io) — skills built for Copilot are portable

#### Constraints Accepted for MVP
- No parallel subagent execution (sequential phases only)
- No cross-session memory (all state in `.sdlc/` files)
- No native phase engine (implemented via handoff chain)
- Autopilot mode is per-session user opt-in (default is human-gate-per-tool)

#### When to Expand
- Claude Code: when autonomous multi-phase loops and background parallelism are needed
- OpenCode: when deep OMO/GSD integration is needed

---

## ADR-007

### Handoff chain as phase engine on Copilot

**Status**: Accepted  
**Date**: 2026-04-07

#### Context
Copilot has no native concept of a phase engine (no "run phases 3-7 in sequence"). The closest mechanism is the **handoff** system in `.agent.md` files.

#### Decision
Implement the phase engine as a **handoff chain**: each phase agent's final action is to produce a `PhasePacket` file and offer a handoff button to the next phase agent. `send: false` on all handoffs = human sees output and clicks to proceed.

```yaml
# Example: decide.agent.md
handoffs:
  - label: "✅ Proceed to Implementation"
    agent: produce
    prompt: "Implement the plan in .sdlc/phases/{id}/decide.json"
    send: false
  - label: "🔄 Revise Design"
    agent: decide
    prompt: "Revise the design based on feedback: "
    send: false
```

#### Rationale
- Works within Copilot's native capability model
- Handoff buttons are natural human review gates
- State is persisted in `.sdlc/phases/` — next agent reads PhasePacket from file

#### Limitation
- User must click handoff button at each phase boundary (no full autonomy)
- Mitigation: document that Autopilot mode + `send: true` enables autonomous chaining (user opt-in)

#### Runtime Mapping (this is the key porting decision)

| Runtime | Phase Engine Mechanism | Autonomy Level |
|---------|----------------------|---------------|
| **GitHub Copilot** | Handoff chain (`send: false` buttons) | Human clicks each phase transition |
| **Claude Code** | Sequential `Task` subagents in a SKILL.md loop | Can run fully autonomous with `--dangerously-skip-permissions` |
| **OpenCode** | `task()` calls with `run_in_background=false` chained in skill | Can run autonomous; `question` tool for gates |

> **Porting note**: When implementing for Claude Code/OpenCode, replace handoff buttons with programmatic phase-to-phase calls. The PhasePacket schema and `.sdlc/` file layout remain identical — only the orchestration mechanism changes.

---

## ADR-008

### `.sdlc/` as runtime-portable state directory

**Status**: Accepted  
**Date**: 2026-04-07

#### Context
State must persist across sessions and be readable by agents on any runtime. Copilot, Claude Code, and OpenCode all need to read and write the same state.

#### Decision
All runtime state is stored in `.sdlc/` at the project root. The directory schema is identical regardless of which runtime is running. Runtimes differ only in *how* they read/write files, not *what* they read/write.

#### Rationale
- `.sdlc/` can be checked into git → full audit trail
- Developer can inspect/edit state without special tooling
- Switching runtimes (Copilot → Claude Code) requires no state migration
- Analogous to GSD's `.planning/` — proven pattern

#### `.sdlc/config.json` Runtime Selection
```json
{
  "knowledge_adapter": "local-file",
  "knowledge_adapter_config": {},
  "active_providers": ["jira", "figma"],
  "profiles": {
    "project": ".sdlc/profiles/project.yaml",
    "org": ".sdlc/profiles/org.yaml"
  }
}
```

---

## ADR-009

### SKILL.md as the portable skill unit

**Status**: Accepted  
**Date**: 2026-04-07

#### Context
Skills need to work across GitHub Copilot, Claude Code, and OpenCode. Each runtime has a different mechanism for loading skills.

#### Decision
Use `SKILL.md` as the canonical skill format — the same open standard used by GSD and now standardized at agentskills.io. Each skill lives in its own directory with a `SKILL.md` file.

```
.github/skills/
  start-feature/
    SKILL.md
  fix-bug/
    SKILL.md
  write-unit-tests/
    SKILL.md
```

#### Runtime Loading

| Runtime | Skill Location | Loading Mechanism |
|---------|--------------|------------------|
| GitHub Copilot | `.github/skills/*/SKILL.md` | Auto-detected by Copilot based on `description:` frontmatter; invoked via `/skill-name` or auto-match |
| Claude Code | `.claude/skills/*/SKILL.md` or project root `SKILL.md` | `@skill-name` mention or slash command |
| OpenCode | `~/.config/opencode/skills/*/SKILL.md` | `load_skills=["skill-name"]` in `task()` call |

> **Porting note**: SKILL.md content is identical. Only the *directory location* and *invocation mechanism* differ per runtime. When porting, copy SKILL.md files to the target runtime's skills directory.

---

## ADR-010

### Human gate only at irreversible/ambiguous transitions

**Status**: Accepted  
**Date**: 2026-04-07

#### Context
Over-gating kills developer productivity. If every phase requires explicit human approval, developers will bypass the framework.

#### Decision
Human gates trigger **only** when:
1. Architecture or API contract is being changed
2. A new design artifact is being created (requires UX/PM review)
3. Code is ready to merge (PR review)
4. A security-sensitive code path is touched
5. Acceptance criteria are ambiguous at Define phase

Everything else auto-passes if evidence thresholds are met.

#### Auto-Pass Examples
- Unit test additions with coverage threshold met
- Documentation updates
- Refactors with no behavior change (verified by tests)
- Bug fixes with reproduction test passing

#### Rationale
- Mirrors how effective senior engineers operate: trust the automated checks, gate only the irreversible
- Prevents "rubber-stamp fatigue" — humans stop reviewing if every task requires approval

---

## ADR-011

### Produce phase supports two modes

**Status**: Accepted  
**Date**: 2026-04-07

#### Context
Different developers and contexts require different levels of AI autonomy during implementation.

#### Decision
The Produce phase agent supports two modes, selectable per invocation:

- **Mode 1 — Fully Autonomous**: AI writes code, runs tests, fixes errors, iterates until done (like Devin/OpenHands). Requires user enabling Autopilot/autonomous mode.
- **Mode 2 — Scaffold + Finalize**: AI generates the scaffold, key interfaces, and critical logic. Developer reviews and completes. AI provides the plan and skeleton.

#### Default
Mode 2 is the default for safety. Mode 1 is opt-in per session.

#### Runtime Mapping

| Runtime | Mode 1 Implementation | Mode 2 Implementation |
|---------|----------------------|----------------------|
| GitHub Copilot | Autopilot mode enabled; `send: true` on internal loops | `send: false` handoffs; developer completes in editor |
| Claude Code | `--dangerously-skip-permissions` + autonomous task loop | Standard interactive task with draft output |
| OpenCode | Background task with autonomous loop | `run_in_background=false` + question tool for checkpoints |

---

## ADR-012

### Bulk ingest as a separate concern from runtime adapter

**Status**: Accepted  
**Date**: 2026-04-07

#### Context
Loading large datasets (entire codebases, legacy documents, issue history) into the knowledge base is a different operation from the real-time read/write that agents do during phase execution.

#### Decision
`BulkIngestor` is a separate pipeline that writes to the knowledge base via `KnowledgeAdapter.store()`. It is not part of the phase engine. It runs as a one-time or scheduled operation, not inline with SDLC tasks.

#### Ingestors (Priority Order)
1. `CodebaseIngestor` — scan repo, extract module/file/symbol structure + deps
2. `DocumentIngestor` — PRD, Confluence, Notion, Word/PDF
3. `IssueIngestor` — Jira/Linear tickets, bug history
4. `ApiSpecIngestor` — OpenAPI specs, GraphQL schemas
5. `GitHistoryIngestor` — deferred (complex chunking, high noise-to-signal ratio)

#### Invocation
```bash
# CLI commands (all runtimes)
sdlc ingest codebase              # scan current repo
sdlc ingest docs ./docs/          # ingest documentation directory
sdlc ingest jira --project PROJ   # pull from Jira project
sdlc ingest openapi ./api.yaml    # ingest OpenAPI spec
```

#### Runtime Mapping
| Runtime | Invocation |
|---------|-----------|
| GitHub Copilot | `/ingest` prompt file triggering ingest agent |
| Claude Code | `sdlc ingest` CLI command or slash command |
| OpenCode | `/sdlc-ingest` skill or `task()` delegation |

---

## ADR-013

### `.sdlc/` committed to git; credentials loaded from environment

**Status**: Accepted
**Date**: 2026-04-07

#### Context
`.sdlc/` contains the project's shared knowledge base — requirements, decisions, phase state, artifact metadata. The team needs to share this context. But external provider credentials (Jira tokens, Figma tokens) must never be committed.

#### Decision
- **Commit `.sdlc/` to git** — full audit trail, team shares context, AI agents on any branch can read project state
- **Never store credentials in `.sdlc/`** — credentials are loaded from environment at runtime
- **`.sdlc/.env` is gitignored** — optional local override file for dev convenience

#### Credential Resolution Order (priority high → low)

```
1. Environment variable          JIRA_TOKEN, FIGMA_TOKEN, etc.
2. Project .env file             .sdlc/.env  (gitignored)
3. Global credential store       ~/.config/sdlc/credentials  (user-level)
4. Provider-specific credential  ~/.jira/credentials, ~/.figma/token, etc.
```

This mirrors how git credentials work — the framework never owns credential storage, it only resolves them.

#### `.gitignore` entries added by framework setup

```gitignore
# ai-in-sdlc — credentials (never commit)
.sdlc/.env
.sdlc/.secrets/

# ai-in-sdlc — local dev overrides (optional gitignore)
# .sdlc/profiles/local.yaml
```

#### What IS committed

```
.sdlc/config.json           ✅  (no credentials, just adapter type + profile paths)
.sdlc/profiles/             ✅  (stack, conventions — not sensitive)
.sdlc/work-items/           ✅  (task state)
.sdlc/artifacts/            ✅  (requirements, design docs, test cases)
.sdlc/decisions/            ✅  (ADRs)
.sdlc/phases/               ✅  (PhasePackets — execution state)
.sdlc/executions/           ✅  (audit log)
.sdlc/actors/               ✅  (team + agent registry)
```

#### `config.json` provider config (no secrets inline)

```json
{
  "knowledge_adapter": "local-file",
  "active_providers": ["jira", "figma"],
  "providers": {
    "jira": {
      "base_url": "https://company.atlassian.net",
      "project_key": "PROJ",
      "token_env": "JIRA_TOKEN"
    },
    "figma": {
      "team_id": "123456789",
      "token_env": "FIGMA_TOKEN"
    }
  },
  "profiles": {
    "project": ".sdlc/profiles/project.yaml"
  }
}
```

`token_env` là tên của environment variable — không phải giá trị. Framework đọc `process.env[token_env]` khi cần.

#### Rationale
- Team chia sẻ context mà không cần setup riêng mỗi người (mỗi người chỉ cần set env vars)
- Pattern quen thuộc với developer — giống `.env` + `git secret` workflow hiện tại
- Credentials không bao giờ accidentially leak qua git
- CI/CD systems inject credentials qua env vars — cùng pattern

#### Alternatives Rejected
- **Gitignore toàn bộ `.sdlc/`**: mỗi developer phải re-ingest toàn bộ context từ đầu, mất audit trail
- **Lưu credentials trong `config.json`** (encrypted): thêm complexity, vẫn có risk nếu key rotation không đúng

---

## Open Questions / Future Decisions

| # | Question | Impact | Target Decision Date |
|---|----------|--------|---------------------|
| OQ-001 | When should we support multiple concurrent WorkItems in the same `.sdlc/`? (team workflows) | Knowledge base concurrency model | Phase 2 |
| OQ-002 | How do we version the adaptation profiles when the codebase evolves? | Profile drift risk | Phase 2 |
| ~~OQ-003~~ | ~~Should `.sdlc/` be committed to git by default?~~ | **Resolved → ADR-013** | 2026-04-07 |
| ~~OQ-004~~ | ~~Model routing strategy per phase?~~ | **Resolved → ADR-014** | 2026-04-07 |

---

## ADR-014

### Model routing config: hierarchy override + centralized definition

**Status**: Accepted  
**Date**: 2026-04-07

#### Context
Different phases have different cognitive demands. Hardcoding model names into each `.agent.md` or `SKILL.md` file makes it impossible to swap models org-wide or per-project without editing every file. Additionally, GPT-5.4 is available at the same price tier as GPT-4o with better quality — the default should reflect this.

#### Decision
Model configuration is **centralized** in `.sdlc/profiles/models.yaml` and applied via a **4-level hierarchy override**. Individual agent/skill files reference a **tier alias** (e.g., `high`, `mid`, `low`), not a model name directly.

#### Override Hierarchy (highest → lowest priority)

```
1. Phase-level override     .sdlc/profiles/models.yaml → phases.{phase}.model
2. Skill-level override     .sdlc/profiles/models.yaml → skills.{skill}.model
3. Project default          .sdlc/profiles/models.yaml → defaults.{tier}
4. Org default              .sdlc/profiles/org.yaml    → models.defaults.{tier}
```

Runtime agent files (`.agent.md`, `SKILL.md`) use tier aliases only — never hardcoded model names:
```yaml
# In .agent.md frontmatter
model: "{{model.tier.high}}"   # resolved at runtime from models.yaml
```

#### `.sdlc/profiles/models.yaml` — Central Model Config

```yaml
# Model tier aliases — change here to affect all phases/skills
defaults:
  high: "claude-opus-4"          # Architecture decisions, design analysis
  mid:  "claude-sonnet-4"        # Code generation, requirement structuring
  low:  "claude-haiku-3"         # Mechanical tasks: checks, PR creation, indexing

# Alternative providers (uncomment to use)
# defaults:
#   high: "gpt-5.4"              # Same price tier as GPT-4o, better quality
#   mid:  "gpt-5.4"
#   low:  "gpt-4o-mini"

# Per-phase overrides (optional — falls back to defaults if not set)
phases:
  intake:   {tier: low,  model: null}   # null = use tier default
  define:   {tier: mid,  model: null}
  decide:   {tier: high, model: null}
  produce:  {tier: mid,  model: null}
  verify:   {tier: low,  model: null}
  approve:  {tier: null, model: null}   # No AI in approve phase
  integrate:{tier: low,  model: null}

# Per-skill overrides (optional — overrides phase default for that skill)
skills:
  start-feature:
    decide: {model: "claude-opus-4"}    # Explicit override for complex features
  fix-bug:
    decide: {model: "claude-sonnet-4"}  # Bug root-cause doesn't need full Opus
  write-unit-tests:
    produce: {model: "claude-sonnet-4"}
  write-auto-tests:
    produce: {model: "claude-sonnet-4"}
    decide:  {model: "claude-opus-4"}   # Test strategy needs careful thinking

# Fallback chain: if primary model unavailable, try next in list
fallback_chain:
  high: ["claude-opus-4", "gpt-5.4", "claude-sonnet-4"]
  mid:  ["claude-sonnet-4", "gpt-5.4", "claude-haiku-3"]
  low:  ["claude-haiku-3", "gpt-4o-mini", "claude-sonnet-4"]
```

#### Default Model Assignments

| Phase | Tier | Default Model | Rationale |
|-------|------|--------------|-----------|
| **Intake** | low | claude-haiku-3 | Context loading, intent parsing — mechanical |
| **Define** | mid | claude-sonnet-4 | Requirement structuring, acceptance criteria |
| **Decide** | high | claude-opus-4 | Impact analysis, architecture decisions — most critical |
| **Produce** | mid | claude-sonnet-4 | Code generation — balance quality and cost |
| **Verify** | low | claude-haiku-3 | Running checks, reading test output — mechanical |
| **Approve** | — | — | No AI; human-only phase |
| **Integrate** | low | claude-haiku-3 | PR creation, graph update — mechanical |

#### Per-Skill Notable Overrides

| Skill | Phase | Override | Reason |
|-------|-------|----------|--------|
| `start-feature` | Decide | claude-opus-4 (explicit) | Features carry highest architecture risk |
| `fix-bug` | Decide | claude-sonnet-4 | Root cause is analytical but scope-limited |
| `write-auto-tests` | Decide | claude-opus-4 | Test strategy, environment, oracle selection — complex |

#### Runtime Mapping

| Runtime | Model Config Location | How Model is Selected |
|---------|----------------------|----------------------|
| **GitHub Copilot** | `.sdlc/profiles/models.yaml` | `.agent.md` frontmatter: `model:` reads resolved value from config |
| **Claude Code** | `.sdlc/profiles/models.yaml` | `--model` flag injected per subagent call |
| **OpenCode** | `.sdlc/profiles/models.yaml` | `task(category=...)` maps tier → category; model resolved by OMO |

> **Porting note for OpenCode**: OMO's category system (quick/deep/ultrabrain) maps naturally to tiers. `low → quick`, `mid → unspecified-high`, `high → ultrabrain` or `deep`. The `models.yaml` tier system and OMO categories are reconciled in the OpenCode adapter.

#### Rationale
- Centralized config = one place to change models for the whole project or org
- Tier aliases decouple agent logic from model names — model upgrades don't require editing agent files
- Per-skill overrides allow fine-tuning without losing the global default
- Fallback chain ensures graceful degradation if a model is unavailable or rate-limited

#### Alternatives Rejected
- **Hardcode model in each `.agent.md`**: model upgrades require editing every file; org-wide changes impossible
- **Single model for everything**: wastes cost on low-complexity phases; under-invests on critical decisions
- **User picks model at invocation time**: too much friction; developers shouldn't think about model selection for routine tasks
