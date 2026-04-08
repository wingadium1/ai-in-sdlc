---
applyTo: "src/**"
name: "SDLC Web Frontend Rules"
---

# SDLC Web Frontend Rules

These rules apply the ai-in-sdlc framework to web frontend projects. You must follow these instructions for all development, refactoring, and maintenance tasks within the `src/` directory.

## 1. Phase Contract

- Before acting, always read the `.sdlc/profiles/project.yaml` file to understand the current stack and conventions.
- Always load the prior `PhasePacket` from `.sdlc/phases/{work-item-id}/{prior-phase}.json` to maintain context and traceability.
- Ensure every change maps back to a specific requirement or architecture decision defined in earlier phases.

## 2. Component Generation Rules

- Use functional components with React hooks exclusively.
- Define a TypeScript interface for component props directly above the component definition.
- Prefer named exports over default exports for better tree shaking and IDE navigation.
- Every new component must include a co-located test file (`*.test.tsx`) using React Testing Library.
- Design system components must include a co-located Storybook story file (`*.stories.tsx`).

## 3. State Management

- Do not drill props beyond two levels deep.
- Use the project's designated state management library (defined in `project.yaml`) or the Context API for shared state.
- Never derive state from other state during the render cycle; use `useMemo` for expensive derivations.
- Keep state as local as possible to minimize unnecessary re-renders.

## 4. Styling

- Use design tokens or CSS variables for colors, typography, and spacing.
- Never hardcode visual values in the component code.
- Follow the project's CSS methodology (e.g., Tailwind, CSS Modules, or Styled Components) as specified in `project.yaml`.
- Use a mobile-first responsive design approach with standard breakpoints.

## 5. Accessibility (A11y)

- Use semantic HTML elements (e.g., `<button>` instead of `<div onClick>`).
- Every interactive element must have a visible label or an `aria-label`.
- Ensure all interactive features are fully navigable and operable via keyboard.
- Maintain a logical heading structure (`h1` through `h6`).

## 6. Testing

- Focus on testing user behavior and accessibility, not internal implementation details.
- Use `Testing Library` queries in order of priority: `getByRole` > `getByLabelText` > `getByText`.
- Avoid snapshot tests for business logic; use them only for verifying stable UI structures.
- Ensure test coverage for both "happy path" and error states.

## 7. What to Never Do

- Never use class-based components.
- Never use inline `style` props for static styling.
- Never use the `any` TypeScript type; use `unknown` if the type is truly dynamic.
- Never manipulate the DOM directly; always work through the framework's state/refs.
- Never hardcode strings that should be localized via an i18n system.

## 8. Artifact Traceability Rule

Every new or modified file must include a comment or metadata entry referencing the WorkItem ID it relates to, ensuring a clear link between the code and the SDLC requirements.
