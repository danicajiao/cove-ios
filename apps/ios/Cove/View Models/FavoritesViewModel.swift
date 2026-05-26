//
//  FavoritesViewModel.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/18/26.
//

import FirebaseAuth

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favorites: [any Item] = []
    @Published var isLoading: Bool = false
    @Published var favoriteCount: Int = 0

    private let favoritesRepository: FavoritesRepository
    private let itemRepository: ItemRepository

    init(
        favoritesRepository: FavoritesRepository = FirebaseFavoritesRepository(),
        itemRepository: ItemRepository = FirebaseItemRepository()
    ) {
        self.favoritesRepository = favoritesRepository
        self.itemRepository = itemRepository
    }

    func fetchFavorites() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user signed in")
            return
        }

        isLoading = true
        defer { isLoading = false }

        let favoriteRefs = try await favoritesRepository.listFavorites(uid: uid)
        let itemIds = favoriteRefs.map(\.itemId)

        guard !itemIds.isEmpty else {
            favorites = []
            favoriteCount = 0
            return
        }

        let fetchedItems = try await itemRepository.fetchItems(withIds: itemIds)
        favorites = fetchedItems
        favoriteCount = fetchedItems.count
    }
}
