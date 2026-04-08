# Project Type Guide: Full-Stack Web App

Full-stack web applications combine frontend and backend layers into a single repository or a tightly coupled monorepo. This setup allows for rapid iteration but introduces a synchronization challenge: changes often touch both layers simultaneously. The primary concern is maintaining a consistent API contract between the frontend UI and the backend services.

## Phase Differences

| Phase | Key Considerations |
| :--- | :--- |
| **Intake** | Tickets must describe end-to-end flows. Documentation should specify what the user sees (UI) and what the system performs (Backend). Both UI and API acceptance criteria are needed from the start. |
| **Define** | Separate acceptance criteria into UI behavior and API contract. Clearly identify which layers are affected. Full-stack changes require both sets of criteria to be clearly defined. |
| **Decide** | Impact analysis must span both layers. Any API contract change on the backend has an immediate frontend impact. Execution order must be planned: schema first, then API, then UI. Schemas (tRPC, GraphQL, Prisma) are primary artifacts. |
| **Produce** | Strict dependency order is required: 1) DB migration, 2) API/schema updates, 3) Frontend implementation. The Produce plan must explicitly declare this order. |
| **Verify** | Both test suites must pass. Verification requires E2E tests covering the full vertical slice: UI action triggers API call, which updates DB, which finally updates UI state. |
| **Approve** | For API contract changes, both frontend and backend leads must approve. In smaller teams, a single tech lead owning the full stack can sign off. |
| **Integrate** | Use a single PR for both layers. Ensure migrations run automatically in CI. New components should include a Storybook story. |

## Quick Setup

For full-stack projects, consider maintaining two sets of `canonical_examples` in your configuration: one for frontend patterns (components, hooks) and one for backend patterns (routes, services, DB queries).

## Conventions

1.  **Contract-First Development**: Define the API or schema before implementing the UI.
2.  **Shared Types**: Keep API types in a canonical location (`src/types/api.ts`) or auto-generate from Prisma/tRPC.
3.  **Co-located Logic**: Use Next.js Server Actions or tRPC procedures to keep server logic close to the components that use it.
4.  **Error Handling**: Use typed errors at the boundary.
5.  **Validation**: Always validate data at the API entry point (e.g., using Zod).
6.  **Environment Variables**: Distinguish between `PUBLIC_` (frontend) and secret (backend) variables.
7.  **Data Fetching**: Prefer Server Components for initial data loads.
8.  **Loading States**: Implement consistent loading patterns (skeletons) for all async actions.
9.  **Database Access**: Never access the database directly from client-side code.
10. **Authentication**: Verify auth server-side for every protected route and action.
11. **Test Coverage**: Maintain a balance between unit tests for logic and E2E tests for flows.
12. **Styling**: Use a single utility-first framework like Tailwind across the entire UI.

## Component Profiles

Split project components into distinct profiles for clearer instructions:

-   `frontend.yaml`: Focuses on React, styling, and client-side interactions.
-   `backend.yaml`: Focuses on Node.js, Prisma, and API logic.

## Monorepos

For monorepos using `packages/` or `apps/`, consider placing a separate `project.yaml` in each package directory. This allows the AI to adapt its behavior specifically for the library or application it's currently modifying.

## Team Checklist

- [ ] Is the API contract defined and agreed upon?
- [ ] Are the database migrations identified?
- [ ] Do E2E tests cover the new vertical slice?
- [ ] Are environment variables updated in all environments?
- [ ] Is the dependency order (DB -> API -> UI) reflected in the plan?
