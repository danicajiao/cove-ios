//
//  CoveAPIUserRepository.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/18/26.
//

import Foundation

/// Stub implementation of `UserRepository` backed by `cove-api`.
///
/// Every method throws `RepositoryError.decodingFailed` until Phase 3
/// fleshes it out with real `cove-user` calls.
final class CoveAPIUserRepository: UserRepository {
    func fetchProfile(uid: String) async throws -> UserProfile {
        throw RepositoryError.decodingFailed("fetchProfile not implemented — lands in Phase 3")
    }

    func updateProfile(_ profile: UserProfile) async throws {
        throw RepositoryError.decodingFailed("updateProfile not implemented — lands in Phase 3")
    }
}
