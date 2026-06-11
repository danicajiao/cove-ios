//
//  InterestOnboardingViewModel.swift
//  Cove
//

import Foundation

struct CategorySection: Identifiable {
    let id: String
    let name: String
    let leaves: [LeafCategory]
}

struct LeafCategory: Identifiable {
    let id: String
    let name: String
}

@MainActor
class InterestOnboardingViewModel: ObservableObject {
    @Published var sections: [CategorySection] = []
    @Published var selectedIDs: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var serverError: String?

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    var canSubmit: Bool {
        !selectedIDs.isEmpty && !isSubmitting
    }

    func fetchCategories() async {
        isLoading = true
        do {
            let nodes = try await CoveAPIClient.shared.categories()
            sections = buildSections(from: nodes)
        } catch {
            print("❌ fetchCategories failed: \(error)")
        }
        isLoading = false
    }

    func toggle(id: String) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    func submit() async {
        guard canSubmit else { return }
        isSubmitting = true
        serverError = nil
        do {
            try await CoveAPIClient.shared.replaceInterests(categoryIds: Array(selectedIDs))
            complete()
        } catch {
            print("❌ replaceInterests failed: \(error)")
            serverError = "Something went wrong. Please try again."
            isSubmitting = false
        }
    }

    func skip() async {
        isSubmitting = true
        do {
            try await CoveAPIClient.shared.replaceInterests(categoryIds: [])
        } catch {
            print("❌ skip replaceInterests failed: \(error)")
        }
        appState.authState = .loggedIn
    }

    private func complete() {
        appState.authState = .loggedIn
    }

    private func buildSections(from nodes: [Components.Schemas.CategoryNode]) -> [CategorySection] {
        nodes.compactMap { root in
            var leaves: [LeafCategory] = []
            extractLeaves(from: root, into: &leaves)
            return leaves.isEmpty ? nil : CategorySection(id: root.id, name: root.name, leaves: leaves)
        }
    }

    private func extractLeaves(from node: Components.Schemas.CategoryNode, into leaves: inout [LeafCategory]) {
        let children = node.children ?? []
        if children.isEmpty {
            leaves.append(LeafCategory(id: node.id, name: node.name))
        } else {
            for child in children {
                extractLeaves(from: child, into: &leaves)
            }
        }
    }
}
