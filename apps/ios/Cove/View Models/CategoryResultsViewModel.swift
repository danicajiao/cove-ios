//
//  CategoryResultsViewModel.swift
//  Cove
//
//  Created by Daniel Cajiao on 6/12/26.
//

import Foundation

/// Drives `CategoryResultsView`: fetches `GET /discovery` scoped to a category
/// ltree path and exposes the resulting items plus load/empty/error state.
///
/// Location is optional — the app has no CoreLocation flow yet, so `lat`/`lon`/
/// `radius` are forwarded as `nil` and the gateway ranks by trust + relevance.
/// When a location provider is added, pass it through `fetch(...)`.
@MainActor
class CategoryResultsViewModel: ObservableObject {
    @Published var items: [any Item] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let categoryPath: String
    private let api: CoveAPIClient
    private var hasLoaded = false

    init(categoryPath: String, api: CoveAPIClient = .shared) {
        self.categoryPath = categoryPath
        self.api = api
    }

    /// True once a load has completed with no items and no error.
    var isEmpty: Bool {
        !isLoading && items.isEmpty && errorMessage == nil
    }

    func fetch(forceRefresh: Bool = false) async {
        guard !hasLoaded || forceRefresh else { return }
        isLoading = true
        errorMessage = nil
        do {
            let results = try await api.discovery(category: categoryPath)
            items = results.map { DiscoveryItem(discovery: $0) }
            hasLoaded = true
        } catch {
            print("❌ category discovery failed: \(error)")
            errorMessage = "Couldn't load results. Please try again."
        }
        isLoading = false
    }
}
