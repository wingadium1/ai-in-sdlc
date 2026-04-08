---
applyTo: "src/**"
name: "SDLC Backend API Rules"
---

# SDLC Backend API Rules

## 1. Phase Contract
Every Backend API work item must advance through the mandated SDLC phases: Intake → Define → Decide → Produce → Verify → Approve → Integrate. No skipping phases.

## 2. Contract-First Rule
You must create or update the OpenAPI spec or shared type definitions BEFORE implementing any route handler. Link the specification change directly to the requirement in the `Decide` phase packet.

## 3. Layering Architecture
Adhere strictly to the Route → Service → Repository pattern. 
- **Routes**: Orchestration, validation, and response formatting only.
- **Services**: Business logic, domain rules, and cross-repository coordination.
- **Repositories**: Database access and data mapping only.
No skipping layers. Never perform database queries directly in route handlers. Do not include business logic in repositories.

## 4. Error Handling
Define typed error classes for domain failures. Catch all exceptions at the route boundary. Never expose internal stack traces or database error messages in API responses. Always return a standardized error envelope: `{ error: { code, message } }`.

## 5. Input Validation
Validate all inputs at the route entry point using the project's designated validator (e.g., Zod, Joi). Do not trust incoming data inside the service or repository layers.

## 6. Database Migrations
Every database schema change requires a dedicated migration file. Migrations must be reversible (Up/Down). Never mutate the production schema manually or through an ORM's auto-sync feature in production environments.

## 7. Authentication and Authorization
Never implement authentication logic inline within routes. Use centralized middleware for token verification and scope checks. Verify permissions before any data access occurs in the service layer.

## 8. Testing Strategy
- **Unit Tests**: Test the service layer in isolation by mocking all repository dependencies.
- **Integration Tests**: Test the routes using a real test database (not mocks). Verify end-to-end behavior from request to database state change.
Ensure every distinct behavior has at least one associated test.

## 9. Prohibited Practices
- No direct database queries in route handlers.
- No raw SQL strings unless specifically justified. Use the project's ORM.
- No silent catch blocks. Always log or rethrow errors.
- No hardcoded credentials. Use environment variables.
- No synchronous file I/O in the request path.

## 10. Artifact Traceability
Every code change must be traceable back to a `PhasePacket` and its associated `WorkItem`. Update the design artifacts in `.sdlc/artifacts/` whenever the API contract or data model changes.
