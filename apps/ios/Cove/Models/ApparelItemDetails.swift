//
//  ApparelItemDetails.swift
//
//  Created by Daniel Cajiao on 4/11/23.
//

import Foundation

struct ApparelItemDetails: ItemDetails {
    var id: String?
    var about: String
    var categoryId: String
    var createdAt: Date?
    var itemId: String
    var description: String
    var specifications: [Specification]

    struct Specification: Codable, Hashable {
        var content: [String]
        var title: String
    }
}
