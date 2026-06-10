//
//  UserRepository.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/18/26.
//

import Foundation

/// Abstraction over user profile reads and writes.
protocol UserRepository {
    /// Fetches the profile for the given Firebase UID.
    ///
    /// Throws `CoveAPIError.unexpectedStatus(404)` if no profile exists yet.
    /// Profile creation is handled by the username onboarding screen.
    ///
    /// - Parameter uid: The Firebase Auth UID of the user whose profile to fetch.
    func fetchProfile(uid: String) async throws -> UserProfile

    /// Persists changes to an existing user profile.
    ///
    /// The `profile.id` field must match an existing record. Implementations
    /// should perform a partial update (merge) rather than a full overwrite so
    /// that concurrent writes to different fields do not conflict.
    ///
    /// - Parameter profile: The updated profile to persist.
    func updateProfile(_ profile: UserProfile) async throws
}
