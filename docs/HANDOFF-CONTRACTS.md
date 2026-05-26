# Handoff Contracts

This document defines the contracts for handoffs between different roles in the AI-SDLC framework. Each contract specifies how artifacts flow from one role to another, including format, location, validation, and versioning rules.

---

## BA → Dev Handoff Contract

### Overview

Business Analysts (BA) produce requirements and specifications that developers consume. This contract ensures BA output artifacts can be reliably consumed by AI-SDLC dev skills without manual reformatting.

**Flow**: `wiki/projects/{project}/` (BA output) → `.sdlc/artifacts/` (Dev input)

---

### Artifact Type Mappings

#### 1. Requirement

**BA Output Format**: Markdown with YAML frontmatter

```markdown
---
id: REQ-042
title: User Password Reset via Email
type: functional
actors: [User, System]
priority: high
status: approved
created_by: ba-team
created_at: 2026-05-20
---

## Description

Users must be able to reset their password by requesting a reset link via email.

## Acceptance Criteria

- [ ] User can click "Forgot Password" on login page
- [ ] System sends email with unique reset link
- [ ] Reset link expires after 24 hours
- [ ] User can set new password via reset link

## Notes

Integration with SendGrid for email delivery.
```

**Dev Input Format**: JSON (`ArtifactVersion` schema)

```json
{
  "id": "req-042",
  "artifact_id": "REQ-042",
  "version": "1.0.0",
  "kind": "requirement",
  "content_ref": "./content.md",
  "provenance_mode": "ai",
  "provider": "agent-for-ba",
  "source_uri": "wiki/projects/myapp/requirements/REQ-042.md",
  "source_version": "1.0.0",
  "created_by_actor": "ba-team",
  "created_in_execution": "exec-20260520-001",
  "created_at": "2026-05-20T10:30:00Z",
  "checksum": "sha256:abc123...",
  "approval_state": "approved",
  "authority_state": "derived",
  "supersedes": null,
  "derives_from": []
}
```

**Content File** (`.sdlc/artifacts/requirement/req-042/content.md`):

```markdown
# User Password Reset via Email

**Actors**: User, System  
**Priority**: high

## Description

Users must be able to reset their password by requesting a reset link via email.

## Acceptance Criteria

- [ ] User can click "Forgot Password" on login page
- [ ] System sends email with unique reset link
- [ ] Reset link expires after 24 hours
- [ ] User can set new password via reset link

## Notes

Integration with SendGrid for email delivery.
```

---

#### 2. UI Specification

**BA Output Format**: Markdown with embedded diagrams or references

```markdown
---
id: UI-015
title: Password Reset Flow
type: ui-spec
related_requirements: [REQ-042]
status: approved
created_by: ba-team
created_at: 2026-05-21
---

## Screens

### 1. Forgot Password Page

**URL**: `/forgot-password`

**Elements**:
- Email input field (required, validation: email format)
- "Send Reset Link" button
- "Back to Login" link

**Flow**:
```plantuml
@startuml
start
:User enters email;
if (valid email?) then
  yes
  :Send reset email;
  :Show success message;
else
  no
  :Show validation error;
endif
stop
@enduml
```

### 2. Reset Password Page

**URL**: `/reset-password?token={token}`

**Elements**:
- New password field (required, min 8 chars)
- Confirm password field (required, must match)
- "Reset Password" button
```

**Dev Input Format**: JSON with extracted structure

```json
{
  "id": "ui-015",
  "artifact_id": "UI-015",
  "version": "1.0.0",
  "kind": "design-artifact",
  "content_ref": "./content.md",
  "provenance_mode": "ai",
  "provider": "agent-for-ba",
  "source_uri": "wiki/projects/myapp/ui-specs/UI-015.md",
  "source_version": "1.0.0",
  "created_by_actor": "ba-team",
  "created_in_execution": "exec-20260521-001",
  "created_at": "2026-05-21T14:00:00Z",
  "checksum": "sha256:def456...",
  "approval_state": "approved",
  "authority_state": "derived",
  "supersedes": null,
  "derives_from": ["req-042"]
}
```

**Content File** (`.sdlc/artifacts/design-artifact/ui-015/content.md`):

```markdown
# Password Reset Flow

**Related Requirements**: REQ-042

## Screens

### 1. Forgot Password Page

**URL**: `/forgot-password`

**Elements**:
- Email input field (required, validation: email format)
- "Send Reset Link" button
- "Back to Login" link

**Flow**:
> Note: PlantUML diagram present in source — extract text description for implementation reference.

1. User enters email
2. System validates email format
3. If valid: send reset email and show success message
4. If invalid: show validation error

### 2. Reset Password Page

**URL**: `/reset-password?token={token}`

**Elements**:
- New password field (required, min 8 chars)
- Confirm password field (required, must match)
- "Reset Password" button
```

---

#### 3. Test Case

**BA Output Format**: Markdown with test steps

```markdown
---
id: TC-101
title: Password Reset - Happy Path
type: test-case
related_requirements: [REQ-042]
test_type: functional
status: approved
created_by: ba-team
created_at: 2026-05-22
---

## Preconditions

- User account exists with email user@example.com
- User is on login page

## Test Steps

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Click "Forgot Password" link | Navigate to forgot password page |
| 2 | Enter valid email "user@example.com" | Email field accepts input |
| 3 | Click "Send Reset Link" | Success message displayed |
| 4 | Check email inbox | Reset email received within 1 minute |
| 5 | Click reset link in email | Navigate to reset password page |
| 6 | Enter new password "NewPass123!" | Password field accepts input |
| 7 | Confirm password "NewPass123!" | Confirm field accepts input |
| 8 | Click "Reset Password" | Success message, redirect to login |

## Postconditions

- User can log in with new password
- Reset link is invalidated after use
```

**Dev Input Format**: JSON with structured test data

```json
{
  "id": "tc-101",
  "artifact_id": "TC-101",
  "version": "1.0.0",
  "kind": "test-case",
  "content_ref": "./content.md",
  "provenance_mode": "ai",
  "provider": "agent-for-ba",
  "source_uri": "wiki/projects/myapp/test-cases/TC-101.md",
  "source_version": "1.0.0",
  "created_by_actor": "ba-team",
  "created_in_execution": "exec-20260522-001",
  "created_at": "2026-05-22T09:15:00Z",
  "checksum": "sha256:ghi789...",
  "approval_state": "approved",
  "authority_state": "derived",
  "supersedes": null,
  "derives_from": ["req-042"]
}
```

**Content File** (`.sdlc/artifacts/test-case/tc-101/content.md`):

```markdown
# Password Reset - Happy Path

**Related Requirements**: REQ-042  
**Test Type**: functional

## Preconditions

- User account exists with email user@example.com
- User is on login page

## Test Steps

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Click "Forgot Password" link | Navigate to forgot password page |
| 2 | Enter valid email "user@example.com" | Email field accepts input |
| 3 | Click "Send Reset Link" | Success message displayed |
| 4 | Check email inbox | Reset email received within 1 minute |
| 5 | Click reset link in email | Navigate to reset password page |
| 6 | Enter new password "NewPass123!" | Password field accepts input |
| 7 | Confirm password "NewPass123!" | Confirm field accepts input |
| 8 | Click "Reset Password" | Success message, redirect to login |

## Postconditions

- User can log in with new password
- Reset link is invalidated after use
```

---

#### 4. Review Report

**BA Output Format**: Markdown with findings

```markdown
---
id: REV-003
title: Password Reset Feature Review
type: review-report
reviewed_artifacts: [REQ-042, UI-015, TC-101]
reviewer: ba-lead
status: approved
created_at: 2026-05-23
---

## Summary

The password reset feature is ready for development. All requirements are clear, UI specs are complete, and test cases cover the happy path.

## Findings

### ✅ Approved

- Requirement REQ-042: Clear acceptance criteria
- UI Spec UI-015: Complete screen definitions
- Test Case TC-101: Covers happy path

### ⚠️ Recommendations

- Add test case for expired reset link scenario
- Add test case for invalid token scenario
- Consider rate limiting on reset requests

## Decision

**Status**: Approved for development

**Notes**: Proceed with implementation. Add edge case test cases during development phase.
```

**Dev Input Format**: JSON with review metadata

```json
{
  "id": "rev-003",
  "artifact_id": "REV-003",
  "version": "1.0.0",
  "kind": "review-note",
  "content_ref": "./content.md",
  "provenance_mode": "ai",
  "provider": "agent-for-ba",
  "source_uri": "wiki/projects/myapp/reviews/REV-003.md",
  "source_version": "1.0.0",
  "created_by_actor": "ba-lead",
  "created_in_execution": "exec-20260523-001",
  "created_at": "2026-05-23T16:45:00Z",
  "checksum": "sha256:jkl012...",
  "approval_state": "approved",
  "authority_state": "derived",
  "supersedes": null,
  "derives_from": ["req-042", "ui-015", "tc-101"]
}
```

**Content File** (`.sdlc/artifacts/review-note/rev-003/content.md`):

```markdown
# Password Reset Feature Review

**Reviewed Artifacts**: REQ-042, UI-015, TC-101  
**Reviewer**: ba-lead

## Summary

The password reset feature is ready for development. All requirements are clear, UI specs are complete, and test cases cover the happy path.

## Findings

### ✅ Approved

- Requirement REQ-042: Clear acceptance criteria
- UI Spec UI-015: Complete screen definitions
- Test Case TC-101: Covers happy path

### ⚠️ Recommendations

- Add test case for expired reset link scenario
- Add test case for invalid token scenario
- Consider rate limiting on reset requests

## Decision

**Status**: Approved for development

**Notes**: Proceed with implementation. Add edge case test cases during development phase.
```

---

### File Location Convention

```
BA Output (agent-for-ba)          Dev Input (AI-in-sdlc)
────────────────────────────      ────────────────────────────
wiki/projects/{project}/          .sdlc/artifacts/
├── requirements/                 ├── requirement/
│   └── REQ-042.md                │   └── req-042/
│                                 │       ├── meta.json
│                                 │       └── content.md
├── ui-specs/                     ├── design-artifact/
│   └── UI-015.md                 │   └── ui-015/
│                                 │       ├── meta.json
│                                 │       └── content.md
├── test-cases/                   ├── test-case/
│   └── TC-101.md                 │   └── tc-101/
│                                 │       ├── meta.json
│                                 │       └── content.md
└── reviews/                      └── review-note/
    └── REV-003.md                    └── rev-003/
                                        ├── meta.json
                                        └── content.md
```

**Adapter Script**: A conversion script reads from `wiki/projects/{project}/` and writes to `.sdlc/artifacts/` with the appropriate JSON structure.

---

### Format Contract

#### YAML Frontmatter Fields (BA Output)

**Required Fields**:
- `id`: Unique identifier (e.g., `REQ-042`, `UI-015`)
- `title`: Human-readable title
- `type`: Artifact type (`requirement`, `ui-spec`, `test-case`, `review-report`)
- `status`: Current state (`draft`, `in-review`, `approved`, `deprecated`)
- `created_by`: Author identifier
- `created_at`: ISO 8601 date

**Optional Fields**:
- `related_requirements`: Array of requirement IDs
- `actors`: Array of actor names (for requirements)
- `priority`: Priority level (`low`, `medium`, `high`, `critical`)
- `reviewed_artifacts`: Array of artifact IDs (for review reports)
- `reviewer`: Reviewer identifier (for review reports)
- `test_type`: Test type (`functional`, `integration`, `e2e`, `unit`)

#### Required Sections (Markdown Body)

**Requirement**:
- `## Description` — What the feature does
- `## Acceptance Criteria` — Checklist of done conditions

**UI Specification**:
- `## Screens` — Screen definitions with elements and flows

**Test Case**:
- `## Preconditions` — Setup required before test
- `## Test Steps` — Step-by-step execution table
- `## Postconditions` — Expected state after test

**Review Report**:
- `## Summary` — High-level overview
- `## Findings` — Approved items and recommendations
- `## Decision` — Final approval status

---

### Validation Rules

Before Dev consumes BA artifacts, the adapter must validate:

#### 1. Completeness Check

```yaml
requirement:
  required_frontmatter: [id, title, type, status, created_by, created_at]
  required_sections: [Description, Acceptance Criteria]
  validation: |
    - id must match pattern REQ-\d+
    - status must be "approved" for Dev consumption
    - Acceptance Criteria must have at least one checkbox item

ui-spec:
  required_frontmatter: [id, title, type, status, created_by, created_at]
  required_sections: [Screens]
  validation: |
    - id must match pattern UI-\d+
    - status must be "approved"
    - Each screen must have URL and Elements defined

test-case:
  required_frontmatter: [id, title, type, status, created_by, created_at]
  required_sections: [Preconditions, Test Steps, Postconditions]
  validation: |
    - id must match pattern TC-\d+
    - status must be "approved"
    - Test Steps must be a table with Step, Action, Expected Result columns
    - Must have related_requirements in frontmatter

review-report:
  required_frontmatter: [id, title, type, status, created_by, created_at, reviewer]
  required_sections: [Summary, Findings, Decision]
  validation: |
    - id must match pattern REV-\d+
    - status must be "approved"
    - Findings must have at least one Approved or Recommendations item
    - reviewed_artifacts must be non-empty
```

#### 2. Consistency Check

```yaml
cross-artifact:
  - All related_requirements in UI-015 must exist as requirement artifacts
  - All reviewed_artifacts in REV-003 must exist and be approved
  - Test case TC-101 must reference existing requirement REQ-042
  - No circular dependencies between artifacts
```

#### 3. Format Check

```yaml
format:
  - Markdown must be valid (no unclosed code blocks)
  - YAML frontmatter must be valid YAML
  - PlantUML diagrams are optional — extract text if present
  - Tables must have proper markdown table syntax
```

**Validation Output**: JSON report with errors and warnings

```json
{
  "artifact_id": "REQ-042",
  "validation_status": "passed",
  "errors": [],
  "warnings": [
    "PlantUML diagram detected — text extraction applied"
  ],
  "timestamp": "2026-05-26T10:00:00Z"
}
```

---

### Versioning

#### Update Flow

When a BA artifact is updated:

1. **BA updates** `wiki/projects/{project}/requirements/REQ-042.md` (version 1.1.0)
2. **Adapter re-runs** conversion, detects version change
3. **New artifact** created at `.sdlc/artifacts/requirement/req-042/meta.json`
4. **Old version** preserved with `supersedes` field pointing to previous version
5. **Dependent artifacts** (test cases, design docs) marked as `draft` for re-validation

#### Version Tracking

```json
{
  "id": "req-042",
  "artifact_id": "REQ-042",
  "version": "1.1.0",
  "kind": "requirement",
  "supersedes": "1.0.0",
  "derives_from": [],
  "approval_state": "approved",
  "created_at": "2026-05-26T10:00:00Z"
}
```

#### Re-validation Triggers

| Change Type | Re-validation Required |
|-------------|------------------------|
| Requirement text changed | Yes — all linked test cases |
| Acceptance criteria added/removed | Yes — all linked test cases |
| UI spec screen flow changed | Yes — linked test cases |
| Test case steps changed | No — unless requirement changed |
| Review report updated | No — informational only |

#### Dependent Artifact Invalidation

When `REQ-042` is updated:

```
.sdlc/artifacts/
├── requirement/req-042/meta.json        ← version: 1.1.0
├── design-artifact/ui-015/meta.json     ← approval_state: draft (needs re-review)
├── test-case/tc-101/meta.json           ← approval_state: draft (needs re-review)
└── review-note/rev-003/meta.json        ← approval_state: draft (needs re-review)
```

Dev skills check `approval_state` before consuming — `draft` artifacts trigger a re-review gate.

---

### Conversion Examples

#### Before: BA Markdown

```markdown
---
id: REQ-050
title: User Session Timeout
type: functional
actors: [User, System]
priority: medium
status: approved
created_by: ba-team
created_at: 2026-05-25
---

## Description

User sessions must automatically timeout after 30 minutes of inactivity.

## Acceptance Criteria

- [ ] Session expires after 30 minutes of no user activity
- [ ] User is redirected to login page on timeout
- [ ] User sees "Session expired" message
- [ ] Unsaved work warning shown if form is dirty

## Notes

Timeout value configurable via environment variable SESSION_TIMEOUT_MINUTES.
```

#### After: Dev JSON + Content

**meta.json**:
```json
{
  "id": "req-050",
  "artifact_id": "REQ-050",
  "version": "1.0.0",
  "kind": "requirement",
  "content_ref": "./content.md",
  "provenance_mode": "ai",
  "provider": "agent-for-ba",
  "source_uri": "wiki/projects/myapp/requirements/REQ-050.md",
  "source_version": "1.0.0",
  "created_by_actor": "ba-team",
  "created_in_execution": "exec-20260525-001",
  "created_at": "2026-05-25T11:30:00Z",
  "checksum": "sha256:xyz789...",
  "approval_state": "approved",
  "authority_state": "derived",
  "supersedes": null,
  "derives_from": []
}
```

**content.md**:
```markdown
# User Session Timeout

**Actors**: User, System  
**Priority**: medium

## Description

User sessions must automatically timeout after 30 minutes of inactivity.

## Acceptance Criteria

- [ ] Session expires after 30 minutes of no user activity
- [ ] User is redirected to login page on timeout
- [ ] User sees "Session expired" message
- [ ] Unsaved work warning shown if form is dirty

## Notes

Timeout value configurable via environment variable SESSION_TIMEOUT_MINUTES.
```

---

### Adapter Implementation Notes

**Script Location**: `scripts/convert-ba-to-dev.sh` (to be implemented)

**Input**: `wiki/projects/{project}/**/*.md`  
**Output**: `.sdlc/artifacts/{kind}/{id}/`

**Steps**:
1. Scan `wiki/projects/{project}/` for markdown files with YAML frontmatter
2. Parse frontmatter and validate against artifact type schema
3. Extract markdown body sections
4. Generate `meta.json` with `ArtifactVersion` schema
5. Write `content.md` with cleaned markdown (extract diagrams to text)
6. Compute checksum of content
7. Update `derives_from` and `supersedes` based on version tracking
8. Generate validation report

**Error Handling**:
- If validation fails, write to `.sdlc/artifacts/.validation-errors/` with error details
- Do not write invalid artifacts to main artifact directories
- Log warnings for non-blocking issues (e.g., PlantUML extraction)

---

---

## GSD → OMO Handoff Contract

### 1.1 Purpose

Defines how a GSD Redux `PLAN.md` task is transformed into an OMO/OpenCode `task()` invocation. This is the execution handoff from the planning layer (GSD) to the orchestration layer (OMO).

**Source system**: GSD Redux (`.planning/`)  
**Target system**: OMO/OpenCode (`.sisyphus/`)  
**Adapter location**: `.sdlc/integration/adapters/gsd-omo-adapter.md`  
**State channel**: GSD `STATE.md` ↔ OMO execution logs

### 1.2 Source Format (GSD `PLAN.md` Task Schema)

A GSD task is a markdown subsection under an execution wave, using the following fields:

```markdown
- [ ] N. Task Title

  **What to do**:
  - Description: <free-text task description>
  - <additional sub-bullets for context>

  **Must NOT do**:
  - <guardrails and exclusions>

  **Recommended Agent Profile**:
  - **Category**: `<category>`
    - Reason: <rationale>
  - **Skills**: [`<skill1>`, `<skill2>`]

  **Parallelization**:
  - **Can Run In Parallel**: YES | NO
  - **Parallel Group**: Wave <N> (with Tasks ...)
  - **Blocks**: <downstream tasks>
  - **Blocked By**: <upstream tasks>

  **References**:
  - `<file-path>` — <description>
  - `<external-url>` — <description>

  **Acceptance Criteria**:
  - [ ] <criterion 1>
  - [ ] <criterion 2>

  **QA Scenarios**:
  ```
  Scenario: <name>
    Tool: <tool>
    Steps: <steps>
    Expected Result: <result>
    Evidence: <evidence-path>
  ```

  **Commit**: YES | NO
  - Message: `[<prefix>] <summary>`
  - Files: `<path1>`, `<path2>`
```

### 1.3 Target Format (OMO `task()` Signature)

OMO exposes a single `task()` function for agent dispatch:

```typescript
task(
  category: "deep" | "quick" | "writing" | "visual-engineering" | ...,
  load_skills: string[],
  description: string,      // 3-5 words, shown in UI/logs
  prompt: string,           // full instructions for the agent
  run_in_background: boolean
)
```

### 1.4 Task Field Mapping

| GSD Field (`PLAN.md`) | OMO Parameter | Mapping Rule | Required |
|---|---|---|---|
| Task Title (`N. Task Title`) | `description` | Truncate to 3–5 words; used as log label | Yes |
| `Description` bullets | `prompt` | Concatenate all `**What to do**` bullets into a single prompt block. Prepend wave/group context for disambiguation. | Yes |
| `Must NOT do` bullets | `prompt` (appended) | Append as a `### Guardrails` section inside the prompt. | No |
| `Recommended Agent Profile → Category` | `category` | Map directly. Fallback: `"deep"` if missing or unrecognised. | Yes |
| `Recommended Agent Profile → Skills` | `load_skills` | Pass as string array. Filter to skills known in the OMO registry; drop unknowns with a warning. | No |
| `Parallelization → Can Run In Parallel` | `run_in_background` | `YES` → `true`; `NO` → `false`. | Yes |
| `References → file-path` | `prompt` (appended) | Append as `### Context Files` with full paths. | No |
| `References → external-url` | `prompt` (appended) | Append as `### External References` with URLs. | No |
| `Acceptance Criteria` | `prompt` (appended) | Append as `### Acceptance Criteria` checklist. OMO agent verifies these before signalling completion. | No |
| `QA Scenarios` | `prompt` (appended) | Append as `### QA Scenarios` in Gherkin-like blocks. Agent executes and captures evidence to the specified path. | No |
| `Commit → Message` | `prompt` (appended) | Append as `### Commit Instruction` with expected prefix and summary. | No |
| `Commit → Files` | `prompt` (appended) | Append as `### Expected Modified Files` list. | No |

### 1.5 Category Mapping

GSD agent profile categories map to OMO `category` values as follows:

| GSD Category Hint | OMO `category` | Rationale |
|---|---|---|
| `deep`, architecture, design, analysis | `"deep"` | Long-horizon reasoning, high token budget |
| `quick`, spike, validation, check | `"quick"` | Short-horizon, fast feedback |
| `writing`, docs, spec, contract | `"writing"` | Narrative generation, low code |
| `visual-engineering`, diagram, UI | `"visual-engineering"` | Diagram, chart, or UI generation |
| `unspecified-high` | `"deep"` | Conservative default for unknown high-skill agents |
| *(missing)* | `"deep"` | Safe fallback |

### 1.6 Dependency & Wave Mapping

GSD organises execution into **waves**. The adapter must respect wave boundaries when dispatching to OMO.

#### Wave Dispatch Rules

```
Wave N (all tasks marked "Can Run In Parallel: YES")
  ├── task_1  →  task(category=..., run_in_background=true)
  ├── task_2  →  task(category=..., run_in_background=true)
  └── task_3  →  task(category=..., run_in_background=true)
       ↓
   Wait for ALL background tasks in Wave N to complete
       ↓
Wave N+1 (sequential or next parallel group)
  ├── task_4  →  task(category=..., run_in_background=false) OR
  │               task(category=..., run_in_background=true) + explicit sync
  └── ...
```

| GSD Dependency Semantics | OMO Behaviour |
|---|---|
| `Can Run In Parallel: YES` + same Wave | Dispatch with `run_in_background=true`. Collect results asynchronously. |
| `Can Run In Parallel: NO` | Dispatch with `run_in_background=false`. Block until completion. |
| `Blocked By: Task X` | Do not dispatch until Task X signals completion in `STATE.md`. |
| `Blocks: Task Y` | After this task completes, update `STATE.md`; Task Y becomes eligible for dispatch. |
| Cross-wave dependency | Adapter polls `STATE.md` for upstream task status. On `completed`, dispatches downstream. |

#### Adapter Sequencing Algorithm

1. **Parse** `PLAN.md` into a DAG of tasks with wave IDs and dependency edges.
2. **Dispatch Wave 0**: All tasks with no `Blocked By` entries and `run_in_background=true`.
3. **Poll loop**: Every 5 s, read `.planning/STATE.md` (or `boulder.json` task state).
4. **Wave advancement**: When all tasks in wave `N` are `completed` (or `skipped`), dispatch all tasks in wave `N+1` whose `Blocked By` tasks are satisfied.
5. **Failure handling**: If any task reports `failed`, halt wave advancement and surface to GSD replanning protocol.

### 1.7 Prompt Assembly Template

The adapter constructs the OMO `prompt` by concatenating GSD sections in a fixed order:

```markdown
## Task
<task title>

### Description
<What to do bullets>

### Guardrails
<Must NOT do bullets>

### Context Files
<References file-path list>

### External References
<References external-url list>

### Acceptance Criteria
<checkbox list>

### QA Scenarios
<scenario blocks>

### Commit Instruction
Message: `[<prefix>] <summary>`
Files: <path list>
```

### 1.8 State Feedback Protocol (OMO → GSD)

When an OMO task finishes, the adapter writes a structured result back to GSD state.

#### Feedback File

**Location**: `.planning/STATE.md` (append) or `.planning/boulder.json` task entry update  
**Format**: Markdown log entry per task (human-readable) + JSON fragment (machine-readable)

#### Feedback Schema

```markdown
## Task N: <Title>

**Status**: <completed | failed | skipped | partial>
**OMO Task ID**: <uuid>
**Started**: <ISO-8601>
**Finished**: <ISO-8601>
**Agent Category**: <category>
**Skills Loaded**: [<skill1>, <skill2>]

**Evidence**:
- <path to evidence file or artifact>

**Commit Result**:
- Commit: `<hash>`
- Message: `[<prefix>] <message>`
- Files: `<path1>`, `<path2>`

**Delta Summary**:
- Lines added: <N>
- Lines removed: <N>
- Files changed: <N>

**Blockers for Downstream**:
- <none | list of unresolved issues>
```

#### State Update Rules

| OMO Result | GSD `STATE.md` Action |
|---|---|
| Agent reports success + all acceptance criteria pass | Mark task `completed`. Append evidence path. Trigger downstream dispatch. |
| Agent reports success + some criteria skipped | Mark task `partial`. Append rationale. Trigger downstream **with warning**. |
| Agent reports failure | Mark task `failed`. Append error summary. **Halt wave**. Invoke replanning protocol. |
| Agent timeout / no response after threshold | Mark task `failed`. Append `TIMEOUT`. **Halt wave**. |
| Commit created by agent | Record commit hash, message, and file list under `Commit Result`. |

#### GSD `boulder.json` Sync

For machine consumption, the adapter also patches `boulder.json`:

```json
{
  "tasks": {
    "task-N": {
      "status": "completed",
      "omo_task_id": "uuid",
      "started_at": "2026-05-26T09:00:00Z",
      "finished_at": "2026-05-26T09:15:00Z",
      "commit": "abc1234",
      "evidence": ".sisyphus/evidence/task-N-result.txt"
    }
  }
}
```

### 1.9 Example: Full Handoff

**GSD Source (PLAN.md fragment)**:

```markdown
- [ ] 8. Design GSD→OMO Handoff Contract

  **What to do**:
  - Task mapping: GSD PLAN.md task fields → OMO task() parameters
  - Dependency handling: GSD waves → OMO run_in_background/sequencing
  - State feedback: OMO execution results → GSD STATE.md updates

  **Must NOT do**:
  - Không implement adapter đầy đủ (chỉ spike)
  - Không sửa GSD hoặc OMO internal code

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Cần hiểu cả GSD task model và OMO execution model
  - **Skills**: [`git-master`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 6, 7, 9, 10)
  - **Blocked By**: Task 5 + Task 1

  **Acceptance Criteria**:
  - [ ] `AI-in-sdlc/docs/HANDOFF-CONTRACTS.md` §GSD→OMO
  - [ ] Task field mapping table + dependency/wave mapping
  - [ ] Result feedback protocol

  **Commit**: YES
  - Message: `[int] design: GSD-to-OMO handoff contract`
  - Files: `AI-in-sdlc/docs/HANDOFF-CONTRACTS.md`
```

**Generated OMO Invocation**:

```typescript
task(
  category: "deep",
  load_skills: ["git-master"],
  description: "Design GSD-to-OMO handoff contract",
  prompt: `
## Task
Design GSD→OMO Handoff Contract

### Description
- Task mapping: GSD PLAN.md task fields → OMO task() parameters
- Dependency handling: GSD waves → OMO run_in_background/sequencing
- State feedback: OMO execution results → GSD STATE.md updates

### Guardrails
- Không implement adapter đầy đủ (chỉ spike)
- Không sửa GSD hoặc OMO internal code

### Context Files
- AI-in-sdlc/docs/spikes/gsd-omo-handoff.md — Spike results
- AI-in-sdlc/docs/spikes/system-conventions.md — System conventions

### Acceptance Criteria
- [ ] AI-in-sdlc/docs/HANDOFF-CONTRACTS.md §GSD→OMO
- [ ] Task field mapping table + dependency/wave mapping
- [ ] Result feedback protocol

### Commit Instruction
Message: [int] design: GSD-to-OMO handoff contract
Files: AI-in-sdlc/docs/HANDOFF-CONTRACTS.md
  `,
  run_in_background: true
)
```

**Generated State Feedback (after completion)**:

```markdown
## Task 8: Design GSD→OMO Handoff Contract

**Status**: completed
**OMO Task ID**: omo-uuid-8
**Started**: 2026-05-26T09:00:00Z
**Finished**: 2026-05-26T09:42:00Z
**Agent Category**: deep
**Skills Loaded**: [git-master]

**Evidence**:
- .sisyphus/evidence/task-8-handoff-gsd-omo.txt

**Commit Result**:
- Commit: `a1b2c3d`
- Message: `[int] design: GSD-to-OMO handoff contract`
- Files: `AI-in-sdlc/docs/HANDOFF-CONTRACTS.md`

**Delta Summary**:
- Lines added: 312
- Lines removed: 0
- Files changed: 1

**Blockers for Downstream**:
- none
```

### 1.10 Validation Rules

Before dispatch, the adapter validates the handoff:

| Check | Failure Action |
|---|---|
| Task title present and non-empty | Reject with `MALFORMED_TASK_TITLE` |
| `description` ≤ 80 chars after truncation | Truncate and append `…` |
| `category` in OMO allow-list | Fallback to `"deep"`, log warning |
| `load_skills` entries exist in OMO registry | Drop unknowns, log warning |
| `Blocked By` tasks exist in parsed DAG | Reject with `UNKNOWN_DEPENDENCY` |
| No circular dependencies in wave | Reject with `CIRCULAR_DEPENDENCY` |
| `Acceptance Criteria` has ≥ 1 item | Warn `NO_ACCEPTANCE_CRITERIA` |
| Evidence path is writable | Pre-create directory if missing |

### 1.11 Error & Replanning Protocol

When validation fails or an OMO task fails mid-flight:

1. **Log** the failure to `.planning/STATE.md` and `boulder.json`.
2. **Halt** the current wave; do not dispatch downstream tasks.
3. **Surface** a concise summary to the user:
   ```
   [GSD→OMO] Task N failed: <reason>
   Affected downstream: Task M, Task O
   Options:
   [1] Retry Task N
   [2] Replan — modify PLAN.md and reload
   [3] Skip Task N and continue (human override)
   ```
4. **Await** human input before proceeding (replanning gate).

---

## Future Contracts

- Dev → QA Handoff (test automation artifacts)
- QA → Ops Handoff (deployment artifacts)
- Ops → BA Feedback Loop (production metrics to requirements)
