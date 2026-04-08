---
applyTo: "src/**"
name: "SDLC Microservices Rules"
---

## 1. Phase Contract
Every change must flow through the defined SDLC phases. For microservices, the **Define** and **Decide** phases must explicitly address cross-service impacts.

## 2. Service Boundary Rule
This service owns its own database. Never share a database with another service. Never call another service's database directly. Communication must happen through APIs or asynchronous events.

## 3. Contract-First
Any change to a published API or event schema must start with updating the contract spec, such as OpenAPI, AsyncAPI, or Pact. The spec change is the primary artifact that gates the **Decide** phase.

## 4. Cross-Service Calls
Use the service client abstraction for all external requests. Never perform raw HTTP calls inside business logic. Implement timeouts and circuit breaking at the client layer to ensure system resilience.

## 5. Event-Driven
Event producers must publish to a schema registry. Event consumers must validate incoming messages against the registered schema before processing. Dead letter queue (DLQ) handling is required for all consumers.

## 6. Error Handling
Distinguish between transient errors that warrant a retry and permanent errors that should be sent to a DLQ or trigger an alert. Log correlation IDs on all errors to allow cross-service tracing. Never swallow errors silently.

## 7. Observability
Every request and event must emit a structured log containing: service name, correlation ID, duration, and outcome. A health check endpoint with `/health` and `/ready` paths must be implemented and maintained.

## 8. Auth
Service-to-service authentication should be handled via mTLS or service account tokens. Do not reuse user JWTs for internal service calls. User identity should be propagated through the request context, not re-validated at every service hop.

## 9. Testing
Unit tests are required for domain logic. Integration tests must cover database interactions. Contract tests are mandatory for all API and event contracts. End-to-end (E2E) tests are managed at the platform level, not by individual services.

## 10. What to Never Do
- No direct cross-service database queries.
- No undocumented event schema changes.
- No synchronous calls for non-critical paths.
- No missing health or readiness endpoints.
- No hardcoded service URLs; use service discovery mechanisms.

## 11. Artifact Traceability Rule
Every code change must be traceable back to a `PhasePacket` in `.sdlc/phases/`. Contract changes must reference the specific version of the design artifact they implement.
