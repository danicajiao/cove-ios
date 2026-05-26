//
//  BagViewModel.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/24/23.
//

import FirebaseAuth

class BagViewModel: ObservableObject {
    @Published var similarItems = [any Item]()
    var tempCategories = [String]()
    var fetchedItemIds = [String]()
    private let itemRepository: ItemRepository
    private let favoritesRepository: FavoritesRepository

    init(
        itemRepository: ItemRepository = FirebaseItemRepository(),
        favoritesRepository: FavoritesRepository = FirebaseFavoritesRepository()
    ) {
        self.itemRepository = itemRepository
        self.favoritesRepository = favoritesRepository
    }

    /// Fetches similar items and populates the similarItems array used in BagView
    func fetchSimilarItems(categories: [String]) async throws {
        if categories.isEmpty {
            await MainActor.run(body: { self.similarItems = [] })
            return
        }

        if tempCategories == categories { return }

        print("Fetching similar items...")
        fetchedItemIds = [String]()

        var items = try await itemRepository.fetchItems(inCategories: categories)
        fetchedItemIds = items.compactMap(\.id)

        if items.isEmpty {
            print("No items returned from request")
            return
        }

        guard let user = Auth.auth().currentUser else {
            print("Failed to get signed in user to fetch favorites")
            return
        }

        let favorites = try await favoritesRepository.listFavorites(uid: user.uid)
        let favoriteIds = Set(favorites.map(\.itemId))

        for index in items.indices {
            if let id = items[index].id, favoriteIds.contains(id) {
                items[index].isFavorite = true
            }
        }

        tempCategories = categories
        let sendableItems = items
        await MainActor.run(body: { self.similarItems = sendableItems })
    }
}
