# Spike: GSD to OMO Handoff Feasibility

## Objective
Validate if GSD Redux `PLAN.md` tasks can be automatically handed off to OMO/OpenCode's `task()` function.

## Findings

1. **PLAN.md Format**: GSD uses a structured markdown format with markdown checkboxes `- [ ] Task Description`. This is easily parseable using standard CLI tools (grep/awk/sed) or a simple script.
2. **OMO task() Format**: OMO uses a function call format like `task(category="...", load_skills=[...], prompt="...")`.
3. **Mapping Feasibility**: 
   - We can successfully extract task descriptions from `PLAN.md`.
   - The task description maps cleanly to the `description` and `prompt` fields of the `task()` function.
   - We can dynamically assign a default category (e.g., `deep` or `unspecified-high`) and set `run_in_background=true` for parallel execution.

## Limitations & Challenges
- **Context Loss**: A simple string extraction loses the broader context of the PLAN.md (e.g., Phase description, upstream dependencies).
- **Task Granularity**: GSD tasks might be too broad or too granular for an optimal OMO agent prompt without enrichment.
- **Wave Management**: GSD executes in waves. The handoff adapter must group tasks by wave and wait for completion before proceeding.

## Conclusion
**FEASIBLE.** A lightweight file-based adapter can parse `PLAN.md` and generate OMO `task()` calls. The prototype script (`scripts/spike-gsd-omo-handoff.sh`) successfully demonstrates this extraction and formatting.
