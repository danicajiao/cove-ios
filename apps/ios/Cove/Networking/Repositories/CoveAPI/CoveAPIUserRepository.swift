//
//  CoveAPIUserRepository.swift
//
//  Created by Daniel Cajiao on 5/18/26.
//

import FirebaseAuth
import Foundation

/// `UserRepository` implementation backed by the cove-api gateway → cove-user service.
///
/// `fetchProfile(uid:)` implements lazy-create semantics: on a 404, it derives a
/// username from the Firebase Auth user's email or display name and calls
/// `POST /users/me` to create the profile. Subsequent calls return the existing profile.
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
        do {
            let profile = try await api.me()
            return UserProfile(
                id: profile.uid,
                displayName: profile.username,
                email: nil,
                photoURL: nil,
                createdAt: profile.createdAt
            )
        } catch CoveAPIError.unexpectedStatus(404) {
            // No profile yet — auto-create with a username derived from the
            // Firebase Auth user's email or display name.
            let username = deriveUsername()
            do {
                let created = try await api.createMe(username: username)
                return UserProfile(
                    id: created.uid,
                    displayName: created.username,
                    email: nil,
                    photoURL: nil,
                    createdAt: created.createdAt
                )
            } catch CoveAPIError.unexpectedStatus(409) {
                // Race condition: profile was created between GET and POST.
                // Re-fetch and return it.
                let profile = try await api.me()
                return UserProfile(
                    id: profile.uid,
                    displayName: profile.username,
                    email: nil,
                    photoURL: nil,
                    createdAt: profile.createdAt
                )
            }
        }
    }

    /// No-op: `PATCH /users/me` is not yet defined in the API spec.
    ///
    /// Profile mutation support will be added in a future issue once the
    /// cove-user service exposes an update endpoint.
    func updateProfile(_ profile: UserProfile) async throws {
        // Deferred to a future issue (#325 or similar).
    }

    // MARK: - Private helpers

    /// Derives a URL-safe username from the current Firebase Auth user.
    ///
    /// Priority:
    /// 1. Display name → lower-cased, spaces replaced with underscores
    /// 2. Email prefix (part before `@`) → lower-cased
    /// 3. Random UUID prefix as a last-resort fallback
    private func deriveUsername() -> String {
        guard let user = Auth.auth().currentUser else {
            return "user_\(UUID().uuidString.prefix(8).lowercased())"
        }

        if let displayName = user.displayName, !displayName.isEmpty {
            return displayName
                .lowercased()
                .replacingOccurrences(of: " ", with: "_")
                .filter { $0.isLetter || $0.isNumber || $0 == "_" }
        }

        if let email = user.email, !email.isEmpty {
            let prefix = String(email.prefix(while: { $0 != "@" }))
            return prefix
                .lowercased()
                .replacingOccurrences(of: ".", with: "_")
                .filter { $0.isLetter || $0.isNumber || $0 == "_" }
        }

        return "user_\(UUID().uuidString.prefix(8).lowercased())"
    }
}
