//
//  Item.swift
//
//  Created by Daniel Cajiao on 3/8/22.
//

import Foundation

protocol Item: Codable, Identifiable, Hashable {
    var id: String? { get }
    var createdAt: Date? { get }
    var categoryId: String { get }
    var defaultPrice: Float { get }
    var defaultImageURL: String { get }
    var isFavorite: Bool? { get set }
    var itemDetailsId: String { get }
}

struct ExampleItem: Item {
    var id: String?
    var createdAt: Date?
    var categoryId: String
    var defaultPrice: Float
    var defaultImageURL: String
    var info: ExampleInfo
    var isFavorite: Bool?
    var itemDetailsId: String

    struct ExampleInfo: Codable {
        var name: String
        var desc: String
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ExampleItem, rhs: ExampleItem) -> Bool {
        lhs.id == rhs.id
    }

    static let placeholder = ExampleItem(
        id: "aaaaa123445",
        createdAt: nil,
        categoryId: "some categoryID",
        defaultPrice: 23,
        defaultImageURL: "some url",
        info: ExampleInfo(name: "Some name", desc: "Some description"),
        isFavorite: true,
        itemDetailsId: "12345"
    )
}
