# ai-in-sdlc

> A universal, project-aware AI-assisted SDLC framework for structured software delivery, delivered as agent skills for **GitHub Copilot** (VS Code Agent Mode).

`ai-in-sdlc` gives your team a structured, project-aware AI coworker that covers the full development lifecycle — from requirement capture through coding, testing, review, and PR creation — while keeping humans in control at every critical decision point.

---

## What it does

Every developer task — add a feature, fix a bug, write tests, update requirements — is guided through a lightweight **7-phase pipeline**:

```
Intake → Define → Decide → Produce → Verify → Approve → Integrate
```

The AI handles each phase using **your project's actual stack, conventions, and prior decisions** (loaded from a local knowledge base in `.sdlc/`). Nothing is hardcoded. The framework adapts to any language, framework, or project type.

---

## Quick Start (GitHub Copilot)

### Prerequisites

- VS Code with the [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) extension (v1.250+)
- GitHub Copilot subscription (Individual, Team, or Enterprise)
- Agent Mode enabled: `github.copilot.chat.agent.enabled: true` in VS Code settings

### Step 1 — Copy the framework into your project

```bash
# From the ai-in-sdlc repo, copy the runtime files to your project root
cp -r runtime/copilot/.github /path/to/your-project/
cp -r .sdlc /path/to/your-project/
```

Your project structure will look like:

```
your-project/
├── .github/
│   ├── copilot-instructions.md   ← always-on context for all Copilot chats
│   ├── agents/                   ← 7 phase agents (sdlc-intake, sdlc-define, ...)
│   ├── skills/                   ← 5 developer skills (start-feature, fix-bug, ...)
│   └── prompts/                  ← setup commands (sdlc-init, sdlc-ingest)
└── .sdlc/                        ← knowledge base (committed to git)
    ├── config.json
    ├── profiles/
    │   ├── project.yaml          ← fill this in (Step 2)
    │   ├── models.yaml           ← model routing config
    │   └── org.yaml              ← org-wide policies
    └── artifacts/                ← requirements, decisions, test cases, code index
```

### Step 2 — Initialize the knowledge base

Open Copilot Chat in VS Code and run:

```
/sdlc-init
```

Copilot will scan your codebase, auto-detect your stack (language, frameworks, test runner, build commands), and fill in `.sdlc/profiles/project.yaml`. Confirm or correct the detected values.

### Step 3 — Ingest your codebase

```
/sdlc-ingest codebase
```

This indexes your source files into `.sdlc/artifacts/code-file/` so phase agents can query your project structure without reading every file from scratch.

Optional ingestion targets:
```
/sdlc-ingest docs ./docs          ← index Markdown/PDF documentation
/sdlc-ingest openapi ./api.yaml   ← index OpenAPI/GraphQL specs
/sdlc-ingest jira                 ← pull open issues (requires JIRA_TOKEN in .sdlc/.env)
```

### Step 4 — Start working

You're ready. Use the skills directly in Copilot Chat:

```
/start-feature add a password reset flow via email
/fix-bug users get logged out randomly after 10 minutes
/code-review https://github.com/org/repo/pull/123
/reconstruct-architecture checkout-payment-flow
/write-unit-tests the payment service
/write-auto-tests the checkout flow
/update-requirements the session timeout is now 30 minutes not 60
```

---

## Developer Skills Reference

### `/start-feature <description>`

Implements a new feature end-to-end.

```
/start-feature add a dark mode toggle to user settings
/start-feature PROJ-123                              ← Jira ticket
/start-feature https://github.com/org/repo/issues/42 ← GitHub issue
```

**Pipeline**: Intake → Define → Decide → Produce → Verify → **Approve (human gate)** → Integrate

The Approve gate always fires for features because they typically introduce new interfaces or patterns. You review a structured package — what changed, why, design decisions made, test evidence — then click **Approved** or **Changes requested**.

**Produce modes**:
- `autonomous mode` — AI implements fully, runs tests, iterates until passing
- *(default)* — AI generates skeleton + key logic, annotates `// TODO:` for your review

---

### `/fix-bug <description or error>`

Investigates and patches a defect with minimal blast radius.

```
/fix-bug NullPointerException in UserService.getProfile() line 42
/fix-bug BUG-456
/fix-bug users can't log in after password reset
```

**Pipeline**: Intake → Define → Decide → Produce → Verify → Integrate

`fix-bug` now behaves as a debugging coworker workflow by default:

- AI confirms the symptom, gathers evidence, ranks likely causes, and proposes next actions.
- Humans coordinate runtime access, choose risky mitigation steps, and confirm live-system recovery when needed.
- For simple locally proven defects, the workflow can still take the fast path: regression test first (red), fix second (green).

The Approve gate is **skipped by default** — simple fixes go straight to Integrate unless the fix touches architecture or API contracts, or live operational confirmation is still needed.

**Constraint**: The AI never refactors while fixing. The change is always minimal.

Project-specific debugging behavior comes from:

- `.sdlc/work-types/debugging.md`
- `project.yaml -> observability`
- `project.yaml -> work_type_overrides.debugging`

This is designed for project-specific evidence collection without hardcoding vendors into the universal workflow. A microservice may start from correlation IDs and APM traces, a data pipeline may start from MLflow runs and dataset snapshots, and a frontend may start from browser errors and replayed user flows — the coworker protocol stays the same.

---

### `/write-unit-tests <target>`

Generates or improves unit test coverage for existing code.

```
/write-unit-tests src/services/AuthService.ts
/write-unit-tests the login flow
/write-unit-tests REQ-042                ← tests for a specific requirement
/write-unit-tests -- we're below 80%    ← coverage gap analysis
```

**Pipeline**: Intake → Define → Decide → Produce → Verify → Integrate

The Approve gate auto-passes if coverage meets the threshold in `.sdlc/profiles/org.yaml` (default 80%). Each generated test is linked to a requirement or code unit in `.sdlc/`.

---

### `/code-review <PR URL, branch, or diff>`

Reviews an existing implementation or pull request and produces structured findings.

```
/code-review https://github.com/org/repo/pull/123
/code-review branch: feature/session-timeout
/code-review src/services/AuthService.ts
```

**Pipeline**: Intake → Define → Decide → Produce → Verify → Approve → Integrate

The skill defaults to the `code-review` work type, so project-specific review rules can be injected from `project.yaml -> work_type_overrides.code-review`.

**Typical outputs**:
- review findings with severity and rationale
- risk summary for maintainers
- follow-up actions or required revisions

---

### `/reconstruct-architecture <scope>`

Recovers missing or stale architecture/design artifacts for an existing system, subsystem, service, or flow.

```
/reconstruct-architecture checkout-payment-flow
/reconstruct-architecture auth-service
/reconstruct-architecture payment-platform
```

**Pipeline**: Intake → Define → Decide → Produce → Verify → Approve → Integrate

Use this when the problem is not “write code now,” but “we do not have enough trustworthy architecture context to proceed safely.”

It works with:
- `docs/brownfield-reconstruction-workflow.md`
- `docs/artifact-templates/`

Typical outputs:
- reconstructed `design-artifact` slices
- explicit artifact-gap list
- confidence and validation notes
- reusable context for later feature, bug, review, or release work

---

### `/write-auto-tests <flow or feature>`

Creates E2E or integration automation scripts.

```
/write-auto-tests the checkout flow
/write-auto-tests login and session management
/write-auto-tests REQ-015 through REQ-018
```

**Pipeline**: Intake → Define → Decide → Produce → Verify → **Approve (human gate)** → Integrate

The Decide phase is heavier here — test architecture (framework choice, page object model, data strategy, environment design) is an architectural decision and always requires human review before implementation.

---

### `/update-requirements <input>`

Captures new or changed requirements and propagates impact to linked artifacts.

```
/update-requirements users must be able to reset their password via SMS
/update-requirements PROJ-99
/update-requirements REQ-042 is changing — timeout is now 30s not 60s
```

**Pipeline**: Intake → Define → Decide → Produce → **Approve (PM gate)** → Integrate

Requirements always require human approval — they are the source of truth for all downstream work. After approval, the Integrate phase automatically marks any design docs, code files, and test cases that derive from the changed requirement as `draft` (needs re-review), surfacing a clear review queue.

---

## The Phase Pipeline in Detail

Every skill routes through the same 7-phase backbone. Phases can be skipped (e.g. `write-unit-tests` skips Approve by default) or can loop back (Verify → Decide on failure, Approve → Decide on "changes requested").

| Phase | Agent | Model tier | What happens |
|-------|-------|-----------|-------------|
| **Intake** | `sdlc-intake` | Low (fast) | Work item created, `.sdlc/` context loaded, scope confirmed |
| **Define** | `sdlc-define` | Mid | Acceptance criteria written; done-definition established |
| **Decide** | `sdlc-decide` | High (Opus) | Impact analysis, design decisions recorded, implementation plan produced |
| **Produce** | `sdlc-produce` | Mid | Code, tests, docs created; each artifact linked to a requirement or decision |
| **Verify** | `sdlc-verify` | Low (fast) | Lint, typecheck, tests run; traceability verified; gate status determined |
| **Approve** | `sdlc-approve` | Mid | Review package assembled; **human decides**: approved / changes requested |
| **Integrate** | `sdlc-integrate` | Low (fast) | PR created via `gh pr create`; work item closed; invalidations propagated |

### Handoff buttons

After each phase completes, Copilot shows a handoff button. The prompt is pre-filled but **not auto-submitted** — you review it and press Enter to proceed. This gives you a natural pause point at every phase boundary.

Example after Decide completes:
```
[ ➡️ Produce — Implement the plan ]   [ 🔄 Revise design — Changes needed ]
```

### Human gate policy

Gates trigger automatically based on the work item's risk profile:

| Trigger condition | Gate behavior |
|---|---|
| Architecture or API contract change | `human-required` → Approve phase |
| New external dependency | `human-required` → Approve phase |
| Missing artifact required by `artifact_policy` | `blocked` or `human-required` until reconstructed or waived |
| Security-sensitive code touched | `human-required` → Approve phase |
| PR merge | Always `human-required` |
| Simple code change, no risk flags | `auto-pass` → skip Approve |
| Test coverage below threshold | `human-required` with coverage gap report |

Gate policy is configured in `.sdlc/config.json` and `.sdlc/profiles/org.yaml`.

---

## Knowledge Base (`.sdlc/`)

The `.sdlc/` directory is your project's AI memory. It's committed to git — it's an audit trail, not a cache.

```
.sdlc/
├── config.json                    ← adapter config, gate policy, external providers
├── profiles/
│   ├── project.yaml               ← stack, commands, conventions, canonical examples
│   ├── models.yaml                ← model routing per phase and skill
│   └── org.yaml                   ← org-wide policies (coverage thresholds, audit)
├── work-items/                    ← one JSON per task (feature, bug, review, test-task, etc.)
├── phases/{work-item-id}/         ← PhasePacket for each completed phase
├── artifacts/
│   ├── requirement/               ← structured requirements with acceptance criteria
│   ├── design-artifact/           ← architecture diagrams, API specs, mockups
│   ├── code-file/                 ← indexed codebase metadata (not full file copies)
│   ├── test-case/                 ← test case specifications linked to requirements
│   ├── review-note/               ← review findings, audit notes, and recommendation packages
│   └── bug-report/                ← structured bug reports with root cause
├── decisions/                     ← Architecture Decision Records
└── executions/                    ← phase execution logs (optional)
```

### What to commit

**Commit**: everything in `.sdlc/` except credentials.

**Never commit**:
```
.sdlc/.env           ← provider tokens (JIRA_TOKEN, FIGMA_TOKEN, etc.)
.sdlc/.secrets/      ← any other sensitive config
```

Both are gitignored by default.

### Connecting external providers

Edit `.sdlc/config.json` to enable Jira, Figma, or Linear:

```json
{
  "active_providers": ["jira"],
  "providers": {
    "jira": {
      "base_url": "https://yourteam.atlassian.net",
      "project_key": "PROJ",
      "token_env": "JIRA_TOKEN"
    }
  }
}
```

Set the token in `.sdlc/.env` (never in `config.json`):
```
JIRA_TOKEN=your-token-here
```

---

## Model Configuration

Models are configured in `.sdlc/profiles/models.yaml`. The framework uses tier aliases so you change the model once and it applies everywhere:

```yaml
defaults:
  high: "claude-opus-4-5"      # Decide phase — architecture analysis
  mid:  "claude-sonnet-4-5"    # Define, Produce, Approve — generation work
  low:  "claude-3.5-haiku"     # Intake, Verify, Integrate — fast mechanical tasks
```

To switch to GPT across the board:
```yaml
defaults:
  high: "gpt-4.5"
  mid:  "gpt-4.5"
  low:  "gpt-4o-mini"
```

Per-skill overrides are also supported — see `.sdlc/profiles/models.yaml` for the full schema.

---

## Project Adaptation

The single most important file is `.sdlc/profiles/project.yaml`. Every agent loads it before acting. A well-filled `project.yaml` means generated code matches your project's style without you needing to re-explain conventions in every chat.

Key fields:

```yaml
stack:
  language: "typescript"
  frameworks: [react, express]
  test_framework: "vitest"
  e2e_framework: "cypress"

commands:
  build: "yarn build"
  unit_test: "yarn test:unit"
  lint: "yarn lint"
  typecheck: "yarn types"

conventions:
  - "React functional components only — no class components"
  - "All API responses follow { data, error, meta } envelope"
  - "Database access only through repository pattern"

canonical_examples:
  - path: "src/services/UserService.ts"
    description: "Reference service class — match this structure for new services"
  - path: "src/api/routes/users.ts"
    description: "Reference route handler — match this pattern for new routes"

work_type_overrides:
  debugging:
    additional_steps:
      - "After root cause is confirmed, post the incident summary in #incidents"
    required_tools:
      - "datadog-mcp"

artifact_policy:
  baseline:
    context-view: warn
    container-view: required
    interaction-view: warn
  by_work_type:
    debugging:
      interaction-view: required
    code-review:
      contract-view: required
```

Run `/sdlc-init` to auto-populate this from your codebase, then review and tune.

### Work types

`project.yaml` controls project conventions. Work types control **how agents think about a class of work**.

Framework-provided work types live under `.sdlc/work-types/`:

- `debugging` — reproduce → isolate → prove root cause → minimal fix → regression lock
- `code-review` — understand intent → inspect change surface → evaluate risk → recommend action
- `requirement-analysis` — identify stakeholders → clarify scope → define acceptance criteria → assess impact

Projects can override any of these with `project.yaml -> work_type_overrides` to append steps, replace specific steps, require extra tools, or tighten verification.

### Artifact templates

When the framework needs to create or reconstruct missing architecture/design artifacts, start from the reusable templates in [`docs/artifact-templates/`](docs/artifact-templates/):

- `context-view`
- `container-view`
- `interaction-view`
- `contract-view`
- `deployment-view`

These are especially useful during brownfield onboarding, release-readiness checks, and work types such as debugging, code review, and requirement analysis.

When a missing-view problem is larger than a single artifact, use `/reconstruct-architecture <scope>` together with `docs/brownfield-reconstruction-workflow.md`.

### Artifact policy

Projects can refine the framework defaults with `project.yaml -> artifact_policy`.

Use severities:

- `required` — block or gate if missing
- `warn` — raise an artifact gap and recommend reconstruction
- `optional` — no automatic warning

This lets teams say, for example, that `contract-view` is mandatory for `code-review` in a microservices project, while `deployment-view` is only warning-level for less risky work.

At runtime, agents resolve artifact expectations in this order:

1. active scope reality
2. `project.yaml -> artifact_policy.by_work_type`
3. `project.yaml -> artifact_policy.baseline`
4. project-type guide defaults
5. framework deliverables matrix

Each phase carries forward:

- `artifact_gaps` — missing or waived artifacts for the active scope
- `artifact_policy_applied` — which policy sources were used to reach the decision

That makes missing artifacts visible all the way from Intake through Verify, instead of leaving policy as setup-time documentation only.

---

## Project Type Guides

The framework is universal — it adapts to any project through `project.yaml`. To make onboarding faster, first-class guides are provided for the most common project types.

| Project Type | Description |
|---|---|
| [**web-frontend**](docs/project-types/web-frontend/) | React, Vue, Angular, Svelte — SPA or SSR |
| [**backend-api**](docs/project-types/backend-api/) | REST/GraphQL services, microservice backends |
| [**full-stack-web**](docs/project-types/full-stack-web/) | Monorepo with frontend + API in one repo |
| [**mobile**](docs/project-types/mobile/) | React Native, Flutter, native iOS/Android |
| [**microservices**](docs/project-types/microservices/) | Multi-service systems with inter-service contracts |
| [**data-ml**](docs/project-types/data-ml/) | Data pipelines, model training, MLOps |
| [**cli-devtool**](docs/project-types/cli-devtool/) | CLI tools, developer utilities, SDKs |
| [**embedded-firmware**](docs/project-types/embedded-firmware/) | C/C++ firmware, RTOS, hardware-constrained targets |
| [**infrastructure-iac**](docs/project-types/infrastructure-iac/) | Terraform, CloudFormation, Ansible, Pulumi |

Each guide contains:
- **GUIDE.md** — phase-by-phase differences, conventions, component profiles, team checklist
- **project.yaml** — pre-filled template for that stack (copy to `.sdlc/profiles/project.yaml`)
- **sdlc-{type}.instructions.md** — drop into `.github/instructions/` for Copilot context

Use the project-type guide together with the artifact templates in [`docs/artifact-templates/`](docs/artifact-templates/) when `/sdlc-init` or brownfield work reveals missing architecture views.

For broader recovery work, route into `/reconstruct-architecture <scope>` rather than trying to rebuild every artifact manually in one chat.

The framework stays open — if your stack doesn't fit a preset, start from the [`_template/`](docs/project-types/_template/) and customize freely.

---

## Pilot: cypress-realworld-app

The framework ships with a complete pilot demonstration on [`cypress-io/cypress-realworld-app`](https://github.com/cypress-io/cypress-realworld-app) — a TypeScript full-stack payment app with 4 test layers.

**Pilot task**: Issue #1591 — Add `cy.logoutByApi()` Cypress custom command.

The pilot shows a real `/start-feature` run: all 7 PhasePackets created, actual code changes made (`cypress/support/commands.ts` + `cypress/global.d.ts`), Approve gate triggered, PR description drafted.

See `cypress-realworld-app/.sdlc/phases/wi-20260407-001/` for the full phase trail.

---

## Repository Structure

```
ai-in-sdlc/
├── README.md                       ← this file
├── AGENTS.md                       ← cross-agent instructions (Claude Code, OpenCode)
├── ARCHITECTURE.md                 ← system design, phase model, schemas
├── DECISIONS.md                    ← 15 Architecture Decision Records
├── ROADMAP.md                      ← milestone plan (M1 Copilot → M2 Claude Code → M3 OpenCode)
├── docs/brownfield-reconstruction-workflow.md ← architecture/document recovery workflow
│
├── .sdlc/                          ← schema templates
│   ├── config.json
│   ├── profiles/
│   │   ├── project.yaml            ← fill in per project
│   │   ├── models.yaml
│   │   └── org.yaml
│   ├── work-types/                 ← reusable thinking guides per class of work
│   │   ├── debugging.md
│   │   ├── code-review.md
│   │   └── requirement-analysis.md
│   ├── work-items/_template.json
│   ├── artifacts/_template-meta.json
│   ├── phases/_template.json
│   └── decisions/_template.json
│
└── runtime/
    └── copilot/
        └── .github/                ← copy this entire folder into your project
            ├── copilot-instructions.md
            ├── agents/
            │   ├── sdlc-intake.agent.md
            │   ├── sdlc-define.agent.md
            │   ├── sdlc-decide.agent.md
            │   ├── sdlc-produce.agent.md
            │   ├── sdlc-verify.agent.md
            │   ├── sdlc-approve.agent.md
            │   └── sdlc-integrate.agent.md
            ├── skills/
            │   ├── start-feature/SKILL.md
            │   ├── fix-bug/SKILL.md
            │   ├── code-review/SKILL.md
            │   ├── reconstruct-architecture/SKILL.md
            │   ├── write-unit-tests/SKILL.md
            │   ├── write-auto-tests/SKILL.md
            │   └── update-requirements/SKILL.md
            └── prompts/
                ├── sdlc-init.prompt.md
                └── sdlc-ingest.prompt.md
```

---

## Roadmap

| Milestone | Target | Status |
|---|---|---|
| **M1 — GitHub Copilot MVP** | VS Code Agent Mode | 🔄 In progress |
| **M2 — Claude Code port** | Claude Code CLI | Planned |
| **M3 — OpenCode port** | OpenCode (OMO) CLI | Planned |
| **M4 — Knowledge base upgrade** | Vector DB + Graph DB | Planned |
| **M5 — Additional providers** | Confluence, GitHub Issues, Git history | Planned |

The `.sdlc/` artifact schema is **identical across all runtimes** — only the skill injection mechanism changes per platform. A project onboarded on M1 works without schema migration on M2 or M3.

---

## Contributing

This repo contains the **framework itself**, not applications built with it. Contributions should focus on:

- Improving agent prompts in `runtime/copilot/.github/agents/`
- Extending skill definitions in `runtime/copilot/.github/skills/`
- Expanding schema templates in `.sdlc/`
- Porting to new runtimes under `runtime/`

See `ARCHITECTURE.md` for the design principles and `DECISIONS.md` for the 14 architecture decision records that shaped the current design.
