//
//  CoveAPIItemRepository.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/18/26.
//

import Foundation

/// Stub implementation of `ItemRepository` backed by `cove-api`.
///
/// Every method throws `RepositoryError.decodingFailed` until Phase 3
/// fleshes it out with real `cove-product` calls. Wiring it in place now
/// means the Phase 3 swap requires only a one-line DI change in `AppState`.
final class CoveAPIItemRepository: ItemRepository {
    func fetchHome() async throws -> [any Item] {
        throw RepositoryError.decodingFailed("fetchHome not implemented — lands in Phase 3")
    }

    func fetchProduct(id: String) async throws -> any Item {
        throw RepositoryError.decodingFailed("fetchProduct not implemented — lands in Phase 3")
    }

    func fetchDetails(for item: any Item) async throws -> any ItemDetails {
        throw RepositoryError.decodingFailed("fetchDetails not implemented — lands in Phase 3")
    }

    func fetchSimilarProducts(categoryId: String, limit: Int) async throws -> [any Item] {
        throw RepositoryError.decodingFailed("fetchSimilarProducts not implemented — lands in Phase 3")
    }

    func fetchProducts(inCategories categoryIds: [String]) async throws -> [any Item] {
        throw RepositoryError.decodingFailed("fetchProducts(inCategories:) not implemented — lands in Phase 3")
    }

    func fetchProducts(withIds ids: [String]) async throws -> [any Item] {
        throw RepositoryError.decodingFailed("fetchProducts(withIds:) not implemented — lands in Phase 3")
    }

    func fetchBrands() async throws -> [Brand] {
        throw RepositoryError.decodingFailed("fetchBrands not implemented — lands in Phase 3")
    }
}
