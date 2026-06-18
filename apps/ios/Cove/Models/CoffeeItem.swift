//
//  CoffeeItem.swift
//
//  Created by Daniel Cajiao on 3/6/23.
//

import Foundation

struct CoffeeItem: Item {
    var id: String?
    var createdAt: Date?
    var categoryId: String
    var defaultPrice: Float
    var defaultImageURL: String
    var info: CoffeeInfo
    var isFavorite: Bool?
    var itemDetailsId: String

    struct CoffeeInfo: Codable {
        var name: String
        var roastery: String
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CoffeeItem, rhs: CoffeeItem) -> Bool {
        lhs.id == rhs.id
    }
}
