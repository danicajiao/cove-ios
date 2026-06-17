# iOS App Architecture

This document covers the Cove iOS app's architecture — how it's structured, how data flows, and how key systems work.

## Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Authentication & Navigation](#authentication--navigation)
- [Tab Structure](#tab-structure)
- [ViewModels](#viewmodels)
- [Global State](#global-state)
- [Networking](#networking)
- [Product Type System](#product-type-system)
- [Firebase Data Model](#firebase-data-model)
- [Key Data Flows](#key-data-flows)
- [Not Yet Implemented](#not-yet-implemented)
- [Phase 3 migration: what changes](#phase-3-migration-what-changes)

---

## Overview

Cove uses **MVVM (Model-View-ViewModel)** with SwiftUI. State is managed through a combination of `@StateObject`, `@EnvironmentObject`, and `@Published` properties.

The app talks to two separate backends:
- **Firebase** — Auth (sign-in) and Firestore (structured data). Accessed directly through the Firebase iOS SDK. Firebase Storage was retired in Phase 2.
- **cove-api gateway** — the custom K3s-hosted backend. All calls go through `CoveAPIClient`, which is generated from the gateway's OpenAPI spec. Image loading goes through this path via `CoveAPIImageRepository`.

---

## Project Structure

```
apps/ios/Cove/
├── Supporting Files/     # App entry point (CoveApp.swift), Info.plist
├── Models/               # Data models and global state (AppState, Bag, TabState, etc.)
│                         #   Note: Path, AuthState, AuthMethod enums are defined in AppState.swift
├── View Models/          # Business logic (HomeViewModel, FavoritesViewModel, etc.)
├── Views/                # SwiftUI views organized by feature
│   ├── Profile/          # ProfileHeaderView, StatsRowView, ProfileRowView
│   └── ...               # HomeView, BagView, ProductDetailView, auth views
├── Components/           # Reusable UI components (ProductCard, LikeButton, SmallCategoryButton, etc.)
├── Styles/               # Custom button styles and shadow modifiers
├── Enums/                # ProductTypes (Firestore era), AuthPath
├── Constants/            # Design token constants (Spacing.swift, Radius.swift)
└── Resources/            # Assets, fonts (Gazpacho, Lato), Rive animations
```

---

## Authentication & Navigation

### Auth-Driven Routing

`CoveApp` is the root of the app. It reads `AppState.authState` to decide which UI to show:

```
CoveApp
├── authState == .loggedIn  →  MainView (tab bar)
└── authState == .loggedOut →  NavigationStack (auth flow)
    ├── network available   →  WelcomeView
    └── no network          →  SplashView
```

`AppState` holds `@Published var authState: AuthState`. When a user successfully signs in, `authState` flips to `.loggedIn`, which triggers `CoveApp` to rebuild and show `MainView`. Auth navigation is owned locally by `CoveApp` via `@State private var authPath: [AuthPath]`, which is reset to `[]` via `.onChange(of: appState.authState)` on logout.

### Supported Auth Methods

| Method | Provider |
|--------|----------|
| Email/Password | Firebase Auth |
| Google | GoogleSignIn SDK → Firebase Auth |
| Facebook | FBSDKLoginKit → Firebase Auth |
| Apple | Planned, not yet implemented |

### Navigation Enums

`AuthPath` drives the auth `NavigationStack` in `CoveApp`. It is defined in `Enums/AuthPath.swift`:

```swift
enum AuthPath: Hashable {
    case login
    case signup
}
```

`Path` drives in-app navigation within `TabNavigationStack`. It is defined in `Models/AppState.swift` alongside `AuthState` and `AuthMethod`:

```swift
enum Path: Hashable {
    case welcome
    case login
    case signup
    case main
    case home
    case product(id: String)
}
```

---

## Tab Structure

`MainView` hosts a `TabView` with 5 tabs. Each tab is wrapped in a `TabNavigationStack` to support in-tab navigation (e.g., tapping a product from the Home tab pushes `ProductDetailView` without leaving the tab).

| Tab | Tag | View | Status |
|-----|-----|------|--------|
| Home | `"home"` | `HomeView` | Implemented |
| Browse | `"browse"` | Placeholder `Text` | Not implemented |
| Bag | `"bag"` | `BagView` | Implemented (badge shows item count) |
| Favorites | `"favorites"` | `FavoritesView` | Implemented |
| Profile | `"profile"` | `ProfileView` | Implemented |

Tab selection is managed by `TabState` (`Models/TabState.swift`) — an `ObservableObject` that tracks `currentTab` and `previousTab` as `String` values matching the tab tags above.

---

## ViewModels

### HomeViewModel
Serves `HomeView`. Fetches all products and brands via the `ProductRepository` protocol (currently backed by `FirebaseProductRepository`). Products are cached in-memory with a 5-minute TTL; `fetchProducts()` early-returns unless the cache is expired or `forceRefresh` is true. Also publishes a static `categories` list used by the `SmallCategoryButton` row, and an `origins` list for display purposes.

### ProductDetailViewModel
Serves `ProductDetailView`. Initialized with a `productId`, it runs three async fetches on init: the product itself, its type-specific details, and up to 5 similar products (same `categoryId`). Also manages `detailSelection` — the currently active tab (Description / Origin / Tracklist / Specifications / About), which varies by product type.

### BagViewModel
Serves `BagView`. Manages the user's bag — products they intend to purchase or revisit. Fetches product recommendations based on the categories of items in the bag.

### FavoritesViewModel
Serves `FavoritesView`. Fetches the current user's favorited products via the `FavoritesRepository` and `ProductRepository` protocols (currently backed by Firebase). Reads favorite product IDs, then hydrates each one by fetching the corresponding product document. Publishes `favorites: [any Product]` and `isLoading`.

### ProfileViewModel
Serves `ProfileView`. Lightweight — all data is derived from `Auth.auth().currentUser` (display name, initials, photo URL, member since date). No repository calls, no local state mutations.

---

## Global State

### AppState
Injected at the root via `.environmentObject`. Owns:
- `authState` — drives the root UI split between auth flow and main app
- All sign-in/sign-out methods for every auth provider

### Bag
`Bag` (`Models/Bag.swift`) is injected at the root (`CoveApp`) via `.environmentObject` and available throughout the app. Owns:
- `items: [BagItem]` — products the user has added to their bag
- `totalItems: Int` — computed count used to badge the Bag tab
- `categories: [String]` — categoryIds of items in the bag, used to fetch recommendations in `BagViewModel`

### FavoritesStore
Injected at the root (`CoveApp`) via `.environmentObject` and available throughout the entire app. Owns:
- `favoriteIds: Set<String>` — the set of favorited product IDs for the current user
- `isTogglingFavorite: Bool` — prevents concurrent toggle operations
- Listens to `Auth.auth().addStateDidChangeListener` to load favorites on sign-in and clear them on sign-out
- `toggle(_:categoryId:)` — optimistically updates `favoriteIds` locally, then syncs to Firestore
- Used by `LikeButton` to read and mutate favorite state across all views

---

## Networking

The app has two completely separate networking tracks. They never share code.

```
Firebase SDK                        cove-api gateway
(Google-managed infrastructure)     (K3s homelab, Cloudflare Tunnel)

FirebaseAuth  ─────────────────►  Auth token issuance only
FirebaseFirestore ─────────────►  Structured data (current; retired in Phase 3)
FirebaseStorage ───────────────►  (retired in Phase 2 — unlinked from Xcode target)

                                  CoveAPIClient ──────────────────►  cove-api
                                  (all gateway calls go here,
                                   including image loading via
                                   CoveAPIImageRepository)
```

### APIEnvironment

`APIEnvironment` selects the server URL at compile time:

```swift
// Debug builds → staging-api.coveapp.dev
// Release builds → api.coveapp.dev
static var current: APIEnvironment {
    #if DEBUG
        return .staging
    #else
        return .production
    #endif
}
```

This means TestFlight builds hit staging automatically; App Store builds hit production. No runtime toggle, no Info.plist key.

---

### CoveAPIClient

`CoveAPIClient` is the only path the iOS app uses to call cove-api. It wraps a generated `Client` struct produced by `swift-openapi-generator` from the gateway's OpenAPI spec.

**How the generation works:**

```
services/cove-api/api/openapi.yaml          ← backend source of truth
        │
        │  manual copy when spec changes:
        │  cp services/cove-api/api/openapi.yaml \
        │     apps/ios/Cove/Networking/Generated/openapi.yaml
        ▼
Cove/Networking/Generated/
  openapi.yaml                          ← iOS copy of the spec
  openapi-generator-config.yaml         ← instructs plugin: generate types + client
        │
        │  ⌘B triggers the OpenAPIGenerator build plugin
        ▼
DerivedData/.../GeneratedSources/       ← never checked in, never edited
  Types.swift                           ← Components.Schemas.* structs
  Client.swift                          ← one typed method per API operation
        │
        │  compiled into the app binary alongside hand-written code
        ▼
Cove/Networking/CoveAPIClient.swift     ← thin wrapper, what ViewModels call
```

The generated files live in DerivedData and are never committed. They recompile automatically whenever `openapi.yaml` changes.

**What `CoveAPIClient` adds on top of the generated `Client`:**

| Concern | How it's handled |
|---|---|
| Server URL | `APIEnvironment.current.baseURL` — staging in Debug, prod in Release |
| Auth | `FirebaseAuthMiddleware` injects `Authorization: Bearer <token>` on every request |
| Response unwrapping | Each method switches over the generated response enum and returns a plain Swift type |
| Shared instance | `CoveAPIClient.shared` for standard use; injectable `serverURL` + `session` for tests |

**Calling an endpoint:**

```swift
// What a ViewModel or repository calls:
let health = try await CoveAPIClient.shared.health()
// health.service == "cove-api"
// health.status  == "ok"
// health.commit  == "a3f8c12"
```

---

### FirebaseAuthMiddleware

A `ClientMiddleware` that runs on every outgoing request to cove-api. It fetches the current Firebase user's ID token and injects it as a Bearer header before forwarding the request.

```
CoveAPIClient.shared.health()
    │
    ├─ FirebaseAuthMiddleware.intercept(...)
    │    ├─ Auth.auth().currentUser? → get ID token
    │    └─ request.headerFields[.authorization] = "Bearer <token>"
    │
    ├─ URLSessionTransport sends HTTP request to staging-api.coveapp.dev
    │
    └─ response decoded into Components.Schemas.HealthResponse
```

Routes that opt out of auth (e.g. `GET /health`) receive the header anyway — the gateway ignores it. This keeps the middleware unconditional with no per-route branching.

If no user is signed in the request is forwarded without a header. Unauthenticated routes continue to work; protected routes receive a 401 from the gateway.

---

### Adding a new gateway endpoint

When a new route is added to cove-api:

1. Backend adds the route to `services/cove-api/api/openapi.yaml`
2. Copy the updated spec into iOS:
   ```bash
   cp services/cove-api/api/openapi.yaml apps/ios/Cove/Networking/Generated/openapi.yaml
   ```
3. Build (`⌘B`) — the plugin regenerates `Types.swift` and `Client.swift`
4. Add a method to `CoveAPIClient.swift` that calls the generated method and unwraps the response

---

### ImageRepository — protocol and active implementation

Image loading is abstracted behind the `ImageRepository` protocol (`Networking/Repositories/ImageRepository.swift`). Views access it through the SwiftUI environment; `CoveApp` injects the concrete implementation at the root via `\.imageRepository`.

```swift
// Protocol — key-based: takes the Garage object key directly
protocol ImageRepository: Sendable {
    func imageURL(for key: String) async throws -> URL
}
```

The environment key provides a default of `CoveAPIImageRepository()`, so views receive the correct implementation without explicit injection at each call site. Tests and Previews override it with a mock via `.environment(\.imageRepository, mock)`.

**`CoveAPIImageRepository`** is the active implementation. It:
1. Strips the `images/` prefix from the Garage key to get the bare filename
2. Calls `CoveAPIClient.shared.imageURL(filename:width:height:)` — the `GET /images/{filename}/url` gateway endpoint
3. Returns the signed imgproxy URL ready for `AsyncImage`

`FirebaseImageRepository` was removed in Phase 2. There are no remaining references to Firebase Storage in the iOS codebase.

---

## Product Type System

Products in Firestore share a common `categoryId` field. The app uses this to decode into the correct Swift type at runtime.

`ProductTypes.swift` (`Enums/ProductTypes.swift`) is a Firestore-era enum that maps human-readable category names to their Firestore document IDs. It is used exclusively by `FirebaseProductRepository` to dispatch decoding. In Phase 3 this file will be removed and categories will be served as data from `GET /categories` on `cove-api`.

### Type Mapping

```swift
enum ProductTypes: String {
    case coffee  = "8JbKssVf2zw8ryq1pace"
    case music   = "JzzwWDRpp2B5zG4TNdWx"
    case apparel = "s97tOnvbfrNtoe2VaNRQ"
}
```

### Protocol Hierarchy

```
Product (protocol)
├── CoffeeProduct   → info: CoffeeInfo  { name, roastery }
├── MusicProduct    → info: MusicInfo   { artist, album }
└── ApparelProduct  → info: ApparelInfo { brand, name }

ProductDetails (protocol)
├── CoffeeProductDetails   → description, about, origin: [OriginInfo]
├── MusicProductDetails    → description, about, tracklist: [Track]
└── ApparelProductDetails  → description, about, specifications: [Specification]
```

### Decoding Strategy

ViewModels read the raw `categoryId` from each Firestore document before decoding:

```swift
let categoryId = document["categoryId"] as? String
if categoryId == ProductTypes.coffee.rawValue {
    let product = try document.data(as: CoffeeProduct.self)
} else if categoryId == ProductTypes.music.rawValue {
    let product = try document.data(as: MusicProduct.self)
} // ...
```

`ProductDetailView` and `ProductCardView` then type-cast `any Product` back to the concrete type to access type-specific fields (e.g., `(product as? CoffeeProduct)?.info.roastery`).

---

## Firebase Data Model

### Collections

| Collection | Purpose |
|------------|---------|
| `products` | All product listings |
| `product_details` | Type-specific product details (keyed by `productDetailsId`) |
| `brands` | Brand/store info shown in the Home "Stores" section |
| `users/{uid}/favorites` | Per-user favorited product IDs |

### Product Document Structure

```
products/{productId}
  ├── categoryId: String          // Maps to ProductTypes enum
  ├── defaultPrice: Float
  ├── defaultImageURL: String     // Garage object key, e.g. "images/<sha256>.webp"
  ├── productDetailsId: String    // Foreign key to product_details
  ├── isFavorite: Bool?           // Set client-side after favorites query
  ├── createdAt: Timestamp
  └── info: { ... }              // Type-specific nested object
```

Note: `defaultImageURL` previously held a Firebase Storage `gs://` URL. As of Phase 2 it holds a Garage object key (`images/<sha256>.webp`). The same key format applies to `brands.imageURL`.

### Image Loading

Product images are loaded via the `ImageRepository` protocol injected into the SwiftUI environment. All image-loading views (`ProductCardView`, `ProductRowView`, `ProductDetailView`, `HomeView` brand logos) call `imageRepository.imageURL(for:)` with the Garage object key from Firestore, then pass the resulting signed URL to `AsyncImage`. Firebase Storage is no longer used.

---

## Key Data Flows

### App Launch → Products Displayed

```
1. CoveApp checks authState → .loggedIn
2. MainView shown with HomeView in first tab
3. HomeView.onAppear → viewModel.fetchProducts() + viewModel.fetchBrands()
4. FirebaseProductRepository → Firestore collection("products").getDocuments()
5. Each doc decoded by categoryId → CoffeeProduct / MusicProduct / ApparelProduct
6. products array published → HomeView renders ProductCard grid
7. brands array published → HomeView renders brand logo row
```

### Product Tap → Detail View

```
1. User taps ProductCard
2. NavigationLink(value: Path.product(id:)) fires
3. TabNavigationStack routes to ProductDetailView(productId:)
4. ViewModel init → async fetch: product + details + similar products
5. UI renders with type-specific tabs
```

### Add to Bag

```
1. User taps "Add to Bag" in ProductDetailView
2. Check if item already in bag.items
   ├── Yes → no-op or increment quantity
   └── No  → append new BagItem
3. bag.categories updated with product's categoryId
4. BagView badge on tab updates via bag.totalItems
```

### Sign Out

```
1. User taps "Log Out" in ProfileView → confirmation dialog
2. appState.logOut() called
3. Provider-specific cleanup (GIDSignIn.signOut() / LoginManager().logOut())
4. Firebase Auth signOut()
5. authState = .loggedOut → CoveApp resets authPath = [] → WelcomeView shown
```

---

## Not Yet Implemented

| Feature | Location |
|---------|----------|
| Browse tab | Placeholder `Text` in `MainView` |
| Search | `TextField` in `HomeView` is present but not connected |
| Bag actions | Add/remove items wired up; purchase confirmation not implemented |
| Reviews | `NavigationLink` exists in `ProductDetailView` but no destination |
| Profile editing | `ProfileRowView` items are not wired up |
| Notifications | Bell icon in `HomeView` has no action |
| Apple Sign-In | `AuthMethod.apple` referenced but sign-in flow not implemented |

---

## Phase 3 migration: what changes

Phase 3 replaces Firestore with the Postgres-backed `cove-api` gateway for all structured data. The repository abstraction (`ProductRepository`, `UserRepository`, `FavoritesRepository`) exists precisely to make this swap a one-line DI change per repository, with no ViewModel changes.

### What the migration looks like

| Layer | Before (current) | After (Phase 3) |
|---|---|---|
| Products/brands | `FirebaseProductRepository` (Firestore) | `CoveAPIProductRepository` (cove-api REST) |
| User profiles | `FirebaseUserRepository` (Firestore) | `CoveAPIUserRepository` (cove-user REST) |
| Favorites | `FirebaseFavoritesRepository` (Firestore) | `CoveAPIFavoritesRepository` (cove-user REST) |
| Images | `CoveAPIImageRepository` (already migrated) | No change |
| Categories | Hardcoded in `HomeViewModel.categories` + `SmallCategoryButton` | `GET /categories` from cove-api; `CategoryCard` component replaces `SmallCategoryButton` |
| Product types | `ProductTypes.swift` (Firestore document IDs) | Removed; categories are API data |

### Stub implementations

`CoveAPIProductRepository`, `CoveAPIUserRepository`, and `CoveAPIFavoritesRepository` are stubbed out in `Networking/Repositories/CoveAPI/` — every method currently throws `RepositoryError.decodingFailed` with a "lands in Phase 3" message. They exist to prove the DI seams work and to give Phase 3 implementers a clear target.

### Interest onboarding and personalized category cards (Phase 3)

The Phase 3 iOS scope also includes:
- **`InterestOnboardingView`** — shown at first launch after sign-in; user picks interest categories that are stored as `user.interests` rows via `POST /users/me/interests`
- **`CategoryCard`** — replaces `SmallCategoryButton`; rendered from data returned by `GET /recommendations/categories`; tapping a card triggers `GET /discovery?category=<path>&lat=...`
- **`CategoryResultsView`** — destination for category card taps; renders discovery results for a category
- **`POST /users/me/events`** — attention events (`category_tap`, `product_view`, etc.) sent after each user interaction to power behavioral recommendation ranking
