//
//  FirebaseImageRepository.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/18/26.
//

import Foundation

/// Firebase Storage-backed implementation of `ImageRepository`.
///
/// > Important: Deprecated. Product and brand images have been migrated from
/// > Firebase Storage to Garage object storage. This implementation always throws
/// > `RepositoryError.notFound`. It will be removed in Phase 3 (danicajiao/cove#248).
@available(*, deprecated, message: "Images have migrated to Garage. Use CoveAPIImageRepository. Removed in #248.")
final class FirebaseImageRepository: ImageRepository {
    func imageURL(for key: String) async throws -> URL {
        throw RepositoryError.notFound
    }
}
