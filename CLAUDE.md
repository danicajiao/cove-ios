# Cove iOS — Claude Context

## Project Overview

Cove is an iOS app built with SwiftUI following MVVM architecture. It uses Firebase (Auth, Firestore, Storage) for backend, CocoaPods for dependency management, and targets iOS 18+.

See `docs/` for architecture details: `APP_ARCHITECTURE.md`, `QUICK_START.md`, `CI_CD_WORKFLOWS.md`.

---

## Branch Naming

Format: `<label>/<issue-id>-<description-in-kebab-case>`

| Label | Use |
|---|---|
| `feature/` | New screens or user-facing functionality |
| `enhancement/` | Improvements to existing features |
| `bug/` | Bug fixes |
| `docs/` | Documentation-only changes |
| `chore/` | Maintenance, config, tooling |

Examples:
- `feature/137-profile-view-model`
- `enhancement/66-improve-tab-navigation`
- `bug/3-fix-login-crash`
- `docs/update-readme`

---

## Commit Messages

Imperative mood, sentence case.

```
Add ProfileViewModel with Firebase Auth user data
```

- Start with a verb: `Add`, `Update`, `Fix`, `Refactor`, `Remove`, `Build`
- Keep the subject line under 72 characters
- PR merge commits include the PR number: `Build ProfileRowView (#145)`

---

## Code Conventions

### Architecture — MVVM

- **Views** (`Views/`, `Components/`): SwiftUI only, no business logic
- **ViewModels** (`View Models/`): `ObservableObject`, marked `@MainActor`, one per major view
- **Models** (`Models/`): Data structures and global state (e.g. `AppState`, `Bag`)
- **Enums** (`Enums/`): Shared enum types (`ProductTypes`); note that `AuthState`, `AuthMethod`, and `Path` are currently defined in `Models/AppState.swift`
- **Styles** (`Styles/`): Custom `PrimitiveButtonStyle` implementations

### Naming

- Types: `PascalCase` — `HomeView`, `ProductDetailViewModel`, `CoffeeProduct`
- Properties/variables: `camelCase` — `viewModel`, `productId`, `averageColor`
- Files: match the primary type — `HomeView.swift` contains `struct HomeView: View`

### View Patterns

```swift
// Top-level screen: owns the ViewModel
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var appState: AppState
}

// Child component: receives ViewModel from parent
struct ProfileHeaderView: View {
    @ObservedObject var viewModel: ProfileViewModel
}

// Complex views: extract content into a private struct
private struct ProductDetailContent: View { ... }
```

- Use `@StateObject` when the view owns and instantiates the ViewModel
- Use `@ObservedObject` when passing a ViewModel down to a child component
- Use `@EnvironmentObject` for global state (`AppState`, `Bag`)
- Extract large `body` blocks into private structs or computed properties
- Include `#Preview` at the bottom of every view file
- Wrap async Firebase calls in `Task { try await viewModel.fetch...() }` inside `.onAppear`

### Colors & Fonts

Always use the centralized color and font systems — never hardcode values.

```swift
// Colors
Color.Colors.Backgrounds.primary
Color.Colors.Fills.secondary
Color.Colors.Brand.accent

// Fonts
Font.custom("Gazpacho-Black", size: 25)   // headings
Font.custom("Lato-Bold", size: 16)         // subheadings
Font.custom("Lato-Regular", size: 14)      // body
```

### Formatting

- Indentation: 4 spaces
- Max line width: 150 characters (SwiftFormat), 200 warning / 250 error (SwiftLint)
- No semicolons
- Run SwiftFormat before committing (config in `.swiftformat`)

---

## File Organization

```
Cove/
├── Supporting Files/   # App entry point
├── Models/             # Data + global state
├── View Models/        # Business logic
├── Views/              # Screens (subfolders group related views, e.g. Profile/)
├── Components/         # Reusable UI components
├── Styles/             # Button styles and view modifiers
├── Enums/              # Shared enum types
└── Resources/          # Assets, fonts, Rive animations
```

Group new views in a subfolder when they belong to the same feature screen (e.g., `Views/Profile/`).

---

## Agent Workflows

Claude agents run in isolated git worktrees — each agent gets its own directory on disk and its own branch, allowing multiple agents to work on the codebase simultaneously without interfering with each other.

### Full Pipeline

```
github-project-planner
  └── creates epic + sub-issues on GitHub
        └── sub-issue (e.g. ui/ux + figma) is picked up by an agent
              └── harness spins up a worktree: branch claude/<name>, isolated directory
                    └── agent renames branch: feature/<issue-id>-<desc>
                          └── agent implements, commits, pushes
                                └── PR created with "Closes #<issue-id>"
                                      └── PR merged → issue auto-closed
```

Multiple sub-issues can be in-flight simultaneously, each in its own worktree, each on its own branch. They never touch each other's files.

### When you are running as an agent in a worktree

- You are already on an isolated branch (initially named `claude/<worktree-name>`) — do not run `git checkout -b`
- Rename the branch to follow the naming convention before pushing: `git branch -m <label>/<issue-id>-<description>`
- Commit and push your changes to that branch
- Open a PR targeting `main` with `Closes #<issue-id>` in the description

### Issue-to-agent routing

| Sub-issue labels | Handled by |
|---|---|
| `ui/ux` + `figma` | `figma-ui-implementer` |
| `docs` | `documentation-maintainer` |
| planning / epics | `github-project-planner` |
