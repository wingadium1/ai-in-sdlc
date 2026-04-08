# Project Type Guide: Web Frontend

This guide explains how to use the ai-in-sdlc framework for Web Frontend projects. It covers modern stacks including React, Vue, Angular, and Svelte, usually paired with TypeScript, Vite or webpack, and testing tools like Vitest, Jest, Playwright, or Cypress.

## What's different about this type

Frontend development is heavily visual and component-driven. The 7-phase SDLC process adapts to these requirements as follows:

| Phase | Difference for Frontend | Key Focus |
| :--- | :--- | :--- |
| **Intake** | Requirements often originate from Figma mockups, design tickets, or UX research rather than just text-based user stories. | Visual intent capture |
| **Define** | Acceptance criteria must specify visual behavior, responsive breakpoints, accessibility (WCAG), and interaction states. | Component specifications |
| **Decide** | Focuses on component architecture (Atomic Design, feature-based), state management strategy, and bundle impact analysis. | Architectural choices |
| **Produce** | AI generates component shells and logic. Humans typically finalize visual polish and ensure adherence to design tokens. | Scaffolded implementation |
| **Verify** | Adds visual regression testing (Storybook, Percy, Chromatic) and bundle size budget checks to standard unit/e2e tests. | Visual and perf audits |
| **Approve** | Requires a formal design review. A designer or design system owner must sign off on the visual and UX output. | Human-in-the-loop UX gate |
| **Integrate** | New components must be accompanied by Storybook stories or documentation in the local component library. | Documentation & library sync |

## Quick Setup

To enable the Web Frontend specialization in your project:

1. Create a `.sdlc/` directory in your project root if it doesn't exist.
2. Copy the [project.yaml](./project.yaml) template to `.sdlc/profiles/project.yaml`.
3. Copy the [sdlc-web-frontend.instructions.md](./sdlc-web-frontend.instructions.md) file to your repository (e.g., `.github/copilot-instructions.md`).
4. Run `/sdlc-init` or the equivalent initialization command for your agent.

## Recommended Canonical Examples

Use these patterns to help the AI understand your architecture:

- `src/components/Button/Button.tsx`: An atomic component with multiple variants and states.
- `src/features/auth/LoginForm.tsx`: A feature-level component handling complex user interaction and API calls.
- `src/hooks/useAuth.ts`: A custom React hook for shared logic and state.
- `src/components/layout/Sidebar/Sidebar.stories.tsx`: A Storybook story demonstrating component permutations.
- `src/api/userService.ts`: A clean data-fetching layer using axios or fetch.

## Common Conventions

1. **Functional Components**: Use functional components with hooks only. Avoid class components.
2. **Co-located Tests**: Keep `.test.tsx` or `.spec.ts` files in the same directory as the component.
3. **Named Exports**: Use named exports instead of default exports for better IDE support and tree shaking.
4. **Design Tokens**: Never hardcode colors or spacing. Always use CSS variables or theme tokens.
5. **A11y First**: Include ARIA labels, proper semantic HTML, and ensure keyboard navigability from the start.
6. **Props Interfaces**: Always define a TypeScript interface for component props directly above the component.
7. **No Prop Drilling**: Use Context API or state management libraries for data needed deeper than two levels.
8. **Semantic Versioning**: Follow semver for internal component library updates.
9. **Responsive Design**: Use a mobile-first approach with defined breakpoints in your styling system.
10. **Error Boundaries**: Wrap major features in error boundaries to prevent app-wide crashes.

## Component Profiles

For projects using a central design system, create `.sdlc/profiles/components/design-system.yaml`. This profile should define the mapping between your UI library and the local component wrappers, ensuring the AI uses the correct base components and theme props.

## Team Customization Checklist

- [ ] Define the CSS methodology (Tailwind, CSS Modules, Styled Components).
- [ ] Set up visual regression testing tokens in CI.
- [ ] Define the state management library (Zustand, Redux, TanStack Store).
- [ ] Map existing design tokens to the AI configuration.
- [ ] Choose the documentation standard (Storybook, Docz, Docusaurus).
