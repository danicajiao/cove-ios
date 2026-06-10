//
//  UsernameOnboardingViewModel.swift
//  Cove
//

import Foundation

@MainActor
class UsernameOnboardingViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var isLoading: Bool = false
    @Published var serverError: String?

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    var validationError: String? {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        if trimmed.count < 3 { return "At least 3 characters required" }
        if trimmed.count > 30 { return "30 characters maximum" }
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        if trimmed.unicodeScalars.contains(where: { !allowed.contains($0) }) {
            return "Letters, numbers, and underscores only"
        }
        return nil
    }

    var canSubmit: Bool {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        return trimmed.count >= 3 && trimmed.count <= 30 && validationError == nil && !isLoading
    }

    func submit() async {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        guard canSubmit else { return }

        isLoading = true
        serverError = nil

        do {
            _ = try await CoveAPIClient.shared.createMe(username: trimmed)
            appState.authState = .loggedIn
        } catch CoveAPIError.unexpectedStatus(409) {
            serverError = "That username is already taken. Try another."
            isLoading = false
        } catch let CoveAPIError.unexpectedStatus(code) {
            print("❌ createMe failed with HTTP \(code)")
            serverError = "Something went wrong. Please try again."
            isLoading = false
        } catch {
            print("❌ createMe failed: \(error)")
            serverError = "Something went wrong. Please try again."
            isLoading = false
        }
    }
}
