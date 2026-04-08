# Project Type Guide: [TYPE NAME]

> One-line description of what makes this project type distinct from others.

## Who this guide is for

[2-3 sentences: what team, what stack, what SDLC pain points this addresses]

## What's different about this type

| SDLC concern | How it differs from default |
|---|---|
| Intake | [e.g. tickets come from Figma, not Jira] |
| Define | [e.g. acceptance criteria include visual spec, not just behavior] |
| Decide | [e.g. API contract review is mandatory] |
| Produce | [e.g. scaffold mode is preferred — humans finalize domain logic] |
| Verify | [e.g. visual regression in addition to unit/e2e] |
| Approve | [e.g. design sign-off required before merge] |
| Integrate | [e.g. deployment is separate step requiring infra team] |

## Quick setup

```bash
# 1. Copy profiles into your project
cp project.yaml /path/to/your-project/.sdlc/profiles/project.yaml
cp org.yaml /path/to/your-project/.sdlc/profiles/org.yaml

# 2. Copy the instructions file
cp sdlc-[type].instructions.md /path/to/your-project/.github/instructions/

# 3. Fill in the blanks
# Edit project.yaml: source path, commands, your canonical example files

# 4. Initialize
# Open Copilot Chat → /sdlc-init
```

## `project.yaml`

See [project.yaml](project.yaml) — copy and fill in the commented `# FILL IN:` lines.

## `org.yaml`

See [org.yaml](org.yaml) — review gate policies and coverage thresholds.

## Coding instructions

See [sdlc-[type].instructions.md](sdlc-[type].instructions.md) — copy to `.github/instructions/` in your project.

## Recommended canonical examples

Point agents to these files in your project (add to `project.yaml → canonical_examples`):

| File pattern | What it demonstrates |
|---|---|
| `[path pattern]` | [what pattern this teaches agents] |

## Common conventions to add

Add these to `project.yaml → conventions` and tune to your team:

```yaml
conventions:
  - "[Rule 1]"
  - "[Rule 2]"
```

## Component profiles

For larger [type] projects, add per-module profiles under `.sdlc/profiles/components/`:

```yaml
# .sdlc/profiles/components/[module].yaml
module: "[module name]"
description: "[what this module does]"
owns:
  - "[file/directory owned by this module]"
conventions:
  - "[module-specific rule]"
canonical_examples:
  - path: "[path]"
    description: "[what to learn from this file]"
```

## Team customization checklist

- [ ] `project.yaml`: source, test, e2e paths filled in
- [ ] `project.yaml`: build/test/lint commands filled in
- [ ] `project.yaml`: 2-3 canonical example files added
- [ ] `project.yaml`: team conventions reviewed and tuned
- [ ] `org.yaml`: coverage threshold matches your team standard
- [ ] `org.yaml`: gate policy reflects your review culture
- [ ] `.github/instructions/`: instructions file copied and reviewed
- [ ] `/sdlc-init` run to verify detection
- [ ] `/sdlc-ingest codebase` run to build the code index
