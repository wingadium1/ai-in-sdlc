# External Patterns Review

> Review of external AI skill / rules / agent ecosystems to identify which structural patterns AI-in-SDLC should adopt, reject, or defer.

**Status**: Research synthesis and design guidance.
**Purpose**: Capture reusable ideas from external repositories before AI-in-SDLC evolves its own skill system, context packs, artifact templates, and project specialization model.

---

## Why this document exists

AI-in-SDLC is building a universal SDLC backbone with:

- phase agents,
- skills,
- work types,
- project-type guides,
- `.sdlc/` schema templates,
- and an emerging interim artifact model.

Many adjacent repositories already explore parts of this problem:

- reusable skill packaging,
- skill marketplaces and collections,
- rules and specialized agent systems,
- framework bootstrap/install flows,
- and skill/template generators.

This document records which ideas are worth borrowing and which should be rejected to preserve the design integrity of AI-in-SDLC.

---

## Repositories reviewed

### Skill ecosystems

- `affaan-m/everything-claude-code`
- `hoodini/ai-agents-skills`
- `wondelai/skills`
- `marketingjuliancongdanh79-pixel/skill-generator`

### Framework / rules ecosystems

- `lee-to/ai-factory`
- `jabrena/cursor-rules-java`

---

## High-level synthesis

The external ecosystem points to five useful pattern families:

1. **Skill authoring discipline** — concise trigger-aware SKILL.md, templates, examples, anti-patterns.
2. **Bundling and packaging** — collections, manifests, sidecar references, install surfaces.
3. **Project specialization** — rules hierarchies, framework- or language-specific overlays.
4. **Bootstrap and runtime adaptation** — stack detection, config generation, guided initialization.
5. **Generator and evaluation layers** — scaffold tools, validation rubrics, trigger testing, CI checks.

AI-in-SDLC should adopt patterns from all five families, but only in ways that reinforce its core identity:

- universal SDLC backbone,
- traceable artifacts,
- work-type-aware reasoning,
- project-specific adaptation,
- and approval/provenance discipline.

---

## Repository-by-repository review

## 1. everything-claude-code

### What it does well

- Organizes an agent ecosystem beyond just skills:
  - skills,
  - agents,
  - commands,
  - rules,
  - contexts,
  - hooks,
  - schemas,
  - MCP config.
- Treats the repository as an **agent operating system**, not just a skill collection.
- Makes reusable context explicit instead of burying everything inside one prompt file.

### Patterns worth borrowing

- Separate reusable **context packs** from executable skill instructions.
- Treat hooks / rules / context / skills as different layers with different responsibilities.
- Keep deep reference material out of the main skill definition.

### Risks to avoid

- Scope explosion: an “everything for every agent” repo can drift away from a clear framework purpose.
- Too many surfaces can make ownership and evolution unclear.

### AI-in-SDLC conclusion

Borrow the idea of **layer separation**, but keep the framework centered on SDLC rather than becoming a generic agent operating system.

---

## 2. hoodini/ai-agents-skills

### What it does well

- Simple, readable, practical skill packaging.
- Clear cross-runtime installation mapping.
- Good emphasis on “only encode what the model does not already know.”
- Useful single-skill template pattern.

### Patterns worth borrowing

- Official skill template.
- Explicit runtime install path table.
- Concise authoring discipline.
- README catalog of skill names + descriptions + trigger phrasing.

### Risks to avoid

- Metadata is too thin for a growing framework.
- No governance or versioning story.
- Not strong enough for multi-phase SDLC orchestration by itself.

### AI-in-SDLC conclusion

Adopt this as the baseline for **skill authoring style**, but layer stronger metadata and SDLC semantics on top.

---

## 3. wondelai/skills

### What it does well

- Strong packaging model via plugin collections and marketplace manifest.
- Semver and author metadata.
- References as separate sidecar files.
- Skills grouped into conceptual bundles.
- Each skill acts as a “knowledge lens” based on a named framework or source.

### Patterns worth borrowing

- Bundle / collection manifest.
- References sidecar pattern.
- Semver for published reusable assets.
- Clear installable collections by concern.

### Risks to avoid

- Knowledge-distillation skills are not the same as executable workflows.
- The library can turn into a marketplace of frameworks rather than a coherent SDLC system.

### AI-in-SDLC conclusion

Adopt the **bundle + sidecar + versioning** ideas, but do not turn AI-in-SDLC into a marketplace of book-inspired skill packs.

---

## 4. skill-generator

### What it does well

- Treats skill creation itself as a structured workflow.
- Uses phase-based generation, evaluation, comparison, validation, export, and packaging.
- Strong anti-pattern catalog.
- Strong trigger/anti-trigger thinking.
- Complexity-based scaffold decisions.
- CI-ready evaluation mindset.

### Patterns worth borrowing

- Complexity-based scaffold rule.
- Skill evaluation rubric.
- Trigger / anti-trigger test cases.
- Anti-pattern catalog for authoring.
- Scaffold/export tooling as a later platform capability.

### Risks to avoid

- Too much ceremony for simple skills.
- Generator-heavy tooling before the underlying taxonomy stabilizes.
- Large monolithic orchestrator skill files.

### AI-in-SDLC conclusion

Adopt its **meta-quality ideas** first (rubrics, anti-patterns, trigger tests), and defer full generator tooling until the framework’s own skill and artifact taxonomies are stable.

---

## 5. ai-factory

### What it does well

- Strong initialization and bootstrap experience.
- Explicit project configuration.
- Detect-then-configure flow.
- Rule hierarchy.
- Area-specific rule registration.
- Multi-agent and multi-runtime mindset.
- Spec-driven workflow packaging.

### Patterns worth borrowing

- Better `/sdlc-init` detection and project bootstrapping.
- Explicit rules hierarchy.
- Stronger configuration story for project-specific adaptation.
- Detect conventions from the codebase before writing configuration.
- Install/UX thinking: selectable setup surface, clearer guided start.

### Risks to avoid

- Monolithic skills that accumulate too much responsibility.
- Shadow override systems that become hard to reason about.
- Product scope drift away from the framework core.

### AI-in-SDLC conclusion

This is the strongest reference for **bootstrap UX and layered project adaptation**, but AI-in-SDLC should keep single-phase ownership and avoid oversized skills.

---

## 6. cursor-rules-java

### What it does well

- Connects rules, skills, agents, examples, and deliverables to actual SDLC questions.
- Treats architecture views and deliverables as first-class outputs.
- Uses specialized overlays for framework-specific behavior.
- Makes preconditions like compile checks explicit.
- Shows how to combine universal guidance with domain-specific depth.

### Patterns worth borrowing

- Deliverables mindset per iteration.
- Architecture artifacts as explicit SDLC outputs.
- Specialized overlays for framework-specific behavior.
- ADR-driven dispatch and interpretation.
- Precondition gates before implementation.
- Behavior modifiers separate from core content rules.

### Risks to avoid

- Language-specific scope embedded too deeply in the core model.
- Manual index maintenance.
- Flat numbering systems without strong evolution metadata.

### AI-in-SDLC conclusion

This is the strongest reference for **specialization, deliverables, and architecture-aware SDLC**, but its language-specific depth must be translated into universal patterns plus project-type overrides.

---

## Patterns AI-in-SDLC should adopt

### Adopt now

#### 1. Official skill authoring system

Add:

- `runtime/copilot/.github/skills/_template/SKILL.md`
- `docs/skill-authoring-guide.md`

Include:

- purpose,
- when to use,
- when not to use,
- output artifacts,
- related skills,
- work type mapping,
- gate behavior,
- 5 trigger examples,
- 5 anti-trigger examples.

**Why**: strongest combined lesson from `hoodini`, `everything-claude-code`, and `skill-generator`.

---

#### 2. Sidecar references / context packs

Adopt a structure where the main executable instruction stays concise, and deep reference material lives nearby.

Examples:

- `contexts/architecture-recovery/`
- `contexts/release-readiness/`
- `contexts/microservice-review/`

**Why**: strongest lesson from `everything-claude-code` and `wondelai`.

---

#### 3. Deliverables / artifact expectation matrix

Define what artifacts are expected by:

- phase,
- work type,
- project type,
- release risk.

This should connect directly to:

- `docs/interim-artifacts-proposal.md`
- `artifact_subtype`
- brownfield reconstruction workflows.

**Why**: strongest lesson from `cursor-rules-java` and aligned with the framework’s current direction.

---

#### 4. Stronger bootstrap/init flow

Extend `/sdlc-init` so it can:

- detect stack and likely project type,
- infer conventions,
- find missing artifact gaps,
- and write better draft project configuration.

**Why**: strongest lesson from `ai-factory`.

---

#### 5. Explicit rules / override hierarchy

Document and enforce the framework hierarchy more explicitly:

- universal axioms,
- org policies,
- project conventions,
- work type overrides,
- component overrides.

**Why**: `ai-factory` and `cursor-rules-java` both show that specialization works best when the override order is explicit.

---

### Adopt later

#### 6. Bundle / marketplace manifest

Eventually add a manifest for skill collections, context packs, or project-specific bundles.

**Why later**: valuable, but only after the framework’s internal taxonomies stabilize.

---

#### 7. Skill/context/artifact generators

Eventually add:

- skill scaffold,
- context scaffold,
- artifact template scaffold,
- maybe project-type guide scaffold.

**Why later**: generator quality depends on stable taxonomy. Premature tooling will lock in weak structures.

---

#### 8. Evaluation rubric for reusable framework assets

Add review rubrics for skill quality, trigger quality, and maybe artifact template quality.

**Why later**: worth doing after authoring standards are formalized.

---

## Patterns AI-in-SDLC should reject

### 1. Monolithic “do everything” skills

Each skill or agent should own a clear concern. The phase-agent model is already stronger than mega-skill designs.

### 2. Manual catalogs that drift

Any future skill index, bundle index, or artifact catalog should be generated from source directories or manifests, not maintained by hand.

### 3. Shadow override systems

Avoid hidden override directories that silently take precedence. Prefer explicit configuration or documented override locations.

### 4. Unbounded skill proliferation

Do not create a marketplace of hundreds of overlapping skills. AI-in-SDLC should remain structured around:

- phase agents,
- work types,
- project types,
- context packs,
- and artifact models.

### 5. Language-specific logic in the universal core

Framework-specific or language-specific depth belongs in project types, work type overrides, or future bundles — not in the universal backbone.

---

## Recommended next moves

### Immediate next step

Create the official skill authoring system:

- `_template/SKILL.md`
- `docs/skill-authoring-guide.md`

This has the best leverage because it improves every future skill, context pack, and work-type implementation.

### Near-term follow-up

Design the deliverables / artifact expectation matrix to connect:

- project types,
- work types,
- interim artifacts,
- and brownfield reconstruction.

### After that

Define the first context pack, likely:

- `contexts/architecture-recovery/`

because it directly supports the current strategy around missing design artifacts and brownfield onboarding.

---

## Final recommendation

AI-in-SDLC should learn from the external ecosystem, but not imitate any single repository.

The most important synthesis is:

- use **hoodini** for concise skill authoring discipline,
- use **wondelai** for bundle/version/reference packaging,
- use **skill-generator** for anti-patterns, trigger quality, and future scaffolding,
- use **ai-factory** for bootstrap/init UX and layered adaptation,
- use **cursor-rules-java** for deliverables, specialization, and architecture-aware SDLC outputs.

The framework should combine those strengths while preserving its own center of gravity:

**a universal SDLC backbone with adaptive artifacts, project-aware overrides, and traceable approval/provenance.**
