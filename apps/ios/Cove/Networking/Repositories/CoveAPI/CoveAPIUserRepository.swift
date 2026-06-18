//
//  CoveAPIUserRepository.swift
//
//  Created by Daniel Cajiao on 5/18/26.
//

import Foundation

/// `UserRepository` implementation backed by the cove-api gateway → cove-user service.
///
/// `updateProfile` is a no-op for now — `PATCH /users/me` is not in the current
/// API spec. Profile mutation support will be added in a future issue.
final class CoveAPIUserRepository: UserRepository {
    // MARK: - Properties

    private let api: CoveAPIClient

    // MARK: - Init

    init(api: CoveAPIClient = .shared) {
        self.api = api
    }

    // MARK: - UserRepository

    func fetchProfile(uid: String) async throws -> UserProfile {
        let profile = try await api.me()
        return UserProfile(
            id: profile.uid,
            displayName: profile.username,
            email: nil,
            photoURL: nil,
            createdAt: profile.created_at
        )
    }

    /// No-op: `PATCH /users/me` is not yet defined in the API spec.
    ///
    /// Profile mutation support will be added in a future issue once the
    /// cove-user service exposes an update endpoint.
    func updateProfile(_ profile: UserProfile) async throws {
        // Deferred to a future issue (#325 or similar).
    }
}
