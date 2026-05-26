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
