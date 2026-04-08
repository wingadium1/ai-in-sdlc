# Project Type Guides

The ai-in-sdlc framework is **universal** — the same 7-phase pipeline and `.sdlc/` schema work for any project. But the quality of AI output rises sharply when agents know your exact stack, conventions, and team workflow up front.

These guides give you a **ready-to-use starting point** for each common project type. Each guide contains:

- A filled-in `project.yaml` template for that type
- An `org.yaml` template with appropriate gate policies and coverage thresholds  
- A `.github/instructions/` file with coding rules the agent must follow
- A list of recommended `canonical_examples` to add
- Common `conventions` entries that catch the most frequent AI mistakes for that type
- Team-specific customization notes

The framework also provides reusable architecture/design templates under [`docs/artifact-templates/`](../artifact-templates/) for common interim artifact subtypes such as `context-view`, `container-view`, `interaction-view`, `contract-view`, and `deployment-view`.

Projects can refine artifact expectations in `project.yaml -> artifact_policy`, for example to declare that `contract-view` is required while `deployment-view` is only warning-level for a given work type.

## How to use a guide

1. Find your project type below
2. Copy the `project.yaml` from the guide into your project's `.sdlc/profiles/project.yaml`
3. Fill in the blanks (commands, source paths, your actual canonical files)
4. Copy the `.instructions.md` into `.github/instructions/`
5. Run `/sdlc-init` to let Copilot verify and supplement what you've configured
6. If `/sdlc-init` detects missing architecture artifact gaps, start from the recommended template in `docs/artifact-templates/`
7. If the gaps are broader than one missing view, run `/reconstruct-architecture <scope>` and follow `docs/brownfield-reconstruction-workflow.md`

## Project Types

| Type | Guide | Key differentiators |
|------|-------|-------------------|
| [Web Frontend](#web-frontend) | [web-frontend/](web-frontend/) | Design-first, component-driven, Figma integration, visual testing |
| [Backend API](#backend-api) | [backend-api/](backend-api/) | Contract-first, OpenAPI, DB migrations, no UI |
| [Full-Stack Web App](#full-stack-web) | [full-stack-web/](full-stack-web/) | Combined frontend + backend, monorepo or split, Figma + OpenAPI |
| [Mobile](#mobile) | [mobile/](mobile/) | App Store release cycles, platform test layers, device farms |
| [Microservices / Platform](#microservices) | [microservices/](microservices/) | Cross-service contracts, API versioning, service ownership |
| [Data / ML Pipeline](#data-ml) | [data-ml/](data-ml/) | Notebooks, feature pipelines, model evaluation as acceptance criteria |
| [CLI / Developer Tool](#cli-devtool) | [cli-devtool/](cli-devtool/) | Backward compatibility, semver, changelog, public API surface |
| [Embedded / Firmware](#embedded-firmware) | [embedded-firmware/](embedded-firmware/) | Hardware-in-the-loop, device flashing, safety constraints |
| [Infrastructure / IaC](#infrastructure-iac) | [infrastructure-iac/](infrastructure-iac/) | Terraform/CloudFormation/Ansible, drift detection, blast radius |

## The framework stays open

These guides are **starting points, not constraints**. You can:

- Mix types (e.g. a monorepo with a `web-frontend` + `backend-api` guide applied to different subdirectories)
- Add custom `conventions` entries for your team's specific rules
- Override any gate policy in `config.json` or `org.yaml`
- Add component profiles under `.sdlc/profiles/components/` for specific modules
- Write custom `.instructions.md` files scoped to specific file globs

The `_template/` directory contains the baseline scaffold every guide builds on.

## Adding a new project type

Copy `_template/` to a new directory, fill in the placeholders, and open a PR. See `_template/GUIDE.md` for the expected structure.
