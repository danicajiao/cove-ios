//
//  FavoriteItem.swift
//  Cove
//
//  Created by Daniel Cajiao on 3/21/23.
//

import FirebaseFirestore

struct FavoriteItem: Codable, Identifiable {
    @DocumentID var id: String?
    var itemId: String
    var categoryId: String?
}
