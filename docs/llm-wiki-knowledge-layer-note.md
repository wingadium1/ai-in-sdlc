# Note: Layered LLM Wiki as an External Knowledge System

> Capture the idea of using a Karpathy-style LLM wiki as a separate knowledge-layer project, while keeping `ai-in-sdlc` focused on SDLC orchestration, artifacts, and runtime behavior.

**Status**: Design note only — this document does not change the framework architecture in this repository.
**Intent**: Preserve the idea for continuation in another project or workspace.

---

## Why this note exists

The Karpathy "LLM Wiki" pattern is highly relevant to long-lived organizational knowledge, but it is broader than the scope of `ai-in-sdlc`.

`ai-in-sdlc` is primarily concerned with:

- SDLC orchestration,
- work-item and phase execution,
- artifacts, approvals, and provenance,
- project adaptation,
- and runtime portability across Copilot, Claude Code, and OpenCode.

The LLM wiki idea is different in nature. It focuses on:

- persistent compiled knowledge,
- incremental synthesis over time,
- note and wiki maintenance,
- layered retrieval,
- and long-horizon memory beyond one repository or one SDLC task.

For that reason, the LLM wiki should be treated as a **separate but compatible knowledge system**, not merged into the core responsibility of this repository.

---

## The core idea

Use Karpathy’s LLM wiki pattern as a **method** for building knowledge systems:

1. **Raw sources** are immutable.
2. An LLM maintains a **compiled markdown wiki** that sits between humans and raw sources.
3. A **schema/instructions file** teaches the LLM how to ingest, update, query, lint, and write back into the wiki.
4. The wiki becomes a **persistent, compounding artifact** instead of query-time-only retrieval.

The key distinction from naive RAG is:

- **RAG** re-derives knowledge from source chunks at query time.
- **LLM wiki** compiles knowledge once, then keeps the compiled understanding current.

This pattern is useful far beyond software repositories. It can span:

- organization knowledge,
- team and domain memory,
- project learning,
- operating playbooks,
- research,
- and personal or leadership knowledge.

---

## Proposed separation of concerns

### `ai-in-sdlc`

This repository should remain responsible for:

- SDLC phase flow,
- `WorkItem`, `PhasePacket`, `ArtifactVersion`, and `Decision` structures,
- runtime agent behavior,
- project and work-type adaptation,
- artifact policy and approval logic,
- and execution traceability.

In short: **operational SDLC state and process**.

### External LLM wiki project

The separate knowledge-layer project should be responsible for:

- ingesting raw knowledge sources,
- maintaining compiled wiki pages,
- running retrieval and lint workflows,
- preserving graph structure and backlinks,
- promoting knowledge across scopes,
- and serving synthesized context back to SDLC systems.

In short: **compiled organizational memory and synthesized knowledge**.

---

## Recommended layered knowledge model

The LLM wiki should not be a single flat vault by default. The better model is **scoped layers**.

### 1. Organization layer

Knowledge that applies across many teams and projects:

- platform standards,
- security rules,
- architecture principles,
- approved patterns,
- shared debugging heuristics,
- incident themes,
- governance and policy context.

### 2. Team or domain layer

Knowledge that applies within a product domain or shared service family:

- domain maps,
- service interaction summaries,
- team conventions,
- bounded-context knowledge,
- repeated failure patterns,
- runbooks and operating knowledge.

### 3. Project layer

Knowledge specific to a single repository or deployed system:

- architecture synthesis,
- current topology and flows,
- known gaps,
- local design narratives,
- project-specific heuristics,
- operational context.

### 4. Work-item layer

Short-lived or task-scoped synthesis:

- investigation notes,
- root-cause packets,
- temporary analyses,
- local comparison pages,
- closeout summaries,
- unresolved questions.

The crucial rule is **promotion instead of duplication**:

- work-item learnings may promote to project knowledge,
- project knowledge may promote to team/domain knowledge,
- team/domain knowledge may promote to organization knowledge.

Knowledge should move upward only when it becomes reusable at that scope.

---

## Relationship to `.sdlc/`

This is the most important design boundary.

The external LLM wiki should **not replace** `.sdlc/`.

### `.sdlc/` remains the source of truth for:

- structured SDLC state,
- work-item execution,
- artifact metadata,
- approvals,
- provenance,
- decisions,
- gates,
- and machine-readable runtime handoff.

### The LLM wiki should serve as:

- compiled synthesis,
- human-readable organizational memory,
- long-lived cross-artifact understanding,
- cross-project retrieval layer,
- and navigation surface for agents and humans.

So the correct relationship is:

- `.sdlc/` = **operational source of truth**
- LLM wiki = **compiled knowledge layer above and around it**

The wiki may read from `.sdlc/` as one source among many, but `.sdlc/` should not depend on the wiki to remain operational.

---

## Integration model with `ai-in-sdlc`

`ai-in-sdlc` should treat the LLM wiki as an **external knowledge provider**.

Possible interaction modes:

1. **Read-only context provider**
   - Agents retrieve synthesized context from the wiki.
   - The wiki acts like a smart reference layer.

2. **Artifact-backed enrichment**
   - A wiki page can be imported or referenced as a design artifact, requirement artifact, or supporting note.

3. **Promotion target**
   - Outputs from `.sdlc/` can be promoted into the wiki when they become reusable knowledge.

4. **Lint / contradiction signal source**
   - The wiki can report inconsistencies, missing links, stale assumptions, or repeated unresolved gaps back into SDLC workflows.

The integration boundary should stay explicit:

- `ai-in-sdlc` consumes normalized knowledge artifacts or references,
- but does not own the wiki maintenance lifecycle.

---

## Retrieval strategy recommendation

The external knowledge system should use **scoped retrieval first, federated retrieval second**.

For example, when an SDLC agent works in a repo:

1. search project-scoped knowledge first,
2. then team/domain knowledge,
3. then organization knowledge,
4. then external/public sources.

This prevents the system from becoming a single noisy vault and keeps retrieval aligned to ownership and relevance.

Cross-scope linking is still valuable, but retrieval should begin with the nearest scope.

---

## Why this should live in another project

If this repository absorbs the LLM wiki concept directly into its core, several risks appear:

1. **Scope creep**
   - `ai-in-sdlc` becomes both an SDLC runtime framework and a general knowledge platform.

2. **Blurry ownership**
   - It becomes unclear whether `.sdlc/` is state, wiki, or both.

3. **Architectural confusion**
   - Structured operational records and freeform compiled knowledge solve different problems.

4. **Harder portability**
   - Runtime adapters would inherit assumptions from a wiki system they may not need.

5. **Reduced clarity for adopters**
   - Users who only want SDLC orchestration should not need to buy into a full organizational knowledge architecture.

Treating the LLM wiki as a separate project preserves a clean boundary:

- this repo remains the SDLC engine,
- the other repo becomes the knowledge engine,
- and the two can integrate through stable contracts.

---

## Suggested direction for the separate project

The separate project could explore:

- Karpathy-style ingest / query / lint / write-back,
- scoped wiki layers,
- markdown plus backlinks as a graph surface,
- hybrid retrieval beyond naive index-only search,
- promotion workflows across scopes,
- and provider interfaces for SDLC systems like `ai-in-sdlc`.

A good framing would be:

> Build a layered LLM-maintained knowledge system that can serve compiled context to SDLC frameworks, teams, and organization-level workflows.

---

## Recommended one-sentence position for `ai-in-sdlc`

If this idea needs to be referenced later from this repository, the clean position is:

> `ai-in-sdlc` uses structured `.sdlc/` state as its operational knowledge base and may integrate with an external LLM-maintained wiki system for compiled, cross-scope organizational knowledge.

---

## Open questions for the external project

These are intentionally deferred from this repository:

1. What is the canonical directory and schema model for org/team/project/work-item wiki layers?
2. How should promotion across scopes be governed and approved?
3. When should write-back create new pages versus update existing pages?
4. How should contradictions be tracked and surfaced?
5. What retrieval model works best at moderate versus large scale?
6. How should the wiki expose stable interfaces to SDLC consumers?
7. What access control model is needed across org/team/project scopes?

---

## Final recommendation

Use the LLM wiki pattern as a **knowledge-system method**, but continue the implementation in a separate project.

Keep this repository focused on:

- SDLC orchestration,
- artifact and approval semantics,
- runtime behavior,
- and structured portable execution state.

Then let the external knowledge-layer project provide a richer compiled memory surface that `ai-in-sdlc` can read from when appropriate.
