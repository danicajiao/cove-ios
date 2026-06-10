//
//  ProfileViewModel.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/15/26.
//

import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?

    private let userRepository: UserRepository

    private var currentUser: User? {
        Auth.auth().currentUser
    }

    init(userRepository: UserRepository = CoveAPIUserRepository()) {
        self.userRepository = userRepository
    }

    func fetchProfile() async {
        guard let uid = currentUser?.uid else { return }
        do {
            profile = try await userRepository.fetchProfile(uid: uid)
        } catch {
            // Profile unavailable — view falls back to Firebase-derived display name.
        }
    }

    var displayName: String {
        if let name = currentUser?.displayName, !name.isEmpty {
            return name
        }
        return emailPrefix
    }

    var username: String {
        if let dbUsername = profile?.displayName, !dbUsername.isEmpty {
            return "@\(dbUsername)"
        }
        let slug = displayName.lowercased().replacingOccurrences(of: " ", with: "_")
        return "@\(slug)"
    }

    var initials: String {
        let words = displayName.split(separator: " ")
        let letters = words.prefix(2).compactMap(\.first)
        return String(letters).uppercased()
    }

    var photoURL: URL? {
        currentUser?.photoURL
    }

    var memberSinceText: String {
        guard let date = currentUser?.metadata.creationDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return "Member since \(formatter.string(from: date))"
    }

    private var emailPrefix: String {
        guard let email = currentUser?.email else { return "" }
        return String(email.prefix(while: { $0 != "@" }))
    }
}
