# ai-in-sdlc — Roadmap

---

## Milestone 1: GitHub Copilot MVP

**Goal**: A working toolset for GitHub Copilot (VS Code Agent Mode) covering the two most common developer intents: `start-feature` and `fix-bug`. Proves the phase engine and knowledge base work end-to-end on a real project.

### Phase 1 — Core Infrastructure

**Deliverables**:
- `.sdlc/` directory schema (WorkItem, Artifact, ArtifactVersion, Decision, Execution, PhasePacket)
- `LocalFileAdapter` — read/write/search over `.sdlc/` files
- `project.yaml` adaptation profile schema + loader
- `copilot-instructions.md` — always-on project context injection
- Phase agent skeleton: `intake.agent.md`, `define.agent.md`, `decide.agent.md`, `produce.agent.md`, `verify.agent.md`, `approve.agent.md`, `integrate.agent.md`
- Handoff chain wiring (each agent → next via `send: false` buttons)

**Human gate implementation**:
- Approve phase: agent outputs review package → user opens artifact → reports back in chat

**Success criteria**:
- Developer can run through all 7 phases manually (clicking handoff buttons)
- State is persisted in `.sdlc/` between sessions
- PhasePacket written at end of each phase, readable by next phase agent

---

### Phase 2 — Skills: `start-feature` + `fix-bug`

**Deliverables**:
- `start-feature/SKILL.md` — full phase projection, acceptance criteria gathering, design decision capture
- `fix-bug/SKILL.md` — bug reproduction, root cause analysis, minimal fix plan
- `update-requirements/SKILL.md` — requirement structuring + invalidation propagation
- Adaptation profile injection: project stack + component profile loaded per skill invocation
- Approve gate artifacts: excalidraw diagram generation for architecture decisions

**Success criteria**:
- Developer types `/start-feature` in Copilot Chat, completes a full feature cycle end-to-end
- All decisions, artifacts, and executions recorded in `.sdlc/`
- Approve gate correctly triggers for architecture changes, auto-passes for trivial changes

---

### Phase 3 — Skills: `write-unit-tests` + `write-auto-tests`

**Deliverables**:
- `write-unit-tests/SKILL.md` — coverage gap analysis, test seam identification, test generation
- `write-auto-tests/SKILL.md` — flow extraction from design artifacts, E2E script generation
- Traceability: generated tests linked to requirements in `.sdlc/`
- Coverage threshold check in Verify phase (auto-pass gate)

**Success criteria**:
- Developer types `/write-unit-tests`, agent generates tests with correct coverage for the given requirements
- Tests are linked to requirement `ArtifactVersion` records in `.sdlc/`

---

### Phase 4 — External Providers (MVP integrations)

**Deliverables**:
- Jira MCP server configuration + `JiraProviderAdapter` (normalize tickets → WorkItems + requirements)
- Figma MCP server configuration + `FigmaProviderAdapter` (normalize frames → design-artifact ArtifactVersions)
- OpenAPI `ApiSpecIngestor` (ingest API specs into knowledge base)
- `BulkIngestor` CLI: `sdlc ingest codebase`, `sdlc ingest docs`, `sdlc ingest jira`

**Fallback** (for Enterprise where MCP is disabled):
- Documented workflow for manually pasting Jira/Figma content + agent normalization step

**Success criteria**:
- Developer runs `sdlc ingest jira --project PROJ`, requirements appear in `.sdlc/artifacts/requirement/`
- Figma mockup imported via MCP, available as `design-artifact` in knowledge base, linked to requirement

---

### Phase 5 — Pilot on Real Project

**Goal**: Validate framework on one real project with a real team.

**Activities**:
- Onboard one project (run `sdlc ingest codebase` + `sdlc ingest docs`)
- Team uses `start-feature` and `fix-bug` for 2–4 weeks
- Collect: which phases are skipped, which gates are clicked through without reading, which skills feel too heavy

**Prune criteria** (per ADR-001):
- If a phase is consistently skipped → make it optional by default in skill config
- If a gate is consistently rubber-stamped → convert to auto-pass with evidence
- If a skill feels like mini-waterfall → reduce required phases to minimum viable

**Milestone 1 Done When**:
- [ ] Two skills (`start-feature`, `fix-bug`) used in production on one project
- [ ] Knowledge base populated and queried by agents
- [ ] At least one external provider (Jira or Figma) integrated
- [ ] Pilot feedback incorporated

---

## Milestone 2: Claude Code Port

**Goal**: Port the framework to Claude Code CLI. Leverage background parallelism and cross-session memory unavailable in Copilot.

### Key Porting Tasks (see DECISIONS.md for detailed mapping)

| Component | Copilot (M1) | Claude Code (M2) |
|-----------|-------------|-----------------|
| Phase engine | Handoff chain (`.agent.md`) | Sequential `Task` subagent calls in SKILL.md loop |
| Skill loading | `.github/skills/*/SKILL.md` | `.claude/skills/*/SKILL.md` |
| Human gates | Handoff buttons (`send: false`) | Interactive prompts + `--dangerously-skip-permissions` off |
| Parallel execution | ❌ | ✅ Background tasks for within-phase parallelism |
| Cross-session memory | Files only | `phloem_remember` + files |
| Autonomy level | Per-session user opt-in | Default autonomous, gates at key points |

**New capabilities unlocked in M2**:
- Parallel subagents within Produce phase (API agent + UI agent run simultaneously)
- Cross-session memory: past decisions and patterns remembered without re-reading files
- Autonomous mode: full `start-feature` cycle without clicking handoff buttons

**M2 Done When**:
- [ ] All M1 skills ported and working in Claude Code
- [ ] Parallel Produce phase working (two subagents for complex features)
- [ ] Cross-session memory reducing context load per invocation

---

## Milestone 3: OpenCode Port

**Goal**: Port to OpenCode (OMO), with deep GSD integration.

### Key Additions vs M2

- Skills loadable via `load_skills=[...]` in OMO `task()` calls
- Skills surfaced as OMO slash commands
- Phase engine runs as OMO orchestration loop (Sisyphus orchestrates phase subagents)
- GSD-style phase directories mapped to `.sdlc/phases/`

**M3 Done When**:
- [ ] All skills available as OMO slash commands
- [ ] Phase engine integrated with OMO's task/todo system
- [ ] `.sdlc/` and `.planning/` coexist cleanly (GSD for project phases, `.sdlc/` for SDLC artifacts)

---

## Milestone 4: Knowledge Base Upgrade

**Goal**: Upgrade default knowledge base from LocalFile to vector + graph for teams that need semantic search and requirement traceability at scale.

### Deliverables
- `VectorDBAdapter` (Qdrant) — semantic similarity search over requirements and design docs
- `GraphDBAdapter` (Neo4j + Graphiti) — multi-hop traceability queries + temporal facts
- Migration tool: `sdlc migrate local-file → vector-db`
- Traceability queries: "which tests cover this requirement?", "what changed since sprint start?"

---

## Milestone 5: Additional Providers + Ingestors

**Goal**: Expand the external artifact ecosystem.

| Provider | Milestone |
|----------|-----------|
| Jira / Linear | M1 Phase 4 |
| Figma | M1 Phase 4 |
| OpenAPI / GraphQL | M1 Phase 4 |
| Confluence / Notion | M5 |
| GitHub Issues | M5 |
| Git history (advanced) | M5 |

---

## Open Questions Blocking Roadmap

| Question | Blocks | Resolution |
|----------|--------|-----------|
| OQ-003: Should `.sdlc/` be git-committed by default? | M1 Phase 1 | Decide before Phase 1 ships |
| OQ-004: Model routing per phase? | M1 Phase 2 | Decide before skill implementation |
