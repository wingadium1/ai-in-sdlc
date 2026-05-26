# AI-SDLC Integration Framework — Implementation Roadmap

> **Purpose**: Detailed execution plan for the AI-SDLC Integration Framework. This document translates the strategic roadmap (`ROADMAP.md`) into actionable milestones with task-level breakdowns, effort estimates, dependency chains, risk registers, and completion criteria.
>
> **Scope**: Covers both the product roadmap (M1–M5) and the integration-layer milestones (IM1–IM3) that connect GSD, OMO, AI-in-sdlc, and agent-for-ba.
>
> **Estimation Unit**: Person-days (pd). A single senior engineer working full-time on the task. Parallel workstreams scale linearly.

**Status**: Living roadmap  
**Last Updated**: 2026-05-26  
**Owner**: AI-SDLC Core Team

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Milestone Inventory (Summary)](#milestone-inventory-summary)
3. [Milestone 1 — GitHub Copilot MVP](#milestone-1--github-copilot-mvp)
4. [Milestone 2 — Claude Code Port](#milestone-2--claude-code-port)
5. [Milestone 3 — OpenCode Port](#milestone-3--opencode-port)
6. [Milestone 4 — Knowledge Base Upgrade](#milestone-4--knowledge-base-upgrade)
7. [Milestone 5 — Additional Providers + Ingestors](#milestone-5--additional-providers--ingestors)
8. [Integration Milestone 1 — Convention Layer + Handoff Adapters](#integration-milestone-1--convention-layer--handoff-adapters)
9. [Integration Milestone 2 — State Sync + Safety Mechanisms](#integration-milestone-2--state-sync--safety-mechanisms)
10. [Integration Milestone 3 — E2E Pipeline + Team Onboarding](#integration-milestone-3--e2e-pipeline--team-onboarding)
11. [Critical Path Analysis](#critical-path-analysis)
12. [Risk Register](#risk-register)
13. [Resource & Effort Summary](#resource--effort-summary)
14. [Open Questions](#open-questions)
15. [Next Steps](#next-steps)
16. [References](#references)

---

## Executive Summary

This roadmap defines the delivery of the AI-SDLC Integration Framework across **five product milestones** (M1–M5) and **three integration milestones** (IM1–IM3). The product milestones mature the framework from a GitHub Copilot MVP through advanced knowledge base capabilities. The integration milestones connect GSD (planning), OMO (execution), AI-in-sdlc (dev skills), and agent-for-ba (BA skills) into a unified AI-augmented SDLC pipeline.

**Key Principles**:
- `.sdlc/` artifact schema remains identical across all runtimes
- Integration is file-based (convention layer), not a custom orchestrator
- Each system keeps its own knowledge base (`.planning/`, `wiki/`, `.sdlc/`)
- Human gates trigger only at irreversible or ambiguous transitions

**Total Estimated Effort**: ~200 person-days across all milestones.

---

## Milestone Inventory (Summary)

| ID | Milestone | Target Duration | Effort (pd) | Parallel Workstreams | Status | Blocks |
|-----------|-----------|----------------|-------------|---------------------|--------|--------|
| **M1** | GitHub Copilot MVP | 8–10 weeks | ~45 pd | 3 | 🔄 In progress | M2, M3, IM1 |
| **M2** | Claude Code Port | 5–6 weeks | ~25 pd | 2 | Planned | M3, IM2 |
| **M3** | OpenCode Port | 5–6 weeks | ~25 pd | 2 | Planned | M4, IM3 |
| **M4** | Knowledge Base Upgrade | 6–8 weeks | ~35 pd | 2 | Planned | M5 |
| **M5** | Additional Providers + Ingestors | 4–5 weeks | ~20 pd | 2 | Planned | — |
| **IM1** | Convention Layer + Handoff Adapters | 3–4 weeks | ~15 pd | 2 | Planned | IM2 |
| **IM2** | State Sync + Safety Mechanisms | 4–5 weeks | ~20 pd | 2 | Planned | IM3 |
| **IM3** | E2E Pipeline + Team Onboarding | 3–4 weeks | ~15 pd | 2 | Planned | — |

**Team Recommendation**: 2 DevEx engineers, 1 Backend engineer, 1 Integrations specialist, 1 QA engineer, 0.5 Architect, 0.5 PM (~5.5 FTE).

---

## Milestone 1 — GitHub Copilot MVP

**Goal**: A working toolset for GitHub Copilot (VS Code Agent Mode) covering `start-feature` and `fix-bug`. Proves the phase engine and knowledge base work end-to-end on a real project.

**Target Duration**: 8–10 weeks  
**Estimated Effort**: ~45 person-days  
**Parallel Workstreams**: 3 (Core Infra, Skills, Providers)

### Task Breakdown

#### Phase 1 — Core Infrastructure (15 pd)

| Task ID | Task | Effort (pd) | Owner | Dependencies | Deliverable |
|---------|------|-------------|-------|-------------|-------------|
| M1-P1-T1 | Design `.sdlc/` directory schema | 2 | Architect | — | Schema spec + JSON templates |
| M1-P1-T2 | Implement `LocalFileAdapter` (CRUD, search) | 3 | Backend | M1-P1-T1 | Adapter code + unit tests |
| M1-P1-T3 | Define `project.yaml` schema + loader | 2 | Backend | M1-P1-T1 | Schema + loader code |
| M1-P1-T4 | Author `copilot-instructions.md` | 1 | DevEx | M1-P1-T3 | Always-on context file |
| M1-P1-T5 | Create 7 phase agent skeletons (`*.agent.md`) | 4 | DevEx | M1-P1-T1 | `runtime/copilot/.github/agents/` |
| M1-P1-T6 | Wire handoff chain (`send: false` buttons) | 2 | DevEx | M1-P1-T5 | Handoff definitions + test |
| M1-P1-T7 | Implement Approve-phase human gate | 1 | DevEx | M1-P1-T5 | Gate logic + artifact review flow |

#### Phase 2 — Skills: `start-feature` + `fix-bug` (12 pd)

| Task ID | Task | Effort (pd) | Owner | Dependencies | Deliverable |
|---------|------|-------------|-------|-------------|-------------|
| M1-P2-T1 | Author `start-feature/SKILL.md` | 3 | DevEx | M1-P1-T6 | Full skill definition |
| M1-P2-T2 | Author `fix-bug/SKILL.md` | 3 | DevEx | M1-P1-T6 | Full skill definition |
| M1-P2-T3 | Author `update-requirements/SKILL.md` | 2 | DevEx | M1-P1-T6 | Requirement propagation skill |
| M1-P2-T4 | Implement adaptation profile injection | 2 | Backend | M1-P1-T3 | Profile loader per skill |
| M1-P2-T5 | Approve gate: Excalidraw diagram generation | 2 | DevEx | M1-P2-T1 | Architecture decision artifact |

#### Phase 3 — Skills: `write-unit-tests` + `write-auto-tests` (8 pd)

| Task ID | Task | Effort (pd) | Owner | Dependencies | Deliverable |
|---------|------|-------------|-------|-------------|-------------|
| M1-P3-T1 | Author `write-unit-tests/SKILL.md` | 3 | QA Eng | M1-P2-T1 | Coverage-aware test skill |
| M1-P3-T2 | Author `write-auto-tests/SKILL.md` | 3 | QA Eng | M1-P2-T1 | E2E test skill |
| M1-P3-T3 | Traceability: link tests to requirements | 1 | Backend | M1-P3-T1 | Artifact linking logic |
| M1-P3-T4 | Coverage threshold gate in Verify phase | 1 | QA Eng | M1-P3-T3 | Auto-pass gate logic |

#### Phase 4 — External Providers (7 pd)

| Task ID | Task | Effort (pd) | Owner | Dependencies | Deliverable |
|---------|------|-------------|-------|-------------|-------------|
| M1-P4-T1 | Jira MCP server config + `JiraProviderAdapter` | 2 | Integrations | M1-P1-T2 | Jira → WorkItem normalizer |
| M1-P4-T2 | Figma MCP server config + `FigmaProviderAdapter` | 2 | Integrations | M1-P1-T2 | Figma → ArtifactVersion normalizer |
| M1-P4-T3 | OpenAPI `ApiSpecIngestor` | 2 | Integrations | M1-P1-T2 | Spec → design-artifact ingestor |
| M1-P4-T4 | `BulkIngestor` CLI (`sdlc ingest …`) | 1 | Integrations | M1-P4-T1, M1-P4-T2 | CLI commands |

#### Phase 5 — Pilot on Real Project (3 pd)

| Task ID | Task | Effort (pd) | Owner | Dependencies | Deliverable |
|---------|------|-------------|-------|-------------|-------------|
| M1-P5-T1 | Onboard pilot project | 1 | DevEx | M1-P2-T2, M1-P4-T4 | Populated `.sdlc/` |
| M1-P5-T2 | 2–4 week pilot execution | 1 | Team | M1-P5-T1 | Usage logs + feedback |
| M1-P5-T3 | Prune framework based on feedback | 1 | DevEx | M1-P5-T2 | ADR updates + config changes |

### Dependencies

```
M1-P1 (Infra) ─────┬──► M1-P2 (Skills) ────┬──► M1-P5 (Pilot)
                   │                        │
                   └──► M1-P3 (Tests) ──────┘
                   │
                   └──► M1-P4 (Providers) ───┘
```

### Milestone Completion Criteria

- [ ] Two skills (`start-feature`, `fix-bug`) used in production on one project.
- [ ] Knowledge base (`.sdlc/`) populated and queried by agents.
- [ ] At least one external provider (Jira or Figma) integrated.
- [ ] Pilot feedback incorporated (phases pruned, gates adjusted).
- [ ] All 7 phase agents complete handoff chain end-to-end without state loss.
- [ ] Approve gate correctly triggers for architecture changes, auto-passes for trivial changes.

### Risks & Mitigations

| Risk ID | Risk | Likelihood | Impact | Mitigation |
|---------|------|------------|--------|------------|
| M1-R1 | GitHub Copilot `.agent.md` handoff API changes | Medium | High | Pin Copilot extension version; maintain compatibility layer in `copilot-instructions.md` |
| M1-R2 | MCP servers unavailable in Enterprise (firewall) | High | Medium | Implement fallback: manual paste + agent normalization step |
| M1-R3 | Phase chain feels too heavy for small fixes | Medium | Medium | Implement prune criteria per ADR-001; make phases optional by default |
| M1-R4 | `.sdlc/` schema needs breaking change mid-M1 | Low | High | Freeze schema after P1-T1; version schema files; migration script |

---

## Milestone 2 — Claude Code Port

**Goal**: Port the framework to Claude Code CLI. Leverage background parallelism and cross-session memory unavailable in Copilot.

**Target Duration**: 5–6 weeks  
**Estimated Effort**: ~25 person-days  
**Parallel Workstreams**: 2 (Porting, New Capabilities)

### Task Breakdown

#### Workstream A — Porting (15 pd)

| Task ID | Task | Effort (pd) | Owner | Dependencies | Deliverable |
|---------|------|-------------|-------|-------------|-------------|
| M2-A-T1 | Map Copilot `.agent.md` → Claude Code subagents | 3 | DevEx | M1 done | Porting guide + agent stubs |
| M2-A-T2 | Port `start-feature` skill to Claude Code | 2 | DevEx | M2-A-T1 | `.claude/skills/start-feature/SKILL.md` |
| M2-A-T3 | Port `fix-bug` skill to Claude Code | 2 | DevEx | M2-A-T1 | `.claude/skills/fix-bug/SKILL.md` |
| M2-A-T4 | Port remaining 5 skills | 4 | DevEx | M2-A-T2, M2-A-T3 | All skills in `.claude/skills/` |
| M2-A-T5 | Human gate: interactive prompts + permissions | 2 | DevEx | M2-A-T1 | Permission-aware gate implementation |
| M2-A-T6 | Phase engine: sequential `Task` subagent loop | 2 | DevEx | M2-A-T1 | Orchestration loop in SKILL.md |

#### Workstream B — New Capabilities (10 pd)

| Task ID | Task | Effort (pd) | Owner | Dependencies | Deliverable |
|---------|------|-------------|-------|-------------|-------------|
| M2-B-T1 | Parallel Produce phase (API + UI subagents) | 3 | DevEx | M2-A-T6 | Multi-subagent Produce skill |
| M2-B-T2 | Cross-session memory via `phloem_remember` | 3 | Backend | M2-A-T6 | Memory integration + persistence |
| M2-B-T3 | Autonomous mode: full cycle without handoff clicks | 2 | DevEx | M2-A-T6 | `--dangerously-skip-permissions` loop |
| M2-B-T4 | Migration guide: Copilot → Claude Code | 2 | DevEx | M2-A-T4 | `docs/migration/copilot-to-claude.md` |

### Dependencies

```
M1 ─────► M2-A (Porting) ─────┬──► M2-B-T1 (Parallel Produce)
                              ├──► M2-B-T2 (Cross-session memory)
                              └──► M2-B-T3 (Autonomous mode)
```

### Milestone Completion Criteria

- [ ] All M1 skills ported and working in Claude Code.
- [ ] Parallel Produce phase working (two subagents for complex features).
- [ ] Cross-session memory reducing context load per invocation.
- [ ] Autonomous mode documented and tested on at least one real feature.
- [ ] `.sdlc/` schema unchanged (zero migration required).

### Risks & Mitigations

| Risk ID | Risk | Likelihood | Impact | Mitigation |
|---------|------|------------|--------|------------|
| M2-R1 | Claude Code `Task` API behavior differs from docs | Medium | High | Spike subagent invocation early; build thin wrapper |
| M2-R2 | `--dangerously-skip-permissions` deemed unsafe for team use | Medium | Medium | Make autonomous mode opt-in per project; document guardrails |
| M2-R3 | `phloem_remember` API rate limits | Low | Medium | Fallback to file-only state; cache frequently accessed decisions |
| M2-R4 | Parallel subagents conflict on shared `.sdlc/` files | Medium | High | Implement file locking or atomic writes in `LocalFileAdapter` |

---

## Milestone 3 — OpenCode Port

**Goal**: Port to OpenCode (OMO), with deep GSD integration.

**Target Duration**: 5–6 weeks  
**Estimated Effort**: ~25 person-days  
**Parallel Workstreams**: 2 (Porting, GSD Integration)

### Task Breakdown

#### Workstream A — OMO Porting (15 pd)

| Task ID | Task | Effort (pd) | Owner | Dependencies | Deliverable |
|---------|------|-------------|-------|-------------|-------------|
| M3-A-T1 | Map skills to OMO `load_skills=[...]` | 3 | DevEx | M2 done | Skill registration spec |
| M3-A-T2 | Surface skills as OMO slash commands | 2 | DevEx | M3-A-T1 | Command definitions |
| M3-A-T3 | Port phase engine to OMO `task()` orchestration | 3 | DevEx | M3-A-T1 | Sisyphus orchestration loop |
| M3-A-T4 | Port all 7 skills to OMO runtime | 4 | DevEx | M3-A-T2 | `.opencode/skills/` |
| M3-A-T5 | OMO-specific `question` tool gates | 2 | DevEx | M3-A-T3 | Human gate via `question` tool |

#### Workstream B — GSD Integration (10 pd)

| Task ID | Task | Effort (pd) | Owner | Dependencies | Deliverable |
|---------|------|-------------|-------|-------------|-------------|
| M3-B-T1 | Map GSD phase directories → `.sdlc/phases/` | 2 | Integrations | M3-A-T3 | Directory coexistence spec |
| M3-B-T2 | Implement GSD→OMO handoff adapter | 3 | Integrations | M3-B-T1 | File-based adapter script |
| M3-B-T3 | OMO task result → GSD STATE.md feedback | 2 | Integrations | M3-B-T2 | Result propagation logic |
| M3-B-T4 | `.sdlc/` and `.planning/` coexistence validation | 2 | Integrations | M3-B-T1 | Validation tests |
| M3-B-T5 | Document integration workflow | 1 | Integrations | M3-B-T4 | `docs/integration/gsd-omo.md` |

### Dependencies

```
M2 ─────► M3-A (OMO Porting) ─────┬──► M3-B-T1 (Directory mapping)
                                  │     └──► M3-B-T2 (Handoff adapter)
                                  │           └──► M3-B-T3 (Result feedback)
                                  │                 └──► M3-B-T5 (Docs)
                                  └──► M3-B-T4 (Coexistence validation)
```

### Milestone Completion Criteria

- [ ] All skills available as OMO slash commands.
- [ ] Phase engine integrated with OMO's task/todo system.
- [ ] `.sdlc/` and `.planning/` coexist cleanly (no file collisions, no overwrites).
- [ ] GSD→OMO handoff works end-to-end on at least one GSD phase.
- [ ] `.sdlc/` schema unchanged.

### Risks & Mitigations

| Risk ID | Risk | Likelihood | Impact | Mitigation |
|---------|------|------------|--------|------------|
| M3-R1 | OMO `task()` API changes during porting | Low | High | Pin OMO version; build abstraction layer |
| M3-R2 | GSD and OMO directory conventions conflict | Medium | Medium | Early validation spike (Task 3 in PLAN.md); explicit ownership rules |
| M3-R3 | Deep GSD integration creates circular dependency | Low | High | Keep GSD and OMO as peers; integration layer is read-only adapter |
| M3-R4 | Team adoption slower due to CLI learning curve | Medium | Medium | Pair with M3-B-T5 documentation; provide migration guide from Copilot |

---

## Milestone 4 — Knowledge Base Upgrade

**Goal**: Upgrade default knowledge base from LocalFile to vector + graph for teams needing semantic search and requirement traceability at scale.

**Target Duration**: 6–8 weeks  
**Estimated Effort**: ~35 person-days  
**Parallel Workstreams**: 2 (Vector DB, Graph DB)

### Task Breakdown

#### Workstream A — Vector DB (15 pd)

| Task ID | Task | Effort (pd) | Owner | Dependencies | Deliverable |
|---------|------|-------------|-------|-------------|-------------|
| M4-A-T1 | Design `VectorDBAdapter` interface | 2 | Architect | M3 done | Interface spec + Qdrant schema |
| M4-A-T2 | Implement `VectorDBAdapter` (Qdrant) | 5 | Backend | M4-A-T1 | Adapter + CRUD + search |
| M4-A-T3 | Semantic search: requirements + design docs | 3 | Backend | M4-A-T2 | Search endpoints |
| M4-A-T4 | Migration tool: `sdlc migrate local-file → vector-db` | 3 | Backend | M4-A-T2 | CLI migration command |
| M4-A-T5 | Model routing: embedding model config | 2 | Backend | M4-A-T1 | `models.yaml` embedding tier |

#### Workstream B — Graph DB (15 pd)

| Task ID | Task | Effort (pd) | Owner | Dependencies | Deliverable |
|---------|------|-------------|-------|-------------|-------------|
| M4-B-T1 | Design `GraphDBAdapter` interface (Neo4j + Graphiti) | 2 | Architect | M3 done | Interface spec + graph schema |
| M4-B-T2 | Implement `GraphDBAdapter` | 5 | Backend | M4-B-T1 | Adapter + CRUD + traversal |
| M4-B-T3 | Multi-hop traceability queries | 3 | Backend | M4-B-T2 | "Tests cover requirement?" queries |
| M4-B-T4 | Temporal queries: "state at point T" | 3 | Backend | M4-B-T2 | Graphiti temporal facts |
| M4-B-T5 | Migration tool: `sdlc migrate local-file → graph-db` | 2 | Backend | M4-B-T2 | CLI migration command |

#### Integration (5 pd)

| Task ID | Task | Effort (pd) | Owner | Dependencies | Deliverable |
|---------|------|-------------|-------|-------------|-------------|
| M4-I-T1 | Composite adapter: auto-select backend | 2 | Backend | M4-A-T2, M4-B-T2 | Router logic |
| M4-I-T2 | Benchmark: query latency vs LocalFile | 2 | QA Eng | M4-I-T1 | Performance report |
| M4-I-T3 | Documentation: when to upgrade | 1 | DevEx | M4-I-T2 | `docs/kb-upgrade-guide.md` |

### Dependencies

```
M3 ─────┬──► M4-A (Vector DB) ────┬──► M4-I (Integration)
        │                         │
        └──► M4-B (Graph DB) ─────┘
```

### Milestone Completion Criteria

- [ ] `VectorDBAdapter` supports semantic similarity search over requirements.
- [ ] `GraphDBAdapter` supports multi-hop traceability queries.
- [ ] Migration tool converts existing `.sdlc/` data without loss.
- [ ] Query latency benchmark shows acceptable performance vs LocalFile.
- [ ] Teams can upgrade by changing one config key (`knowledge_adapter` in `config.json`).

### Risks & Mitigations

| Risk ID | Risk | Likelihood | Impact | Mitigation |
|---------|------|------------|--------|------------|
| M4-R1 | Qdrant/Neo4j infra unavailable for small teams | High | Medium | Keep LocalFile as default; upgrade is opt-in |
| M4-R2 | Embedding model costs unpredictable | Medium | Medium | Support local embedding models (e.g., Ollama); budget caps in `org.yaml` |
| M4-R3 | Graph schema needs redesign for temporal queries | Medium | High | Prototype with Graphiti early; iterate schema before full implementation |
| M4-R4 | Migration tool corrupts existing `.sdlc/` data | Low | High | Full backup before migration; idempotent migration; dry-run mode |

---

## Milestone 5 — Additional Providers + Ingestors

**Goal**: Expand the external artifact ecosystem.

**Target Duration**: 4–5 weeks  
**Estimated Effort**: ~20 person-days  
**Parallel Workstreams**: 2 (Providers, Ingestors)

### Task Breakdown

| Task ID | Task | Effort (pd) | Owner | Dependencies | Deliverable |
|---------|------|-------------|-------|-------------|-------------|
| M5-T1 | Confluence `ProviderAdapter` + MCP | 4 | Integrations | M4 done | Confluence → ArtifactVersion |
| M5-T2 | Notion `ProviderAdapter` + MCP | 3 | Integrations | M4 done | Notion → ArtifactVersion |
| M5-T3 | GitHub Issues `ProviderAdapter` | 3 | Integrations | M4 done | Issues → WorkItem/BugReport |
| M5-T4 | Git history advanced ingestor | 4 | Integrations | M4 done | `sdlc ingest git-history` |
| M5-T5 | Provider priority config in `config.json` | 2 | Backend | M5-T1 | Dynamic provider loading |
| M5-T6 | Documentation: provider setup guide | 2 | DevEx | M5-T5 | `docs/provider-setup.md` |
| M5-T7 | Community provider template | 2 | DevEx | M5-T5 | `docs/provider-template.md` |

### Dependencies

```
M4 ─────► M5-T1 (Confluence) ─────┬──► M5-T5 (Config)
M4 ─────► M5-T2 (Notion) ─────────┤     └──► M5-T6 (Docs)
M4 ─────► M5-T3 (GitHub Issues) ──┤     └──► M5-T7 (Template)
M4 ─────► M5-T4 (Git history) ────┘
```

### Milestone Completion Criteria

- [ ] Confluence and Notion pages ingestible as `design-artifact` or `requirement`.
- [ ] GitHub Issues createable as `WorkItem` + `bug-report`.
- [ ] Git history ingestable for "what changed since sprint start?" queries.
- [ ] New providers can be added by implementing a 3-method interface.
- [ ] Provider setup guide covers all 6 providers (Jira, Figma, OpenAPI, Confluence, Notion, GitHub Issues).

### Risks & Mitigations

| Risk ID | Risk | Likelihood | Impact | Mitigation |
|---------|------|------------|--------|------------|
| M5-R1 | Confluence/Notion API rate limits | Medium | Low | Implement backoff + caching; batch requests |
| M5-R2 | Git history chunking complexity | High | Medium | Start with commit-message-only; defer diff chunking |
| M5-R3 | Provider API breaking changes | Medium | Medium | Version provider adapters independently; semantic versioning |
| M5-R4 | Too many providers dilute maintenance | Low | Medium | Community template + plugin model; core team maintains 4 only |

---

## Integration Milestone 1 — Convention Layer + Handoff Adapters

**Goal**: Establish the lightweight file-based integration layer connecting GSD, OMO, AI-in-sdlc, and agent-for-ba.

**Target Duration**: 3–4 weeks  
**Estimated Effort**: ~15 person-days  
**Parallel Workstreams**: 2 (Adapters, Validation)

### Task Breakdown

| Task ID | Task | Effort (pd) | Owner | Dependencies | Deliverable |
|---------|------|-------------|-------|-------------|-------------|
| IM1-T1 | Design convention layer topology | 2 | Architect | M1-P1-T1 | `docs/INTEGRATION-TOPOLOGY.md` |
| IM1-T2 | Define file location conventions | 1 | Architect | IM1-T1 | Convention spec |
| IM1-T3 | Implement GSD→OMO task handoff adapter | 3 | Integrations | IM1-T2 | `scripts/gsd-omo-handoff.sh` |
| IM1-T4 | Implement BA→Dev artifact handoff adapter | 3 | Integrations | IM1-T2 | `scripts/ba-dev-handoff.sh` |
| IM1-T5 | Define adapter input/output contracts | 2 | Architect | IM1-T3, IM1-T4 | `docs/HANDOFF-CONTRACTS.md` |
| IM1-T6 | Validation spike: end-to-end handoff test | 2 | QA Eng | IM1-T5 | E2E test script |
| IM1-T7 | Directory coexistence test | 1 | QA Eng | IM1-T2 | `test/coexistence/` |
| IM1-T8 | Document integration setup | 1 | DevEx | IM1-T6 | `docs/integration-setup.md` |

### Dependencies

```
IM1-T1 (Topology) ─────► IM1-T2 (Conventions) ─────┬──► IM1-T3 (GSD→OMO)
                                                    ├──► IM1-T4 (BA→Dev)
                                                    └──► IM1-T7 (Coexistence)

IM1-T3 + IM1-T4 ─────► IM1-T5 (Contracts)
IM1-T5 + IM1-T7 ─────► IM1-T6 (Validation)
IM1-T6 ──────────────► IM1-T8 (Docs)
```

### Milestone Completion Criteria

- [ ] GSD PLAN.md tasks can be extracted and fed to OMO as prompts.
- [ ] BA wiki artifacts can be discovered by Dev skills in `.sdlc/`.
- [ ] `.planning/`, `wiki/`, and `.sdlc/` coexist without collisions.
- [ ] Handoff contracts documented with format examples.
- [ ] E2E validation test passes for at least one handoff path.

### Risks & Mitigations

| Risk ID | Risk | Likelihood | Impact | Mitigation |
|---------|------|------------|--------|------------|
| IM1-R1 | File-based handoff too slow for large artifacts | Medium | Medium | Implement async batching; size limits in contract |
| IM1-R2 | BA output format changes break adapter | Medium | High | Version contract; validation gate before consumption |
| IM1-R3 | GSD PLAN.md format varies across phases | Medium | Medium | Parse multiple heading patterns; lenient extraction |
| IM1-R4 | Directory ownership confusion | Medium | Medium | Explicit ownership matrix in `INTEGRATION-TOPOLOGY.md`; git hooks |

---

## Integration Milestone 2 — State Sync + Safety Mechanisms

**Goal**: Ensure consistency across systems and define safety boundaries for autonomous execution.

**Target Duration**: 4–5 weeks  
**Estimated Effort**: ~20 person-days  
**Parallel Workstreams**: 2 (State Sync, Safety)

### Task Breakdown

| Task ID | Task | Effort (pd) | Owner | Dependencies | Deliverable |
|---------|------|-------------|-------|-------------|-------------|
| IM2-T1 | Define canonical state ownership matrix | 2 | Architect | IM1 done | `docs/STATE-SYNC.md` §Ownership |
| IM2-T2 | Implement conflict detection algorithm | 3 | Backend | IM2-T1 | Conflict detection script |
| IM2-T3 | Design replanning protocol | 2 | Architect | IM2-T1 | Protocol spec |
| IM2-T4 | Implement state sync rules | 3 | Backend | IM2-T1 | Sync daemon/script |
| IM2-T5 | Define circuit breaker rules | 2 | Architect | IM2-T3 | `docs/SAFETY-MECHANISMS.md` |
| IM2-T6 | Implement max-autonomy bounds | 2 | Backend | IM2-T5 | Autonomy limiter |
| IM2-T7 | Design rollback protocol | 2 | Architect | IM2-T3 | Rollback spec |
| IM2-T8 | Implement rollback mechanism | 2 | Backend | IM2-T7 | Rollback script |
| IM2-T9 | Ultrawork bounds documentation | 1 | DevEx | IM2-T5 | `docs/ultrawork-bounds.md` |
| IM2-T10 | Safety integration tests | 1 | QA Eng | IM2-T6, IM2-T8 | Safety test suite |

### Dependencies

```
IM1 ─────► IM2-T1 (Ownership) ─────┬──► IM2-T2 (Conflict detection)
                                   ├──► IM2-T3 (Replanning) ────┬──► IM2-T5 (Circuit breakers)
                                   │                            │     └──► IM2-T6 (Autonomy bounds)
                                   │                            │     └──► IM2-T9 (Ultrawork docs)
                                   ├──► IM2-T4 (Sync rules)     │
                                   └──► IM2-T7 (Rollback) ──────┘
                                                                 └──► IM2-T8 (Rollback impl)
                                                                       └──► IM2-T10 (Tests)
```

### Milestone Completion Criteria

- [ ] State ownership matrix defines which system owns which state.
- [ ] Conflict detection triggers human gate when systems disagree.
- [ ] Replanning protocol handles mid-execution plan changes safely.
- [ ] Circuit breakers stop autonomous execution after N errors or M minutes.
- [ ] Rollback protocol reverts to last known good state.
- [ ] Safety integration tests cover all failure modes.

### Risks & Mitigations

| Risk ID | Risk | Likelihood | Impact | Mitigation |
|---------|------|------------|--------|------------|
| IM2-R1 | Conflict detection too noisy (false positives) | Medium | Medium | Tunable thresholds; learn from human overrides |
| IM2-R2 | Rollback corrupts `.sdlc/` or `.planning/` | Low | High | Atomic snapshots before rollback; dry-run mode |
| IM2-R3 | Circuit breakers halt productive work | Medium | Medium | Warnings before breaks; escalate-to-human option |
| IM2-R4 | State sync creates infinite loops | Low | High | Deduplication checksums; max sync iterations |

---

## Integration Milestone 3 — E2E Pipeline + Team Onboarding

**Goal**: Validate the full integrated pipeline and onboard the first team.

**Target Duration**: 3–4 weeks  
**Estimated Effort**: ~15 person-days  
**Parallel Workstreams**: 2 (E2E, Onboarding)

### Task Breakdown

| Task ID | Task | Effort (pd) | Owner | Dependencies | Deliverable |
|---------|------|-------------|-------|-------------|-------------|
| IM3-T1 | E2E test: GSD plan → OMO execution → `.sdlc/` artifact | 3 | QA Eng | IM2 done | E2E test script |
| IM3-T2 | E2E test: BA requirement → Dev skill → verified code | 3 | QA Eng | IM2 done | E2E test script |
| IM3-T3 | Performance benchmark: full pipeline latency | 2 | QA Eng | IM3-T1, IM3-T2 | Benchmark report |
| IM3-T4 | Team onboarding guide | 2 | DevEx | IM3-T1 | `docs/team-onboarding.md` |
| IM3-T5 | Training materials (video/scripts) | 2 | DevEx | IM3-T4 | Training assets |
| IM3-T6 | Pilot with first real team | 2 | Team | IM3-T5 | Pilot feedback report |
| IM3-T7 | Iterate based on pilot feedback | 1 | DevEx | IM3-T6 | Framework updates |

### Dependencies

```
IM2 ─────┬──► IM3-T1 (E2E GSD→OMO)
         ├──► IM3-T2 (E2E BA→Dev)
         │       └──► IM3-T3 (Benchmark)
         │
         └──► IM3-T4 (Onboarding guide) ────► IM3-T5 (Training)
                                                   └──► IM3-T6 (Pilot)
                                                         └──► IM3-T7 (Iterate)
```

### Milestone Completion Criteria

- [ ] Full E2E pipeline runs successfully on synthetic data.
- [ ] BA requirement flows to Dev skill and produces verified code.
- [ ] GSD plan flows to OMO and produces `.sdlc/` artifacts.
- [ ] Team onboarding guide enables self-service setup.
- [ ] First real team completes at least one work item end-to-end.
- [ ] Pilot feedback incorporated into framework.

### Risks & Mitigations

| Risk ID | Risk | Likelihood | Impact | Mitigation |
|---------|------|------------|--------|------------|
| IM3-R1 | E2E test brittle due to timing/race conditions | Medium | Medium | Deterministic test data; mock external APIs |
| IM3-R2 | Real team workflow differs from synthetic test | High | High | Shadow mode: run framework parallel to manual process |
| IM3-R3 | Onboarding guide too complex for non-technical users | Medium | Medium | User testing with BA/PM personas; simplify |
| IM3-R4 | Pilot team abandons framework mid-pilot | Low | High | Champion model: identify early adopter; weekly check-ins |

---

## Critical Path Analysis

### Dependency Graph (All Milestones)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CRITICAL PATH                                        │
│  (Longest path determining minimum project duration)                        │
└─────────────────────────────────────────────────────────────────────────────┘

M1 (Core Infra)
  ├──► M1-P2 (Skills)
  │      └──► M1-P5 (Pilot)
  │             │
  │             ▼
  │         M2 (Claude Code Port)
  │             │
  │             ▼
  │         M3 (OpenCode Port)
  │             │
  │             ├──► M4 (KB Upgrade)
  │             │       └──► M5 (Providers)
  │             │
  │             └──► IM1 (Convention Layer)
  │                     │
  │                     ▼
  │                 IM2 (State Sync + Safety)
  │                     │
  │                     ▼
  │                 IM3 (E2E + Onboarding)
  │
  └──► M1-P3 (Tests) ─────► [joins M1-P5]
  └──► M1-P4 (Providers) ─► [joins M1-P5]
```

### Critical Path Identification

The **critical path** is:

```
M1-P1 (Core Infra) → M1-P2 (Skills) → M1-P5 (Pilot)
  → M2 (Claude Code Port)
  → M3 (OpenCode Port)
  → IM1 (Convention Layer)
  → IM2 (State Sync + Safety)
  → IM3 (E2E + Onboarding)
```

**Critical Path Duration**:
- M1: 8–10 weeks (longest sequential chain: P1 → P2 → P5)
- M2: 5–6 weeks
- M3: 5–6 weeks
- IM1: 3–4 weeks
- IM2: 4–5 weeks
- IM3: 3–4 weeks

**Total Critical Path**: **28–35 weeks** (7–8.5 months) with 2 full-time engineers on the product track and 1 integration specialist.

### Parallelizable Workstreams

These workstreams can run in parallel with the critical path, reducing overall calendar time:

| Workstream | Parallel With | Time Saved |
|------------|--------------|------------|
| M1-P3 (Tests) | M1-P2 (Skills) | ~1 week |
| M1-P4 (Providers) | M1-P2 (Skills) | ~1 week |
| M2-B (New Capabilities) | M3-A (OMO Porting) | ~2 weeks |
| M4-A (Vector DB) | M4-B (Graph DB) | ~2 weeks |
| M5 (Providers) | IM3 (Onboarding) | ~1 week |

**Effective Calendar Duration with Parallelism**: **22–28 weeks** (5.5–7 months) with the recommended team.

### Fast-Track Options

| Option | Impact | Risk |
|--------|--------|------|
| Skip M2 (Claude Code) and go directly M1→M3 | Saves 5–6 weeks | Loses parallel Produce + cross-session memory; may need rework |
| Run IM1 in parallel with M1-P5 | Saves 2–3 weeks | Integration work may need M3 features not yet stable |
| Defer M4+M5 post-IM3 | Saves 6–8 weeks | Limits scale; may need KB upgrade sooner for large teams |

---

## Risk Register

### Cross-Milestone Risks

| Risk ID | Risk | Likelihood | Impact | Affected Milestones | Mitigation |
|---------|------|------------|--------|---------------------|------------|
| **XR-1** | AI runtime (Copilot/Claude/OMO) API changes break phase engine | Medium | High | M1, M2, M3 | Pin runtime versions; abstraction layer; rapid patch process |
| **XR-2** | `.sdlc/` schema requires breaking change | Low | High | M1–M5, IM1–IM3 | Schema versioning; migration scripts; freeze schema after M1 |
| **XR-3** | Key engineer leaves mid-project | Medium | High | All | Knowledge transfer docs; pair programming; bus factor ≥ 2 |
| **XR-4** | Pilot project drops out | Medium | Medium | M1, IM3 | Maintain 2+ pilot candidates; synthetic pilot as fallback |
| **XR-5** | Security audit blocks `.sdlc/` git commit | Medium | Medium | M1, IM1 | Document `.sdlc/` contents; exclude credentials; compliance guide |
| **XR-6** | Integration layer too complex for team to maintain | Medium | Medium | IM1–IM3 | Keep adapters simple (<200 LOC each); document extensively |
| **XR-7** | Vendor MCP server sunset (Jira/Figma) | Low | Medium | M1, M4, M5 | Build provider interface; swap implementations without agent changes |
| **XR-8** | Embedding model licensing issues | Low | Medium | M4 | Support open-source embeddings (Ollama); legal review |

### Risk Heat Map

```
Impact
  High │  XR-2        XR-1, XR-3
       │  M1-R1       M2-R1, M4-R4
       │  IM2-R2
       │
 Medium│  XR-4, XR-5  XR-6, XR-7
       │  M1-R2, M3-R1 M1-R3, M2-R4
       │  IM1-R1, IM3-R2
       │
  Low  │  XR-8        (accept)
       │
       └─────────────────────────────
            Low        Medium     High
                    Likelihood
```

### Risk Triggers & Responses

| Trigger | Response | Owner |
|---------|----------|-------|
| Copilot API change announced | Assess impact in 48h; create patch branch | DevEx Lead |
| `.sdlc/` schema change needed | Call architecture review; freeze other work | Architect |
| Pilot team NPS < 5 | Emergency user interview; identify top 3 blockers | PM |
| Integration adapter > 200 LOC | Refactor; split into smaller adapters; add tests | Integrations Lead |
| Safety test failure rate > 10% | Halt autonomous mode; manual review required | QA Lead |

---

## Resource & Effort Summary

### Team Composition

| Role | Count | Responsibilities |
|------|-------|------------------|
| **DevEx Engineer** | 2 | Agent authoring, skill design, runtime porting, docs |
| **Backend Engineer** | 1 | Adapters, ingestion, KB upgrades, state sync |
| **Integrations Specialist** | 1 | Provider adapters, handoff scripts, E2E tests |
| **QA Engineer** | 1 | Test strategy, validation spikes, safety tests |
| **Architect** | 0.5 | Schema design, ADRs, topology, reviews |
| **PM / DevEx Lead** | 0.5 | Pilot coordination, feedback synthesis, prioritization |

**Total FTE**: ~5.5 engineers.

### Effort Distribution

| Milestone | Person-Days | % of Total |
|-----------|-------------|------------|
| M1 Copilot MVP | 45 | 22.5% |
| M2 Claude Code | 25 | 12.5% |
| M3 OpenCode | 25 | 12.5% |
| M4 KB Upgrade | 35 | 17.5% |
| M5 Providers | 20 | 10.0% |
| IM1 Convention | 15 | 7.5% |
| IM2 State+Safety | 20 | 10.0% |
| IM3 E2E+Onboard | 15 | 7.5% |
| **Total** | **~200** | **100.0%** |

### Timeline Visualization

```
Week:  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28
       ├──────────────────────────────────────────────────────────────────────────────────────┤

M1     [████████████████████████████████████████]  (W1–W10)
M2                          [██████████████████████████]  (W9–W14)
M3                                        [██████████████████████████]  (W14–W19)
M4                                                          [████████████████████████████]  (W19–W26)
M5                                                                            [████████████████]  (W25–W28)
IM1              [████████████████████]  (W3–W7)
IM2                          [████████████████████████]  (W8–W13)
IM3                                        [████████████████████]  (W14–W18)
```

> **Note**: The integration milestones (IM1–IM3) can start earlier if M1-P1 (Core Infra) is stable. The timeline above shows a conservative start after M1 completion.

### Budget Estimate

Assuming blended rate of **$800/day** (senior engineer contractor rate):

| Milestone | Person-Days | Budget (USD) |
|-----------|-------------|--------------|
| M1 | 45 | $36,000 |
| M2 | 25 | $20,000 |
| M3 | 25 | $20,000 |
| M4 | 35 | $28,000 |
| M5 | 20 | $16,000 |
| IM1 | 15 | $12,000 |
| IM2 | 20 | $16,000 |
| IM3 | 15 | $12,000 |
| **Total** | **~200** | **~$160,000** |

> Infrastructure costs (Qdrant, Neo4j, embedding APIs) are excluded. Add ~$500–$2,000/month for M4+ depending on team size.

---

## Open Questions

| Question | Blocks | Target Resolution | Owner |
|----------|--------|-------------------|-------|
| OQ-003: Should `.sdlc/` be git-committed by default? | M1 Phase 1, IM1-T7 | Before M1-P1 ships | Architect |
| OQ-004: Model routing per phase? | M1 Phase 2, M4-A-T5 | Before skill implementation | Backend |
| OQ-005: Which embedding model for VectorDB? | M4-A-T1 | Before M4 starts | Architect |
| OQ-006: Graphiti temporal query requirements? | M4-B-T1 | Before M4 starts | Architect |
| OQ-007: Enterprise MCP firewall policy? | M1-P4, M5 | Before provider integration | Integrations |

**Note**: OQ-003 resolved in ADR-013 (yes, commit `.sdlc/` except credentials). OQ-004 resolved in ADR-014 (centralized `models.yaml` with tier aliases).

---

## Next Steps

1. **Immediate (Week 1)**: Complete M1 Phase 1 (Core Infrastructure) — schema freeze, adapter implementation, agent skeletons
2. **Week 2–3**: Implement M1 Phase 2 (start-feature + fix-bug skills) + Phase 3 (test skills) in parallel
3. **Week 4**: Implement M1 Phase 4 (external providers) + begin IM1 (convention layer design)
4. **Week 5–6**: M1 Phase 5 pilot onboarding; continue IM1 adapter implementation
5. **Week 7–10**: Pilot execution + feedback incorporation; finalize IM1 validation
6. **Post-M1**: Begin M2 (Claude Code port) + IM2 (state sync) in parallel
7. **Post-M2**: Begin M3 (OpenCode port) + IM3 (E2E validation)
8. **Post-M3**: Begin M4 (KB upgrade) and M5 (additional providers)

---

## References

- [ROADMAP.md](../ROADMAP.md) — Strategic milestone definitions
- [DECISIONS.md](../DECISIONS.md) — 15 Architecture Decision Records
- [ARCHITECTURE.md](../ARCHITECTURE.md) — Phase model, schemas, adapter patterns
- [PLAN.md](../PLAN.md) — AI-SDLC Integration Framework plan (Tasks 1–14)
- [HANDOFF.md](../HANDOFF.md) — Continuation handoff from agent-for-ba
- [docs/PHASE-MAPPING.md](PHASE-MAPPING.md) — Cross-system phase mapping
- [docs/INTEGRATION-TOPOLOGY.md](INTEGRATION-TOPOLOGY.md) — Data flow and adapter design
- [docs/HANDOFF-CONTRACTS.md](HANDOFF-CONTRACTS.md) — BA→Dev and GSD→OMO handoff specs
- [docs/STATE-SYNC.md](STATE-SYNC.md) — State synchronization mechanism
- [docs/SAFETY-MECHANISMS.md](SAFETY-MECHANISMS.md) — Circuit breakers and conflict detection
- [docs/deliverables-matrix.md](deliverables-matrix.md) — Artifact expectation matrix
- [docs/skill-authoring-guide.md](skill-authoring-guide.md) — Skill development standards

---

*Document version: 1.0*  
*Last updated: 2026-05-26*  
*Next review: After M1 Phase 2 completion*
