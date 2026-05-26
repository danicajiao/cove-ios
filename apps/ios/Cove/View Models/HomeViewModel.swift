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

    let categories = ["Music", "Coffee", "Home", "Bevs", "Apparel"]
    let origins = ["Colombia", "Guatemala", "Ethiopia", "Costa Rica", "Kenya"]

    private var lastFetchTime: Date?
    private let cacheTimeout: TimeInterval = 300
    private let itemRepository: ItemRepository

    init(itemRepository: ItemRepository = FirebaseItemRepository()) {
        self.itemRepository = itemRepository
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
