//
//  FirebaseItemRepository.swift
//  Cove
//
//  Created by Daniel Cajiao on 5/18/26.
//

import FirebaseFirestore

/// Firestore-backed implementation of `ItemRepository`.
///
/// All Firestore reads that were previously scattered across `HomeViewModel`,
/// `ItemDetailViewModel`, and `BagViewModel` are consolidated here.
/// ViewModels should not import `FirebaseFirestore` directly after the
/// DI refactor lands in #226.
final class FirebaseItemRepository: ItemRepository {
    // MARK: - Properties

    private let firestore = Firestore.firestore()

    // MARK: - ItemRepository

    func fetchHome() async throws -> [any Item] {
        let snapshot = try await firestore.collection("products").getDocuments()
        return snapshot.documents.compactMap { decodeItem(from: $0) }
    }

    func fetchItem(id: String) async throws -> any Item {
        let snapshot = try await firestore.collection("products").document(id).getDocument()

        guard snapshot.exists else {
            throw RepositoryError.notFound
        }

        guard let item = decodeItem(from: snapshot) else {
            throw RepositoryError.decodingFailed("Unrecognized item category for id \(id)")
        }

        return item
    }

    func fetchDetails(for item: any Item) async throws -> any ItemDetails {
        let snapshot = try await firestore
            .collection("product_details")
            .document(item.itemDetailsId)
            .getDocument()

        guard snapshot.exists else {
            throw RepositoryError.notFound
        }

        if item is CoffeeItem {
            return try snapshot.data(as: CoffeeItemDetails.self)
        } else if item is MusicItem {
            return try snapshot.data(as: MusicItemDetails.self)
        } else if item is ApparelItem {
            return try snapshot.data(as: ApparelItemDetails.self)
        } else {
            throw RepositoryError.decodingFailed("Unrecognized item type — cannot decode details")
        }
    }

    func fetchSimilarItems(categoryId: String, limit: Int) async throws -> [any Item] {
        let snapshot = try await firestore
            .collection("products")
            .whereField("categoryId", isEqualTo: categoryId)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { decodeItem(from: $0) }
    }

    func fetchItems(inCategories categoryIds: [String]) async throws -> [any Item] {
        guard !categoryIds.isEmpty else { return [] }

        let snapshot = try await firestore
            .collection("products")
            .whereField("categoryId", in: categoryIds)
            .getDocuments()

        return snapshot.documents.compactMap { decodeItem(from: $0) }
    }

    func fetchItems(withIds ids: [String]) async throws -> [any Item] {
        guard !ids.isEmpty else { return [] }

        var items: [any Item] = []

        // Firestore's `in` operator supports up to 30 values — batch if needed.
        for batchStart in stride(from: 0, to: ids.count, by: 30) {
            let batch = Array(ids[batchStart ..< min(batchStart + 30, ids.count)])
            let snapshot = try await firestore
                .collection("products")
                .whereField(FieldPath.documentID(), in: batch)
                .getDocuments()
            items.append(contentsOf: snapshot.documents.compactMap { decodeItem(from: $0) })
        }

        return items
    }

    func fetchBrands() async throws -> [Brand] {
        let snapshot = try await firestore.collection("brands").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Brand.self) }
    }

    // MARK: - Private helpers

    /// Decodes a Firestore document into the correct `Item` concrete type
    /// based on its `categoryId` field. Returns `nil` for unrecognised categories.
    private func decodeItem(from snapshot: DocumentSnapshot) -> (any Item)? {
        let categoryId = snapshot["categoryId"] as? String
        do {
            switch categoryId {
            case ItemTypes.coffee.rawValue:
                return try snapshot.data(as: CoffeeItem.self)
            case ItemTypes.music.rawValue:
                return try snapshot.data(as: MusicItem.self)
            case ItemTypes.apparel.rawValue:
                return try snapshot.data(as: ApparelItem.self)
            default:
                return nil
            }
        } catch {
            print("FirebaseItemRepository: failed to decode item \(snapshot.documentID): \(error)")
            return nil
        }
    }
}
