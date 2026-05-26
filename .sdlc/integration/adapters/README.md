# Adapter Implementation Specifications

> **Task 13** of AI-SDLC Integration Framework
>
> Detailed specifications for the three core integration adapters that enable
> communication between GSD Redux, OMO/OpenCode, AI-in-sdlc, and agent-for-ba systems.

---

## Overview

This document specifies three adapters that form the integration layer:

| Adapter | Source → Target | Purpose |
|---------|----------------|---------|
| **GSD→OMO** | GSD Redux → OMO/OpenCode | Transform PLAN.md tasks into task() invocations |
| **BA→Dev** | agent-for-ba → AI-in-sdlc | Convert BA markdown artifacts to ArtifactVersion JSON |
| **State Sync** | Bidirectional | Keep execution state consistent across all systems |

Each adapter is a **file-based script** that reads one system's canonical KB and writes to another's, following ADR-016 (File-based Convention Layer Integration) and ADR-017 (Distributed Knowledge Base Ownership).

---

## 1. GSD→OMO Adapter

### 1.1 Purpose

Transforms GSD Redux `PLAN.md` task definitions into OMO/OpenCode `task()` function invocations, managing wave-based dispatch and state feedback.

**Source**: `.planning/PLAN.md`  
**Target**: OMO `task()` calls (runtime) + `.planning/STATE.md` (feedback)  
**Estimated LOC**: ~350 lines (TypeScript)  
**Implementation File**: `scripts/adapters/gsd-omo-adapter.ts`

---

### 1.2 Input Format

**Source File**: `.planning/PLAN.md`

```markdown
## Wave 2

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
  - **Blocks**: Task 11

  **References**:
  - AI-in-sdlc/docs/spikes/gsd-omo-handoff.md — Spike results
  - https://example.com/omo-docs — OMO task() API

  **Acceptance Criteria**:
  - [ ] AI-in-sdlc/docs/HANDOFF-CONTRACTS.md §GSD→OMO
  - [ ] Task field mapping table + dependency/wave mapping
  - [ ] Result feedback protocol

  **QA Scenarios**:
  ```
  Scenario: Task completes successfully
    Tool: background_output
    Steps: Dispatch task, wait for completion
    Expected Result: STATE.md updated with completed status
    Evidence: .sisyphus/evidence/task-8-result.txt
  ```

  **Commit**: YES
  - Message: `[int] design: GSD-to-OMO handoff contract`
  - Files: AI-in-sdlc/docs/HANDOFF-CONTRACTS.md
```

**Parsed Structure** (internal representation):

```typescript
interface GSDTask {
  waveId: number;
  taskId: number;
  title: string;
  description: string[];
  guardrails: string[];
  category: string;
  skills: string[];
  parallelizable: boolean;
  blockedBy: number[];
  blocks: number[];
  references: { path: string; description: string }[];
  acceptanceCriteria: string[];
  qaScenarios: QAScenario[];
  commit: {
    enabled: boolean;
    message: string;
    files: string[];
  };
}
```

---

### 1.3 Output Format

**Primary Output**: OMO `task()` invocation (runtime)

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
- https://example.com/omo-docs — OMO task() API

### Acceptance Criteria
- [ ] AI-in-sdlc/docs/HANDOFF-CONTRACTS.md §GSD→OMO
- [ ] Task field mapping table + dependency/wave mapping
- [ ] Result feedback protocol

### QA Scenarios
Scenario: Task completes successfully
  Tool: background_output
  Steps: Dispatch task, wait for completion
  Expected Result: STATE.md updated with completed status
  Evidence: .sisyphus/evidence/task-8-result.txt

### Commit Instruction
Message: [int] design: GSD-to-OMO handoff contract
Files: AI-in-sdlc/docs/HANDOFF-CONTRACTS.md
  `,
  run_in_background: true
)
```

**Secondary Output**: State feedback to `.planning/STATE.md`

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

**Machine-Readable Output**: `.planning/boulder.json` patch

```json
{
  "tasks": {
    "task-8": {
      "status": "completed",
      "omo_task_id": "omo-uuid-8",
      "started_at": "2026-05-26T09:00:00Z",
      "finished_at": "2026-05-26T09:42:00Z",
      "commit": "a1b2c3d",
      "evidence": ".sisyphus/evidence/task-8-result.txt"
    }
  }
}
```

---

### 1.4 Error Handling

| Error Code | Trigger | Action | Recovery |
|------------|---------|--------|----------|
| `MALFORMED_TASK_TITLE` | Task title missing or empty | Reject task, log to `.planning/.adapter-errors/` | Human fixes PLAN.md |
| `UNKNOWN_DEPENDENCY` | `Blocked By` references non-existent task | Reject wave, halt dispatch | Human adds missing task or fixes dependency |
| `CIRCULAR_DEPENDENCY` | Cycle detected in task DAG | Reject wave, log cycle path | Human breaks cycle in PLAN.md |
| `INVALID_CATEGORY` | Category not in OMO allow-list | Fallback to `"deep"`, log warning | No action needed |
| `UNKNOWN_SKILL` | Skill not in OMO registry | Drop skill, log warning | Human updates skill reference |
| `NO_ACCEPTANCE_CRITERIA` | Empty acceptance criteria list | Warn, proceed with dispatch | Optional: human adds criteria |
| `EVIDENCE_PATH_NOT_WRITABLE` | Evidence directory missing/locked | Pre-create directory, retry | If fails, halt and alert |
| `OMO_DISPATCH_TIMEOUT` | OMO task no response after 30 min | Mark `failed`, append `TIMEOUT` | Human retries or replans |
| `OMO_TASK_FAILED` | OMO agent reports failure | Mark `failed`, halt wave | Human invokes replanning |

**Error Log Format**: `.planning/.adapter-errors/gsd-omo-{timestamp}.json`

```json
{
  "error_id": "ERR-20260526-001",
  "adapter": "gsd-omo",
  "error_code": "UNKNOWN_DEPENDENCY",
  "task_id": 8,
  "wave_id": 2,
  "message": "Task 8 references non-existent dependency: Task 99",
  "timestamp": "2026-05-26T09:00:00Z",
  "resolution_status": "pending_human_fix"
}
```

---

### 1.5 Test Cases

#### Unit Tests

```typescript
// File: scripts/adapters/__tests__/gsd-omo-adapter.test.ts

describe('GSD→OMO Adapter', () => {
  test('parse valid PLAN.md task', () => {
    const planMd = `
- [ ] 8. Test Task Title

  **What to do**:
  - Do something useful

  **Recommended Agent Profile**:
  - **Category**: \`deep\`
  - **Skills**: [\`git-master\`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  `;
    const task = parseTask(planMd);
    expect(task.taskId).toBe(8);
    expect(task.category).toBe('deep');
    expect(task.parallelizable).toBe(true);
  });

  test('reject task with circular dependency', () => {
    const tasks = [
      { taskId: 1, blockedBy: [3] },
      { taskId: 2, blockedBy: [1] },
      { taskId: 3, blockedBy: [2] },
    ];
    expect(detectCycle(tasks)).toBeTruthy();
  });

  test('fallback to deep category for unknown category', () => {
    const task = { category: 'unknown-category' };
    const mapped = mapCategory(task.category);
    expect(mapped).toBe('deep');
  });

  test('build prompt from task sections', () => {
    const task = {
      title: 'Test Task',
      description: ['Do X', 'Do Y'],
      guardrails: ['Do not Z'],
      acceptanceCriteria: ['Criterion 1'],
    };
    const prompt = buildPrompt(task);
    expect(prompt).toContain('## Task');
    expect(prompt).toContain('### Description');
    expect(prompt).toContain('### Guardrails');
    expect(prompt).toContain('### Acceptance Criteria');
  });
});
```

#### Integration Tests

```typescript
describe('GSD→OMO Integration', () => {
  test('full wave dispatch and state feedback', async () => {
    // Setup: Create mock PLAN.md with 3 tasks in Wave 1
    const planMd = createMockPlan();
    writeFileSync('.planning/PLAN.md', planMd);

    // Execute: Run adapter
    const adapter = new GsdOmoAdapter();
    await adapter.dispatchWave(1);

    // Verify: STATE.md updated
    const state = readFileSync('.planning/STATE.md', 'utf-8');
    expect(state).toContain('Task 1');
    expect(state).toContain('completed');

    // Verify: boulder.json patched
    const boulder = JSON.parse(readFileSync('.planning/boulder.json', 'utf-8'));
    expect(boulder.tasks['task-1'].status).toBe('completed');
  });

  test('halt wave on task failure', async () => {
    // Setup: Task 1 fails
    mockOmoTaskFailure('task-1');

    // Execute: Dispatch Wave 1
    const adapter = new GsdOmoAdapter();
    await adapter.dispatchWave(1);

    // Verify: Wave 2 NOT dispatched
    expect(adapter.waveDispatched(2)).toBe(false);

    // Verify: Error logged
    const errors = readErrorLog();
    expect(errors).toContain('OMO_TASK_FAILED');
  });
});
```

#### Test Data Files

- `test/fixtures/plan-valid.md` — Valid PLAN.md with multiple waves
- `test/fixtures/plan-circular.md` — PLAN.md with circular dependencies
- `test/fixtures/plan-missing-deps.md` — PLAN.md with unknown dependencies
- `test/mocks/omo-runtime.ts` — Mock OMO task() runtime

---

### 1.6 Key Algorithms

#### 1.6.1 Wave Dispatch Algorithm

```typescript
async function dispatchWave(waveId: number): Promise<void> {
  // 1. Parse PLAN.md into task DAG
  const tasks = parsePlanMd('.planning/PLAN.md');
  const waveTasks = tasks.filter(t => t.waveId === waveId);

  // 2. Validate dependencies
  const errors = validateDependencies(waveTasks);
  if (errors.length > 0) {
    logErrors(errors);
    throw new AdapterError('WAVE_VALIDATION_FAILED', errors);
  }

  // 3. Dispatch parallel tasks
  const backgroundTasks = waveTasks.filter(t => t.parallelizable);
  const taskIds = await Promise.all(
    backgroundTasks.map(t => dispatchTask(t))
  );

  // 4. Wait for all background tasks
  const results = await Promise.all(
    taskIds.map(id => pollForCompletion(id))
  );

  // 5. Write state feedback
  for (const result of results) {
    writeStateFeedback(result);
    patchBoulderJson(result);
  }

  // 6. Check for failures
  const failures = results.filter(r => r.status === 'failed');
  if (failures.length > 0) {
    haltDownstreamWaves(failures);
    throw new AdapterError('WAVE_PARTIAL_FAILURE', failures);
  }
}
```

#### 1.6.2 Cycle Detection (DFS)

```typescript
function detectCycle(tasks: GSDTask[]): boolean {
  const graph = buildDependencyGraph(tasks);
  const visited = new Set();
  const recStack = new Set();

  function dfs(taskId: number): boolean {
    visited.add(taskId);
    recStack.add(taskId);

    for (const neighbor of graph.get(taskId) || []) {
      if (!visited.has(neighbor) && dfs(neighbor)) {
        return true;
      }
      if (recStack.has(neighbor)) {
        return true; // Cycle detected
      }
    }

    recStack.delete(taskId);
    return false;
  }

  for (const task of tasks) {
    if (!visited.has(task.taskId) && dfs(task.taskId)) {
      return true;
    }
  }

  return false;
}
```

#### 1.6.3 Prompt Assembly

```typescript
function buildPrompt(task: GSDTask): string {
  const sections = [
    `## Task\n${task.title}`,
    `### Description\n${task.description.join('\n')}`,
  ];

  if (task.guardrails.length > 0) {
    sections.push(`### Guardrails\n${task.guardrails.join('\n')}`);
  }

  if (task.references.length > 0) {
    sections.push(`### Context Files\n${formatReferences(task.references)}`);
  }

  if (task.acceptanceCriteria.length > 0) {
    sections.push(`### Acceptance Criteria\n${task.acceptanceCriteria.map(c => `- [ ] ${c}`).join('\n')}`);
  }

  if (task.qaScenarios.length > 0) {
    sections.push(`### QA Scenarios\n${formatQaScenarios(task.qaScenarios)}`);
  }

  if (task.commit.enabled) {
    sections.push(`### Commit Instruction\nMessage: ${task.commit.message}\nFiles: ${task.commit.files.join(', ')}`);
  }

  return sections.join('\n\n');
}
```

---

## 2. BA→Dev Adapter

### 2.1 Purpose

Converts Business Analyst markdown artifacts (from `wiki/projects/{project}/`) into AI-in-sdlc `ArtifactVersion` JSON structures (`.sdlc/artifacts/`).

**Source**: `wiki/projects/{project}/**/*.md`  
**Target**: `.sdlc/artifacts/{kind}/{id}/meta.json` + `content.md`  
**Estimated LOC**: ~280 lines (TypeScript)  
**Implementation File**: `scripts/adapters/ba-dev-adapter.ts`

---

### 2.2 Input Format

**Source File**: `wiki/projects/myapp/requirements/REQ-042.md`

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

**Supported Artifact Types**:

| BA Type | Frontmatter `type` | Dev `kind` |
|---------|-------------------|------------|
| Requirement | `functional`, `non-functional`, `requirement` | `requirement` |
| UI Spec | `ui-spec`, `design` | `design-artifact` |
| Test Case | `test-case`, `test` | `test-case` |
| Review Report | `review-report`, `review` | `review-note` |

---

### 2.3 Output Format

**Meta File**: `.sdlc/artifacts/requirement/req-042/meta.json`

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

**Content File**: `.sdlc/artifacts/requirement/req-042/content.md`

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

### 2.4 Error Handling

| Error Code | Trigger | Action | Recovery |
|------------|---------|--------|----------|
| `INVALID_FRONTMATTER` | YAML frontmatter parse error | Skip file, log to `.sdlc/artifacts/.validation-errors/` | Human fixes markdown |
| `MISSING_REQUIRED_FIELD` | Required frontmatter field absent | Reject artifact, log details | Human adds missing field |
| `INVALID_ARTIFACT_TYPE` | `type` not in allow-list | Reject, log unknown type | Human corrects type or adapter adds mapping |
| `MISSING_REQUIRED_SECTION` | Required markdown section absent | Reject, log missing section | Human adds section |
| `INVALID_ID_FORMAT` | ID doesn't match pattern (e.g., `REQ-\d+`) | Reject, log pattern mismatch | Human fixes ID |
| `DRAFT_STATUS` | `status: draft` or `in-review` | Skip (not ready for Dev), log info | BA updates to `approved` |
| `BROKEN_REFERENCE` | `related_requirements` points to non-existent artifact | Warn, proceed with conversion | BA adds missing artifact |
| `CHECKSUM_MISMATCH` | Content checksum doesn't match computed | Log warning, overwrite with new checksum | Auto-resolved |
| `PLANTUML_EXTRACTION_FAIL` | PlantUML diagram present but extraction fails | Extract raw text, log warning | Manual extraction if needed |

**Validation Report**: `.sdlc/artifacts/.validation-errors/REQ-042-validation.json`

```json
{
  "artifact_id": "REQ-042",
  "validation_status": "failed",
  "errors": [
    {
      "code": "MISSING_REQUIRED_SECTION",
      "message": "Required section 'Acceptance Criteria' not found",
      "line": null
    }
  ],
  "warnings": [],
  "timestamp": "2026-05-26T10:00:00Z"
}
```

---

### 2.5 Test Cases

#### Unit Tests

```typescript
// File: scripts/adapters/__tests__/ba-dev-adapter.test.ts

describe('BA→Dev Adapter', () => {
  test('parse valid requirement markdown', () => {
    const md = `
---
id: REQ-042
title: Test Requirement
type: functional
status: approved
created_by: ba-team
created_at: 2026-05-20
---

## Description
Test description.

## Acceptance Criteria
- [ ] Criterion 1
`;
    const artifact = parseRequirement(md);
    expect(artifact.id).toBe('req-042');
    expect(artifact.kind).toBe('requirement');
    expect(artifact.approval_state).toBe('approved');
  });

  test('reject draft status artifact', () => {
    const md = `
---
id: REQ-043
type: functional
status: draft
---
`;
    expect(() => parseRequirement(md)).toThrow('DRAFT_STATUS');
  });

  test('extract PlantUML diagram to text', () => {
    const md = `
## Flow
\`\`\`plantuml
@startuml
start
:Step 1;
stop
@enduml
\`\`\`
`;
    const extracted = extractPlantuml(md);
    expect(extracted).toContain('1. Step 1');
  });

  test('compute SHA256 checksum', () => {
    const content = 'Test content';
    const checksum = computeChecksum(content);
    expect(checksum).toMatch(/^sha256:[a-f0-9]{64}$/);
  });

  test('validate ID format', () => {
    expect(validateId('REQ-042', 'requirement')).toBe(true);
    expect(validateId('UI-015', 'design-artifact')).toBe(true);
    expect(validateId('INVALID', 'requirement')).toBe(false);
  });
});
```

#### Integration Tests

```typescript
describe('BA→Dev Integration', () => {
  test('full conversion pipeline', async () => {
    // Setup: Create mock wiki directory
    const wikiDir = '/tmp/test-wiki/projects/myapp/requirements/';
    mkdirSync(wikiDir, { recursive: true });
    writeFileSync(`${wikiDir}/REQ-042.md`, VALID_REQUIREMENT_MD);

    // Execute: Run adapter
    const adapter = new BaDevAdapter();
    await adapter.convertProject('myapp');

    // Verify: meta.json created
    const metaPath = '.sdlc/artifacts/requirement/req-042/meta.json';
    expect(existsSync(metaPath)).toBe(true);
    const meta = JSON.parse(readFileSync(metaPath, 'utf-8'));
    expect(meta.kind).toBe('requirement');

    // Verify: content.md created
    const contentPath = '.sdlc/artifacts/requirement/req-042/content.md';
    expect(existsSync(contentPath)).toBe(true);

    // Verify: checksum computed
    expect(meta.checksum).toMatch(/^sha256:/);
  });

  test('handle validation errors gracefully', async () => {
    // Setup: Invalid markdown (missing frontmatter)
    writeFileSync('/tmp/test-wiki/INVALID.md', 'No frontmatter here');

    // Execute: Run adapter
    const adapter = new BaDevAdapter();
    const report = await adapter.convertProject('myapp');

    // Verify: Error logged
    expect(report.errors.length).toBeGreaterThan(0);
    expect(report.errors[0].code).toBe('INVALID_FRONTMATTER');

    // Verify: No artifact created
    expect(existsSync('.sdlc/artifacts/requirement/invalid/')).toBe(false);
  });

  test('version tracking on update', async () => {
    // Setup: Existing artifact version 1.0.0
    createExistingArtifact('req-042', '1.0.0');

    // Update: BA updates wiki file
    writeFileSync('/tmp/test-wiki/REQ-042.md', UPDATED_REQUIREMENT_MD);

    // Execute: Re-run adapter
    const adapter = new BaDevAdapter();
    await adapter.convertProject('myapp');

    // Verify: New version created
    const meta = readArtifactMeta('req-042');
    expect(meta.version).toBe('1.1.0');
    expect(meta.supersedes).toBe('1.0.0');
  });
});
```

#### Test Data Files

- `test/fixtures/requirement-valid.md` — Valid requirement with all fields
- `test/fixtures/ui-spec-valid.md` — Valid UI specification
- `test/fixtures/test-case-valid.md` — Valid test case with table
- `test/fixtures/review-report-valid.md` — Valid review report
- `test/fixtures/invalid-frontmatter.md` — Malformed YAML
- `test/fixtures/missing-sections.md` — Missing required sections
- `test/fixtures/draft-status.md` — Not yet approved
- `test/fixtures/plantuml-diagram.md` — Requirement with PlantUML

---

### 2.6 Key Algorithms

#### 2.6.1 Frontmatter Parsing

```typescript
function parseFrontmatter(md: string): Frontmatter {
  const match = md.match(/^---\n([\s\S]*?)\n---/);
  if (!match) {
    throw new AdapterError('INVALID_FRONTMATTER');
  }

  const yaml = match[1];
  const data = jsYaml.load(yaml) as Frontmatter;

  // Validate required fields
  const required = ['id', 'title', 'type', 'status', 'created_by', 'created_at'];
  for (const field of required) {
    if (!data[field]) {
      throw new AdapterError('MISSING_REQUIRED_FIELD', { field });
    }
  }

  return data;
}
```

#### 2.6.2 Content Extraction

```typescript
function extractContent(md: string, frontmatter: Frontmatter): string {
  // Remove frontmatter
  const body = md.replace(/^---\n[\s\S]*?\n---\n/, '');

  // Extract PlantUML diagrams to text
  const withExtractedDiagrams = extractPlantuml(body);

  // Add metadata header
  const header = `# ${frontmatter.title}\n\n`;
  const metadata = buildMetadataLine(frontmatter);

  return header + metadata + '\n\n' + withExtractedDiagrams;
}

function extractPlantuml(markdown: string): string {
  return markdown.replace(
    /```plantuml\n([\s\S]*?)\n```/g,
    (match, diagram) => {
      // Parse PlantUML and extract text description
      const steps = parsePlantumlSteps(diagram);
      return `> PlantUML diagram extracted:\n\n${steps.join('\n')}`;
    }
  );
}
```

#### 2.6.3 Version Tracking

```typescript
function trackVersion(
  existingMeta: ArtifactVersion | null,
  newContent: string
): Partial<ArtifactVersion> {
  if (!existingMeta) {
    return { version: '1.0.0', supersedes: null };
  }

  const newChecksum = computeChecksum(newContent);
  if (newChecksum === existingMeta.checksum) {
    // No change
    return {};
  }

  // Version bump
  const newVersion = bumpVersion(existingMeta.version);
  return {
    version: newVersion,
    supersedes: existingMeta.version,
    approval_state: 'draft', // Requires re-validation
  };
}

function bumpVersion(version: string): string {
  const [major, minor, patch] = version.split('.').map(Number);
  return `${major}.${minor + 1}.${patch}`;
}
```

---

## 3. State Sync Adapter

### 3.1 Purpose

Maintains eventual consistency of execution state across all four systems (GSD Redux, OMO/OpenCode, AI-in-sdlc, agent-for-ba) through polling, conflict detection, and human-gated resolution.

**Source**: All systems (bidirectional reads)  
**Target**: `.sdlc/integration/sync-state.json` + `.sdlc/integration/conflict-log.json`  
**Estimated LOC**: ~420 lines (TypeScript)  
**Implementation File**: `scripts/adapters/state-sync-adapter.ts`

---

### 3.2 Input Format

**Multiple Sources** (read-only per system):

| System | Source Files | State Extracted |
|--------|-------------|-----------------|
| **GSD Redux** | `.planning/PLAN.md`, `.planning/STATE.md`, `.planning/boulder.json` | Task status, wave progress, phase completion |
| **AI-in-sdlc** | `.sdlc/work-items/*.json`, `.sdlc/phases/{id}/*.json` | Work item status, phase packets, gate status |
| **OMO/OpenCode** | `.sisyphus/` (runtime logs), implicit task state | Task execution results, agent outputs |
| **agent-for-ba** | `wiki/projects/{name}/` (mtime tracking) | Artifact update timestamps |

**Sync State Checkpoint**: `.sdlc/integration/sync-state.json`

```json
{
  "last_sync": "2026-05-26T14:30:00Z",
  "checkpoints": {
    "gsd-to-sdlc": {
      "last_file": ".planning/STATE.md",
      "last_mtime": "2026-05-26T14:28:00Z",
      "items_synced": 12
    },
    "sdlc-to-gsd": {
      "last_file": ".sdlc/phases/wi-20260526-042/Decide.json",
      "last_mtime": "2026-05-26T14:29:30Z",
      "items_synced": 8
    },
    "ba-to-sdlc": {
      "last_file": "wiki/projects/acme/requirements/login.md",
      "last_mtime": "2026-05-26T14:15:00Z",
      "items_synced": 3
    }
  },
  "open_conflicts": ["C-20260526-001"]
}
```

---

### 3.3 Output Format

**Primary Output**: Sync state updates

```json
{
  "last_sync": "2026-05-26T14:35:00Z",
  "checkpoints": {
    "gsd-to-sdlc": {
      "last_file": ".planning/STATE.md",
      "last_mtime": "2026-05-26T14:33:00Z",
      "items_synced": 14
    }
  },
  "open_conflicts": []
}
```

**Conflict Log**: `.sdlc/integration/conflict-log.json`

```json
{
  "conflicts": [
    {
      "conflict_id": "C-20260526-001",
      "type": "C-PHASE",
      "severity": "blocking",
      "work_item_id": "wi-20260526-042",
      "systems_involved": ["gsd-redux", "ai-in-sdlc"],
      "canonical_value": "Decide",
      "divergent_value": "Produce",
      "detected_at": "2026-05-26T14:32:00Z",
      "resolution_status": "open",
      "assigned_to": "human"
    }
  ]
}
```

**Human Gate Prompt** (when conflict detected):

```
CONFLICT DETECTED: C-PHASE
Work Item: wi-20260526-042

GSD Redux says:    Phase = "Decide" (done)
AI-in-sdlc says:   Phase = "Produce" (blocked)

[Resolve as GSD]  [Resolve as AI-in-sdlc]
[View Details]    [Defer (blocks handoff)]
```

---

### 3.4 Error Handling

| Error Code | Trigger | Action | Recovery |
|------------|---------|--------|----------|
| `SYNC_TIMEOUT` | Polling exceeds 30s without response | Log warning, retry with backoff | Auto-resolves on retry |
| `CONFLICT_DETECTED` | State mismatch between systems | Log to conflict-log, trigger human gate | Human resolves via gate |
| `CHECKPOINT_CORRUPT` | sync-state.json invalid JSON | Rebuild checkpoint from scratch | Full re-sync required |
| `FILE_NOT_WRITABLE` | Cannot write to target KB | Abort sync run, log error | Human fixes permissions |
| `CIRCULAR_SYNC` | Same work item updated >3 times in one window | Flag C-CYCLE, halt propagation | Human investigates root cause |
| `ORPHANED_WORK_ITEM` | Work item exists in one KB only | Auto-create placeholder (non-blocking) | No action needed |
| `VERSION_SKEW` | Source file mtime < checkpoint mtime | Skip file, log info | Normal operation |

**Conflict Detection Log**: Written immediately on detection

```json
{
  "conflict_id": "C-20260526-002",
  "type": "C-STATUS",
  "severity": "blocking",
  "work_item_id": "wi-20260526-043",
  "systems_involved": ["gsd-redux", "ai-in-sdlc"],
  "gsd_value": "completed",
  "sdlc_value": "in-progress",
  "detected_at": "2026-05-26T14:40:00Z",
  "resolution_status": "open",
  "assigned_to": "human",
  "auto_resolution_eligible": false
}
```

---

### 3.5 Test Cases

#### Unit Tests

```typescript
// File: scripts/adapters/__tests__/state-sync-adapter.test.ts

describe('State Sync Adapter', () => {
  test('detect phase mismatch conflict', () => {
    const gsdState = { phase: 'Decide', status: 'done' };
    const sdlcState = { phase: 'Produce', status: 'blocked' };

    const conflict = detectConflict('wi-042', gsdState, sdlcState);
    expect(conflict).toBeTruthy();
    expect(conflict.type).toBe('C-PHASE');
    expect(conflict.severity).toBe('blocking');
  });

  test('auto-resolve orphaned work item', () => {
    const sdlcWorkItem = { id: 'wi-042', status: 'open' };
    const gsdTasks = []; // No matching task

    const resolution = resolveConflict('C-ORPHAN', sdlcWorkItem, gsdTasks);
    expect(resolution.action).toBe('create_placeholder');
    expect(resolution.auto).toBe(true);
  });

  test('detect circular sync propagation', () => {
    const updateHistory = [
      { timestamp: '14:30:00', system: 'gsd' },
      { timestamp: '14:30:05', system: 'sdlc' },
      { timestamp: '14:30:10', system: 'gsd' },
      { timestamp: '14:30:15', system: 'sdlc' },
    ];

    const isCircular = detectCircularSync(updateHistory);
    expect(isCircular).toBe(true);
  });

  test('build checkpoint from mtime tracking', () => {
    const files = [
      { path: '.planning/STATE.md', mtime: '2026-05-26T14:28:00Z' },
      { path: '.planning/boulder.json', mtime: '2026-05-26T14:27:00Z' },
    ];

    const checkpoint = buildCheckpoint(files, 'gsd-to-sdlc');
    expect(checkpoint.last_file).toBe('.planning/STATE.md');
    expect(checkpoint.last_mtime).toBe('2026-05-26T14:28:00Z');
  });
});
```

#### Integration Tests

```typescript
describe('State Sync Integration', () => {
  test('full sync cycle with conflict detection', async () => {
    // Setup: Create divergent state
    writeFileSync('.planning/STATE.md', GSD_STATE_PHASE_DECIDE);
    writeFileSync('.sdlc/phases/wi-042/Decide.json', SDLC_STATE_PHASE_PRODUCE);

    // Execute: Run sync
    const adapter = new StateSyncAdapter();
    const report = await adapter.runSync();

    // Verify: Conflict detected
    expect(report.conflicts.length).toBeGreaterThan(0);
    expect(report.conflicts[0].type).toBe('C-PHASE');

    // Verify: Conflict logged
    const conflictLog = JSON.parse(readFileSync('.sdlc/integration/conflict-log.json', 'utf-8'));
    expect(conflictLog.conflicts).toContainEqual(
      expect.objectContaining({ type: 'C-PHASE' })
    );

    // Verify: Sync checkpoint updated
    const syncState = JSON.parse(readFileSync('.sdlc/integration/sync-state.json', 'utf-8'));
    expect(syncState.open_conflicts).toContain(report.conflicts[0].conflict_id);
  });

  test('recover from checkpoint corruption', async () => {
    // Setup: Corrupt checkpoint file
    writeFileSync('.sdlc/integration/sync-state.json', 'invalid json {{{');

    // Execute: Run sync
    const adapter = new StateSyncAdapter();
    const report = await adapter.runSync();

    // Verify: Checkpoint rebuilt
    expect(report.checkpoint_rebuilt).toBe(true);
    expect(existsSync('.sdlc/integration/sync-state.json')).toBe(true);

    // Verify: Full re-sync performed
    expect(report.full_resync).toBe(true);
  });

  test('polling sync with mtime tracking', async () => {
    // Setup: Create files with different mtimes
    const oldTime = new Date('2026-05-26T14:00:00Z');
    const newTime = new Date('2026-05-26T14:30:00Z');

    writeFileSync('.planning/STATE.md', 'old content');
    utimesSync('.planning/STATE.md', oldTime, oldTime);

    // Execute: First sync
    const adapter = new StateSyncAdapter();
    await adapter.runSync();

    // Update: Modify one file
    writeFileSync('.planning/STATE.md', 'new content');
    utimesSync('.planning/STATE.md', newTime, newTime);

    // Execute: Second sync
    const report = await adapter.runSync();

    // Verify: Only new file synced
    expect(report.files_synced).toBe(1);
    expect(report.checkpoints['gsd-to-sdlc'].last_mtime).toBe(newTime.toISOString());
  });
});
```

#### Test Data Files

- `test/fixtures/sync-state-valid.json` — Valid checkpoint file
- `test/fixtures/sync-state-corrupt.json` — Corrupted checkpoint
- `test/fixtures/conflict-log-empty.json` — Empty conflict log
- `test/fixtures/conflict-log-with-conflicts.json` — Log with open conflicts
- `test/mocks/system-states.ts` — Mock state for all four systems

---

### 3.6 Key Algorithms

#### 3.6.1 Conflict Detection Algorithm

```typescript
function detectConflicts(
  gsdState: GsdState,
  sdlcState: SdlcState,
  baState: BaState
): Conflict[] {
  const conflicts: Conflict[] = [];

  // 1. Cross-reference work items
  for (const workItem of union(gsdState.tasks, sdlcState.workItems)) {
    if (!existsInAll(workItem.id, [gsdState, sdlcState])) {
      conflicts.push({
        type: 'C-ORPHAN',
        work_item_id: workItem.id,
        severity: 'non-blocking',
      });
    }
  }

  // 2. Phase alignment check
  for (const wi of sdlcState.workItems) {
    const gsdPhase = gsdState.tasks.find(t => t.id === wi.id)?.phase;
    const sdlcPhase = wi.phase;

    if (gsdPhase && sdlcPhase && gsdPhase !== sdlcPhase) {
      conflicts.push({
        type: 'C-PHASE',
        work_item_id: wi.id,
        canonical_value: sdlcPhase, // AI-in-sdlc owns phase state
        divergent_value: gsdPhase,
        severity: 'blocking',
      });
    }
  }

  // 3. Status alignment check
  for (const wi of sdlcState.workItems) {
    const gsdStatus = gsdState.tasks.find(t => t.id === wi.id)?.status;
    const sdlcStatus = wi.status;

    if (gsdStatus === 'completed' && sdlcStatus !== 'done') {
      conflicts.push({
        type: 'C-STATUS',
        work_item_id: wi.id,
        severity: 'blocking',
      });
    }
  }

  // 4. Artifact version check
  for (const artifact of baState.requirements) {
    const sdlcArtifact = sdlcState.artifacts.find(a => a.artifact_id === artifact.id);
    if (sdlcArtifact && artifact.mtime > sdlcArtifact.mtime + 5 * 60 * 1000) {
      // BA ahead by >5 minutes
      conflicts.push({
        type: 'C-ARTIFACT',
        work_item_id: artifact.id,
        severity: 'non-blocking',
        auto_resolution_eligible: true,
      });
    }
  }

  return conflicts;
}
```

#### 3.6.2 Sync Run Loop

```typescript
async function runSync(): Promise<SyncReport> {
  const report: SyncReport = {
    timestamp: new Date().toISOString(),
    conflicts: [],
    files_synced: 0,
  };

  // 1. Load checkpoint
  let checkpoint = loadCheckpoint();
  if (!checkpoint) {
    checkpoint = await rebuildCheckpoint();
    report.checkpoint_rebuilt = true;
  }

  // 2. Poll all systems for changes
  const gsdChanges = pollGsdChanges(checkpoint);
  const sdlcChanges = pollSdlcChanges(checkpoint);
  const baChanges = pollBaChanges(checkpoint);

  // 3. Detect conflicts
  report.conflicts = detectConflicts(gsdChanges, sdlcChanges, baChanges);

  // 4. Log conflicts
  if (report.conflicts.length > 0) {
    writeConflictLog(report.conflicts);
    updateSyncState({ open_conflicts: report.conflicts.map(c => c.conflict_id) });
  }

  // 5. Apply non-blocking sync
  for (const change of [...gsdChanges, ...sdlcChanges, ...baChanges]) {
    if (!isConflictRelated(change, report.conflicts)) {
      applySync(change);
      report.files_synced++;
    }
  }

  // 6. Update checkpoint
  saveCheckpoint({
    ...checkpoint,
    last_sync: new Date().toISOString(),
  });

  return report;
}
```

#### 3.6.3 Human Gate Resolution

```typescript
async function resolveConflictViaHumanGate(conflict: Conflict): Promise<Resolution> {
  // Present gate to human
  const gatePrompt = buildGatePrompt(conflict);
  const choice = await presentHumanGate(gatePrompt);

  switch (choice) {
    case 'accept_gsd':
      return {
        action: 'adopt_gsd_value',
        target_system: 'ai-in-sdlc',
        value: conflict.gsd_value,
      };

    case 'accept_sdlc':
      return {
        action: 'adopt_sdlc_value',
        target_system: 'gsd-redux',
        value: conflict.sdlc_value,
      };

    case 'merge':
      const mergedValue = await humanDefineMergedValue(conflict);
      return {
        action: 'apply_merge',
        target_systems: ['gsd-redux', 'ai-in-sdlc'],
        value: mergedValue,
      };

    case 'defer':
      return {
        action: 'defer',
        blocks_handoff: true,
      };

    default:
      throw new AdapterError('INVALID_GATE_CHOICE');
  }
}
```

---

## 4. Adapter Test Strategy

### 4.1 Testing Pyramid

```
        /\
       /  \
      / E2E \       ~10% — Full integration across all adapters
     /--------\
    /          \
   / Integration\   ~30% — Adapter-to-adapter contracts
  /--------------\
 /      Unit      \ ~60% — Individual adapter logic
/------------------\
```

### 4.2 Unit Testing (60%)

**Coverage Target**: 90% line coverage per adapter

**Test Types**:
- Parser tests (markdown, YAML, JSON)
- Validation tests (schema, format, completeness)
- Transformation tests (field mapping, checksum computation)
- Error handling tests (all error codes)

**Mocking Strategy**:
- Mock file system operations (`fs.readFileSync`, `fs.writeFileSync`)
- Mock external APIs (OMO `task()`, Jira, Figma)
- Use in-memory data structures for KB state

**Example**:
```typescript
jest.mock('fs', () => ({
  readFileSync: jest.fn(),
  writeFileSync: jest.fn(),
  existsSync: jest.fn(),
}));
```

### 4.3 Integration Testing (30%)

**Coverage Target**: All adapter contracts tested end-to-end

**Test Scenarios**:
1. **GSD→OMO→State**: Task dispatch → execution → feedback loop
2. **BA→Dev→Validation**: Markdown conversion → validation → artifact creation
3. **State Sync Conflict**: Divergent state → detection → human gate → resolution

**Test Fixtures**:
- Complete mock KBs for all four systems
- Pre-populated `.planning/`, `.sdlc/`, `wiki/`, `.sisyphus/` directories
- Known-good and known-bad test data

**Assertions**:
- File system state after adapter run
- Conflict log entries
- Checkpoint updates
- Error log entries

### 4.4 End-to-End Testing (10%)

**Coverage Target**: Critical user journeys

**E2E Scenarios**:

1. **Feature Implementation Flow**
   ```
   BA creates requirement → BA→Dev converts → GSD plans task →
   GSD→OMO dispatches → OMO executes → State Sync updates all
   ```

2. **Conflict Resolution Flow**
   ```
   GSD marks task done → AI-in-sdlc marks blocked →
   State Sync detects C-PHASE → Human gate triggered →
   Human resolves → State propagated
   ```

3. **Version Update Flow**
   ```
   BA updates requirement → BA→Dev detects change →
   New version created → Linked artifacts marked draft →
   State Sync notifies dependent systems
   ```

**Test Environment**:
- Isolated temp directory per test run
- Full adapter stack deployed
- Real file system (not mocked)
- Cleanup after each test

### 4.5 Test Automation

**CI Pipeline Integration**:

```yaml
# .github/workflows/adapter-tests.yml
name: Adapter Tests

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test -- scripts/adapters/__tests__/*.test.ts

  integration-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run test:integration -- adapters

  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run test:e2e -- adapters
```

**Test Data Management**:
- Fixtures versioned in `test/fixtures/`
- Auto-generated test data via scripts
- Snapshot testing for JSON outputs

### 4.6 Manual Testing Checklist

Before each release:

- [ ] Run all unit tests (green)
- [ ] Run all integration tests (green)
- [ ] Run E2E scenarios manually
- [ ] Verify error logs are human-readable
- [ ] Verify conflict gate prompts are clear
- [ ] Test with real BA artifacts from pilot project
- [ ] Test with real GSD PLAN.md from pilot project
- [ ] Verify checkpoint recovery works after crash simulation

---

## 5. Implementation Notes

### 5.1 File Structure

```
scripts/adapters/
├── gsd-omo-adapter.ts          # GSD→OMO implementation
├── ba-dev-adapter.ts           # BA→Dev implementation
├── state-sync-adapter.ts       # State Sync implementation
├── __tests__/
│   ├── gsd-omo-adapter.test.ts
│   ├── ba-dev-adapter.test.ts
│   └── state-sync-adapter.test.ts
└── utils/
    ├── markdown-parser.ts
    ├── yaml-validator.ts
    ├── checksum.ts
    └── conflict-detector.ts
```

### 5.2 Dependencies

```json
{
  "dependencies": {
    "js-yaml": "^4.1.0",
    "node-fetch": "^3.3.0",
    "glob": "^10.0.0"
  },
  "devDependencies": {
    "@types/js-yaml": "^4.0.5",
    "@types/node": "^20.0.0",
    "jest": "^29.0.0",
    "ts-jest": "^29.0.0",
    "typescript": "^5.0.0"
  }
}
```

### 5.3 Runtime Requirements

- Node.js 18+
- Read/write access to `.planning/`, `.sdlc/`, `wiki/` directories
- OMO/OpenCode runtime available (for GSD→OMO)
- Optional: File watcher (e.g., `chokidar`) for real-time sync

### 5.4 Performance Considerations

| Operation | Target Latency | Optimization |
|-----------|---------------|--------------|
| Parse PLAN.md (100 tasks) | <100ms | Cache parsed AST |
| Convert BA artifact | <50ms per artifact | Parallel processing |
| Detect conflicts (1000 work items) | <500ms | Incremental diff |
| Write state feedback | <10ms | Async I/O |
| Full sync run | <5s | Polling interval tuning |

### 5.5 Security Considerations

- **No credentials in adapter code** — Load from env vars or `.sdlc/.env`
- **Validate all file paths** — Prevent path traversal attacks
- **Sanitize markdown content** — Prevent XSS if rendered in UI
- **Rate limit external API calls** — Avoid DDoS on provider endpoints

---

## 6. Acceptance Criteria

| Criterion | Status |
|-----------|--------|
| GSD→OMO adapter spec complete (input, output, errors, tests) | Done |
| BA→Dev adapter spec complete (input, output, errors, tests) | Done |
| State Sync adapter spec complete (input, output, errors, tests) | Done |
| Test strategy documented per adapter | Done |
| Estimated LOC per adapter | Done |
| Key algorithms specified | Done |
| Error handling matrix complete | Done |

---

## 7. Next Steps

1. **Implement GSD→OMO adapter** (Task 14) — ~350 LOC
2. **Implement BA→Dev adapter** (Task 15) — ~280 LOC
3. **Implement State Sync adapter** (Task 16) — ~420 LOC
4. **Write unit tests** (Task 17) — 90% coverage target
5. **Integration test suite** (Task 18) — Full contract coverage
6. **E2E test scenarios** (Task 19) — Critical user journeys

---

## References

- `docs/HANDOFF-CONTRACTS.md` — Handoff contract definitions
- `docs/STATE-SYNC.md` — State synchronization design
- `ARCHITECTURE.md` — Phase model and adapter pattern
- `.sdlc/artifacts/_template-meta.json` — ArtifactVersion schema
- `.sdlc/phases/_template.json` — PhasePacket schema
