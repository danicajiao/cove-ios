//
//  ApparelItemDetails.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/11/23.
//

import FirebaseFirestore

struct ApparelItemDetails: ItemDetails {
    @DocumentID var id: String?
    var about: String
    var categoryId: String
    @ServerTimestamp var createdAt: Timestamp?
    var itemId: String
    var description: String
    var specifications: [Specification]

    struct Specification: Codable, Hashable {
        var content: [String]
        var title: String
    }
}
