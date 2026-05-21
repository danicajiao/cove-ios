# App Architecture

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

---

## Overview

Cove uses **MVVM (Model-View-ViewModel)** with SwiftUI. State is managed through a combination of `@StateObject`, `@EnvironmentObject`, and `@Published` properties.

The app talks to two separate backends:
- **Firebase** — Auth (sign-in), Firestore (structured data), Cloud Storage (images). Accessed directly through the Firebase iOS SDK.
- **cove-api gateway** — the custom K3s-hosted backend. All calls go through `CoveAPIClient`, which is generated from the gateway's OpenAPI spec.

---

## Project Structure

```
apps/ios/Cove/
├── Supporting Files/     # App entry point (CoveApp.swift), Info.plist
├── Models/               # Data models and global state (AppState, VisitList, Product types)
│                         #   Also defines Path, AuthState, AuthMethod enums (in AppState.swift)
├── View Models/          # Business logic and Firestore access
├── Views/                # SwiftUI views organized by feature
│   ├── Profile/          # ProfileHeaderView, StatsRowView, ProfileRowView
│   └── ...               # HomeView, VisitListView, ProductDetailView, auth views
├── Components/           # Reusable UI components (ProductCardView, LikeButton, etc.)
├── Styles/               # Custom button styles and shadow modifiers
├── Enums/                # ProductTypes
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

`AuthPath` drives the auth `NavigationStack` in `CoveApp`:

```swift
enum AuthPath: Hashable {
    case login
    case signup
}
```

`Path` drives in-app navigation within `TabNavigationStack`:

```swift
enum Path: Hashable {
    case product(id: String)   // Product detail navigation within tabs
}
```

---

## Tab Structure

`MainView` hosts a `TabView` with 5 tabs. Each tab is wrapped in a `TabNavigationStack` to support in-tab navigation (e.g., tapping a product from the Home tab pushes `ProductDetailView` without leaving the tab).

| Tab | View | Status |
|-----|------|--------|
| Home | `HomeView` | Implemented |
| Browse | Placeholder | Not implemented |
| Visit List | `VisitListView` | In progress |
| Favorites | `FavoritesView` | Implemented |
| Profile | `ProfileView` | Implemented |

---

## ViewModels

### HomeViewModel
Serves `HomeView`. Fetches all products and brands from Firestore on first load. After fetching products, it queries the current user's favorites subcollection and marks matching products with `isFavorite = true`. Results are cached in-memory — `fetchProducts()` early-returns if `products` is already populated.

### ProductDetailViewModel
Serves `ProductDetailView`. Initialized with a `productId`, it runs three async fetches on init: the product itself, its type-specific details, and up to 5 similar products (same `categoryId`). Also manages `detailSelection` — the currently active tab (Description / Origin / Tracklist / Specifications / About), which varies by product type.

### VisitListViewModel
Serves `VisitListView`. Manages the user's Visit List — vendors and products they intend to visit in person. Tracks visit status (`pending`, `visited`) and whether a purchase was made. Fetches similar product recommendations based on the categories of items in the list.

### FavoritesViewModel
Serves `FavoritesView`. Fetches the current user's favorited products from Firestore in batches of 30 (Firestore `in` query limit). Reads the `users/{uid}/favorites` subcollection to get product IDs, then fetches the corresponding product documents and decodes them by `categoryId` into the correct concrete type. Publishes `favorites: [any Product]` and `isLoading`.

### ProfileViewModel
Serves `ProfileView`. Lightweight — all data is derived from `Auth.auth().currentUser` (display name, initials, photo URL, member since date). No Firestore reads, no local state mutations.

---

## Global State

### AppState
Injected at the root via `.environmentObject`. Owns:
- `authState` — drives the root UI split between auth flow and main app
- All sign-in/sign-out methods for every auth provider

### VisitList
Injected into `MainView` and its children via `.environmentObject`. Owns:
- `items: [VisitListItem]` — vendors and products the user wants to visit in person
- `categories: [String]` — categoryIds of items in the list, used to fetch recommendations

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
FirebaseFirestore ─────────────►  Structured data (Phase 1–2 only; Firestore retired in Phase 3)
FirebaseStorage ───────────────►  Images (Phase 1–2 only; retired in Phase 2)

                                  CoveAPIClient ──────────────────►  cove-api
                                  (all new gateway calls go here)
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

## Product Type System

Products in Firestore share a common `categoryId` field. The app uses this to decode into the correct Swift type at runtime.

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
  ├── defaultImageURL: String     // Firebase Storage URL
  ├── productDetailsId: String    // Foreign key to product_details
  ├── isFavorite: Bool?           // Set client-side after favorites query
  ├── createdAt: Timestamp
  └── info: { ... }              // Type-specific nested object
```

### Image Loading

Product images are stored in Firebase Storage. `ProductCardView` fetches them asynchronously via `Storage.storage().reference(forURL:).getData(maxSize:)`, storing the result in a `@State var uiImage`. No caching library is used — images re-fetch on each view appearance.

---

## Key Data Flows

### App Launch → Products Displayed

```
1. CoveApp checks authState → .loggedIn
2. MainView shown with HomeView in first tab
3. HomeView.onAppear → viewModel.fetchProducts()
4. Firestore query: collection("products").getDocuments()
5. Each doc decoded by categoryId → CoffeeProduct / MusicProduct / ApparelProduct
6. Favorites query: users/{uid}/favorites where productId in fetchedIds
7. Matching products marked isFavorite = true
8. products array published → HomeView renders ProductCardView grid
```

### Product Tap → Detail View

```
1. User taps ProductCardView
2. NavigationLink(value: Path.product(id:)) fires
3. TabNavigationStack routes to ProductDetailView(productId:)
4. ViewModel init → async fetch: product + details + similar products
5. UI renders with type-specific tabs
```

### Add to Visit List

```
1. User taps "Add to Visit List" in ProductDetailView or vendor page
2. Check if item already in visitList.items
   ├── Yes → no-op (already tracked)
   └── No  → append new VisitListItem with status = .pending
3. visitList.categories updated with product's categoryId
4. VisitListView onChange → VisitListViewModel.fetchSimilarProducts(categories:)
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
| Browse tab | Placeholder `Text` in MainView |
| Search | TextField in HomeView is present but not connected |
| Visit status update | Mark a visit as completed / purchased in VisitListView |
| Reviews | NavigationLink exists in ProductDetailView but no destination |
| Profile editing | ProfileRowView items are not wired up |
| Notifications | Bell icon in HomeView has no action |
| Apple Sign-In | Auth method referenced but not implemented |
