//
//  CoveAPIFavoritesRepository.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/18/26.
//

import Foundation

/// Stub implementation of `FavoritesRepository` backed by `cove-api`.
///
/// Every method throws `RepositoryError.decodingFailed` until Phase 3
/// fleshes it out with real `cove-user` calls (favorites live under the user service).
final class CoveAPIFavoritesRepository: FavoritesRepository {
    func listFavorites(uid: String) async throws -> [FavoriteItem] {
        throw RepositoryError.decodingFailed("listFavorites not implemented — lands in Phase 3")
    }

    func add(itemId: String, categoryId: String, uid: String) async throws {
        throw RepositoryError.decodingFailed("add not implemented — lands in Phase 3")
    }

    func remove(itemId: String, uid: String) async throws {
        throw RepositoryError.decodingFailed("remove not implemented — lands in Phase 3")
    }
}
