# Skill Authoring Guide

> How to design reusable AI-in-SDLC skills that are concise, triggerable, reviewable, and compatible with the framework’s phase backbone.

**Status**: Framework authoring standard.
**Scope**: Applies to new skills added under `runtime/copilot/.github/skills/` and should inform future runtime ports.

---

## Why this guide exists

AI-in-SDLC uses skills as user-invocable workflow surfaces.

A good skill must do more than describe a task. It must:

- trigger reliably from real developer language,
- map cleanly into the SDLC backbone,
- load the right project and work-type context,
- produce traceable artifacts,
- and avoid overlapping ambiguously with other skills.

This guide standardizes how skills should be authored so the framework remains coherent as new skills are added.

---

## Core principles

### 1. A skill owns one clear job

A skill should exist for a distinct user-facing workflow such as:

- start a feature,
- fix a bug,
- review code,
- update requirements.

Do not create mega-skills that try to bootstrap, design, implement, review, and publish everything at once.

### 2. Skills are workflow surfaces, not knowledge dumps

The main `SKILL.md` should stay concise.

If the skill needs deep background material, put it in sidecar references — preferably `references/*.md` beside the skill — or future context packs rather than expanding the main instruction indefinitely.

### 3. Skills should map to work types where possible

If a skill aligns with a framework work type such as `debugging`, `code-review`, or `requirement-analysis`, declare it explicitly in frontmatter using `work-type`.

If it does not map cleanly, explain why.

### 4. Trigger quality matters as much as execution quality

Poor trigger wording creates accidental activation, overlap, and user confusion.

Every skill should define:

- example trigger phrases,
- anti-trigger phrases,
- and “when not to use” guidance.

### 5. Skills should describe artifact expectations

Every skill should say what it creates or updates in `.sdlc/`.

This keeps the framework auditable and consistent with the Artifact / ArtifactVersion model.

### 6. Skills should delegate deep reuse to the framework

Do not restate all universal rules inside every skill.

Skills should reference the framework layers they rely on:

- phase agents,
- `project.yaml`,
- `org.yaml`,
- work types,
- component profiles,
- decisions,
- and artifact records.

---

## Required structure of a skill

Every skill should start from:

- `runtime/copilot/.github/skills/_template/SKILL.md`

At minimum, a published skill should include:

1. YAML frontmatter
2. short purpose summary
3. when to use
4. when not to use
5. invocation examples
6. workflow / phase behavior
7. work type mapping
8. key constraints
9. gate behavior
10. project adaptation
11. output artifacts
12. trigger examples
13. anti-trigger examples

---

## Frontmatter rules

Required fields:

```yaml
name: your-skill-name
description: One-sentence trigger-aware description
argument-hint: "[primary input]"
user-invocable: true
work-type: null
```

### `name`

- use kebab-case
- keep it semantic and stable
- avoid runtime-specific names

Good:

- `fix-bug`
- `code-review`
- `update-requirements`

Bad:

- `skill-for-fixing-things`
- `code-review-v2`
- `copilot-bug-fix`

### `description`

The description should include:

- what the skill does,
- the result it produces,
- and 2–4 representative user phrases.

Good pattern:

> Review an existing implementation, diff, or pull request and produce structured findings, risks, and recommended next actions. Use when a developer says "review this", "check my changes", or "audit this PR".

### `argument-hint`

Show the primary kind of input the skill expects.

Examples:

- `"[feature description or ticket ID]"`
- `"[bug description, error message, or ticket ID]"`
- `"[PR URL, branch name, file path, or diff summary]"`

### `work-type`

- set it when there is a clean mapping
- use `null` when the skill spans multiple work types or is only a thin wrapper

---

## Trigger design

### Trigger examples are mandatory

Every skill should include 5 example requests that **should** trigger it.

This improves:

- author clarity,
- future evaluation,
- and possible trigger testing automation.

### Anti-trigger examples are mandatory

Every skill should include 5 example requests that **should not** trigger it.

This is especially important when two skills are adjacent, such as:

- `start-feature` vs `update-requirements`
- `fix-bug` vs `code-review`
- `code-review` vs direct chat feedback

### Anti-patterns to avoid in trigger writing

#### 1. The octopus description

The skill tries to own too many different jobs.

Bad:

> Use for feature planning, bug fixing, review, release, and documentation.

#### 2. The ghost description

The description is too vague to activate reliably.

Bad:

> Helps with development tasks.

#### 3. The overlap trap

The skill description collides heavily with an existing skill and gives no anti-trigger guidance.

#### 4. The tool-first description

The description talks about internal mechanics rather than the user-visible job.

Bad:

> Loads project.yaml, reads decisions, and writes phase packets.

Good:

> Update changed requirements, acceptance criteria, and invalidated downstream artifacts.

---

## Work type mapping guidance

Use a work type when the skill consistently relies on a shared reasoning pattern.

Examples:

- `fix-bug` → `debugging`
- `code-review` → `code-review`
- `update-requirements` → `requirement-analysis`

If the skill maps to a work type, the skill should say:

- which `.sdlc/work-types/{id}.md` file is loaded,
- whether `project.yaml -> work_type_overrides.{id}` may refine behavior,
- which artifact subtypes are usually expected for that work type,
- and how `project.yaml -> artifact_policy` can raise them to `required`, `warn`, or `optional`,
- and which phases are most affected.

---

## Gate behavior guidance

Every skill should clearly say:

- when it auto-passes,
- when it requires approval,
- and what risk flags trigger the gate.

Typical flags:

- `architecture_change`
- `api_contract_change`
- `security_sensitive`
- `new_external_dependency`
- `blocking_review_findings`

If a skill normally requires review, say so explicitly.
If it normally auto-passes, say what exceptions override that default.

---

## Output artifact guidance

Every skill should list its expected `.sdlc/` artifacts.

Examples:

- `fix-bug`
  - `bug-report`
  - `test-case`
- `code-review`
  - `review-note`
- `start-feature`
  - `requirement`
  - `design-artifact`
  - `decision`

If the skill does not normally create new artifacts, it should say which artifacts it depends on or updates.

If the skill depends on existing architecture/design artifacts, say how it should react when they are missing:

- `required` → gate, reconstruct, or require an explicit waiver
- `warn` → surface the gap and recommend a template or reconstruction path
- `optional` → continue without automatic warning

---

## When to add sidecar references

Add sidecar files under `references/` when:

- the skill needs deep reference material,
- the core instruction would become too long,
- the domain requires reusable checklists or examples,
- or the same reference content will be reused by multiple skills.

Good candidates:

- architecture recovery checklists
- release readiness checklists
- brownfield inventory questions
- diagram conventions
- project-type-specific references

Do **not** add sidecars just to avoid editing the main skill. Only add them when there is real reusable reference material.

---

## Author checklist

Before publishing a new skill, verify:

- [ ] The skill owns one clear job.
- [ ] The frontmatter is complete and concise.
- [ ] The description includes realistic trigger phrases.
- [ ] The skill includes 5 trigger examples.
- [ ] The skill includes 5 anti-trigger examples.
- [ ] The skill explains when not to use it.
- [ ] The skill maps to a work type or explains why it does not.
- [ ] Gate behavior is explicit.
- [ ] Output artifacts are listed.
- [ ] Project adaptation sources are listed.
- [ ] The file stays concise; deep material is moved to sidecars if needed.
- [ ] The skill does not duplicate universal phase-agent behavior without reason.

---

## Review checklist

When reviewing a new skill, ask:

1. Could a user easily know when to invoke this skill?
2. Could a user easily know when **not** to invoke it?
3. Does it overlap dangerously with an existing skill?
4. Does it map to the right work type?
5. Does it preserve the universal phase backbone?
6. Are its artifact outputs consistent with the framework?
7. Does it keep project-specific behavior in project/work-type layers instead of hardcoding it?
8. Is the wording concise enough for runtime use?

---

## Recommended next evolution

This guide should later gain:

- a trigger quality rubric,
- a lightweight skill evaluation checklist,
- and generator/scaffold support once the template stabilizes.

For now, the template plus this guide are the official standard for skill authoring in AI-in-SDLC.
