---
applyTo: "**"
name: "SDLC Full-Stack Web Rules"
---

# SDLC Full-Stack Web Rules

## 1. Phase Contract
Every development cycle must produce a PhasePacket that identifies dependencies between frontend and backend changes. If a change touches both layers, the Produce plan must explicitly sequence backend work before frontend work.

## 2. Layer Separation Rule
Identify upfront whether a change touches frontend-only, backend-only, or both. For full-stack changes, implementation must follow this order:
1.  **Schema**: Update database models or API definitions.
2.  **API**: Implement the backend logic and expose the endpoint.
3.  **UI**: Build the interface using the new API.

## 3. Frontend Rules
-   Use functional components with TypeScript for all UI elements.
-   Rely on design tokens for styling to ensure consistency.
-   Ensure all new features meet accessibility standards.
-   Write component tests using React Testing Library (RTL).

## 4. Backend / Server Rules
-   Adopt a contract-first approach for all services.
-   Use typed errors to provide clear failure reasons.
-   Validate all data at the boundary (Zod or similar).
-   Keep route handlers thin; place business logic in dedicated service files.

## 5. API Contract Rules
-   Maintain shared types in a single canonical location (e.g., `src/types/api.ts`).
-   Never duplicate type definitions across layers.
-   If using tRPC, the router is the single source of truth for the contract. Never bypass the router for internal data flows.

## 6. Data Fetching
-   Use Server Components to fetch data directly on the server whenever possible.
-   Use hooks or Server Actions for client-side interactivity and mutations.
-   Strictly forbid calling the database or Prisma directly from any client component.

## 7. Authentication
-   Perform all authentication and authorization checks server-side.
-   Verify permissions before returning any data or executing any action.
-   Never rely on client-side state for access control.

## 8. E2E Tests
-   Every new user-visible feature requires at least one E2E test.
-   Tests must cover the full vertical slice: UI action -> API call -> DB update -> UI state verification.

## 9. What to NEVER do
-   Never query the database from the client.
-   Never duplicate type definitions between frontend and backend.
-   Never skip the implementation order (Schema -> API -> UI) for full-stack tasks.
-   Never hardcode API URLs in the frontend; use environment variables or typed routers.

## 10. Artifact Traceability Rule
Ensure every code change links back to its corresponding ticket and phase definition in the `.sdlc/` directory.
