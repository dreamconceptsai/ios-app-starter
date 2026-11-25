# iOS App Starter

[![CI](https://github.com/dreamconceptsai/ios-app-starter/actions/workflows/ci.yml/badge.svg)](https://github.com/dreamconceptsai/ios-app-starter/actions/workflows/ci.yml)
![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![Swift 6](https://img.shields.io/badge/Swift-6-orange)
![License: MIT](https://img.shields.io/badge/license-MIT-green)

A production-ready SwiftUI starter template from **dreamconceptsai**, set up for building with **Claude agents** (Claude Agent in Xcode 26.3+ and Claude Code).

What you get:

- **SwiftUI + MVVM** using `@Observable` view models and dependency injection
- **Async/await networking layer** (`APIClient`) with typed endpoints and errors, and no third-party packages
- **Sample feature**: a list with search, filters, pull-to-refresh, optimistic updates, a detail screen, and error and empty states
- **Settings screen** with a light/dark theme picker and the app version
- **Tests**: unit tests with Swift Testing and UI tests with XCTest, using mock services so they never hit the network
- **GitHub Actions CI** that builds and tests every push and pull request (free for public repos)
- **`CLAUDE.md`** that teaches Claude the project's architecture and rules
- **XcodeGen** project spec, so there are no `.xcodeproj` merge conflicts

---

## Table of contents

1. [Prerequisites](#1-prerequisites)
2. [Create the GitHub repo under dreamconceptsai](#2-create-the-github-repo-under-dreamconceptsai)
3. [Push this code](#3-push-this-code)
4. [Generate and open the Xcode project](#4-generate-and-open-the-xcode-project)
5. [Run the app](#5-run-the-app)
6. [Run the tests](#6-run-the-tests)
7. [Build with Claude agents](#7-build-with-claude-agents)
8. [Project structure](#8-project-structure)
9. [Add your first feature (step by step)](#9-add-your-first-feature-step-by-step)
10. [Connect your own backend](#10-connect-your-own-backend)
11. [Rename the app](#11-rename-the-app)
12. [Ship to TestFlight and the App Store](#12-ship-to-testflight-and-the-app-store)
13. [Troubleshooting](#13-troubleshooting)

---

## 1. Prerequisites

| Tool | Why | Install |
|---|---|---|
| A Mac | iOS apps can only be built on macOS | — |
| **Xcode 26.3 or later** | Building, plus the built-in Claude Agent (Xcode 16+ can build the code, but has no Claude Agent) | Mac App Store |
| Homebrew | Installs command-line tools | https://brew.sh |
| XcodeGen | Generates the Xcode project | `brew install xcodegen` |
| Git | Version control | Comes with Xcode Command Line Tools: `xcode-select --install` |
| GitHub CLI (optional) | Creates the repo from the terminal | `brew install gh` |
| GitHub account `dreamconceptsai` | Hosts the repo | https://github.com |
| Paid Claude plan (Pro, Max, Team or Enterprise) | Required for Claude Agent in Xcode | https://claude.ai |
| Apple Developer Program (optional) | Only needed to run on a real device for long periods or to publish ($99/year) | https://developer.apple.com/programs |

> The Simulator is free. You can build, run and test everything here without paying Apple.

---

## 2. Create the GitHub repo under dreamconceptsai

Public repositories on GitHub are free, including GitHub Actions minutes for CI.

### Option A: GitHub website

1. Sign in to https://github.com as `dreamconceptsai` (or as a member of the `dreamconceptsai` organization).
2. Click **+** (top right) › **New repository**.
3. **Owner:** `dreamconceptsai`. **Repository name:** `ios-app-starter`.
4. Choose **Public**.
5. **Leave every "Initialize this repository" box unchecked.** Don't add a README, .gitignore or license, because this project already has them.
6. Click **Create repository**.

### Option B: GitHub CLI (creates and pushes in one step)

```bash
gh auth login                      # one time; choose GitHub.com and sign in as dreamconceptsai
cd ios-app-starter
git init -b main
git add .
git commit -m "Initial commit: iOS starter template"
gh repo create dreamconceptsai/ios-app-starter --public --source=. --remote=origin --push
```

If you used Option B, skip to step 4.

---

## 3. Push this code

From the unzipped `ios-app-starter` folder:

```bash
cd ios-app-starter
chmod +x scripts/test.sh
git init -b main
git add .
git commit -m "Initial commit: iOS starter template"
git remote add origin https://github.com/dreamconceptsai/ios-app-starter.git
git push -u origin main
```

When Git asks for a password, use a **personal access token** (GitHub › Settings › Developer settings › Personal access tokens), not your account password. Running `gh auth login` first avoids this.

After the push, open the repo's **Actions** tab to watch CI run.

---

## 4. Generate and open the Xcode project

```bash
make setup     # installs XcodeGen (one time)
make open      # generates StarterApp.xcodeproj and opens it in Xcode
```

Without `make`:

```bash
brew install xcodegen
xcodegen generate
open StarterApp.xcodeproj
```

> Re-run `xcodegen generate` whenever you **add, remove or rename files**. Files are picked up from the folders automatically, so you never edit the project file by hand.

---

## 5. Run the app

1. In Xcode, select the **StarterApp** scheme and an iPhone simulator in the toolbar.
2. Press **⌘R**.

The app loads 20 items from the free demo API [JSONPlaceholder](https://jsonplaceholder.typicode.com). Try search, the filter menu, pull-to-refresh, tapping the circle to complete an item, and the Settings tab.

### Run on your own iPhone

1. Connect the iPhone with a cable and trust the Mac.
2. In Xcode, select the **StarterApp** target › **Signing & Capabilities**.
3. Under **Team**, choose your Apple ID. A free Apple ID works for personal testing.
4. If the bundle ID is taken, change `com.dreamconceptsai.starterapp` to something unique, both here and in `project.yml`.
5. Select your iPhone in the toolbar and press **⌘R**. The first time, approve the developer profile on the phone under **Settings › General › VPN & Device Management**.

To avoid choosing the team every time, put your 10-character Team ID in `DEVELOPMENT_TEAM` in `project.yml`.

---

## 6. Run the tests

- **In Xcode:** press **⌘U**.
- **Terminal:** `make test` (or `./scripts/test.sh`)
- **Specific simulator:** `SIMULATOR_NAME="iPhone 16 Pro" ./scripts/test.sh`

| Suite | Framework | What it covers |
|---|---|---|
| `ItemsViewModelTests` | Swift Testing | loading, errors, filters, search, optimistic toggle and rollback |
| `APIClientTests` | Swift Testing | URL building, decoding, HTTP errors, bad JSON (network stubbed) |
| `StarterAppUITests` | XCTest | list shows data, navigation to detail, settings tab |

UI tests launch the app with `-uiTesting`, which swaps in `MockItemService`, so they're fast and work offline.

---

## 7. Build with Claude agents

### Option A: Claude Agent inside Xcode (recommended)

Xcode 26.3+ includes Claude Agent, built on the same Claude Agent SDK as Claude Code. It can edit many files at once, build, run tests, and check its UI work against SwiftUI Previews.

1. Open **Xcode › Settings › Intelligence**. Menu names can differ slightly between Xcode versions.
2. Add **Claude** as a provider and sign in with your Claude account (paid plan required).
3. Open the coding assistant panel, choose **Claude Agent**, and pick a model:
   - **Claude Opus 5.5**: the default for features, refactors and long agent runs
   - **Claude Sonnet 5.5**: faster and cheaper for small edits and UI tweaks
4. Claude reads `CLAUDE.md` automatically, so it already knows this project's architecture and rules.

### Option B: Claude Code in the terminal

```bash
# Install: see https://docs.claude.com/en/docs/claude-code for the current command
cd ios-app-starter
claude
```

### Example prompts that work well with this template

```text
Add a "Profile" feature following CLAUDE.md: a model, a ProfileService protocol with
Remote and Mock implementations, a view model, a view with previews for loaded/error states,
a new tab in RootView, and unit tests. Then run xcodegen generate and ./scripts/test.sh.
```

```text
Persist items locally with SwiftData so the list works offline. Keep ItemService as the
interface the view model uses. Add tests.
```

```text
Look at the ItemsView preview and improve the visual design: better spacing, a header
with progress (open vs done), and an empty state illustration using SF Symbols.
```

**Tips**

- Ask Claude to **plan first** for big changes ("Propose a plan before editing").
- Always end prompts with **"run the tests"** so the agent checks its own work.
- Commit before each agent session (`git commit -am "checkpoint"`) so you can roll back easily.
- Keep `CLAUDE.md` up to date as your conventions change. It's the agent's onboarding doc.

---

## 8. Project structure

```
ios-app-starter/
├── project.yml                     # XcodeGen spec (targets, settings, schemes)
├── Makefile                        # setup / generate / open / test / clean
├── CLAUDE.md                       # instructions for Claude agents
├── App/
│   ├── StarterApp.swift            # @main entry point
│   ├── RootView.swift              # TabView
│   ├── Core/
│   │   ├── AppEnvironment.swift    # dependency container (live vs mock)
│   │   ├── AppConfig.swift         # API base URL, links
│   │   └── Networking/
│   │       ├── APIClient.swift     # async/await URLSession client
│   │       ├── Endpoint.swift      # typed request description
│   │       └── APIError.swift      # user-friendly errors
│   ├── Features/
│   │   ├── Items/                  # sample feature (model, service, VM, views)
│   │   └── Settings/               # theme picker, app version
│   └── Resources/Assets.xcassets   # app icon, accent color
├── Tests/
│   ├── StarterAppTests/            # unit tests (Swift Testing)
│   └── StarterAppUITests/          # UI tests (XCTest)
├── scripts/test.sh                 # picks a simulator and runs all tests
└── .github/workflows/ci.yml        # GitHub Actions CI
```

**How data flows:** `View` → `ViewModel` (`@MainActor @Observable`) → `Service` protocol → `APIClient` → network.
Previews and tests swap the service for a `Mock…` implementation, so the UI and logic can be tested without a server.

---

## 9. Add your first feature (step by step)

Example: a **Notes** tab.

1. **Create the folder** `App/Features/Notes/`.
2. **Model:** `Note.swift`
   ```swift
   struct Note: Identifiable, Codable, Hashable, Sendable {
       let id: Int
       var title: String
       var body: String
   }
   ```
3. **Service:** `NoteService.swift`. Write a protocol, a `RemoteNoteService` that uses `HTTPClient` with `Endpoint<[Note]>(path: "posts")`, and a `MockNoteService` that returns sample data. Copy the pattern from `ItemService.swift`.
4. **View model:** `NotesViewModel.swift`, marked `@MainActor @Observable`, with `load()` and a `LoadState`.
5. **View:** `NotesView.swift` with `#Preview`s that use the mock.
6. **Register it:** add `let noteService: any NoteService` to `AppEnvironment` and set it in both `bootstrap()` and `preview`.
7. **Show it:** add a tab in `RootView`:
   ```swift
   NotesView(service: environment.noteService)
       .tabItem { Label("Notes", systemImage: "note.text") }
   ```
8. **Test it:** add `Tests/StarterAppTests/NotesViewModelTests.swift`.
9. Run `xcodegen generate`, then `make test`.
10. Commit and push. CI runs automatically.

Or give Claude Agent the prompt from section 7, and it will follow these same steps from `CLAUDE.md`.

---

## 10. Connect your own backend

1. Change `apiBaseURL` in `App/Core/AppConfig.swift`.
2. Update the `Endpoint` paths and model fields to match your API.
3. For authentication, add an `Authorization` header in `APIClient.makeRequest`, using a token stored in the **Keychain**, never in `UserDefaults`.

> **Never ship secret API keys (OpenAI, Anthropic, Stripe secret keys, etc.) inside the app.**
> Anyone can extract them from the app binary. Put them on your server and have the app call your server.
> To add Claude-powered features, build a small backend endpoint that calls the Claude API and have the app call that endpoint.

---

## 11. Rename the app

1. In `project.yml`, change `name`, the target names, `PRODUCT_BUNDLE_IDENTIFIER` values, and `INFOPLIST_KEY_CFBundleDisplayName`.
2. Rename `App/StarterApp.swift` and its `struct`, and update `@testable import StarterApp` in the tests.
3. Update `StarterApp.xcodeproj` and the scheme name in `scripts/test.sh` and `Makefile`.
4. Run `make clean && make open`.

(Or ask Claude: *"Rename the app from StarterApp to MyApp everywhere, including project.yml, tests, scripts and Makefile, then regenerate and run the tests."*)

---

## 12. Ship to TestFlight and the App Store

1. Join the **Apple Developer Program**.
2. In **App Store Connect** (https://appstoreconnect.apple.com), click **Apps › + › New App** and use your bundle ID.
3. Add a 1024×1024 PNG app icon to `App/Resources/Assets.xcassets/AppIcon.appiconset` (drag it into the asset catalog in Xcode).
4. Bump `MARKETING_VERSION` (for example `1.0.1`) and `CURRENT_PROJECT_VERSION` (for example `2`) in `project.yml`, then run `xcodegen generate`.
5. In Xcode, choose the **Any iOS Device (arm64)** destination, then **Product › Archive**.
6. In the Organizer window, click **Distribute App › App Store Connect › Upload**.
7. In App Store Connect, open **TestFlight** to invite testers, and submit for review when you're ready.

---

## 13. Troubleshooting

| Problem | Fix |
|---|---|
| `xcodegen: command not found` | `brew install xcodegen` |
| New file doesn't appear in Xcode | Run `xcodegen generate` |
| "Signing requires a development team" | Pick a Team under **Signing & Capabilities**, or set `DEVELOPMENT_TEAM` in `project.yml` |
| "Bundle identifier is not available" | Change `com.dreamconceptsai.starterapp` to a unique ID |
| `No iPhone simulator found` | **Xcode › Settings › Components** › install an iOS Simulator runtime |
| `./scripts/test.sh: Permission denied` | `chmod +x scripts/test.sh` and commit it |
| CI fails with a Swift version error | The runner's Xcode is too old. Pin a newer one by adding `sudo xcode-select -s /Applications/Xcode_<version>.app` before the build step |
| Claude Agent missing in Xcode | Update to Xcode 26.3+ and sign in with a paid Claude plan |
| `git push` asks for a password | Use a personal access token, or run `gh auth login` |

---

## License

MIT © dreamconceptsai. See [LICENSE](LICENSE).
