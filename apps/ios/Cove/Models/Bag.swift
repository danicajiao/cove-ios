//
//  Bag.swift
//  Cove
//
//  Created by Daniel Cajiao on 4/18/23.
//

import Foundation

class Bag: ObservableObject {
    @Published var bagItems = [BagItem]()
    @Published var total: Int = 0
    var categories = [String]()
    var totalItems: Int = 0
}

struct BagItem: Equatable {
    static func == (lhs: BagItem, rhs: BagItem) -> Bool {
        lhs.item.id == rhs.item.id && lhs.quantity == rhs.quantity
    }

    var item: any Item
    var quantity: Int = 0
}
