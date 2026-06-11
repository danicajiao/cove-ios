//
//  InterestOnboardingViewModel.swift
//  Cove
//

import SwiftUI

struct CategorySection: Identifiable {
    let id: String
    let name: String
    let leaves: [LeafCategory]
    let selectedFill: Color
    let selectedText: Color
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

    // Cycles through brand colors so each section gets a distinct selected-chip color.
    // Pairs: (fill, text) — text chosen for legibility on that fill.
    private static let sectionPalette: [(fill: Color, text: Color)] = [
        (Color.Colors.Brand.coral, Color.Colors.Text.inverse),
        (Color.Colors.Brand.amber, Color.Colors.Text.primary),
        (Color.Colors.Brand.sage, Color.Colors.Text.inverse),
        (Color.Colors.Brand.blue, Color.Colors.Text.inverse),
        (Color.Colors.Brand.violet, Color.Colors.Text.primary),
        (Color.Colors.Brand.accent, Color.Colors.Text.primary)
    ]

    private func buildSections(from nodes: [Components.Schemas.CategoryNode]) -> [CategorySection] {
        var index = 0
        return nodes.compactMap { root in
            let chips = (root.children ?? [])
                .filter { !($0.children ?? []).isEmpty }
                .map { LeafCategory(id: $0.id, name: $0.name) }
            guard !chips.isEmpty else { return nil }
            let palette = Self.sectionPalette[index % Self.sectionPalette.count]
            index += 1
            return CategorySection(
                id: root.id, name: root.name, leaves: chips,
                selectedFill: palette.fill, selectedText: palette.text
            )
        }
    }
}
