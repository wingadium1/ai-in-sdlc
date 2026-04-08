---
applyTo: "src/**"
name: "SDLC Mobile Rules"
---

# SDLC Mobile Rules

## 1. Phase Contract
All mobile development must adhere to the defined phase model (Intake, Define, Decide, Produce, Verify, Approve, Integrate). No code is produced without an approved PhasePacket containing explicit mobile-first criteria.

## 2. Screen Architecture
Every screen must be split into a View component and a ViewModel hook.
- **View:** Purely presentational ("dumb"). It only renders UI based on props or state passed from the ViewModel.
- **ViewModel:** Contains all screen-specific logic, side effects, and state management.
- **Restriction:** No business logic or direct API calls are allowed in the View component.

## 3. State Management
Use the global state management library specified in `project.yaml` (e.g., Zustand or Redux).
- **Rule:** Never use local `useState` for shared state that belongs in the global store.
- **Context:** Use the global store for data that must persist across multiple screens or app sessions.

## 4. Navigation
All navigation configurations must reside in a central navigator file.
- **Rule:** Never navigate programmatically from within a ViewModel. Instead, dispatch a navigation action or use a callback handled by the View.
- **Deep Links:** Define and handle all deep link routing schemas within the central navigator.

## 5. Data & Offline Behavior
Every network request must have a declared offline strategy.
- **Strategies:** Show cached stale data, display a user-friendly offline message, or block the action with a retry option.
- **Restriction:** Never allow a network request to fail silently without informing the user or handling the state.

## 6. Platform Differences
Handle variations between iOS and Android explicitly.
- **Rule:** Use `Platform.select()` or platform-specific file extensions (`.ios.tsx`, `.android.tsx`) for styles and UI behavior.
- **Restriction:** Never include platform-specific code in shared ViewModel logic.

## 7. Permissions
Request system permissions (camera, location, contacts) lazily.
- **Rule:** Trigger the permission request at the exact moment the feature is accessed, rather than on app launch.
- **Graceful Failure:** Always handle cases where a user denies or revokes a permission without crashing or breaking the app flow.

## 8. Performance
Mobile performance is critical for user retention.
- **Lists:** Use `FlatList` for long or dynamic lists; never use `ScrollView` with `.map()`.
- **Optimization:** Memoize expensive computations and avoid creating inline functions within the render cycle of list items.

## 9. Testing
Maintain a robust testing pyramid.
- **Unit Tests:** Test ViewModel logic and business rules with plain unit tests (no React renderer required).
- **Component Tests:** Verify user interactions and UI rendering using Testing Library.
- **E2E Tests:** Use Detox or a similar framework to verify critical user flows on a simulator or device.

## 10. What to Never Do
- No network calls directly in the View.
- No navigation logic inside the ViewModel.
- No hardcoded colors, spacing, or typography outside the defined design tokens.
- No untested permission requests.
- No synchronous storage reads (e.g., AsyncStorage) within the render cycle.

## 11. Artifact Traceability Rule
Every commit and PR must reference the corresponding WorkItem and PhaseID to maintain a clear audit trail from requirement to implementation.
