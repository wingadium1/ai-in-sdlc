# Project Type Guide: Microservices / Platform

Microservices and platform projects involve multiple services or a monorepo where each component is often owned by a different team. The primary challenge is coordination. A change in one service can break others. Cross-service contracts like REST APIs, gRPC definitions, and event schemas are the most important artifacts. Blast radius analysis is required for every change.

## What is Different Per Phase

| Phase | Microservices Specifics |
| :--- | :--- |
| **Intake** | Tickets must identify which services are affected. Cross-service changes require linked coordination tickets across relevant teams. |
| **Define** | Acceptance criteria must include: services involved, the cross-service contract (request/response or event schema), service owners (from `actors/`), and SLA/latency requirements. |
| **Decide** | Check if the change breaks existing consumers. Run a backward-compatibility check. Decisions are required for: new endpoints, changed event schemas, new service dependencies, or breaking changes in existing APIs. Gate always fires for cross-service contract changes. |
| **Produce** | Each service follows its own `project.yaml`. Use per-service profiles under `.sdlc/profiles/components/`. Contract changes should be implemented in consumer-first order or hidden behind feature flags. |
| **Verify** | Consumer-driven contract tests (e.g., Pact) run alongside service unit and integration tests. Event schemas must be validated against the registry. |
| **Approve** | Cross-service contract changes require approval from all consuming service owners. Use `actors/` to identify the required approvers. |
| **Integrate** | Contract specs are published to the schema registry. Consuming teams are notified. A deprecation timeline must be set for any removed endpoints. |

## Service Ownership Model

Use `.sdlc/actors/` to define service owners. Each service should have a clear owner or team assigned. This ensures that when a contract change is proposed, the correct human gates are triggered during the **Approve** phase.

## Multi-Repo Note

The framework typically runs per-service. In a multi-repo setup, each service has its own `.sdlc/` directory. The AI operates within the context of that specific service while referencing shared contracts.

## Cross-Service Contract Artifacts

Store API contracts, such as OpenAPI specs or AsyncAPI definitions, in `.sdlc/artifacts/design-artifact/`. These serve as the source of truth for code generation and verification.

## Recommended Canonical Examples

- **Service Entry Point**: A standardized main file with configuration loading and plugin registration.
- **Event Handler**: A pattern for consuming events, including schema validation and error handling.
- **Contract Test (Pact)**: A test case defining the interaction between a provider and a consumer.
- **Health Check Endpoint**: Standard implementation of `/health` and `/ready` checks.
- **Service Client**: A typed abstraction for calling another service, including retries and circuit breaking.

## Common Conventions

1. **Contract-First**: Always update the cross-service contract before implementing the change.
2. **No Shared DBs**: Never access another service's database directly. Use APIs or events.
3. **Async Preference**: Use asynchronous events for non-critical paths to improve system resilience.
4. **Health Endpoints**: Every service must implement `/health` and `/ready` endpoints.
5. **Circuit Breakers**: Wrap all external service calls in circuit breakers.
6. **Correlation IDs**: Pass correlation IDs through all requests and events for tracing.
7. **Structured Logging**: Log in a machine-readable format with standard metadata.
8. **Statelessness**: Services should be stateless to allow easy scaling.
9. **Backward Compatibility**: Maintain support for at least one previous version of an API.
10. **Schema Validation**: Validate all incoming events against a registered schema.

## Work Type Overrides

Microservices benefit from explicit work type overrides because the same task name can hide very different operational risk. In this template, `debugging` starts with correlation IDs and consumer impact, while `code-review` requires contract compatibility and blast-radius analysis. See [project.yaml](project.yaml) for concrete `work_type_overrides` examples.

## Brownfield Reconstruction Priorities

When onboarding into an existing microservices platform with incomplete docs, do **not** try to recover the whole architecture first. Start from the smallest risky slice and use `/reconstruct-architecture <scope>` together with the templates in `docs/artifact-templates/`.

Recommended priority order:

1. **`contract-view`** — recover API/event/schema ownership first. In microservices, broken understanding of contracts is the fastest path to cross-service incidents.
2. **`interaction-view`** — recover the critical flow being changed or debugged (for example: checkout payment flow, user registration flow, notification dispatch flow).
3. **`deployment-view`** — recover runtime placement and network boundaries when rollout order, queues, ingress, or service discovery affect risk.
4. **`container-view`** — recover static service/runtime units when ownership and topology are unclear.
5. **`context-view`** — recover higher-level boundary views when the platform or external-system edges are still poorly understood.

Typical starting points:

- **Cross-service bug** → `interaction-view` + `contract-view`
- **Breaking API/event review** → `contract-view` + `deployment-view`
- **New team onboarding** → `context-view` + `container-view`
- **Incident/postmortem recovery** → `interaction-view` + `deployment-view`

## Team Checklist

- [ ] Is the service owner defined in `.sdlc/actors/`?
- [ ] Has the blast radius been analyzed?
- [ ] Is the contract updated in `.sdlc/artifacts/design-artifact/`?
- [ ] Are consumer-driven contract tests passing?
- [ ] Is there a rollback plan for the deployment?
