//
//  ApparelItem.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/27/23.
//

import FirebaseFirestore

struct ApparelItem: Item {
    @DocumentID var id: String?
    @ServerTimestamp var createdAt: Timestamp?
    var categoryId: String
    var defaultPrice: Float
    var defaultImageURL: String
    var info: ApparelInfo
    var isFavorite: Bool?
    var itemDetailsId: String

    /// Maps the renamed Swift property back to the existing Firestore field name.
    /// Remove in Phase 3 when Firestore is decommissioned (#324).
    private enum CodingKeys: String, CodingKey {
        case createdAt, categoryId, defaultPrice, defaultImageURL, info, isFavorite
        case itemDetailsId = "productDetailsId"
    }

    struct ApparelInfo: Codable {
        var brand: String
        var name: String
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ApparelItem, rhs: ApparelItem) -> Bool {
        lhs.id == rhs.id
    }
}
