---
id: debugging
name: Debugging
maps_to_skills: [fix-bug]
version: "1.0.0"
---

# Work Type: Debugging

> Diagnose faulty behavior through evidence-first investigation, coordinate with humans on runtime-specific actions, apply the smallest safe fix or mitigation, and prove the regression is covered.

## When This Work Type Applies

Use this work type when the task is about broken behavior, an error message, failing tests, runtime regressions, or production incidents that require root-cause analysis.
This is not general refactoring. The goal is to restore correctness with minimal blast radius.

Debugging is a coworker workflow:

- AI gathers evidence, narrows hypotheses, and prepares next-step options.
- Humans coordinate access, choose risky runtime actions, and confirm operational reality.
- The framework stays universal by keeping the investigation phases stable while `project.yaml` defines the platform-specific evidence sources and tools.

If the bug is trivially obvious from a local failing test or a directly visible code defect, the work type may take the fast path and fix immediately after proving the cause locally. Otherwise, it must stay in evidence-first investigation mode.

## Thinking Steps

Agent must execute these steps in order. Project-specific overrides may replace or extend them from `project.yaml`.

### Step 1: Classify and Confirm the Symptom

**Goal**: Confirm the failure is real, determine whether it is a fast-path local defect or an investigation-heavy incident, and anchor the work on the active scope.

**How**:
- Capture the exact symptom: error, stack trace, failing test, incorrect output, or incident signal.
- Identify the smallest reliable reproduction path.
- Record expected behavior versus actual behavior.
- Classify the bug shape: local code defect, integration/contract issue, data/runtime issue, deployment/ops issue, or unknown.
- Decide whether the cause is already locally provable or whether runtime evidence collection is required first.

**Output**: Symptom summary, bug classification, active scope, and a stable failure condition.

**Gate**: if reproduction is ambiguous and user confirmation is required.

### Step 2: Collect Evidence

**Goal**: Build the smallest reliable evidence packet before proposing a fix.

**How**:
- Start from the strongest available evidence source for this project: local repro, logs, traces, dashboards, metrics, queue payloads, dataset snapshots, or deployment diffs.
- Use project-specific observability tools named in `project.yaml` or `work_type_overrides.debugging.required_tools`.
- Record which evidence was checked, what time window or dataset was used, and what remains unknown.
- Prefer one strong query or reproduction over many speculative checks.

**Output**: Evidence packet, strongest observations, and the first ranked hypothesis list.

**Gate**: never.

### Step 3: Isolate and Rank Hypotheses

**Goal**: Narrow the fault to the smallest responsible module, dependency, contract boundary, or runtime condition.

**How**:
- Trace callers, dependencies, recent changes, and decision context.
- Compare code-level hypotheses against runtime evidence before selecting a likely cause.
- Rank hypotheses by explanatory power and blast radius.
- Explicitly note what a human may need to do next: provide access, run a platform command, verify an operational assumption, or select a mitigation option.

**Output**: Ranked hypotheses, blast radius note, and recommended next actions.

**Gate**: if runtime-only actions, production access, or risky mitigation choices require a human coordinator.

### Step 4: Prove Root Cause and Choose the Action

**Goal**: Reach a root-cause statement strong enough to justify action.

**How**:
- State the failure mechanism in one sentence.
- Link it to a specific file, condition, data shape, configuration, or integration mismatch.
- Verify that the proposed cause explains the observed symptom and surviving evidence.
- Present the smallest action options: code fix, configuration change, rollback, runbook step, feature-flag change, or deeper investigation.
- Let the human choose when the action has operational risk or requires privileged access.

**Output**: Root-cause statement, confidence level, and chosen action path.

**Gate**: if the action crosses architecture, API contract, security, or production-operations boundaries.

### Step 5: Fix or Mitigate Minimally

**Goal**: Restore correct behavior with the smallest safe change.

**How**:
- Prefer a local fix over a broad refactor.
- Preserve existing behavior outside the failure path.
- Update code, config, contract, or runbook only where the root cause demands it.
- If the chosen action is an operational mitigation rather than a code change, record it explicitly instead of forcing a patch.

**Output**: Minimal implementation plan and patch.

**Gate**: if a non-minimal change is required.

### Step 6: Verify, Lock Regression, and Close Out

**Goal**: Prevent the bug from returning unnoticed.

**How**:
- Add or update a regression test that fails before the fix and passes after it.
- Re-run the relevant validation path.
- Confirm no unrelated flows regressed.
- Check whether the symptom improved in the same evidence surface that exposed it.
- Record remaining unknowns instead of pretending the investigation is complete.

**Output**: Regression evidence, verification summary, and closeout note with remaining unknowns.

**Gate**: never.

## Coworker Protocol

The debugging work type should behave like a human-coordinated investigation:

1. AI classifies the bug and gathers evidence.
2. AI proposes ranked hypotheses and next actions.
3. Human selects risky runtime actions, provides missing access, or confirms operational reality.
4. AI updates the analysis and prepares the minimal safe fix or mitigation.
5. Human confirms the observed resolution when the fix depends on live-system behavior.

Use the Approve phase only when the normal framework gates trigger. Use these coworker checkpoints inside Define, Decide, and Verify even when Approve is skipped.

## Circuit Breaker

If three materially different action attempts fail, stop trying to patch blindly.

- Mark the work as stuck in the current PhasePacket.
- Summarize symptom, evidence checked, hypotheses tried, and remaining unknowns.
- Hand the problem back to a human coordinator with a recommendation for deeper architecture review, observability access, or brownfield reconstruction.

## Required Tools / Skills

- `codebase`: Locate the failing path and similar patterns.
- `findTestFiles`: Find the right test layer for the regression.
- `usages`: Trace blast radius and callers.
- Project-specific observability, contract, or runbook tools may be appended in `project.yaml`.

## Artifacts Produced

| Artifact | Location | Notes |
|---|---|---|
| Bug report | `.sdlc/artifacts/bug-report/{id}/` | Root cause, impact, and fix summary |
| Regression test case | `.sdlc/artifacts/test-case/{id}/` | Links the failure to a durable check |
| Phase packets | `.sdlc/phases/{work-item-id}/` | Carry debugging evidence across phases |

The PhasePacket closeout for debugging should always include:

- symptom confirmed
- strongest hypothesis or proven root cause
- evidence checked
- chosen mitigation or fix
- remaining unknowns

## Recommended Artifact Templates

When debugging exposes missing architecture context, prefer reconstructing the smallest useful slice with these templates:

- `docs/artifact-templates/interaction-view.md` — for critical flow understanding
- `docs/artifact-templates/contract-view.md` — when failures cross API/event/schema boundaries
- `docs/artifact-templates/deployment-view.md` — when runtime placement, infra, or network boundaries matter

## Verification Criteria

Before this work type is considered complete:

- [ ] The failure is reproduced or otherwise proven from logs/evidence.
- [ ] A root cause is stated concretely, not guessed.
- [ ] The fix is minimal relative to the blast radius.
- [ ] A regression test or equivalent durable check is added.
- [ ] Relevant tests and checks pass after the fix.

## Per-Phase Behavior

| Phase | Behavior |
|---|---|
| Intake | Classify this as a bug-oriented work item, identify the active scope, and load related bug reports plus project-specific evidence sources. |
| Define | Capture symptom, expected vs actual behavior, reproduction path, and the evidence-collection plan. |
| Decide | Focus on ranked hypotheses, root-cause proof, and action options rather than broad redesign. |
| Produce | Implement the chosen minimal fix or mitigation after the regression test or durable failing check is identified. |
| Verify | Re-run the reproduction path, regression test, adjacent impact checks, and the evidence surface that originally exposed the issue. |
| Approve | Usually auto-pass unless architecture, contract, or security flags are raised. |
| Integrate | Ship the fix with bug-report context, regression evidence, and the investigation closeout summary. |

## Known Variations by Project Type

These are defaults. Projects can extend or replace them via `project.yaml -> work_type_overrides`.

| Project Type | Key Difference |
|---|---|
| microservices | Debugging starts with correlation IDs, distributed traces, and consumer impact. |
| data-ml | Debugging includes schema drift, feature skew, and metric regression on fixed datasets. |
| web-frontend | Debugging emphasizes browser events, rendering state, accessibility, and visual regressions. |
