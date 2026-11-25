# CLAUDE.md — guidance for Claude (Claude Agent in Xcode / Claude Code)

## Project

SwiftUI iOS app template. iOS 17+, Swift 6 language mode (strict concurrency), no third-party dependencies.
The Xcode project is **generated** from `project.yml` by XcodeGen. Never edit `StarterApp.xcodeproj` by hand.

## Commands

- Generate project: `xcodegen generate` (run after adding, removing or renaming files)
- Run all tests: `./scripts/test.sh`
- Build only: `xcodebuild build -project StarterApp.xcodeproj -scheme StarterApp -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO`

## Architecture (MVVM + dependency injection)

```
App/
  StarterApp.swift          entry point; creates AppEnvironment
  RootView.swift            tab layout
  Core/
    AppEnvironment.swift    dependency container (live vs mock)
    AppConfig.swift         base URLs and static config
    Networking/             APIClient, Endpoint, APIError
  Features/<Feature>/
    <Model>.swift           Codable, Sendable value types
    <Feature>Service.swift  protocol + Remote… + Mock… implementations
    <Feature>ViewModel.swift @MainActor @Observable, all UI logic
    <Feature>View.swift     SwiftUI only, no business logic
Tests/
  StarterAppTests/          Swift Testing (`import Testing`, `@Test`, `#expect`)
  StarterAppUITests/        XCTest UI tests; app launched with `-uiTesting`
```

## Rules

1. Views hold no business logic. Put it in a `@MainActor @Observable` view model.
2. View models depend on service **protocols**, never on `APIClient` directly.
3. Every service has a `Mock…` implementation used by previews and tests.
4. Register new services in `AppEnvironment` (both `bootstrap` and `preview`).
5. Models are `struct`s conforming to `Codable, Sendable` (plus `Identifiable, Hashable` when listed).
6. Use `async/await`. No Combine, no completion handlers, no `DispatchQueue`.
7. Every new view gets a `#Preview` for loaded, empty and error states where relevant.
8. Every new view model gets unit tests in `Tests/StarterAppTests`.
9. Add `accessibilityIdentifier`s to elements UI tests need to find.
10. Never put API keys or secrets in the app. Call our backend, which holds the keys.

## Adding a feature (checklist)

1. Create `App/Features/<Name>/` with model, service (protocol + Remote + Mock), view model, view.
2. Add the service to `AppEnvironment`.
3. Add a tab in `RootView` or a navigation link from an existing screen.
4. Write tests, run `xcodegen generate`, then `./scripts/test.sh`. All tests must pass.
5. Check the SwiftUI previews visually.
