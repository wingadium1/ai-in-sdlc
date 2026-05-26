# Integration Topology & Data Flow

## 1. Overview
The AI-SDLC Integration Framework uses a **Convention Layer (Model B)** topology. Instead of building a heavy central orchestrator, the 4 systems (GSD Redux, OMO/OpenCode, AI-in-sdlc, agent-for-ba) interact via lightweight, file-based adapters and shared conventions.

## 2. Knowledge Base Ownership
To prevent conflicts and maintain clear boundaries, each system has strict authority over its own Knowledge Base (KB) directory:

| System | Primary KB Directory | Authority |
|--------|----------------------|-----------|
| **GSD Redux** | `.planning/` | Owns execution phases, project roadmap, and state tracking. |
| **agent-for-ba** | `wiki/` | Owns domain knowledge, high-level/detailed requirements, UI specs. |
| **AI-in-sdlc** | `.sdlc/` | Owns technical artifacts, code metadata, test cases, and delivery tracking. |
| **Integration Layer** | `.sdlc/integration/` | Owns mapping contracts, handoff state, and sync metadata. |

## 3. Data Flow Diagram

```mermaid
flowchart TD
    subgraph BA["agent-for-ba (Planning/Analysis)"]
        WIKI[wiki/ Knowledge Base]
        SKILLS_BA[BA Skills]
    end

    subgraph ORCH["GSD Redux (Orchestration)"]
        PLAN[.planning/ PLAN.md]
        STATE[.planning/ STATE.md]
    end

    subgraph DEV["AI-in-sdlc + OMO (Execution)"]
        SDLC[.sdlc/ Artifacts]
        OMO[OMO task() / Agents]
    end

    %% Flow: BA -> Dev Artifacts
    WIKI -->|Adapter| SDLC
    note1[BA Artifact Adapter transforms Markdown to JSON schema] -.-> SDLC

    %% Flow: GSD -> OMO Tasks
    PLAN -->|Adapter| OMO
    note2[GSD to OMO Adapter extracts tasks and dispatches parallel agents] -.-> OMO

    %% Flow: OMO -> GSD Feedback
    OMO -->|State Sync| STATE
    note3[State Sync Mechanism updates GSD STATE.md on task completion] -.-> STATE
    
    %% Flow: Dev -> BA Feedback
    SDLC -->|Status Update| WIKI
```

## 4. Architecture Decisions (ADRs)

We have established the following new Architecture Decision Records (ADRs) to govern this topology:
- **ADR-016: File-based Convention Layer Integration** - We will use file-based adapters instead of an API-driven custom orchestrator.
- **ADR-017: Distributed Knowledge Base Ownership** - We will maintain separate KB directories (`.planning/`, `.sdlc/`, `wiki/`) instead of a unified single KB.
- **ADR-018: Asynchronous Handoff Protocol** - We will use asynchronous, polling-based or hook-based handoffs to bridge between systems.
