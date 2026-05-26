//
//  ItemDetailViewModel.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/9/23.
//

import Foundation

class ItemDetailViewModel: ObservableObject {
    @Published var item: (any Item)?
    @Published var itemDetails: (any ItemDetails)?
    @Published var detailSelection: DetailSelection
    @Published var similarItems: [any Item]

    private let itemRepository: ItemRepository

    enum DetailSelection {
        case description
        case about

        case specifications
        case origin
        case tracklist
    }

    init(
        itemId: String,
        itemRepository: ItemRepository = FirebaseItemRepository()
    ) {
        self.itemRepository = itemRepository
        item = nil
        detailSelection = .description
        similarItems = [any Item]()

        Task {
            await fetchItem(itemId)
            if self.item != nil {
                do {
                    try await fetchItemDetails()
                    try await fetchSimilarItems()
                } catch {
                    print("Error fetching product details or similar products: \(error)")
                }
            }
        }
    }

    func fetchItem(_ id: String) async {
        print("Fetching product with id: \(id)")
        do {
            let fetched = try await itemRepository.fetchProduct(id: id)
            await MainActor.run { self.item = fetched }
        } catch {
            print("Error fetching product: \(error)")
        }
    }

    func fetchItemDetails() async throws {
        guard let item else { return }

        print("Fetching product details...")
        let details = try await itemRepository.fetchDetails(for: item)
        await MainActor.run { self.itemDetails = details }
    }

    func fetchSimilarItems() async throws {
        if !similarItems.isEmpty { return }
        guard let item else { return }

        print("Fetching similar products...")
        let fetched = try await itemRepository.fetchSimilarProducts(categoryId: item.categoryId, limit: 5)

        if fetched.isEmpty {
            print("No products returned from request")
            return
        }

        await MainActor.run { self.similarItems = fetched }
    }
}
