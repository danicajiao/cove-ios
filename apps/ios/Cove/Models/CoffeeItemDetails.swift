//
//  CoffeeItemDetails.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/11/23.
//

import FirebaseFirestore

struct CoffeeItemDetails: ItemDetails {
    @DocumentID var id: String?
    var about: String
    var categoryId: String
    @ServerTimestamp var createdAt: Timestamp?
    var itemId: String
    var description: String
    var origin: [OriginInfo]

    // Remove in Phase 3 when Firestore is decommissioned (#324).
    private enum CodingKeys: String, CodingKey {
        case id // @DocumentID
        case about, categoryId, createdAt, description, origin
        case itemId = "productId"
    }

    struct OriginInfo: Codable, Hashable {
        var content: String
        var title: String
    }
}
