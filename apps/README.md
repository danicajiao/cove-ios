# Apps

Deployable units of the monorepo — client apps and backend services. Each
subdirectory owns its own build tooling and CI workflow.

| Unit | Stack | Status |
|---|---|---|
| `ios/` | Swift / SwiftUI, Firebase | Active |
| `cove-api/` | Go gateway (Firebase token validation, `/health`) | Active (Phase 1) |
| `web/` | TBD | Planned |

Backend services follow the `cove-<name>` convention (e.g. `cove-api/`); later
phases add `cove-image/`, `cove-product/`, and `cove-user/` here. Cross-app
concerns (shared types, design tokens) live in `../packages/`.
