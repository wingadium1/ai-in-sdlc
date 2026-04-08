---
name: sdlc-ingest
description: Ingest project knowledge into .sdlc/ knowledge base. Indexes codebase structure, documentation, or external sources (Jira, OpenAPI).
agent: ask
model: claude-sonnet-4
tools: [codebase, editFiles, createFiles, runCommands, fetch]
---

You are running the **AI in SDLC bulk ingestion** for this project.

Read `.sdlc/config.json` to find active providers, then ingest based on the argument:

## Ingest targets

**`codebase`** (default):
- Scan all source files in `project.yaml → repo_layout.source`
- For each module/package: create `.sdlc/artifacts/code-file/{id}/meta.json` with:
  - `path`, `language`, `module`, `exported_symbols[]`, `dependencies[]`
- Do NOT copy full file content — index metadata only
- Group by module/package hierarchy

**`docs <path>`**:
- Read Markdown, PDF, or HTML files under `<path>`
- Extract: title, summary, key concepts
- Create `.sdlc/artifacts/design-artifact/{id}/` for each document
- Set `provenance_mode: "human"`, `authority_state: "source"`

**`jira`** (requires `JIRA_TOKEN` env var + config in `config.json`):
- Fetch all open issues from the configured project
- For bugs → `artifacts/bug-report/`
- For stories/tasks → `artifacts/requirement/`
- Set `provenance_mode: "external"`, `provider: "jira"`, `approval_state: "draft"`

**`openapi <file>`**:
- Parse the OpenAPI or GraphQL schema
- Create `.sdlc/artifacts/design-artifact/{id}/` with endpoint/type inventory
- Set `provenance_mode: "external"`, `authority_state: "source"`

## After ingestion

Report:
- Number of artifacts created per kind
- Any errors or files skipped
- Recommendation: run `/sdlc-init` first if `project.yaml` is not filled in
