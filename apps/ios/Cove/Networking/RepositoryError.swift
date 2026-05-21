//
//  RepositoryError.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/20/26.
//

import Foundation

/// Errors thrown by `ProductRepository`, `UserRepository`, `ImageRepository`,
/// and other repository protocol implementations.
///
/// Repository errors are transport-agnostic — callers (ViewModels) never need
/// to know whether the backing store is Firestore, cove-api, or a mock.
/// Transport-specific errors (e.g. `CoveAPIError`, Firestore SDK errors) are
/// caught inside each repository implementation and mapped to these cases.
enum RepositoryError: Error {
    /// The requested resource does not exist in the backing store.
    case notFound

    /// A document or response body could not be decoded into the expected type.
    /// The associated string describes which type or field failed.
    case decodingFailed(String)
}

// MARK: - LocalizedError

extension RepositoryError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFound:
            "The requested resource was not found."
        case let .decodingFailed(detail):
            "Failed to decode server response: \(detail)"
        }
    }
}
