//
//  CoffeeItemDetails.swift
//
//  Created by Daniel Cajiao on 4/11/23.
//

import Foundation

struct CoffeeItemDetails: ItemDetails {
    var id: String?
    var about: String
    var categoryId: String
    var createdAt: Date?
    var itemId: String
    var description: String
    var origin: [OriginInfo]

    struct OriginInfo: Codable, Hashable {
        var content: String
        var title: String
    }
}
