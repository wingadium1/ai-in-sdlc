# Project Type Guide: Backend API

This guide provides the framework for developing robust Backend API services. It's designed for teams building pure API layers, microservices, or headless business logic platforms without a native UI.

Common stacks supported by this guide:
* Node + Express/Fastify
* Python + FastAPI/Django
* Java + Spring Boot
* Go + Gin/Echo

## What's different per phase

| Phase | Key Focus & Behavior Changes |
| :--- | :--- |
| **Intake** | Requirements originate from OpenAPI spec changes, Jira stories defining API contracts, or production error logs. There are no UI mockups or user flow diagrams. |
| **Define** | Acceptance criteria center on API contracts (request/response shapes, status codes, error envelopes). You must define the HTTP method, path, request schema, response schemas, auth scopes, and rate limits. |
| **Decide** | Contract-first approach. Update the OpenAPI spec BEFORE writing code. Include a database migration plan for data model changes. Detect breaking vs non-breaking changes. Human gate is mandatory for any contract change. |
| **Produce** | Implementation follows the Route Handler → Service Layer → Repository Layer pattern. Tests are written first for business logic (unit tests with mocked repositories) and the route itself (integration tests). |
| **Verify** | Automated contract validation ensures the code matches the OpenAPI spec. Run migration dry-runs and verify no breaking changes exist in the diff. Maintain 80%+ unit coverage on the service layer. |
| **Approve** | Human approval is required for any API contract change, database migration, or new authentication scope. |
| **Integrate** | Migrations must run successfully in CI before merging the PR. The OpenAPI spec is updated in `.sdlc/artifacts/design-artifact/` as the final step. |

## Quick Setup

1. Copy the `project.yaml` template to your project root.
2. Ensure your OpenAPI spec is initialized in `.sdlc/artifacts/design-artifact/openapi.yaml`.
3. Configure your CI pipeline to run `db_migrate_dry_run` on every pull request.

## Recommended Canonical Examples

* **Route Handler**: A slim controller that validates input, calls a service, and returns a standardized JSON envelope.
* **Service Class**: Contains pure business logic. It's agnostic of HTTP and database implementation details.
* **Repository Class**: Encapsulates all database access (ORM or raw queries). Never include business logic here.
* **Migration File**: A reversible script (Up/Down) for schema changes.
* **Integration Test**: A test that fires an actual HTTP request against the route and verifies the database state.

## Common Conventions

1. **Contract-First**: Never write a handler without an updated API definition.
2. **Validation at Boundary**: Use a schema validator (Zod, Joi, etc.) at the entry point of every route.
3. **Typed Errors**: Use custom error classes for domain-specific failures (e.g., `NotFoundError`, `ConflictError`).
4. **No Logic in Routes**: Route handlers only handle orchestration and response formatting.
5. **Repository Pattern**: Centralize all data access to prevent DB logic leaks into services.
6. **Idempotent Endpoints**: Ensure PUT and DELETE operations can be repeated without side effects.
7. **Proper HTTP Status Codes**: Use 201 for creation, 204 for empty success, 400 for bad requests, 401 for auth issues.
8. **No Internal Leakage**: Never return internal error messages or stack traces in production API responses.
9. **Consistent Envelopes**: All error responses must follow the `{ error: { code, message } }` format.
10. **Auth via Middleware**: Secure routes using central middleware rather than inline checks.

## Component Profiles

### auth.yaml
```yaml
name: Authentication Service
scopes:
  - read:profile
  - write:profile
  - admin:all
auth_type: JWT
```

### payments.yaml
```yaml
name: Payment Gateway Integration
provider: Stripe
idempotency_header: X-Idempotency-Key
timeout_ms: 5000
```

## Team Checklist

* [ ] Is the OpenAPI spec updated?
* [ ] Does the new endpoint follow the standard error envelope?
* [ ] Are all inputs validated at the route boundary?
* [ ] Is there a migration file for any schema changes?
* [ ] Did you run a migration dry-run?
* [ ] Is the service layer unit test coverage above 80%?
* [ ] Are integration tests using a real test database?
