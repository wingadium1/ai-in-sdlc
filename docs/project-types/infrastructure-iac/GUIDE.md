# Project Type Guide: Infrastructure / IaC

Infrastructure as Code (IaC) projects differ from standard application development because a bug can result in immediate production downtime, data loss, or significant security vulnerabilities. The blast radius of a single change to a shared VPC, IAM role, or database instance can affect every service in the organization.

In this SDLC model, "tests" are primarily `terraform plan` diffs and automated security scans. Cost impact and compliance are first-class acceptance criteria. Common tools include Terraform, CloudFormation, Pulumi, AWS CDK, Ansible, and Helm.

## Phase Deviations

| Phase | How it differs for Infrastructure / IaC |
| :--- | :--- |
| **Intake** | Requests originate from app teams (new resources), security audits, cost reviews, or compliance requirements. Every request must identify the target environment (dev/staging/prod) and estimate the blast radius. |
| **Define** | Acceptance criteria must specify resources affected (create/modify/destroy), expected `terraform plan` summary, a clear rollback procedure, estimated cost delta, and explicit IAM/Security Group changes. |
| **Decide** | Requires blast radius analysis to identify dependencies. Decide on module reuse vs. new resource creation and state backend locking. Classification of change: in-place update, new resource, or resource replacement (downtime). |
| **Produce** | AI operates in **scaffold mode only**. It generates Terraform/Ansible code with TODO comments for values requiring team knowledge (Account IDs, AMI IDs, CIDR ranges). No production secrets or IDs are ever generated. |
| **Verify** | Focuses on `terraform validate`, `terraform plan`, security scans (tflint/checkov), cost estimation (Infracost), and compliance checks against the organization's security baseline. |
| **Approve** | Mandatory for all production changes. Required for any change modifying IAM, security groups, network topology, database instances, or resources exceeding a specific monthly cost threshold. |
| **Integrate** | Execution occurs via CI/CD pipelines (Terraform Cloud, Atlantis, GitHub Actions). Manual `apply` is forbidden. Changes are documented in an infrastructure changelog, and state is stored in a remote backend. |

## Environment Promotion Model

Changes promote through isolated environments, each with its own independent state:
1. **Dev**: Sandbox for testing new modules and resource configurations.
2. **Staging**: Mirror of production for verifying plan outputs and integration.
3. **Prod**: Final target, requiring strict approval and pipeline execution.

## State Management

Terraform state files are **never** stored in the `.sdlc/` directory. They reside in a remote backend like S3, GCS, or Terraform Cloud. The `.sdlc/` directory stores metadata, plan outputs, and human decisions regarding the infrastructure lifecycle.

## Security Baseline

Organization-specific security rules should be defined in `org.yaml`. Examples include:
- S3 buckets must have encryption enabled.
- Security groups must not allow `0.0.0.0/0` on port 22.
- IAM policies must not use wildcards for sensitive actions.

## Common Conventions

- **Modules over Inline**: Use reusable modules for anything used more than once.
- **Variables for Environments**: All environment-specific values must be parameterized.
- **Outputs for References**: Use outputs for cross-stack or cross-module references.
- **No Hardcoded IDs**: Never hardcode Account IDs, VPC IDs, or Subnet IDs.
- **Remote State**: A remote backend with state locking is mandatory.
- **Tag Everything**: All resources must have tags for Environment, Team, and Service.
- **Idempotency**: Every change must produce the same result when applied twice.
- **Explicit Deletions**: Any resource destruction must be flagged and manually confirmed.
- **CI/CD Only**: Production `apply` only happens in the pipeline.
- **Document Decisions**: Use the `.sdlc/` folder to track why infrastructure changes were made.

## Brownfield Reconstruction Priorities

Infrastructure/IaC brownfield work should start from runtime and blast-radius reality, not from abstract application views. When documentation is missing, use `/reconstruct-architecture <scope>` to recover the smallest operationally relevant slice.

Recommended priority order:

1. **`deployment-view`** — recover environments, runtime boundaries, trust zones, and where critical resources actually live. Start here with the available template in `docs/artifact-templates/`.
2. **`migration-view`** — recover change-path and rollout intent when the active work affects stateful resources, replacements, or environment promotion. Use the dedicated template in `docs/artifact-templates/`.
3. **`runbook-view`** — recover rollback and operator procedure when failure handling is unclear. Use the dedicated template in `docs/artifact-templates/`.
4. **`contract-view`** — recover externally consumed infrastructure interfaces such as shared modules, platform contracts, or pipeline expectations when they affect other teams.
5. **`context-view`** — recover broader boundary context when platform ownership or cross-system dependencies are unclear.

Typical starting points:

- **Blast-radius review** → `deployment-view`
- **Stateful resource replacement** → `deployment-view` + `migration-view`
- **Operational recovery uncertainty** → `runbook-view` + `deployment-view`
- **Shared platform/IaC module change** → `contract-view` + `deployment-view`

## Team Checklist

- [ ] Has the blast radius been analyzed and documented?
- [ ] Does the `terraform plan` show any unexpected resource replacements?
- [ ] Are all new resources correctly tagged according to the org policy?
- [ ] Has a security scan (Checkov/TFLint) been performed?
- [ ] Is there a verified rollback procedure for this change?
- [ ] Has the cost impact been estimated and approved?
