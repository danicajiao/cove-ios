//
//  FavoriteItem.swift
//
//  Created by Daniel Cajiao on 3/21/23.
//

import Foundation

struct FavoriteItem: Codable, Identifiable {
    var id: String?
    var itemId: String
    var categoryId: String?
}
