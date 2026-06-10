//
//  CoveAPIFavoritesRepository.swift
//
//  Created by Daniel Cajiao on 5/18/26.
//

import Foundation

/// `FavoritesRepository` implementation backed by the cove-api gateway → cove-user service.
///
/// Uses `GET /users/me/favorites`, `POST /users/me/favorites/{itemId}`, and
/// `DELETE /users/me/favorites/{itemId}`. Both `add` and `remove` are idempotent —
/// 409 (already favorited) and 404 (not favorited) are treated as success.
///
/// The `categoryId` parameter in `add(itemId:categoryId:uid:)` is accepted for
/// protocol conformance but not forwarded to the API; cove-user resolves the
/// item's category from its own store.
final class CoveAPIFavoritesRepository: FavoritesRepository {
    // MARK: - Properties

    private let api: CoveAPIClient

    // MARK: - Init

    init(api: CoveAPIClient = .shared) {
        self.api = api
    }

    // MARK: - FavoritesRepository

    func listFavorites(uid: String) async throws -> [FavoriteItem] {
        let response = try await api.favorites()
        return response.favorites.map { fav in
            FavoriteItem(id: fav.item_id, itemId: fav.item_id, categoryId: nil)
        }
    }

    func add(itemId: String, categoryId: String, uid: String) async throws {
        try await api.addFavorite(itemId: itemId)
    }

    func remove(itemId: String, uid: String) async throws {
        try await api.removeFavorite(itemId: itemId)
    }
}
