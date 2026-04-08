---
applyTo: "**/*.{tf,tfvars,yml,yaml,json}"
name: "SDLC Infrastructure / IaC Rules"
---

# SDLC Infrastructure / IaC Rules

## 1. Phase Contract
Every infrastructure change must follow the PhasePacket lifecycle. The `Decide` phase must include a `risk_flags` assessment of the change's impact on existing resources.

## 2. Blast Radius First
Identify all resources, services, or teams affected by the change before writing code. Document this in the PhasePacket. Changes affecting shared VPCs, IAM roles, or core network components require extra scrutiny and high-level approval.

## 3. No Secrets in Code
Never hardcode credentials, account IDs, access keys, or passwords. Use Parameter Store, Secrets Manager, or environment variables. Any string resembling a secret must be treated as one.

## 4. Module-First
Prefer reusable modules over inline resource blocks. Every module input and output must include a `description` field for clarity and documentation.

## 5. Idempotency
Every infrastructure change must be idempotent. Applying the same configuration twice must produce the identical result. Explicitly document any resource that requires destruction and recreation.

## 6. Resource Tagging
All cloud resources must be tagged. Required tags include:
- `Environment` (dev, staging, prod)
- `Team` (owner)
- `Service/Project` (purpose)
- `ManagedBy` (terraform, pulumi, etc.)

## 7. State Management
Manual state edits are forbidden. State must be stored in a remote backend with locking enabled. Production `apply` operations must occur only within the CI/CD pipeline.

## 8. Security Scanning
All IaC must pass security rules (Checkov, TFLint) before merge. The following violations are non-negotiable:
- S3 buckets with public access.
- Security groups allowing `0.0.0.0/0` on sensitive ports.
- Unencrypted databases or volumes.
- IAM policies using wildcards (`*`) for broad permissions.

## 9. Plan Review
The `terraform plan` output is the primary review artifact. Reviewers must verify:
- No unexpected resource replacements.
- No unintended deletions.
- Acceptable cost delta.
- Security group and IAM changes are within the requested scope.

## 10. Prohibited Actions
- No hardcoded secrets or credentials.
- No manual state manipulation.
- No `apply` without a reviewed `plan`.
- No untagged resources.
- No wildcard IAM permissions.
- No open security groups (`0.0.0.0/0`).
- No production `apply` from local machines.

## 11. Artifact Traceability
Every resource created must be traceable to a specific WorkItem ID and PhasePacket decision. This ensures auditability and long-term maintenance clarity.
