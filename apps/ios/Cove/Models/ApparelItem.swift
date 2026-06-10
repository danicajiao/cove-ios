//
//  ApparelItem.swift
//
//  Created by Daniel Cajiao on 3/27/23.
//

import Foundation

struct ApparelItem: Item {
    var id: String?
    var createdAt: Date?
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
