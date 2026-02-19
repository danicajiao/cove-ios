# Initiative: HomeViewModel Reliability & Favorites Feature

## Overview

This initiative tracks all work needed to make product fetching and favorites reliable,
performant, and maintainable in the Cove iOS app.

**Goal:** Deliver a production-quality `HomeViewModel` that loads products efficiently,
marks favorites correctly at scale, and exposes clean Swift concurrency patterns to
serve as the architectural template for future ViewModels.

**Milestone label:** `backend` · `enhancement` · `bug`

---

## Sub-issues

| # | Title | Labels | Status |
|---|-------|--------|--------|
| [#57](https://github.com/danicajiao/cove-ios/issues/57) | Implement pagination for product fetching in HomeViewModel | `enhancement` `backend` | 🟡 Open |
| [#58](https://github.com/danicajiao/cove-ios/issues/58) | Fix Firebase `in` query limit for favorites fetching | `bug` `backend` | 🟡 Open |
| [#59](https://github.com/danicajiao/cove-ios/issues/59) | Improve error handling in favorites processing loop | `bug` `backend` | 🟡 Open |
| [#60](https://github.com/danicajiao/cove-ios/issues/60) | Implement proper caching/refresh strategy for products | `enhancement` `backend` | 🟡 Open |
| [#61](https://github.com/danicajiao/cove-ios/issues/61) | Remove unnecessary `MainActor.run` usage in HomeViewModel | `enhancement` `backend` | 🟡 Open |

---

## Acceptance Criteria

- [ ] Product list loads with pagination (≤ 20 items per page)
- [ ] Favorites are resolved correctly even when > 30 products are fetched (#58)
- [ ] A corrupted favorite document does not abort the entire fetch loop (#59)
- [ ] Returning to HomeView after favoriting a product elsewhere reflects the updated state (#60)
- [ ] `HomeViewModel` uses idiomatic Swift concurrency without unnecessary `MainActor.run` wrappers (#61)

---

## Technical Notes

All sub-issues target `Cove/View Models/HomeViewModel.swift`.  
Recommended implementation order: **#61 → #59 → #58 → #57 → #60** (cleanest diff path).

### Quick reference – files affected

```
Cove/View Models/HomeViewModel.swift   ← primary file
Cove/Views/HomeView.swift              ← pull-to-refresh (part of #60)
```

---

## Dependencies

None. All sub-issues are independent and can be worked in parallel after #61 lands.

---

## How this document was generated

This initiative was created by the GitHub Copilot coding agent using the following
GitHub MCP read tools to discover and compile existing open issues:

- `github-mcp-server-list_issues` — enumerated all open issues in the repository
- `github-mcp-server-issue_read` — read individual issue details
- `github-mcp-server-get_label` — verified label metadata
- `github-mcp-server-list_issue_types` — checked for configured issue types (none found)

> **Note:** GitHub MCP write tools (`github/issue_write`, `github/sub_issue_write`) were
> not available in the current agent toolset. This document serves as the initiative
> artefact; actual GitHub issues for any net-new sub-issues should be created via the
> implementation-planner agent or the GitHub web UI.
