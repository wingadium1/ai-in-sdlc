---
name: sdlc-init
description: Initialize the AI in SDLC framework for this project. Sets up .sdlc/ structure and fills in project.yaml based on the current codebase.
agent: ask
model: claude-sonnet-4
tools: [codebase, editFiles, createFiles, runCommands]
---

You are initializing the **AI in SDLC framework** for this project.

## Steps

1. **Scan the codebase** to auto-detect the project profile:
   - Detect language and runtime from `package.json`, `pom.xml`, `pyproject.toml`, `build.gradle`, `*.xcodeproj`, etc.
   - Detect frameworks from dependencies
   - Detect test framework from dev dependencies or test file patterns
   - Detect build/lint/test commands from `package.json scripts`, `Makefile`, etc.
   - Detect repo layout by scanning directory structure

2. **Find canonical examples** — identify 2-3 well-structured files that represent good patterns:
   - Look for service classes, route handlers, repository patterns
   - Prefer files with clear separation of concerns

3. **Detect architecture artifact gaps** for the active project shape:
    - Look for existing architecture/design artifacts in `.sdlc/artifacts/design-artifact/`, `docs/`, `README.md`, OpenAPI/AsyncAPI specs, Mermaid diagrams, Excalidraw files, and IaC files
    - Infer which minimum views are likely expected based on the detected project type
    - Resolve missing-view severity in this order: active scope reality → `artifact_policy.by_work_type` → `artifact_policy.baseline` → project-type guide defaults → framework deliverables matrix
    - Flag obvious missing views such as `context-view`, `container-view`, `interaction-view`, `contract-view`, or `deployment-view`
    - When a required or strongly recommended view is missing, suggest the matching template under `docs/artifact-templates/`
    - Do **not** try to fully reconstruct every artifact during init; only detect gaps and recommend the next template/workflow

4. **Populate `.sdlc/profiles/project.yaml`** with detected values
    - If the detected project shape strongly implies minimum architecture views, suggest an `artifact_policy` baseline block in `project.yaml`
    - If one work type clearly needs stricter expectations (for example `code-review` in microservices), suggest an `artifact_policy.by_work_type` override
    - Prefer the nearest matching project-type `project.yaml` example as the starting point for `artifact_policy`
    - Keep the semantics explicit: `required` = gate or reconstruction path, `warn` = artifact gap + recommendation, `optional` = no automatic warning

5. **Ask the user to confirm or correct**:
     - Show the detected values
     - Ask if any conventions should be added
     - Ask if any canonical examples should be swapped
     - Show any detected artifact gaps, their severities, and recommend which template to start from
     - If the gaps are substantial, recommend `/reconstruct-architecture <scope>` as the next workflow

6. **Verify `.sdlc/config.json`** — confirm adapter and providers are configured

7. **Create a test actor** in `.sdlc/actors/`:
    ```json
    {
      "id": "actor-copilot-user",
      "kind": "human",
      "name": "Project Developer",
      "role": "developer"
    }
    ```

8. **Report initialization complete**:
     - Summary of detected stack
     - Skills available: `start-feature`, `fix-bug`, `code-review`, `reconstruct-architecture`, `write-unit-tests`, `write-auto-tests`, `update-requirements`
     - Any detected artifact gaps, the applied `artifact_policy` severity, and the recommended starting templates from `docs/artifact-templates/`
     - Suggest `/reconstruct-architecture <scope>` when artifact gaps need brownfield recovery rather than simple initialization
     - Next step: run `sdlc ingest codebase` to build the knowledge base index
