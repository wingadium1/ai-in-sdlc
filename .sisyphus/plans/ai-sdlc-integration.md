# AI-SDLC Integration Framework — Architecture Design & Implementation Roadmap

## TL;DR

> **Quick Summary**: Thiết kế kiến trúc tích hợp + roadmap triển khai để kết nối GSD Redux (planning), OMO/OpenCode (execution), AI-in-sdlc (dev skills), và agent-for-ba (BA skills) thành một AI-augmented SDLC framework thống nhất cho toàn bộ team phát triển phần mềm.
> 
> **Deliverables**:
> - Architecture Design Document: topology, handoff contracts, phase mapping, KB ownership
> - Implementation Roadmap: phased plan với validation spikes trước khi build
> - Integration Adapters: file-based handoff giữa các system
> - Safety Mechanisms: circuit breakers, conflict detection, replanning protocol
> 
> **Estimated Effort**: Medium (8-14 ngày)
> **Parallel Execution**: YES — 2 waves
> **Critical Path**: Spike validation → Architecture Design → Adapter Implementation → E2E Validation

---

## Context

### Original Request
Người dùng nghiên cứu cách sử dụng AI cho nhóm dự án phát triển phần mềm: git, confluence/gitbooks, jira/github tasks, OMO, GSD Redux, LLM Wiki. Muốn dựng khung tích hợp tại `/Users/sonht2.gmo/git/AI-in-sdlc`, reference concept và skills từ `agent-for-ba`.

### Interview Summary
**Key Discussions**:
- **Team scope**: Toàn bộ team phát triển phần mềm (BA + PM + Dev + QA + Ops)
- **Output type**: Architecture design + Implementation roadmap (cả hai)
- **GSD role**: GSD Redux làm project planning layer chính
- **OMO role**: OMO/OpenCode cho execution layer
- **Target folder**: `/Users/sonht2.gmo/git/AI-in-sdlc` (đã có framework base)
- **Reference only**: BA skills từ `agent-for-ba`, không sửa code gốc

**Research Findings**:
- **AI-in-sdlc**: Đã có 7-phase SDLC pipeline, 7 dev skills, `.sdlc/` KB, 15 ADRs, roadmap M1→M3 (OpenCode port đã planned)
- **OMO**: 11 specialized agents, skills system, category-based routing. **Đã dùng trong project này qua OpenCode**
- **GSD Redux**: 6-command loop, file-based state (`.planning/`), atomic commits, wave execution, fresh context per agent
- **Jira/Confluence**: Cả OMO và GSD đều không có native API integration. agent-for-ba có `ingest-atlassian` skill read-only
- **GSD vs GSD-build**: CHỈ dùng `open-gsd/get-shit-done-redux` (bản gốc đã compromised)

### Metis Review
**Identified Gaps & How Resolved**:

| Gap | Classification | Resolution |
|-----|---------------|------------|
| Integration topology chưa rõ | **CRITICAL** | → Chọn Convention Layer (B): lightweight file-based adapters, không custom orchestrator |
| State authority hierarchy | **CRITICAL** | → Mỗi system sở hữu KB riêng: `.planning/` (GSD), `wiki/` (BA), `.sdlc/` (Dev). Integration layer sync metadata only |
| BA-to-Dev artifact flow | **CRITICAL** | → File-based handoff với contract rõ ràng. BA output → known location → Dev input |
| Replanning protocol | **CRITICAL** | → Conflict detection + human gate khi plan thay đổi mid-execution |
| Subsystem immutability | Guardrail | → KHÔNG sửa internal của agent-for-ba hoặc GSD |
| TDD strategy | Guardrail | → Mọi integration point phải có test trước implementation |
| Scope creep: unified KB | Guardrail | → KHÔNG tạo unified KB, mỗi system giữ KB riêng |
| Scope creep: custom orchestrator | Guardrail | → Dùng GSD phases + OMO tasks, không build engine mới |
| 7 untested assumptions | Risk | → Validation spikes trong Wave 1 trước khi design |
| 10 edge cases | Risk | → Mapped vào acceptance criteria của từng task |

---

## Work Objectives

### Core Objective
Thiết kế kiến trúc và lộ trình triển khai framework tích hợp AI-augmented SDLC, kết nối 4 system (GSD, OMO, AI-in-sdlc, agent-for-ba) qua convention layer và file-based adapters, cho phép toàn bộ team phát triển phần mềm làm việc với AI từ planning đến execution.

### Concrete Deliverables
- `AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md` — Architecture design document
- `AI-in-sdlc/docs/IMPLEMENTATION-ROADMAP.md` — Phased implementation roadmap
- `AI-in-sdlc/.sdlc/integration/` — Integration adapters và contracts
- `AI-in-sdlc/docs/PHASE-MAPPING.md` — Cross-system phase mapping table
- `AI-in-sdlc/docs/HANDOFF-CONTRACTS.md` — BA-to-Dev, GSD-to-OMO handoff specs
- Validation spike results chứng minh assumptions đúng/sai

### Definition of Done
- [ ] Architecture document hoàn chỉnh với topology, phase mapping, data flow diagrams
- [ ] Handoff contracts được spec rõ (format, location, validation rules)
- [ ] Implementation roadmap với milestones, dependencies, effort estimates
- [ ] Validation spikes chạy thành công (hoặc assumptions được điều chỉnh)
- [ ] Tất cả integration points có test stub
- [ ] Team member bất kỳ có thể đọc architecture doc và hiểu cách các system kết nối

### Must Have
- Architecture topology rõ ràng (Convention Layer model)
- Cross-system phase mapping table
- Handoff contracts cho BA→Dev và GSD→OMO
- Implementation roadmap với 3 milestones min
- Validation spikes cho top 3 assumptions

### Must NOT Have (Guardrails)
- **KHÔNG** sửa code internal của `agent-for-ba/`
- **KHÔNG** sửa code internal của GSD Redux
- **KHÔNG** tạo unified knowledge base (mỗi system giữ KB riêng)
- **KHÔNG** build custom orchestration engine
- **KHÔNG** build UI/dashboard
- **KHÔNG** thêm metric/observability ngoài basic logging
- **KHÔNG** tạo skill mới nếu skill hiện có đã làm được chức năng đó
- **KHÔNG** dùng GSD-build (bản compromised) — chỉ dùng `open-gsd/get-shit-done-redux`

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: YES (cả 4 system đều có test capability)
- **Automated tests**: Tests-after (validation spikes trước, tests trong implementation)
- **Framework**: Bash scripts cho handoff tests, pytest/deno test cho adapter tests
- **Agent-Executed QA**: MANDATORY — mọi task có QA scenarios với tool cụ thể

### QA Policy
- **Architecture docs**: Verify bằng cách đọc file, cross-reference với source
- **Handoff contracts**: Verify bằng script test (đọc output system A → validate format → feed vào system B)
- **Phase mapping**: Verify bằng cách chạy cả 3 system và check state consistency
- **Adapters**: Verify bằng integration test (real system, mock data)

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Discovery & Validation — MAX PARALLEL):
├── Task 1: Validate GSD→OMO handoff feasibility
├── Task 2: Validate BA→Dev artifact flow feasibility
├── Task 3: Validate cross-system file coexistence
└── Task 4: Research & document current conventions

Wave 2 (Architecture Design — after Wave 1):
├── Task 5: Define integration topology & data flow
├── Task 6: Create cross-system phase mapping table
├── Task 7: Design BA→Dev handoff contract
├── Task 8: Design GSD→OMO handoff contract
├── Task 9: Design state synchronization mechanism
└── Task 10: Design safety mechanisms (circuit breakers, conflict detection)

Wave 3 (Implementation Roadmap — after Wave 2):
├── Task 11: Create phased implementation roadmap
├── Task 12: Define milestones, dependencies, effort estimates
├── Task 13: Create adapter implementation specifications
└── Task 14: Final integration architecture document

Critical Path: Task 1-4 → Task 5 → Task 7/8 → Task 11 → Task 14
Parallel Speedup: ~60% faster than sequential
Max Concurrent: 4 (Wave 1)
```

---

## TODOs

- [x] 1. Validate GSD→OMO Handoff Feasibility

  **What to do**:
  - Research GSD PLAN.md format: đọc file PLAN.md từ GSD phase để hiểu cấu trúc task description
  - Research OMO task input format: đọc cách OMO `task()` function nhận prompt và mô tả công việc
  - Tạo spike script: viết script Bash đọc GSD PLAN.md, extract tasks, format thành OMO-compatible prompt
  - Test spike: chạy script và verify OMO có thể hiểu và bắt đầu execution
  - Document findings: ghi lại khả năng và hạn chế của handoff này

  **Must NOT do**:
  - Không implement adapter đầy đủ (chỉ spike)
  - Không sửa GSD hoặc OMO internal code

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Cần research sâu cả hai system, phân tích format, viết spike script
  - **Skills**: [`git-master`]
    - `git-master`: Để đọc GSD repo và hiểu PLAN.md conventions

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 2, 3, 4)
  - **Blocks**: Task 8 (GSD→OMO handoff design)
  - **Blocked By**: None (can start immediately)

  **References**:
  - `AI-in-sdlc/.planning/` (nếu có) — Xem GSD PLAN.md format thực tế
  - `AI-in-sdlc/.sdlc/phases/_template.json` — PhasePacket format của AI-in-sdlc
  - GSD docs: `https://github.com/open-gsd/get-shit-done-redux/blob/next/docs/USER-GUIDE.md` — GSD user guide
  - OMO orchestration: `https://github.com/code-yeongyu/oh-my-openagent/blob/HEAD/docs/guide/orchestration.md` — OMO task format

  **Acceptance Criteria**:
  - [ ] Spike script exists at `AI-in-sdlc/scripts/spike-gsd-omo-handoff.sh`
  - [ ] Script extract được ít nhất 3 tasks từ sample GSD PLAN.md
  - [ ] Script format output đúng OMO prompt convention
  - [ ] Documented findings at `AI-in-sdlc/docs/spikes/gsd-omo-handoff.md`

  **QA Scenarios**:

  ```
  Scenario: Extract tasks from valid PLAN.md
    Tool: Bash (interactive_bash)
    Preconditions: Sample PLAN.md exists with 3+ tasks, script is at AI-in-sdlc/scripts/
    Steps:
      1. Run: bash AI-in-sdlc/scripts/spike-gsd-omo-handoff.sh --input test/fixtures/sample-plan.md
      2. Check exit code = 0
      3. Verify stdout contains 3 task descriptions
      4. Verify each task has OMO-compatible format (title + description)
    Expected Result: Script outputs 3 tasks, exit code 0
    Failure Indicators: Exit code non-zero, less than 3 tasks extracted, tasks missing required fields
    Evidence: .sisyphus/evidence/task-1-spike-handoff.txt

  Scenario: Handle malformed PLAN.md gracefully
    Tool: Bash (interactive_bash)
    Preconditions: Malformed PLAN.md with missing sections
    Steps:
      1. Run: bash AI-in-sdlc/scripts/spike-gsd-omo-handoff.sh --input test/fixtures/malformed-plan.md
      2. Check exit code != 0 (should fail gracefully)
      3. Verify stderr contains clear error message about what's malformed
    Expected Result: Script exits with error, clear message on stderr
    Evidence: .sisyphus/evidence/task-1-spike-malformed.txt
  ```

  **Commit**: YES
  - Message: `[int] spike: GSD-to-OMO handoff feasibility validation`
  - Files: `AI-in-sdlc/scripts/spike-gsd-omo-handoff.sh`, `AI-in-sdlc/docs/spikes/gsd-omo-handoff.md`, test fixtures

- [x] 2. Validate BA→Dev Artifact Flow Feasibility

  **What to do**:
  - Analyze agent-for-ba output format: đọc sample output từ `research-domain`, `generate-highlevel-req`, `generate-detailed-req` skills
  - Analyze AI-in-sdlc input format: đọc AI-in-sdlc skill files để hiểu chúng expect input gì
  - Tạo spike script: viết converter từ BA output format → Dev input format
  - Test spike: dùng sample BA output, convert, verify Dev skill có thể consume
  - Document findings: ghi lại format gaps và mapping rules

  **Must NOT do**:
  - Không sửa agent-for-ba skills
  - Không implement full converter (chỉ spike)

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Cần phân tích output format của BA skills và input format của Dev skills
  - **Skills**: [`analyze-requirements`]
    - `analyze-requirements`: Hiểu cấu trúc requirement artifacts để map chính xác

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 3, 4)
  - **Blocks**: Task 7 (BA→Dev handoff design)
  - **Blocked By**: None (can start immediately)

  **References**:
  - `agent-for-ba/.opencode/skills/generate-highlevel-req/SKILL.md` — BA high-level req output format
  - `agent-for-ba/.opencode/skills/generate-detailed-req/SKILL.md` — BA detailed req output format
  - `agent-for-ba/wiki/projects/hcplatform/` — Sample BA artifacts (overview, requirements)
  - `AI-in-sdlc/runtime/copilot/.github/skills/start-feature/SKILL.md` — Dev skill input format
  - `AI-in-sdlc/runtime/copilot/.github/skills/update-requirements/SKILL.md` — Dev req skill input

  **Acceptance Criteria**:
  - [ ] Spike script exists at `AI-in-sdlc/scripts/spike-ba-dev-artifact-flow.sh`
  - [ ] Script convert được BA output → Dev input format cho ít nhất 2 loại artifact
  - [ ] Documented format gaps và mapping rules
  - [ ] Documented findings at `AI-in-sdlc/docs/spikes/ba-dev-artifact-flow.md`

  **QA Scenarios**:

  ```
  Scenario: Convert BA high-level req to Dev input
    Tool: Bash (interactive_bash)
    Preconditions: Sample BA high-level req exists, converter script exists
    Steps:
      1. Run: bash AI-in-sdlc/scripts/spike-ba-dev-artifact-flow.sh --input test/fixtures/sample-ba-hlr.md --type high-level-req
      2. Check exit code = 0
      3. Verify output contains structured requirement fields (title, actors, steps, acceptance criteria)
      4. Verify output format matches AI-in-sdlc requirement artifact schema
    Expected Result: Converted output valid, exit code 0
    Evidence: .sisyphus/evidence/task-2-spike-ba-hlr.txt

  Scenario: Detect unmappable BA fields
    Tool: Bash (interactive_bash)
    Preconditions: BA output with fields not supported by Dev input format
    Steps:
      1. Run converter with BA output containing unsupported fields (e.g., PlantUML diagrams)
      2. Verify stderr lists unmappable fields with warnings
      3. Verify output still contains mappable fields (graceful degradation)
    Expected Result: Warnings on stderr, partial conversion succeeds
    Evidence: .sisyphus/evidence/task-2-spike-unmappable.txt
  ```

  **Commit**: YES
  - Message: `[int] spike: BA-to-Dev artifact flow feasibility validation`
  - Files: `AI-in-sdlc/scripts/spike-ba-dev-artifact-flow.sh`, `AI-in-sdlc/docs/spikes/ba-dev-artifact-flow.md`, test fixtures

- [x] 3. Validate Cross-System File Coexistence

  **What to do**:
  - Analyze directory conventions: kiểm tra `.planning/`, `.sdlc/`, `wiki/` structures
  - Check naming conflicts: verify không có file/folder name collision giữa các system
  - Check gitignore compatibility: verify `.gitignore` rules không xung đột
  - Test coexistence: tạo test repo với cả 3 KB directories, verify mỗi system đọc/ghi đúng
  - Document conventions: ghi lại rules để các system không ghi đè lên nhau

  **Must NOT do**:
  - Không merge các KB directories vào một
  - Không thay đổi internal structure của bất kỳ system nào

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Chủ yếu là file system analysis và kiểm tra conventions
  - **Skills**: [`git-master`]
    - `git-master`: Để kiểm tra gitignore rules và git conventions

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 2, 4)
  - **Blocks**: Task 5 (integration topology)
  - **Blocked By**: None (can start immediately)

  **References**:
  - `AI-in-sdlc/.sdlc/` — SDLC knowledge base structure
  - `agent-for-ba/wiki/` — LLM Wiki structure
  - `AI-in-sdlc/.planning/` (nếu có) — GSD planning directory
  - `AI-in-sdlc/.gitignore` — Current gitignore rules
  - `agent-for-ba/.gitignore` — BA project gitignore rules

  **Acceptance Criteria**:
  - [ ] Directory coexistence analysis at `AI-in-sdlc/docs/spikes/directory-coexistence.md`
  - [ ] No file/folder name collisions detected (hoặc conflicts đã documented)
  - [ ] Test repo verified: mỗi system đọc/ghi đúng KB của nó
  - [ ] Recommended `.gitignore` rules documented

  **QA Scenarios**:

  ```
  Scenario: Verify no directory name conflicts
    Tool: Bash (interactive_bash)
    Preconditions: AI-in-sdlc repo with .sdlc/ and .planning/ directories
    Steps:
      1. Run: ls -d .planning/ .sdlc/ wiki/ 2>&1
      2. Verify all three directories can exist simultaneously
      3. Run: find .planning/ .sdlc/ -name "*.json" | sort — verify no identical paths
    Expected Result: All directories coexist, no path collisions
    Evidence: .sisyphus/evidence/task-3-coexistence.txt

  Scenario: Verify system isolation — GSD writes don't touch .sdlc/
    Tool: Bash (interactive_bash)
    Preconditions: Test fixtures in each directory
    Steps:
      1. Simulate GSD write: echo "test" > .planning/test-state.md
      2. Verify: cat .sdlc/config.json — content unchanged
      3. Simulate AI-in-sdlc write: echo '{"test":true}' > .sdlc/test.json
      4. Verify: cat .planning/test-state.md — content unchanged
    Expected Result: Each system only modifies its own directory
    Evidence: .sisyphus/evidence/task-3-isolation.txt
  ```

  **Commit**: YES
  - Message: `[int] spike: cross-system file coexistence validation`
  - Files: `AI-in-sdlc/docs/spikes/directory-coexistence.md`

- [x] 4. Research & Document Current Conventions

  **What to do**:
  - Document GSD conventions: `.planning/` structure, PLAN.md format, STATE.md format, commit strategy
  - Document OMO conventions: task format, skill loading, category system, boulder.json state
  - Document AI-in-sdlc conventions: `.sdlc/` schema, PhasePacket format, skill structure, model routing
  - Document agent-for-ba conventions: wiki/ format (frontmatter, wikilinks, index.md), skill trigger phrases
  - Create comparison matrix: format, naming, state management, commit strategy per system

  **Must NOT do**:
  - Không copy-paste toàn bộ docs (chỉ summary + reference links)
  - Không propose thay đổi conventions (observation only)

  **Recommended Agent Profile**:
  - **Category**: `writing`
    - Reason: Chủ yếu là documentation và synthesis từ research
  - **Skills**: [] (no specific skills needed)

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 2, 3)
  - **Blocks**: Task 5 (integration topology), Task 6 (phase mapping)
  - **Blocked By**: None (can start immediately)

  **References**:
  - `AI-in-sdlc/ARCHITECTURE.md` — AI-in-sdlc architecture (PhasePacket, KnowledgeAdapter, ProviderAdapter)
  - `AI-in-sdlc/DECISIONS.md` — 15 ADRs với conventions
  - `AI-in-sdlc/ROADMAP.md` — Roadmap với milestone conventions
  - `agent-for-ba/wiki/index.md` — Wiki catalog conventions
  - `agent-for-ba/.github/copilot/AGENTS.md` — BA agent conventions (wiki format, commit format, log format)
  - GSD architecture: `https://github.com/open-gsd/get-shit-done-redux/blob/next/docs/ARCHITECTURE.md`
  - OMO features: `https://github.com/code-yeongyu/oh-my-openagent/blob/HEAD/docs/reference/features.md`

  **Acceptance Criteria**:
  - [ ] Conventions document at `AI-in-sdlc/docs/spikes/system-conventions.md`
  - [ ] Each system có section: directory structure, file format, naming conventions, state management, commit strategy, skill/task format
  - [ ] Comparison matrix shows differences và potential conflicts
  - [ ] Reference links to original docs for each system

  **QA Scenarios**:

  ```
  Scenario: Verify document covers all 4 systems
    Tool: Bash (interactive_bash)
    Preconditions: Document exists at AI-in-sdlc/docs/spikes/system-conventions.md
    Steps:
      1. Run: grep -c "^## " AI-in-sdlc/docs/spikes/system-conventions.md
      2. Verify count >= 4 (one section per system)
      3. Run: grep -c "Comparison Matrix" AI-in-sdlc/docs/spikes/system-conventions.md
      4. Verify count >= 1
    Expected Result: Document has >= 4 system sections + comparison matrix
    Evidence: .sisyphus/evidence/task-4-conventions.txt
  ```

  **Commit**: YES
  - Message: `[docs] research: cross-system conventions documentation`
  - Files: `AI-in-sdlc/docs/spikes/system-conventions.md`

- [x] 5. Define Integration Topology & Data Flow

  **What to do**:
  - Synthesize spike results từ Tasks 1-4 để chọn topology model
  - Chọn Convention Layer (B): lightweight file-based adapters, không custom orchestrator
  - Create Mermaid data flow diagram: how artifacts flow between 4 systems
  - Define integration directory: `AI-in-sdlc/.sdlc/integration/{adapters,contracts,sync}`
  - Define adapter interfaces: GSD→OMO, BA→Dev, State Sync
  - Document topology decision with rationale

  **Must NOT do**:
  - Không define custom orchestrator engine
  - Không propose unified KB schema

  **Recommended Agent Profile**:
  - **Category**: `deep` — Architecture decision cần phân tích trade-offs
  - **Skills**: [] (analysis-heavy, no external tools needed)

  **Parallelization**:
  - **Can Run In Parallel**: NO (must complete first — all other Wave 2 tasks depend on it)
  - **Parallel Group**: Wave 2 (sequential — then Tasks 6-10 can parallel)
  - **Blocks**: Tasks 6, 7, 8, 9, 10
  - **Blocked By**: Tasks 1, 2, 3, 4 (spike results)

  **References**:
  - `AI-in-sdlc/docs/spikes/` — Task 1-4 outputs
  - `AI-in-sdlc/ARCHITECTURE.md` §2-5 — Adapter patterns, KB, providers
  - `AI-in-sdlc/DECISIONS.md#ADR-002` — KnowledgeBase adapter pattern

  **Acceptance Criteria**:
  - [ ] Architecture doc at `AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md` with Topology section
  - [ ] Mermaid flowchart showing data flow between all 4 systems + integration layer
  - [ ] Integration directory structure spec
  - [ ] Adapter interface definitions (input/output contracts per adapter)

  **QA Scenarios**:
  ```
  Scenario: Verify topology document completeness
    Tool: Bash
    Steps:
      1. grep -c "Topology" AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md → >= 1
      2. grep -c "Mermaid\|flowchart" AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md → >= 1
      3. grep -c "Adapter" AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md → >= 3
    Expected Result: Topology section + diagram + 3+ adapter references
    Evidence: .sisyphus/evidence/task-5-topology.txt
  ```

  **Commit**: YES
  - Message: `[int] design: integration topology & data flow`
  - Files: `AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md`

- [x] 6. Create Cross-System Phase Mapping Table

  **What to do**:
  - Map GSD phases → AI-in-sdlc 7-phase pipeline → BA 5-step pipeline
  - Cover variations: greenfield (full), brownfield (reconstruct-architecture), backend-only (no UI)
  - Define phase skip rules và minimum viable path per scenario
  - Document human gates at phase transitions

  **Recommended Agent Profile**:
  - **Category**: `deep` — Cần hiểu sâu phase models của cả 3 system
  - **Skills**: [`write-brd`]

  **Parallelization**: YES | Wave 2 (after Task 5, with Tasks 7-10) | Blocks: Task 11 | Blocked By: Task 5
  **References**: `AI-in-sdlc/ARCHITECTURE.md` §1, `AI-in-sdlc/DECISIONS.md#ADR-001`, agent-for-ba README §6

  **Acceptance Criteria**:
  - [ ] `AI-in-sdlc/docs/PHASE-MAPPING.md` with 3-system mapping table
  - [ ] 3+ scenario variations documented
  - [ ] Phase skip rules + human gate points mapped

  **QA Scenarios**:
  ```
  Scenario: All 3 systems referenced
    Tool: Bash
    Steps: grep -c "GSD\|AI-in-sdlc\|BA" AI-in-sdlc/docs/PHASE-MAPPING.md → each >= 3
    Evidence: .sisyphus/evidence/task-6-phase-mapping.txt
  ```

  **Commit**: YES | `[int] design: cross-system phase mapping` | `AI-in-sdlc/docs/PHASE-MAPPING.md`

- [x] 7. Design BA→Dev Handoff Contract

  **What to do**:
  - Spec: BA artifact types → AI-in-sdlc artifact types mapping
  - Location mapping: where BA writes, where Dev discovers
  - Validation rules: minimum fields per artifact for Dev to proceed
  - Sync protocol: requirement changes → downstream invalidation

  **Recommended Agent Profile**:
  - **Category**: `writing` — Spec writing dựa trên spike results
  - **Skills**: [`generate-detailed-req`, `write-brd`]

  **Parallelization**: YES | Wave 2 (after Task 5, with Tasks 6,8,9,10) | Blocked By: Task 5 + Task 2
  **References**: `AI-in-sdlc/docs/spikes/ba-dev-artifact-flow.md`, `AI-in-sdlc/.sdlc/artifacts/`, agent-for-ba `wiki/craft/`

  **Acceptance Criteria**:
  - [ ] `AI-in-sdlc/docs/HANDOFF-CONTRACTS.md` §BA→Dev
  - [ ] Format mapping: requirement, UI spec, test case → Dev artifact types
  - [ ] Validation rules + sync protocol

  **QA Scenarios**:
  ```
  Scenario: Covers all BA artifact types
    Tool: Bash
    Steps: grep "requirement\|UI spec\|test case" AI-in-sdlc/docs/HANDOFF-CONTRACTS.md → each >= 1
    Evidence: .sisyphus/evidence/task-7-handoff-ba-dev.txt
  ```

  **Commit**: YES | `[int] design: BA-to-Dev handoff contract` | `AI-in-sdlc/docs/HANDOFF-CONTRACTS.md`

- [x] 8. Design GSD→OMO Handoff Contract

  **What to do**:
  - Task mapping: GSD PLAN.md task fields → OMO task() parameters
  - Dependency handling: GSD waves → OMO run_in_background/sequencing
  - State feedback: OMO execution results → GSD STATE.md updates

  **Recommended Agent Profile**:
  - **Category**: `deep` — Cần hiểu cả GSD task model và OMO execution model
  - **Skills**: [`git-master`]

  **Parallelization**: YES | Wave 2 (after Task 5, with Tasks 6,7,9,10) | Blocked By: Task 5 + Task 1
  **References**: `AI-in-sdlc/docs/spikes/gsd-omo-handoff.md`, `AI-in-sdlc/docs/spikes/system-conventions.md`

  **Acceptance Criteria**:
  - [ ] `AI-in-sdlc/docs/HANDOFF-CONTRACTS.md` §GSD→OMO
  - [ ] Task field mapping table + dependency/wave mapping
  - [ ] Result feedback protocol

  **QA Scenarios**:
  ```
  Scenario: References PLAN.md and task()
    Tool: Bash
    Steps: grep "PLAN.md\|task()" AI-in-sdlc/docs/HANDOFF-CONTRACTS.md → each >= 1
    Evidence: .sisyphus/evidence/task-8-handoff-gsd-omo.txt
  ```

  **Commit**: YES | `[int] design: GSD-to-OMO handoff contract` | `AI-in-sdlc/docs/HANDOFF-CONTRACTS.md`

- [x] 9. Design State Synchronization Mechanism

  **What to do**:
  - Define canonical state: which system owns what state
  - Design sync rules: when and how state propagates between systems
  - Define conflict detection: how to detect when systems disagree on phase/status
  - Define conflict resolution: human gate for conflicts

  **Recommended Agent Profile**:
  - **Category**: `deep` — State management needs careful design
  - **Skills**: []

  **Parallelization**: YES | Wave 2 (after Task 5, with Tasks 6,7,8,10) | Blocked By: Task 5
  **References**: `AI-in-sdlc/docs/spikes/system-conventions.md`, `AI-in-sdlc/ARCHITECTURE.md` §4

  **Acceptance Criteria**:
  - [ ] `AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md` §State Sync
  - [ ] State ownership matrix per system
  - [ ] Sync rules + conflict detection/resolution protocol

  **QA Scenarios**:
  ```
  Scenario: State ownership defined
    Tool: Bash
    Steps: grep "owns\|authority\|canonical" AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md → >= 3
    Evidence: .sisyphus/evidence/task-9-state-sync.txt
  ```

  **Commit**: YES | `[int] design: state synchronization mechanism` | `AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md`

- [x] 10. Design Safety Mechanisms

  **What to do**:
  - Define circuit breakers: max autonomous phases, stop conditions
  - Define replanning detection: how to detect mid-execution plan changes
  - Define rollback protocol: how to safely revert to previous state
  - Define ultrawork bounds: what /ulw-loop can/cannot do

  **Recommended Agent Profile**:
  - **Category**: `deep` — Safety needs careful thinking about failure modes
  - **Skills**: []

  **Parallelization**: YES | Wave 2 (after Task 5, with Tasks 6,7,8,9) | Blocked By: Task 5
  **References**: `AI-in-sdlc/DECISIONS.md#ADR-010` (human gates), `AI-in-sdlc/ARCHITECTURE.md` §7

  **Acceptance Criteria**:
  - [ ] `AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md` §Safety
  - [ ] Circuit breaker rules + replanning detection + rollback protocol
  - [ ] Ultrawork bounds documented

  **QA Scenarios**:
  ```
  Scenario: Safety mechanisms documented
    Tool: Bash
    Steps: grep "circuit breaker\|replan\|rollback\|ultrawork" AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md → each >= 1
    Evidence: .sisyphus/evidence/task-10-safety.txt
  ```

  **Commit**: YES | `[int] design: safety mechanisms` | `AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md`

- [x] 11. Create Phased Implementation Roadmap

  **What to do**:
  - Synthesize all design decisions from Tasks 5-10 into implementation phases
  - Define milestones: M1 (COPILOT MVP) → M2 (CLAUDE CODE) → M3 (OPENCODE)
  - Map each milestone to deliverables và success criteria
  - Create dependency graph giữa các milestones
  - Estimate effort: story points hoặc person-days per milestone

  **Recommended Agent Profile**:
  - **Category**: `writing` — Roadmap synthesis từ design outputs
  - **Skills**: [`write-brd`]

  **Parallelization**: YES | Wave 3 (after Wave 2, with Tasks 12, 13) | Blocks: Task 14 | Blocked By: Tasks 6, 7, 8
  **References**: `AI-in-sdlc/ROADMAP.md`, `AI-in-sdlc/DECISIONS.md`, `AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md`

  **Acceptance Criteria**:
  - [ ] `AI-in-sdlc/docs/IMPLEMENTATION-ROADMAP.md`
  - [ ] 3+ milestones defined with deliverables per milestone
  - [ ] Dependency graph between milestones
  - [ ] Effort estimates per milestone

  **QA Scenarios**:
  ```
  Scenario: Roadmap has milestones with deliverables
    Tool: Bash
    Steps: grep -c "Milestone\|M[0-9]" AI-in-sdlc/docs/IMPLEMENTATION-ROADMAP.md → >= 3
    Expected Result: 3+ milestones documented
    Evidence: .sisyphus/evidence/task-11-roadmap.txt
  ```

  **Commit**: YES | `[int] plan: implementation roadmap` | `AI-in-sdlc/docs/IMPLEMENTATION-ROADMAP.md`

- [x] 12. Define Milestone Dependencies & Effort Estimates

  **What to do**:
  - Detail per-milestone: specific tasks, dependencies, effort (person-days)
  - Identify critical path across all milestones
  - Identify risks & mitigation per milestone
  - Define milestone completion criteria

  **Recommended Agent Profile**:
  - **Category**: `deep` — Cần ước lượng effort và phân tích dependencies
  - **Skills**: []

  **Parallelization**: YES | Wave 3 (with Tasks 11, 13) | Blocked By: Task 11
  **References**: `AI-in-sdlc/ROADMAP.md`, `AI-in-sdlc/docs/IMPLEMENTATION-ROADMAP.md`

  **Acceptance Criteria**:
  - [ ] Per-milestone task breakdown in roadmap
  - [ ] Critical path identified
  - [ ] Risk register per milestone
  - [ ] Completion criteria per milestone

  **QA Scenarios**:
  ```
  Scenario: Critical path and risks identified
    Tool: Bash
    Steps: grep "critical path\|risk\|effort\|person-day" AI-in-sdlc/docs/IMPLEMENTATION-ROADMAP.md → each >= 1
    Evidence: .sisyphus/evidence/task-12-dependencies.txt
  ```

  **Commit**: YES | `[int] plan: milestone dependencies & estimates` | `AI-in-sdlc/docs/IMPLEMENTATION-ROADMAP.md`

- [x] 13. Create Adapter Implementation Specifications

  **What to do**:
  - Write detailed specs for 3 adapters: GSD→OMO, BA→Dev, State Sync
  - Per adapter: input format, output format, error handling, test cases
  - Include implementation notes: which files, estimated LOC, key algorithms
  - Define adapter test strategy

  **Recommended Agent Profile**:
  - **Category**: `writing` — Technical spec writing
  - **Skills**: [`generate-detailed-req`]

  **Parallelization**: YES | Wave 3 (with Tasks 11, 12) | Blocked By: Tasks 7, 8, 9
  **References**: Tasks 7, 8, 9 outputs (handoff contracts, state sync design)

  **Acceptance Criteria**:
  - [ ] Adapter specs in `AI-in-sdlc/docs/HANDOFF-CONTRACTS.md` §Implementation
  - [ ] Per-adapter: input/output format, error handling, test strategy
  - [ ] Estimated LOC per adapter

  **QA Scenarios**:
  ```
  Scenario: All 3 adapters specified
    Tool: Bash
    Steps: grep "GSD→OMO\|BA→Dev\|State Sync" AI-in-sdlc/docs/HANDOFF-CONTRACTS.md → each >= 1
    Evidence: .sisyphus/evidence/task-13-adapter-specs.txt
  ```

  **Commit**: YES | `[int] spec: adapter implementation specifications` | `AI-in-sdlc/docs/HANDOFF-CONTRACTS.md`

- [x] 14. Final Integration Architecture Document

  **What to do**:
  - Compile all sections into final `ARCHITECTURE-INTEGRATION.md`
  - Cross-reference all design decisions with ADRs
  - Create executive summary for stakeholder presentation
  - Add "Getting Started" guide for new team members
  - Verify all references are valid (file paths exist)

  **Recommended Agent Profile**:
  - **Category**: `writing` — Final documentation assembly
  - **Skills**: [`review-document`]

  **Parallelization**: NO | Wave 3 (sequential — final compilation) | Blocked By: Tasks 5-13 (ALL)
  **References**: ALL previous task outputs

  **Acceptance Criteria**:
  - [ ] Final `AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md` complete
  - [ ] All sections cross-referenced
  - [ ] Executive summary present
  - [ ] All file path references verified valid
  - [ ] `AI-in-sdlc/docs/IMPLEMENTATION-ROADMAP.md` complete

  **QA Scenarios**:
  ```
  Scenario: Architecture document is self-contained
    Tool: Bash
    Steps: 
      1. wc -l AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md → >= 200 lines
      2. grep "Executive Summary\|Getting Started\|Topology\|Phase Mapping\|Handoff\|Safety" AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md → each >= 1
    Evidence: .sisyphus/evidence/task-14-final.txt

  Scenario: All referenced files exist
    Tool: Bash
    Steps: for each file path reference in ARCHITECTURE-INTEGRATION.md, verify: ls <path> succeeds
    Evidence: .sisyphus/evidence/task-14-refs.txt
  ```

  **Commit**: YES | `[int] docs: final integration architecture & roadmap` | `AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md`, `AI-in-sdlc/docs/IMPLEMENTATION-ROADMAP.md`, `AI-in-sdlc/docs/PHASE-MAPPING.md`, `AI-in-sdlc/docs/HANDOFF-CONTRACTS.md`

---
- [x] 5. Define Integration Topology & Data Flow
  **What to do**: Synthesize spike results, choose Convention Layer topology, create Mermaid data flow diagram, define KB ownership matrix, write ADRs. Output: `AI-in-sdlc/docs/INTEGRATION-TOPOLOGY.md`
  **Must NOT do**: No custom orchestrator, no unified KB. **Category**: `deep`. **Parallel**: Wave 2 (with 6-10), blocked by 1-4. **Commit**: `[int] design: integration topology`

- [x] 6. Create Cross-System Phase Mapping Table
  **What to do**: Map GSD phases ↔ AI-in-sdlc phases ↔ BA steps, define skip rules, transition rules. Output: `AI-in-sdlc/docs/PHASE-MAPPING.md`
  **Category**: `deep`. **Parallel**: Wave 2. **Commit**: `[int] design: phase mapping`

- [x] 7. Design BA→Dev Handoff Contract
  **What to do**: Define artifact type mappings, file location convention, validation rules, versioning. Output: `AI-in-sdlc/docs/HANDOFF-CONTRACTS.md` (BA→Dev section)
  **Category**: `deep`, skill: `analyze-requirements`. **Parallel**: Wave 2. **Commit**: `[int] design: BA-Dev handoff`

- [x] 8. Design GSD→OMO Handoff Contract
  **What to do**: Define PLAN.md→task() mapping, wave→parallel mapping, result feedback protocol. Output: `AI-in-sdlc/docs/HANDOFF-CONTRACTS.md` (GSD→OMO section)
  **Category**: `deep`, skill: `git-master`. **Parallel**: Wave 2. **Commit**: `[int] design: GSD-OMO handoff`

- [x] 9. Design State Synchronization Mechanism
  **What to do**: Define STATE.md sync rules, conflict detection, replanning protocol, phase state agreement check. Output: `AI-in-sdlc/docs/STATE-SYNC.md`
  **Category**: `deep`. **Parallel**: Wave 2. **Commit**: `[int] design: state sync`

- [x] 10. Design Safety Mechanisms
  **What to do**: Define circuit breakers, max-autonomy bounds, log requirements, rollback protocol, human gate points. Output: `AI-in-sdlc/docs/SAFETY-MECHANISMS.md`
  **Category**: `deep`. **Parallel**: Wave 2. **Commit**: `[int] design: safety mechanisms`

- [x] 11. Create Phased Implementation Roadmap
  **What to do**: Define milestones (3 min), dependencies, effort estimates. M1: Convention Layer + Handoff Adapters, M2: State Sync + Safety, M3: E2E Pipeline + Team Onboarding. Output: `AI-in-sdlc/docs/IMPLEMENTATION-ROADMAP.md`
  **Category**: `deep`. **Parallel**: Wave 3 (with 12-13), blocked by 5-10. **Commit**: `[docs] roadmap: implementation plan`

- [ ] 12. Define Adapter Implementation Specs
  **What to do**: Spec GSD→OMO adapter, BA→Dev artifact adapter, State sync adapter — input/output contracts, error handling, test strategy. Output: `AI-in-sdlc/.sdlc/integration/adapters/README.md`
  **Category**: `writing`. **Parallel**: Wave 3. **Commit**: `[int] spec: adapter implementations`

- [ ] 13. Create Integration Test Strategy
  **What to do**: Define contract tests, subsystem isolation tests, E2E flow tests, safety boundary tests. Output: `AI-in-sdlc/docs/INTEGRATION-TEST-STRATEGY.md`
  **Category**: `writing`. **Parallel**: Wave 3. **Commit**: `[test] strategy: integration testing`

- [ ] 14. Final Architecture Document Assembly
  **What to do**: Combine all docs into cohesive `ARCHITECTURE-INTEGRATION.md`, add TOC, cross-references, executive summary. Output: `AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md` (final)
  **Category**: `writing`. **Parallel**: Wave 3 (after all others). **Commit**: `[docs] final: integration architecture document`

---

## Final Verification Wave

- [ ] F1. **Document Completeness Audit** — `oracle`
  Verify all 10+ design documents exist, cross-reference each other, no dead links. Check all 4 systems documented, all handoff contracts defined, phase mapping complete.
  Output: `Docs [N/N exist] | Cross-refs [N/N valid] | Coverage [N/N systems] | VERDICT`

- [ ] F2. **Guardrail Compliance Check** — `unspecified-high`
  Search for forbidden patterns: unified KB proposals, custom orchestrator mentions, agent-for-ba internal modifications, GSD internal modifications, compromised GSD-build references.
  Output: `Guardrails [N/N passed] | Violations [N] | VERDICT`

- [ ] F3. **Phase Mapping Consistency** — `deep`
  Verify phase mapping: no deadlocks (circular deps), all phases have entry/exit criteria, all human gates explicitly defined. Test with 3 scenarios: greenfield, brownfield, backend-only.
  Output: `Scenarios [N/N valid] | Deadlocks [N] | VERDICT`

- [ ] F4. **Implementation Feasibility Check** — `oracle`
  Verify implementation roadmap: milestones realistic, effort estimates reasonable, dependencies valid (no impossible ordering), spike results align with architecture decisions.
  Output: `Feasibility [PASS/FAIL] | Risks [listed] | VERDICT: APPROVE/REJECT`

---

## Commit Strategy

- **Wave 1**: `[int] spike:` hoặc `[docs] research:` — validation scripts + findings
- **Wave 2**: `[int] design:` — architecture documents
- **Wave 3**: `[docs] roadmap:`, `[int] spec:`, `[test] strategy:` — implementation docs

## Success Criteria

### Verification Commands
```bash
# All design docs exist
ls AI-in-sdlc/docs/INTEGRATION-TOPOLOGY.md AI-in-sdlc/docs/PHASE-MAPPING.md AI-in-sdlc/docs/HANDOFF-CONTRACTS.md AI-in-sdlc/docs/IMPLEMENTATION-ROADMAP.md AI-in-sdlc/docs/ARCHITECTURE-INTEGRATION.md

# No compromised references
grep -r "gsd-build\|get-shit-done-cc" AI-in-sdlc/docs/ && echo "FAIL" || echo "PASS"

# All 4 systems referenced
grep -l "GSD\|OMO\|AI-in-sdlc\|agent-for-ba" AI-in-sdlc/docs/*.md | wc -l
```

### Final Checklist
- [ ] Architecture topology defined (Convention Layer model)
- [ ] Phase mapping covers all 3 systems
- [ ] BA→Dev handoff contract specified
- [ ] GSD→OMO handoff contract specified 
- [ ] State sync protocol defined
- [ ] Safety mechanisms designed
- [ ] Implementation roadmap with 3+ milestones
- [ ] All guardrails respected (no internal modifications, no unified KB)
- [ ] All Metis-identified gaps addressed
  **What to do**:
  - Synthesize spike results từ Tasks 1-4
  - Choose integration topology (Convention Layer B per Metis recommendation)
  - Define data flow diagram: mô tả cách artifacts flow từ GSD→OMO, BA→Dev
  - Define KB ownership: `.planning/` (GSD), `wiki/` (BA), `.sdlc/` (Dev), integration metadata in `AI-in-sdlc/.sdlc/integration/`
  - Create Mermaid/Excalidraw diagram showing system interactions
  - Document decisions as ADRs (theo pattern của AI-in-sdlc DECISIONS.md)

  **Must NOT do**:
  - Không propose custom orchestrator
  - Không merge KB directories

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Architecture decision cần phân tích sâu trade-offs
  - **Skills**: [] (no specific skills needed)

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 6, 7, 8, 9, 10) — nhưng nên chạy Task 5 trước vì các task khác depend
  - **Blocks**: Task 11 (implementation roadmap), Task 14 (final doc)
  - **Blocked By**: Tasks 1, 2, 3, 4 (spike results)

  **References**:
  - `AI-in-sdlc/docs/spikes/system-conventions.md` (Task 4 output)
  - `AI-in-sdlc/docs/spikes/gsd-omo-handoff.md` (Task 1 output)
  - `AI-in-sdlc/docs/spikes/ba-dev-artifact-flow.md` (Task 2 output)
  - `AI-in-sdlc/docs/spikes/directory-coexistence.md` (Task 3 output)
  - `AI-in-sdlc/DECISIONS.md` — ADR format template
  - `AI-in-sdlc/ARCHITECTURE.md` — Current architecture for reference

  **Acceptance Criteria**:
  - [ ] Integration topology document at `AI-in-sdlc/docs/INTEGRATION-TOPOLOGY.md`
  - [ ] Contains Mermaid/Excalidraw data flow diagram
  - [ ] Contains KB ownership matrix
  - [ ] Contains at least 3 new ADRs (architecture decisions for integration)
  - [ ] Decisions aligned với Metis guardrails

  **QA Scenarios**:

  ```
  Scenario: Data flow diagram is valid and complete
    Tool: Bash (interactive_bash)
    Preconditions: Document exists
    Steps:
      1. Run: grep -c "graph\|flowchart\|sequenceDiagram" AI-in-sdlc/docs/INTEGRATION-TOPOLOGY.md
      2. Verify count >= 1 (at least one diagram)
      3. Run: grep -c "GSD\|OMO\|AI-in-sdlc\|agent-for-ba" AI-in-sdlc/docs/INTEGRATION-TOPOLOGY.md
      4. Verify all 4 systems mentioned in document
    Expected Result: Diagram present, all 4 systems referenced
    Evidence: .sisyphus/evidence/task-5-topology.txt

  Scenario: KB ownership is explicitly assigned
    Tool: Bash (interactive_bash)
    Preconditions: Document exists
    Steps:
      1. Run: grep -A2 "KB Ownership\|Knowledge Base Ownership" AI-in-sdlc/docs/INTEGRATION-TOPOLOGY.md
      2. Verify each of .planning/, wiki/, .sdlc/ has a clear owner
    Expected Result: All 3 KB directories assigned to specific systems
    Evidence: .sisyphus/evidence/task-5-kb-ownership.txt
  ```

  **Commit**: YES
  - Message: `[int] design: integration topology and data flow architecture`
  - Files: `AI-in-sdlc/docs/INTEGRATION-TOPOLOGY.md`

- [x] 6. Create Cross-System Phase Mapping Table

  **What to do**:
  - Map GSD phases ↔ AI-in-sdlc 7 phases ↔ agent-for-ba 5 steps
  - Define phase equivalence: phase nào tương đương, phase nào overlap, phase nào unique
  - Handle phase skipping: define khi nào phase có thể skip và điều kiện skip
  - Define phase transition rules: system nào trigers transition, validation gates
  - Document as matrix table + explanatory notes

  **Must NOT do**:
  - Không force 1-to-1 mapping nếu không có equivalence tự nhiên
  - Không hardcode phase assumptions

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Phase mapping cần hiểu sâu workflow của cả 3 system
  - **Skills**: [] (no specific skills needed)

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 5, 7, 8, 9, 10)
  - **Blocks**: Task 11 (implementation roadmap)
  - **Blocked By**: Task 4 (system conventions), Task 5 (topology)

  **References**:
  - `AI-in-sdlc/README.md` — 7-phase pipeline definition (Intake→Define→Decide→Produce→Verify→Approve→Integrate)
  - `AI-in-sdlc/ARCHITECTURE.md` — Phase definitions và Skill→Phase mapping
  - `agent-for-ba/README.md` — 5-step BA pipeline
  - `agent-for-ba/.github/copilot/AGENTS.md` — BA workflow definitions
  - GSD docs: `https://github.com/open-gsd/get-shit-done-redux/blob/next/docs/USER-GUIDE.md` — GSD phase model
  - `AI-in-sdlc/docs/spikes/system-conventions.md` (Task 4 output)

  **Acceptance Criteria**:
  - [ ] Phase mapping document at `AI-in-sdlc/docs/PHASE-MAPPING.md`
  - [ ] Matrix table shows all GSD phases, AI-in-sdlc phases, BA steps
  - [ ] Equivalence mapping với rationale cho mỗi cặp
  - [ ] Skip conditions documented
  - [ ] Phase transition rules defined

  **QA Scenarios**:

  ```
  Scenario: All three systems represented in mapping
    Tool: Bash (interactive_bash)
    Preconditions: Document exists
    Steps:
      1. Run: grep -c "GSD\|gsd" AI-in-sdlc/docs/PHASE-MAPPING.md
      2. Verify count >= 3
      3. Run: grep -c "AI-in-sdlc\|sdlc" AI-in-sdlc/docs/PHASE-MAPPING.md
      4. Verify count >= 3
      5. Run: grep -c "agent-for-ba\|BA" AI-in-sdlc/docs/PHASE-MAPPING.md
      6. Verify count >= 3
    Expected Result: All 3 systems well-documented in mapping
    Evidence: .sisyphus/evidence/task-6-phase-mapping.txt
  ```

  **Commit**: YES
  - Message: `[int] design: cross-system phase mapping table`
  - Files: `AI-in-sdlc/docs/PHASE-MAPPING.md`

- [x] 7. Design BA→Dev Handoff Contract

  **What to do**:
  - Define artifact types: requirement, UI spec, test case, review report → Dev input format
  - Define file location convention: BA output written to `wiki/projects/{project}/` → Dev reads from known path
  - Define format contract: YAML frontmatter fields, required sections, optional fields
  - Define validation rules: kiểm tra artifact completeness trước khi Dev consume
  - Define versioning: cách handle artifact updates và re-validation
  - Write contract spec as markdown với examples

  **Must NOT do**:
  - Không sửa BA skill output format
  - Không yêu cầu BA thay đổi workflow

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Contract design cần phân tích format của cả hai system và thiết kế mapping
  - **Skills**: [`analyze-requirements`]
    - `analyze-requirements`: Để hiểu cấu trúc requirement artifacts

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 5, 6, 8, 9, 10)
  - **Blocks**: Task 11 (implementation roadmap)
  - **Blocked By**: Task 2 (BA→Dev spike), Task 5 (topology)

  **References**:
  - `AI-in-sdlc/docs/spikes/ba-dev-artifact-flow.md` (Task 2 output)
  - `agent-for-ba/.opencode/skills/generate-highlevel-req/SKILL.md` — BA HLR output format
  - `agent-for-ba/.opencode/skills/generate-detailed-req/SKILL.md` — BA detailed req output
  - `agent-for-ba/.opencode/skills/generate-ui-spec/SKILL.md` — BA UI spec output
  - `AI-in-sdlc/.sdlc/artifacts/_template-meta.json` — Dev artifact schema
  - `AI-in-sdlc/ARCHITECTURE.md` — ArtifactKind và ArtifactVersion interface

  **Acceptance Criteria**:
  - [ ] Handoff contract document at `AI-in-sdlc/docs/HANDOFF-CONTRACTS.md` (BA→Dev section)
  - [ ] Mỗi BA artifact type có Dev input mapping
  - [ ] File location convention defined (write path → read path)
  - [ ] Validation rules per artifact type
  - [ ] Example for each artifact type (before/after conversion)

  **QA Scenarios**:

  ```
  Scenario: Contract specifies artifact types and mappings
    Tool: Bash (interactive_bash)
    Preconditions: Document exists
    Steps:
      1. Run: grep -c "Artifact Type\|artifact type\|artifact-type" AI-in-sdlc/docs/HANDOFF-CONTRACTS.md
      2. Verify count >= 3 (high-level req, detailed req, UI spec at minimum)
      3. Run: grep -c "→\|maps to\|converts to" AI-in-sdlc/docs/HANDOFF-CONTRACTS.md
      4. Verify count >= 3 (mappings documented)
    Expected Result: At least 3 artifact types with explicit mappings
    Evidence: .sisyphus/evidence/task-7-ba-dev-contract.txt
  ```

  **Commit**: YES
  - Message: `[int] design: BA-to-Dev handoff contract specification`
  - Files: `AI-in-sdlc/docs/HANDOFF-CONTRACTS.md` (partial)





