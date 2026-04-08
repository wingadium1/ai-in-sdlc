---
name: your-skill-name
description: One-sentence description of what this skill does and when it should trigger. Use when a developer says "...", "...", or "...".
argument-hint: "[description, ticket ID, URL, file path, or other primary input]"
user-invocable: true
work-type: null
---

# Skill: your-skill-name

One-paragraph summary of the skill's purpose. State whether it orchestrates a full SDLC path, a partial workflow, or a focused reusable task.

If this skill maps cleanly to a work type, set `work-type` in frontmatter and explain the relationship below.

## When to use

Use this skill when the user is trying to:

- [primary job to be done]
- [second common case]
- [third common case]

Typical user phrases:

- "..."
- "..."
- "..."

## When not to use

Do **not** use this skill when:

- the user actually needs a different existing skill such as `/fix-bug`, `/start-feature`, or `/update-requirements`
- the request is too broad and should start with a requirement or architecture workflow first
- the request is only a small sub-step inside another larger skill execution

Anti-trigger examples:

- "..." → should use `/other-skill`
- "..." → should stay as direct chat / no skill
- "..." → should use a work-type-specific or project-type-specific path instead

## How to invoke

Primary invocation:

`/your-skill-name <input>`

Alternative invocation patterns:

- `/your-skill-name TICKET-123`
- `/your-skill-name https://...`
- `/your-skill-name src/path/to/file`

## What happens

Describe the phase path or major steps this skill drives.

If this skill uses the standard SDLC backbone, document it in a phase table:

| Phase | What the AI does | Human does |
|-------|------------------|-----------|
| **Intake** | ... | ... |
| **Define** | ... | ... |
| **Decide** | ... | ... |
| **Produce** | ... | ... |
| **Verify** | ... | ... |
| **Approve** | ... | ... |
| **Integrate** | ... | ... |

If this is a non-phase skill, replace the table with the ordered steps the skill performs.

## Work type

If `work-type` is set in frontmatter:

- Explain why this skill maps to that work type.
- State which file agents should load from `.sdlc/work-types/`.
- State which `project.yaml -> work_type_overrides.<work-type>` block may refine behavior.

If `work-type: null`, explain why the skill spans multiple work types or does not map cleanly to one.

## Key constraints

List the invariants this skill must preserve.

- [constraint 1]
- [constraint 2]
- [constraint 3]

Examples:

- minimal fix only
- no opportunistic refactor
- human approval required for architecture changes
- use project conventions from `.sdlc/profiles/project.yaml`

## Gate behavior

State when this skill auto-passes versus when it must trigger human approval.

Common gate conditions:

- `architecture_change`
- `api_contract_change`
- `security_sensitive`
- `new_external_dependency`
- `blocking_review_findings`

Be explicit about whether this skill normally auto-passes or normally requires review.

## Project adaptation

List the project-specific context this skill loads.

- `.sdlc/profiles/project.yaml`
- `.sdlc/profiles/org.yaml` (if relevant)
- `.sdlc/work-types/<work-type>.md` (if relevant)
- `.sdlc/profiles/components/*.yaml` (if relevant)
- `.sdlc/decisions/*.json`
- `.sdlc/artifacts/...` (if relevant)

If the skill needs deeper reference material, place it in sidecar files under a `references/` directory near the skill rather than bloating this file.

## Output artifacts in `.sdlc/`

List the artifacts the skill is expected to create, update, or depend on.

- `.sdlc/work-items/{id}.json` — ...
- `.sdlc/artifacts/{kind}/{id}/` — ...
- `.sdlc/decisions/{id}.json` — ...
- `.sdlc/phases/{id}/*.json` — ...

## Trigger examples

These should trigger this skill:

1. "..."
2. "..."
3. "..."
4. "..."
5. "..."

## Anti-trigger examples

These should **not** trigger this skill:

1. "..." → `/other-skill`
2. "..." → direct chat only
3. "..." → `/other-skill`
4. "..." → different work type first
5. "..." → project init / bootstrap flow

## Author notes

Use this section only while drafting. Remove or rewrite it before publishing the skill.

- Keep this file concise. Put long explanations in sidecar references.
- Prefer clear trigger language over broad or vague descriptions.
- Do not duplicate knowledge already captured in universal phase agents unless the skill truly changes behavior.
