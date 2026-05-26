# Cross-System Phase Mapping Table

## 1. Phase Mapping Matrix

The AI-SDLC Integration Framework orchestrates work across 3 different phase models. This mapping ensures state alignment and clear handoffs.

| Stage | agent-for-ba (5 Steps) | GSD Redux Phases | AI-in-sdlc (7 Phases) |
|-------|-------------------------|------------------|-----------------------|
| **Discovery** | 1. Domain Analysis | `plan-milestone` | **Intake** |
| **Requirements** | 2. High-Level Req | `plan-phase` | **Intake** (Update) |
| **Specification** | 3. Detailed Req<br>4. UI Spec | `plan-phase` | **Define** |
| **Design** | 5. Review & Finalize | `discuss-phase` | **Decide** |
| **Implementation** | *Handoff to Dev* | `execute-phase` | **Produce** |
| **Validation** | - | `verify-work` | **Verify** |
| **Review** | - | `audit-milestone` | **Approve** (Human Gate) |
| **Deployment** | - | `complete-milestone` | **Integrate** |

## 2. Phase Equivalence & Rationale

- **BA Steps 1-2 ↔ Intake**: The BA's early exploration maps directly to AI-in-sdlc's Intake phase where the work item is initialized and scoped.
- **BA Steps 3-4 ↔ Define**: Detailed requirements and UI specs establish the "Definition of Done", mapping perfectly to AI-in-sdlc's Define phase.
- **GSD `execute-phase` ↔ Produce**: GSD's execution wave maps to the Produce phase where actual code and tests are generated.
- **GSD `verify-work` ↔ Verify**: Automated verification and QA testing.
- **GSD `audit-milestone` ↔ Approve**: This is the critical Human Gate where PMs/Tech Leads review the work before integration.

## 3. Phase Skipping Rules

- **Bug Fixes (No UI)**: Skip BA Steps 3-4 (UI Spec). Skip GSD `plan-phase` if trivial. Auto-pass AI-in-sdlc **Approve** gate if regression tests pass.
- **Backend-Only Features**: Skip BA Step 4 (UI Spec).
- **Greenfield Projects**: Require all phases. Heavy emphasis on BA Steps 1-2 and AI-in-sdlc **Decide** phase for architecture formulation.
- **Brownfield Updates**: May skip BA Step 1 (Domain Analysis) if the KB is already mature.

## 4. Phase Transition Rules

| Transition | Triggered By | Validation Gate |
|------------|--------------|-----------------|
| BA → GSD | BA marks artifact as "Final" | Schema validation in adapter |
| GSD → OMO | GSD `execute-phase` starts | PLAN.md structure validation |
| OMO → GSD | OMO agents finish execution | All OMO tasks exit 0, tests pass |
| OMO → Approve | Verify phase completes | Human review required |
