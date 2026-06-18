//
//  HomeViewModel.swift
//  Cove
//
//  Created by Daniel Cajiao on 12/6/22.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    var items = [any Item]()
    @Published var brands = [Brand]()
    @Published var categories = [Components.Schemas.RecommendedCategory]()
    @Published var isLoadingCategories = false

    /// Number of category cards requested for the home shelf. Kept small so the
    /// horizontal scroller stays light even for users with no interests (whose
    /// recommendations fall back to the full leaf-category set server-side).
    private let categoryLimit = 5

    private var lastFetchTime: Date?
    private let cacheTimeout: TimeInterval = 300
    private let itemRepository: ItemRepository
    private let api: CoveAPIClient

    init(itemRepository: ItemRepository = CoveAPIItemRepository(), api: CoveAPIClient = .shared) {
        self.itemRepository = itemRepository
        self.api = api
    }

    /// Fetches personalized category cards from `GET /recommendations/categories`.
    func fetchCategories() async {
        guard categories.isEmpty else { return }
        isLoadingCategories = true
        do {
            categories = try await api.recommendedCategories(limit: categoryLimit)
        } catch {
            print("❌ fetchCategories failed: \(error)")
        }
        isLoadingCategories = false
    }

    /// Records a `category_tap` attention event. Fire-and-forget — a failure here
    /// must never block navigation to the category results.
    func recordCategoryTap(_ category: Components.Schemas.RecommendedCategory) {
        Task {
            do {
                try await api.ingestEvent(eventType: .category_tap, categoryId: category.id)
            } catch {
                print("⚠️ category_tap event failed: \(error)")
            }
        }
    }

    func fetchItems(forceRefresh: Bool = false) async throws {
        let cacheExpired = lastFetchTime.map { Date().timeIntervalSince($0) > cacheTimeout } ?? true
        guard items.isEmpty || forceRefresh || cacheExpired else { return }

        print("Fetching items...")
        let fetched = try await itemRepository.fetchHome()

        if fetched.isEmpty {
            print("No items returned from request")
            return
        }

        items = fetched
        lastFetchTime = Date()
    }

    func fetchBrands() async throws {
        if !brands.isEmpty { return }

        print("Fetching brands...")
        let fetched = try await itemRepository.fetchBrands()

        if fetched.isEmpty {
            print("No brands returned from request")
            return
        }

        brands = fetched
    }
}
