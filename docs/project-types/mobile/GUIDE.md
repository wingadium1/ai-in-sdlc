# Project Type Guide: Mobile

Mobile projects involve unique SDLC challenges compared to web or backend services. Developers must navigate rigid App Store release cycles, manage platform-specific testing layers on simulators and physical devices, and account for offline-first data persistence. OS version fragmentation, deep link routing, and push notification delivery add further complexity to the development and verification process.

## What's Different Per Phase

| Phase | Key Mobile Considerations |
| :--- | :--- |
| **Intake** | Requirements often originate from high-fidelity Figma mobile designs. Bug reports are frequently derived from crash reporting tools like Sentry or Crashlytics and user reviews on the App Store or Play Store. |
| **Define** | Acceptance criteria must specify target OS versions, supported device form factors (phone vs. tablet), offline behavior expectations, deep link routing, and push notification payload structures. |
| **Decide** | Technical decisions must cover native vs. cross-platform component selection, offline sync strategies (optimistic vs. pessimistic UI), navigation stack impact, and compliance with App Store permission guidelines. |
| **Produce** | AI-driven scaffold mode is recommended to generate screen shells and ViewModel/Presenter logic. Human developers finalize complex animations and ensure platform-specific UX polish. |
| **Verify** | Testing requires a four-layer approach: unit tests for logic, UI component previews (SwiftUI/Compose/Storybook), simulator-based E2E (Detox/XCUITest/Espresso), and device farm runs for critical paths. |
| **Approve** | New permissions (camera, location, contacts) require a mandatory human gate due to App Store review risks. Changes to in-app purchase flows require legal and business sign-off. |
| **Integrate** | Builds are distributed via TestFlight or Firebase App Distribution for QA testing. Every release requires a documented changelog entry. |

## Quick Setup

- **Native (iOS/Android):** Follow standard Xcode or Android Studio project initialization. Use Swift/SwiftUI for iOS and Kotlin/Jetpack Compose for Android.
- **React Native / Expo:** Use the Expo CLI for rapid development and managed deployments. Ensure the TypeScript template is applied.

## Recommended Canonical Examples

- **Screen / ViewController:** A presentational component that renders UI based on state and forwards user actions.
- **ViewModel / Presenter:** A logic-heavy unit that manages screen state, side effects, and business rules without direct UI dependencies.
- **Repository:** A data layer that abstracts network calls and implements offline caching via local storage (CoreData, Room, or SQLite).
- **Navigation Config:** A centralized routing file defining the app's stack, tab, and drawer navigators alongside deep link patterns.
- **UI Test:** A test script verifying a user flow (e.g., login) on a simulator using an E2E framework.

## Common Conventions

1. Use ViewModels for all business logic; keep Views "dumb" and presentational.
2. Never make direct network calls from a View or ViewController.
3. Explicitly handle loading, error, and empty states for every data-driven screen.
4. Utilize Dependency Injection to manage service and repository instances.
5. Avoid hardcoded strings; use localization files for all user-facing text.
6. Respect safe area insets to avoid UI overlap with notches or home indicators.
7. Implement optimistic UI updates for a more responsive user experience.
8. Use platform-specific design tokens (human interface guidelines vs. material design) where appropriate.
9. Modularize features to keep the build time manageable and code readable.
10. Ensure all assets (icons, images) are provided in appropriate resolutions (@2x, @3x).

## Component Profiles

- **`auth-flow.yaml`**: Standard login, registration, and password recovery flow with secure token storage.
- **`payments.yaml`**: Handles in-app purchases (IAP), which is treated as a high-risk special module requiring rigorous validation.

## Platform-Specific Notes

- **Swift (iOS):** Emphasize memory management (ARC) and protocol-oriented programming.
- **Kotlin (Android):** Focus on coroutines for concurrency and strict adherence to lifecycle events.
- **React Native:** Prioritize performance by avoiding unnecessary re-renders and using native-driven animations.

## Team Checklist

- [ ] Target OS versions confirmed and configured.
- [ ] Offline behavior defined for all network-dependent features.
- [ ] Deep link and push notification schemas documented.
- [ ] UI tested on both small and large screen form factors.
- [ ] All new permissions justified for App Store review.
- [ ] Build distribution pipelines verified (TestFlight/Firebase).
