//
//  ItemRepository.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/18/26.
//

import Foundation

/// Abstraction over all product-catalogue reads.
///
/// ViewModels depend on this protocol rather than on a specific data source.
/// Swap the injected implementation (Firebase, CoveAPI, mock) without touching any ViewModel.
///
/// **Ordering:** `fetchHome()` and `fetchProducts(inCategories:)` return results in
/// insertion order as determined by the backing store. No stable sort is guaranteed
/// across implementations.
///
/// **Polymorphism:** All methods that return `[any Item]` or `any Item` may
/// return any concrete type conforming to `Product` (e.g. `CoffeeItem`, `MusicItem`,
/// `ApparelItem`). Callers should use `is` / `as?` casts or the `categoryId` field
/// to dispatch to the correct concrete type.
protocol ItemRepository {
    /// Fetches the full product catalogue for the home feed.
    func fetchHome() async throws -> [any Item]

    /// Fetches a single product by its unique ID.
    ///
    /// - Throws: `RepositoryError.notFound` when no product exists for the given ID.
    func fetchProduct(id: String) async throws -> any Item

    /// Fetches the type-specific detail document for a product.
    ///
    /// The returned `ItemDetails` concrete type is determined by the product's
    /// `categoryId` — callers cast to `CoffeeItemDetails`, `MusicItemDetails`,
    /// or `ApparelItemDetails` as needed.
    func fetchDetails(for item: any Item) async throws -> any ItemDetails

    /// Fetches products in the same category as `categoryId`, capped at `limit` results.
    ///
    /// Used by `ItemDetailViewModel` to populate the "similar products" shelf.
    /// Results may include the source product itself — callers are responsible for
    /// filtering it out if needed.
    func fetchSimilarProducts(categoryId: String, limit: Int) async throws -> [any Item]

    /// Fetches products whose `categoryId` is in the provided set.
    ///
    /// Used by `BagViewModel` to populate the "you might also like" shelf alongside
    /// bag items. Implementations may cap the result set internally.
    func fetchProducts(inCategories categoryIds: [String]) async throws -> [any Item]

    /// Fetches products whose document IDs are in the provided set.
    ///
    /// Used by `FavoritesViewModel` to hydrate the favourites list from persisted
    /// product IDs. Implementations must batch queries when `ids` exceeds 30 elements
    /// to stay within Firestore's `in` operator limit (or the equivalent backend limit).
    func fetchProducts(withIds ids: [String]) async throws -> [any Item]

    /// Fetches all brands.
    func fetchBrands() async throws -> [Brand]
}
