//
//  CoveAPIImageRepository.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/18/26.
//

import Foundation

/// Stub implementation of `ImageRepository` backed by `cove-api`.
///
/// Every method throws `RepositoryError.decodingFailed` until Phase 2
/// fleshes it out with real `cove-image` calls.
final class CoveAPIImageRepository: ImageRepository {
    func imageURL(for productId: String) async throws -> URL {
        throw RepositoryError.decodingFailed("imageURL not implemented — lands in Phase 2")
    }
}
