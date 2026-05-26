# System Conventions Research

## Section 1: GSD Redux Conventions
- **Directory Structure**: Uses `.planning/` as the state directory containing `phases/`, `requirements/`, and execution logs.
- **File Formats**: Heavy reliance on `PLAN.md` (task definition with markdown checkboxes) and `STATE.md` / `boulder.json` for tracking execution state.
- **Commit Strategy**: Requires atomic commits per task with prefixes (`[int]`, `[fix]`, `[docs]`, etc.).
- **Execution Model**: Wave-based execution where parallel tasks are grouped into waves.

## Section 2: OMO/OpenCode Conventions
- **Task Invocation**: Uses the `task()` tool call with parameters like `category`, `load_skills`, `description`, `prompt`, and `run_in_background`.
- **Skill Mechanism**: Relies on loading predefined skills via the `load_skills` array parameter to inject context and tools.
- **Category System**: Uses categories (`deep`, `quick`, `writing`, `visual-engineering`, etc.) to route tasks to optimized underlying LLM models.
- **Agent Types**: Supports specialized direct agents (`explore`, `oracle`, `metis`, `momus`, `librarian`).

## Section 3: AI-in-sdlc Conventions
- **Knowledge Base**: Centralized in the `.sdlc/` directory (config, profiles, artifacts, work-items, phases).
- **Artifact Format**: Uses strict JSON schema (`_template.json` / `_template-meta.json`) for data persistence.
- **Phase Pipeline**: A strict 7-phase pipeline: Intake → Define → Decide → Produce → Verify → Approve → Integrate.
- **Model Routing**: Managed via `.sdlc/profiles/models.yaml` allowing tier aliases (high, mid, low).

## Section 4: agent-for-ba Conventions
- **Directory Structure**: Uses `wiki/` directory acting as an LLM-friendly knowledge base.
- **File Format**: Markdown files heavily utilizing YAML frontmatter and wikilinks (`[[Page Name]]`) for relationships.
- **Workflow**: 5-step BA pipeline (Domain Analysis → High-Level Req → Detailed Req → UI Spec → Review).
- **Commit Format**: Follows specific commit conventions for BA updates.

## Section 5: Comparison Matrix

| Feature | GSD Redux | OMO/OpenCode | AI-in-sdlc | agent-for-ba |
|---------|-----------|--------------|------------|--------------|
| **State Dir** | `.planning/` | Implicit / `.sisyphus` | `.sdlc/` | `wiki/` |
| **Format** | Markdown (.md) | Function call/JSON | JSON schema | Markdown + Frontmatter |
| **Workflow** | Wave-based | Parallel tasking | 7-phase strict | 5-step BA pipeline |
| **Primary Use** | Execution planning | Orchestration & acting | SDLC governance | Requirement analysis |

### Potential Conflicts
- **State format mismatch**: GSD's markdown plans vs AI-in-sdlc's JSON PhasePackets.
- **Workflow alignment**: Mapping GSD's flexible phase execution to AI-in-sdlc's strict 7-phase pipeline requires careful transition rules.
